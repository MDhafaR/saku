import 'dart:convert';
import 'dart:typed_data';

/// Pure Dart decoder for legacy Microsoft Excel 97-2004 (.xls / BIFF8) files.
/// Parses the Compound File Binary Format (CFBF/OLE2) container and extracts
/// sheet cells into `List<List<String>>`.
class XlsDecoder {
  /// Decodes raw bytes of an .xls file into a 2D matrix of row cells.
  static List<List<String>> decodeBytes(Uint8List bytes) {
    if (bytes.length < 512) {
      throw const FormatException('File terlalu kecil untuk format .xls valid');
    }

    final byteData = ByteData.sublistView(bytes);

    // 1. Verify CFBF Signature: 0xD0CF11E0A1B11AE1
    final magic1 = byteData.getUint32(0, Endian.little);
    final magic2 = byteData.getUint32(4, Endian.little);
    if (magic1 != 0xE011CFD0 || magic2 != 0xE11AB1A1) {
      throw const FormatException('Header file bukan format .xls (CFBF/OLE2) yang valid');
    }

    // 2. Read Sector Size & FAT metadata
    final sectorShift = byteData.getUint16(30, Endian.little);
    final sectorSize = 1 << sectorShift; // Typically 512 bytes

    final dirFirstSec = byteData.getUint32(48, Endian.little);
    final numDifatSec = byteData.getUint32(72, Endian.little);

    // Read initial 109 DIFAT entries from header
    final difat = <int>[];
    for (int i = 0; i < 109; i++) {
      final sec = byteData.getUint32(76 + i * 4, Endian.little);
      if (sec < 0xFFFFFFFC) {
        difat.add(sec);
      }
    }

    // Read additional DIFAT sectors if any
    int difatFirstSec = byteData.getUint32(68, Endian.little);
    int currentDifatSec = difatFirstSec;
    for (int d = 0; d < numDifatSec && currentDifatSec < 0xFFFFFFFC; d++) {
      final offset = 512 + currentDifatSec * sectorSize;
      if (offset + sectorSize > bytes.length) break;
      final count = (sectorSize ~/ 4) - 1;
      for (int i = 0; i < count; i++) {
        final sec = byteData.getUint32(offset + i * 4, Endian.little);
        if (sec < 0xFFFFFFFC) difat.add(sec);
      }
      currentDifatSec = byteData.getUint32(offset + count * 4, Endian.little);
    }

    // Build FAT table from DIFAT sectors
    final fat = <int>[];
    final intsPerSec = sectorSize ~/ 4;
    for (final sec in difat) {
      final offset = 512 + sec * sectorSize;
      if (offset + sectorSize > bytes.length) break;
      for (int i = 0; i < intsPerSec; i++) {
        fat.add(byteData.getUint32(offset + i * 4, Endian.little));
      }
    }

    // Helper to read a stream from FAT chain
    Uint8List getStream(int startSec, int size) {
      final builder = BytesBuilder(copy: false);
      int curr = startSec;
      int bytesRemaining = size;

      while (curr < fat.length && curr < 0xFFFFFFFC && bytesRemaining > 0) {
        final offset = 512 + curr * sectorSize;
        if (offset >= bytes.length) break;
        final chunkLen = (offset + sectorSize <= bytes.length)
            ? (bytesRemaining < sectorSize ? bytesRemaining : sectorSize)
            : (bytes.length - offset);
        builder.add(Uint8List.sublistView(bytes, offset, offset + chunkLen));
        bytesRemaining -= chunkLen;
        curr = fat[curr];
      }
      return builder.toBytes();
    }

    // 3. Read Directory Entries (128 bytes each)
    final dirData = getStream(dirFirstSec, 5000000);
    final dirByteData = ByteData.sublistView(dirData);

    Uint8List? workbookStream;
    for (int i = 0; i + 128 <= dirData.length; i += 128) {
      final nameLen = dirByteData.getUint16(i + 64, Endian.little);
      if (nameLen < 2) continue;

      final nameBytes = Uint8List.sublistView(dirData, i, i + nameLen - 2);
      final name = _utf16LeDecode(nameBytes);

      final startSec = dirByteData.getUint32(i + 116, Endian.little);
      final streamSize = dirByteData.getUint32(i + 120, Endian.little);

      if (name.toLowerCase() == 'workbook' || name.toLowerCase() == 'book') {
        workbookStream = getStream(startSec, streamSize);
        break;
      }
    }

    if (workbookStream == null || workbookStream.isEmpty) {
      throw const FormatException('Workbook stream tidak ditemukan di dalam file .xls');
    }

    // 4. Parse BIFF Records
    return _parseBiffStream(workbookStream);
  }

  static String _utf16LeDecode(Uint8List bytes) {
    return utf8.decode(
      utf8.encode(String.fromCharCodes(Uint16List.view(
        bytes.buffer,
        bytes.offsetInBytes,
        bytes.lengthInBytes ~/ 2,
      ))),
      allowMalformed: true,
    );
  }

  static List<List<String>> _parseBiffStream(Uint8List stream) {
    final byteData = ByteData.sublistView(stream);
    final records = <_BiffRecord>[];
    int pos = 0;

    while (pos + 4 <= stream.length) {
      final type = byteData.getUint16(pos, Endian.little);
      final len = byteData.getUint16(pos + 2, Endian.little);
      pos += 4;
      if (pos + len > stream.length) break;
      records.add(_BiffRecord(type, Uint8List.sublistView(stream, pos, pos + len)));
      pos += len;
    }

    // Collect SST and consecutive CONTINUE records
    final sstRecords = <Uint8List>[];
    for (int i = 0; i < records.length; i++) {
      if (records[i].type == 0x00FC) {
        sstRecords.add(records[i].data);
        int j = i + 1;
        while (j < records.length && records[j].type == 0x003C) {
          sstRecords.add(records[j].data);
          j++;
        }
        break;
      }
    }

    final sstStrings = _BiffSstParser(sstRecords).parseAll();

    // 5. Extract Cell Records
    final rowsMap = <int, Map<int, String>>{};

    for (final rec in records) {
      final data = rec.data;
      final dataView = ByteData.sublistView(data);

      if (rec.type == 0x00FD && data.length >= 10) {
        // LABELSST
        final row = dataView.getUint16(0, Endian.little);
        final col = dataView.getUint16(2, Endian.little);
        final sstIdx = dataView.getUint32(6, Endian.little);
        final str = (sstIdx < sstStrings.length) ? sstStrings[sstIdx] : '';
        rowsMap.putIfAbsent(row, () => {})[col] = str;
      } else if (rec.type == 0x0204 && data.length >= 8) {
        // LABEL (Inline string)
        final row = dataView.getUint16(0, Endian.little);
        final col = dataView.getUint16(2, Endian.little);
        final cch = dataView.getUint16(6, Endian.little);
        final flags = (data.length > 8) ? data[8] : 0;
        final isUnicode = (flags & 1) != 0;
        final byteLen = cch * (isUnicode ? 2 : 1);
        if (data.length >= 9 + byteLen) {
          final raw = Uint8List.sublistView(data, 9, 9 + byteLen);
          final str = isUnicode ? _utf16LeDecode(raw) : latin1.decode(raw);
          rowsMap.putIfAbsent(row, () => {})[col] = str;
        }
      } else if (rec.type == 0x0203 && data.length >= 14) {
        // NUMBER
        final row = dataView.getUint16(0, Endian.little);
        final col = dataView.getUint16(2, Endian.little);
        final num = dataView.getFloat64(6, Endian.little);
        final str = (num == num.toInt()) ? num.toInt().toString() : num.toString();
        rowsMap.putIfAbsent(row, () => {})[col] = str;
      } else if (rec.type == 0x027E && data.length >= 10) {
        // RK
        final row = dataView.getUint16(0, Endian.little);
        final col = dataView.getUint16(2, Endian.little);
        final rk = dataView.getUint32(6, Endian.little);
        final num = _decodeRk(rk);
        final str = (num == num.toInt()) ? num.toInt().toString() : num.toString();
        rowsMap.putIfAbsent(row, () => {})[col] = str;
      } else if (rec.type == 0x00BD && data.length >= 6) {
        // MULRK
        final row = dataView.getUint16(0, Endian.little);
        final colFirst = dataView.getUint16(2, Endian.little);
        final numRks = (data.length - 6) ~/ 6;
        for (int ci = 0; ci < numRks; ci++) {
          final rk = dataView.getUint32(4 + ci * 6 + 2, Endian.little);
          final col = colFirst + ci;
          final num = _decodeRk(rk);
          final str = (num == num.toInt()) ? num.toInt().toString() : num.toString();
          rowsMap.putIfAbsent(row, () => {})[col] = str;
        }
      }
    }

    if (rowsMap.isEmpty) {
      return [];
    }

    final maxRow = rowsMap.keys.reduce((a, b) => a > b ? a : b);
    final result = <List<String>>[];

    for (int r = 0; r <= maxRow; r++) {
      if (!rowsMap.containsKey(r)) {
        result.add([]);
        continue;
      }
      final colsMap = rowsMap[r]!;
      final maxCol = colsMap.keys.isEmpty ? -1 : colsMap.keys.reduce((a, b) => a > b ? a : b);
      final rowCells = <String>[];
      for (int c = 0; c <= maxCol; c++) {
        rowCells.add(colsMap[c] ?? '');
      }
      result.add(rowCells);
    }

    return result;
  }

  static double _decodeRk(int rk) {
    final isMult100 = (rk & 1) != 0;
    final isInt = (rk & 2) != 0;
    final val = (rk >> 2);

    double res;
    if (isInt) {
      res = val.toDouble();
    } else {
      final bytes = Uint8List(8);
      final bdata = ByteData.sublistView(bytes);
      bdata.setUint32(0, (rk & 0xFFFFFFFC), Endian.big);
      res = bdata.getFloat64(0, Endian.big);
    }

    if (isMult100) {
      res /= 100.0;
    }
    return res;
  }
}

class _BiffRecord {
  final int type;
  final Uint8List data;
  const _BiffRecord(this.type, this.data);
}

/// Robust SST (Shared String Table) parser supporting CONTINUE record splitting
/// and dynamic UTF-16 / Latin-1 compression flag resets on continuation boundaries.
class _BiffSstParser {
  final List<Uint8List> records;
  int recIdx = 0;
  int offset = 0;

  _BiffSstParser(this.records);

  bool get hasMore => recIdx < records.length;

  Uint8List readRaw(int n) {
    final builder = BytesBuilder(copy: false);
    int remaining = n;
    while (remaining > 0 && recIdx < records.length) {
      final cur = records[recIdx];
      final avail = cur.length - offset;
      if (avail <= 0) {
        recIdx++;
        offset = 0;
        continue;
      }
      final take = remaining < avail ? remaining : avail;
      builder.add(Uint8List.sublistView(cur, offset, offset + take));
      offset += take;
      remaining -= take;
      if (offset >= cur.length) {
        recIdx++;
        offset = 0;
      }
    }
    return builder.toBytes();
  }

  List<String> parseAll() {
    if (!hasMore) return [];

    final header = readRaw(8);
    if (header.length < 8) return [];
    final headerView = ByteData.sublistView(header);
    final uniqueStrings = headerView.getUint32(4, Endian.little);

    final strings = <String>[];

    for (int s = 0; s < uniqueStrings; s++) {
      if (!hasMore) break;

      final rawCch = readRaw(2);
      if (rawCch.length < 2) break;
      final cch = ByteData.sublistView(rawCch).getUint16(0, Endian.little);

      final rawFlags = readRaw(1);
      if (rawFlags.isEmpty) break;
      final flags = rawFlags[0];

      final isUnicode = (flags & 0x01) != 0;
      final isRich = (flags & 0x08) != 0;
      final isExt = (flags & 0x04) != 0;

      int rtCount = 0;
      int extLen = 0;

      if (isRich) {
        final rawRt = readRaw(2);
        if (rawRt.length >= 2) {
          rtCount = ByteData.sublistView(rawRt).getUint16(0, Endian.little);
        }
      }
      if (isExt) {
        final rawExt = readRaw(4);
        if (rawExt.length >= 4) {
          extLen = ByteData.sublistView(rawExt).getUint32(0, Endian.little);
        }
      }

      int charsLeft = cch;
      final charBuffer = StringBuffer();
      bool curUnicode = isUnicode;

      while (charsLeft > 0 && hasMore) {
        var curRec = records[recIdx];
        var avail = curRec.length - offset;

        if (avail <= 0) {
          recIdx++;
          offset = 0;
          if (!hasMore) break;
          // Boundary reached while reading string chars: read 1-byte continuation flag
          curRec = records[recIdx];
          final compFlag = curRec[offset];
          offset++;
          curUnicode = (compFlag & 0x01) != 0;
          avail = curRec.length - offset;
        }

        final bytesPerChar = curUnicode ? 2 : 1;
        final charsAvail = avail ~/ bytesPerChar;
        final takeChars = charsLeft < charsAvail ? charsLeft : charsAvail;

        if (takeChars > 0) {
          final takeBytes = takeChars * bytesPerChar;
          final rawChunk = Uint8List.sublistView(curRec, offset, offset + takeBytes);
          offset += takeBytes;
          charsLeft -= takeChars;

          if (curUnicode) {
            for (int i = 0; i + 1 < rawChunk.length; i += 2) {
              final codeUnit = rawChunk[i] | (rawChunk[i + 1] << 8);
              charBuffer.writeCharCode(codeUnit);
            }
          } else {
            charBuffer.write(latin1.decode(rawChunk));
          }
        }

        if (offset >= curRec.length) {
          recIdx++;
          offset = 0;
          if (charsLeft > 0 && hasMore) {
            curRec = records[recIdx];
            final compFlag = curRec[offset];
            offset++;
            curUnicode = (compFlag & 0x01) != 0;
          }
        }
      }

      // Skip formatting runs & extended data
      if (rtCount > 0) {
        readRaw(rtCount * 4);
      }
      if (extLen > 0) {
        readRaw(extLen);
      }

      strings.add(charBuffer.toString());
    }

    return strings;
  }
}
