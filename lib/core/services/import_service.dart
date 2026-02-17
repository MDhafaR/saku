import 'dart:io';

import 'package:drift/drift.dart';
import 'package:excel/excel.dart' as xl;
import 'package:intl/intl.dart';

import '../../data/local/database/app_database.dart';

// ─── Column type enum ────────────────────────────────────────────────────────

enum ImportColumnType {
  tanggal('Tanggal'),
  nominal('Nominal'),
  deskripsi('Deskripsi'),
  kategori('Kategori'),
  tipe('Tipe'),
  wallet('Wallet / Rekening'),
  abaikan('Abaikan');

  final String label;
  const ImportColumnType(this.label);
}

// ─── Parsed file result ──────────────────────────────────────────────────────

class ParsedFile {
  final String fileName;
  final int fileSize;
  final List<String> headers;
  final List<List<String>> rows; // excludes header row
  final List<ImportColumnType> autoMapping;

  const ParsedFile({
    required this.fileName,
    required this.fileSize,
    required this.headers,
    required this.rows,
    required this.autoMapping,
  });
}

// ─── Import summary ─────────────────────────────────────────────────────────

class ImportSummary {
  final int totalRows;
  final int imported;
  final int skippedDuplicates;
  final int incomeCount;
  final int expenseCount;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const ImportSummary({
    required this.totalRows,
    required this.imported,
    required this.skippedDuplicates,
    required this.incomeCount,
    required this.expenseCount,
    this.dateFrom,
    this.dateTo,
  });
}

// ─── Category match result ──────────────────────────────────────────────────

class CategoryMatch {
  final String sourceName;
  int? matchedCategoryId;
  String? matchedCategoryName;
  bool isAutoMatched;

  CategoryMatch({
    required this.sourceName,
    this.matchedCategoryId,
    this.matchedCategoryName,
    this.isAutoMatched = false,
  });
}

// ─── Wallet match result ────────────────────────────────────────────────────

class WalletMatch {
  final String sourceName;
  int? matchedWalletId;
  String? matchedWalletName;
  bool isAutoMatched;

  WalletMatch({
    required this.sourceName,
    this.matchedWalletId,
    this.matchedWalletName,
    this.isAutoMatched = false,
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// Import Service
// ═════════════════════════════════════════════════════════════════════════════

class ImportService {
  final AppDatabase _db;

  ImportService(this._db);

  // ─── Default wallet ───────────────────────────────────────────────────

  Future<int> getDefaultWalletId() async {
    final wallets = await _db.walletDao.getAllWallets();

    if (wallets.isEmpty) {
      // Auto-create a default wallet instead of blocking import
      final newId = await _db.walletDao.createWallet(
        const WalletsCompanion(
          name: Value('Dompet'),
          type: Value('cash'),
          isMain: Value(true),
        ),
      );
      return newId;
    }

    // Prefer the main wallet, fallback to first
    final mainWallet = wallets.where((w) => w.isMain).firstOrNull;
    return mainWallet?.id ?? wallets.first.id;
  }

  // ─── Import history ───────────────────────────────────────────────────

  Future<void> saveImportHistory({
    required String fileName,
    String? filePath,
    required ImportSummary summary,
    required bool isSuccess,
    String? errorMessage,
  }) async {
    await _db
        .into(_db.importHistories)
        .insert(
          ImportHistoriesCompanion(
            fileName: Value(fileName),
            filePath: Value(filePath),
            totalRows: Value(summary.totalRows),
            importedCount: Value(summary.imported),
            skippedDuplicates: Value(summary.skippedDuplicates),
            incomeCount: Value(summary.incomeCount),
            expenseCount: Value(summary.expenseCount),
            isSuccess: Value(isSuccess),
            errorMessage: Value(errorMessage),
          ),
        );
  }

  Future<List<ImportHistory>> getImportHistory({int limit = 10}) async {
    return (_db.select(_db.importHistories)
          ..orderBy([(t) => OrderingTerm.desc(t.importedAt)])
          ..limit(limit))
        .get();
  }

  // ─── 1. Parse file ───────────────────────────────────────────────────────

  Future<ParsedFile> parseFile(String filePath) async {
    final file = File(filePath);
    final fileName = filePath.split(Platform.pathSeparator).last;
    final fileSize = await file.length();
    final ext = fileName.split('.').last.toLowerCase();

    List<List<String>> allRows;

    if (ext == 'csv') {
      allRows = await _parseCsv(file);
    } else if (ext == 'xlsx') {
      allRows = _parseExcel(file);
    } else if (ext == 'xls') {
      throw ArgumentError(
        'Format .xls (Excel lama) tidak didukung.\n'
        'Silakan buka file di Excel/Google Sheets lalu simpan ulang sebagai .xlsx atau .csv.',
      );
    } else {
      throw ArgumentError('Format file tidak didukung: .$ext');
    }

    if (allRows.isEmpty) {
      throw StateError('File kosong');
    }

    // Assume first row is headers
    final headers = allRows.first;
    final dataRows = allRows.skip(1).toList();

    // Auto-detect column mappings
    final autoMapping = _autoDetectColumns(headers);

    return ParsedFile(
      fileName: fileName,
      fileSize: fileSize,
      headers: headers,
      rows: dataRows,
      autoMapping: autoMapping,
    );
  }

  Future<List<List<String>>> _parseCsv(File file) async {
    final content = await file.readAsString();
    final lines = content
        .split(RegExp(r'\r?\n'))
        .where((l) => l.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) return [];

    // Auto-detect delimiter: comma or semicolon
    final firstLine = lines.first;
    final commaCount = ','.allMatches(firstLine).length;
    final semicolonCount = ';'.allMatches(firstLine).length;
    final delimiter = semicolonCount > commaCount ? ';' : ',';

    return lines.map((line) {
      final cells = <String>[];
      final buffer = StringBuffer();
      bool inQuotes = false;

      for (int i = 0; i < line.length; i++) {
        final char = line[i];
        if (char == '"') {
          if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
            buffer.write('"');
            i++; // skip escaped quote
          } else {
            inQuotes = !inQuotes;
          }
        } else if (char == delimiter && !inQuotes) {
          cells.add(buffer.toString().trim());
          buffer.clear();
        } else {
          buffer.write(char);
        }
      }
      cells.add(buffer.toString().trim());
      return cells;
    }).toList();
  }

  List<List<String>> _parseExcel(File file) {
    final bytes = file.readAsBytesSync();
    final excel = xl.Excel.decodeBytes(bytes);

    // Use first sheet
    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName]!;

    return sheet.rows.map((row) {
      return row.map((cell) => cell?.value?.toString() ?? '').toList();
    }).toList();
  }

  // ─── 2. Auto-detect columns ─────────────────────────────────────────────

  List<ImportColumnType> _autoDetectColumns(List<String> headers) {
    return headers.map((h) {
      final lower = h.toLowerCase().trim();

      // Tanggal
      if (_matchesAny(lower, [
        'tanggal',
        'date',
        'tgl',
        'transaction date',
        'posting date',
        'value date',
      ])) {
        return ImportColumnType.tanggal;
      }

      // Nominal / Amount
      if (_matchesAny(lower, [
        'nominal',
        'amount',
        'jumlah',
        'nilai',
        'debit',
        'credit',
        'kredit',
        'total',
        'saldo',
        'balance',
      ])) {
        return ImportColumnType.nominal;
      }

      // Deskripsi
      if (_matchesAny(lower, [
        'deskripsi',
        'description',
        'keterangan',
        'uraian',
        'memo',
        'note',
        'catatan',
        'remark',
        'narasi',
      ])) {
        return ImportColumnType.deskripsi;
      }

      // Kategori
      if (_matchesAny(lower, [
        'kategori',
        'category',
        'jenis',
        'tipe transaksi',
      ])) {
        return ImportColumnType.kategori;
      }

      // Wallet / Rekening
      if (_matchesAny(lower, [
        'wallet',
        'rekening',
        'account',
        'bank',
        'sumber',
        'dompet',
        'e-wallet',
        'ewallet',
      ])) {
        return ImportColumnType.wallet;
      }

      // Tipe
      if (_matchesAny(lower, ['tipe', 'type', 'db/cr', 'debet/kredit'])) {
        return ImportColumnType.tipe;
      }

      return ImportColumnType.abaikan;
    }).toList();
  }

  bool _matchesAny(String value, List<String> candidates) {
    return candidates.any((c) => value.contains(c) || c.contains(value));
  }

  // ─── 3. Category matching ───────────────────────────────────────────────

  Future<List<CategoryMatch>> matchCategories(
    List<String> sourceCategories,
  ) async {
    final dbCategories = await _db.categoryDao.getAllCategories();

    return sourceCategories.map((source) {
      final lower = source.toLowerCase().trim();

      // Try exact match first
      for (final cat in dbCategories) {
        if (cat.name.toLowerCase() == lower) {
          return CategoryMatch(
            sourceName: source,
            matchedCategoryId: cat.id,
            matchedCategoryName: cat.name,
            isAutoMatched: true,
          );
        }
      }

      // Try contains match
      for (final cat in dbCategories) {
        if (cat.name.toLowerCase().contains(lower) ||
            lower.contains(cat.name.toLowerCase())) {
          return CategoryMatch(
            sourceName: source,
            matchedCategoryId: cat.id,
            matchedCategoryName: cat.name,
            isAutoMatched: true,
          );
        }
      }

      // No match
      return CategoryMatch(sourceName: source);
    }).toList();
  }

  // ─── Wallet matching ──────────────────────────────────────────────────

  Future<List<WalletMatch>> matchWallets(List<String> sourceWallets) async {
    final dbWallets = await _db.walletDao.getAllWallets();

    return sourceWallets.map((source) {
      final lower = source.toLowerCase().trim();

      // Try exact match first
      for (final w in dbWallets) {
        if (w.name.toLowerCase() == lower) {
          return WalletMatch(
            sourceName: source,
            matchedWalletId: w.id,
            matchedWalletName: w.name,
            isAutoMatched: true,
          );
        }
      }

      // Try contains match
      for (final w in dbWallets) {
        if (w.name.toLowerCase().contains(lower) ||
            lower.contains(w.name.toLowerCase())) {
          return WalletMatch(
            sourceName: source,
            matchedWalletId: w.id,
            matchedWalletName: w.name,
            isAutoMatched: true,
          );
        }
      }

      // No match
      return WalletMatch(sourceName: source);
    }).toList();
  }

  // ─── 4. Preview / stats ─────────────────────────────────────────────────

  Future<ImportSummary> previewImport({
    required ParsedFile parsedFile,
    required List<ImportColumnType> columnMapping,
    required bool skipHeader,
    required int walletId,
    required Map<String, int> categoryMap,
    required Map<String, int> walletMap,
    required bool autoCreateCategories,
    required int defaultCategoryId,
  }) async {
    final rows = parsedFile.rows;
    final parsed = _buildTransactionData(
      rows: rows,
      columnMapping: columnMapping,
      categoryMap: categoryMap,
      defaultCategoryId: defaultCategoryId,
    );

    // Check duplicates
    int duplicates = 0;
    for (final t in parsed) {
      if (t.date != null) {
        final resolvedWalletId =
            (t.walletName != null && walletMap.containsKey(t.walletName))
            ? walletMap[t.walletName]!
            : walletId;
        final isDup = await _isDuplicate(
          date: t.date!,
          amount: t.amount,
          description: t.description,
          walletId: resolvedWalletId,
        );
        if (isDup) duplicates++;
      }
    }

    final dates =
        parsed.where((t) => t.date != null).map((t) => t.date!).toList()
          ..sort();

    int incomeCount = parsed.where((t) => t.isIncome).length;
    int expenseCount = parsed.where((t) => !t.isIncome).length;

    return ImportSummary(
      totalRows: parsed.length,
      imported: parsed.length - duplicates,
      skippedDuplicates: duplicates,
      incomeCount: incomeCount,
      expenseCount: expenseCount,
      dateFrom: dates.isNotEmpty ? dates.first : null,
      dateTo: dates.isNotEmpty ? dates.last : null,
    );
  }

  // ─── 5. Execute import ──────────────────────────────────────────────────

  Future<ImportSummary> executeImport({
    required ParsedFile parsedFile,
    required List<ImportColumnType> columnMapping,
    required int walletId,
    required Map<String, int> categoryMap,
    required Map<String, int> walletMap,
    required bool autoCreateWallets,
    required bool autoCreateCategories,
    required int defaultCategoryId,
    void Function(int current, int total)? onProgress,
  }) async {
    final rows = parsedFile.rows;
    final parsed = _buildTransactionData(
      rows: rows,
      columnMapping: columnMapping,
      categoryMap: categoryMap,
      defaultCategoryId: defaultCategoryId,
    );

    // Build case-insensitive maps for lookup
    final ciCategoryMap = <String, int>{};
    for (final entry in categoryMap.entries) {
      ciCategoryMap[entry.key.toLowerCase().trim()] = entry.value;
    }

    final ciWalletMap = <String, int>{};
    for (final entry in walletMap.entries) {
      ciWalletMap[entry.key.toLowerCase().trim()] = entry.value;
    }

    // Create missing categories if auto-create is on
    if (autoCreateCategories) {
      final allCats = await _db.categoryDao.getAllCategories();
      final existingNames = allCats.map((c) => c.name.toLowerCase()).toSet();

      for (final t in parsed) {
        if (t.categoryName != null) {
          final key = t.categoryName!.toLowerCase().trim();
          if (!existingNames.contains(key) && !ciCategoryMap.containsKey(key)) {
            final newId = await _db.categoryDao.createCategory(
              CategoriesCompanion(
                name: Value(t.categoryName!),
                type: Value(t.isIncome ? 'income' : 'expense'),
                icon: const Value('category'),
              ),
            );
            ciCategoryMap[key] = newId;
            existingNames.add(key);
          }
        }
      }
    }

    // Create missing wallets if auto-create is on
    if (autoCreateWallets) {
      final allWallets = await _db.walletDao.getAllWallets();
      final existingWalletNames = allWallets
          .map((w) => w.name.toLowerCase())
          .toSet();

      for (final t in parsed) {
        if (t.walletName != null) {
          final key = t.walletName!.toLowerCase().trim();
          if (!existingWalletNames.contains(key) &&
              !ciWalletMap.containsKey(key)) {
            final newId = await _db.walletDao.createWallet(
              WalletsCompanion(
                name: Value(t.walletName!),
                type: const Value('bank'),
              ),
            );
            ciWalletMap[key] = newId;
            existingWalletNames.add(key);
          }
        }
      }
    }

    int imported = 0;
    int duplicates = 0;
    int incomeCount = 0;
    int expenseCount = 0;
    final dates = <DateTime>[];

    int processed = 0;

    for (final t in parsed) {
      processed++;
      onProgress?.call(processed, parsed.length);

      if (t.date == null) continue;

      // Resolve wallet ID per row (case-insensitive)
      int resolvedWalletId = walletId;
      if (t.walletName != null) {
        final walletKey = t.walletName!.toLowerCase().trim();
        if (ciWalletMap.containsKey(walletKey)) {
          resolvedWalletId = ciWalletMap[walletKey]!;
        }
      }

      // Check duplicate
      final isDup = await _isDuplicate(
        date: t.date!,
        amount: t.amount,
        description: t.description,
        walletId: resolvedWalletId,
      );
      if (isDup) {
        duplicates++;
        continue;
      }

      // Resolve category ID (case-insensitive)
      int catId = defaultCategoryId;
      if (t.categoryName != null) {
        final catKey = t.categoryName!.toLowerCase().trim();
        if (ciCategoryMap.containsKey(catKey)) {
          catId = ciCategoryMap[catKey]!;
        }
      }

      final type = t.isIncome ? 'income' : 'expense';

      await _db.transactionDao.createTransaction(
        TransactionsCompanion(
          walletId: Value(resolvedWalletId),
          categoryId: Value(catId),
          amount: Value(t.amount.abs()),
          type: Value(type),
          description: Value(t.description),
          transactionDate: Value(t.date!),
        ),
      );

      imported++;
      dates.add(t.date!);
      if (t.isIncome) {
        incomeCount++;
      } else {
        expenseCount++;
      }
    }

    dates.sort();

    return ImportSummary(
      totalRows: parsed.length,
      imported: imported,
      skippedDuplicates: duplicates,
      incomeCount: incomeCount,
      expenseCount: expenseCount,
      dateFrom: dates.isNotEmpty ? dates.first : null,
      dateTo: dates.isNotEmpty ? dates.last : null,
    );
  }

  // ─── Internal helpers ───────────────────────────────────────────────────

  List<_ParsedTransaction> _buildTransactionData({
    required List<List<String>> rows,
    required List<ImportColumnType> columnMapping,
    required Map<String, int> categoryMap,
    required int defaultCategoryId,
  }) {
    final tanggalIdx = columnMapping.indexOf(ImportColumnType.tanggal);
    final nominalIdx = columnMapping.indexOf(ImportColumnType.nominal);
    final deskripsiIdx = columnMapping.indexOf(ImportColumnType.deskripsi);
    final kategoriIdx = columnMapping.indexOf(ImportColumnType.kategori);
    final tipeIdx = columnMapping.indexOf(ImportColumnType.tipe);
    final walletIdx = columnMapping.indexOf(ImportColumnType.wallet);

    if (tanggalIdx < 0 || nominalIdx < 0) {
      throw StateError('Kolom Tanggal dan Nominal wajib dipetakan');
    }

    // Auto-detect date format from first data row
    String? dateFormat;
    if (rows.isNotEmpty && tanggalIdx < rows.first.length) {
      dateFormat = _detectDateFormat(rows.first[tanggalIdx]);
    }

    return rows
        .where((row) => row.length > tanggalIdx && row.length > nominalIdx)
        .map((row) {
          final dateStr = row[tanggalIdx].trim();
          final amountStr = row[nominalIdx].trim();

          final date = _parseDate(dateStr, dateFormat);
          final amount = _parseAmount(amountStr);

          final description = deskripsiIdx >= 0 && deskripsiIdx < row.length
              ? row[deskripsiIdx].trim()
              : '';
          final categoryName = kategoriIdx >= 0 && kategoriIdx < row.length
              ? row[kategoriIdx].trim()
              : null;
          final walletName = walletIdx >= 0 && walletIdx < row.length
              ? row[walletIdx].trim()
              : null;

          // Determine income vs expense
          bool isIncome = amount >= 0;
          if (tipeIdx >= 0 && tipeIdx < row.length) {
            final tipeStr = row[tipeIdx].trim().toLowerCase();
            if (tipeStr == 'cr' ||
                tipeStr == 'credit' ||
                tipeStr == 'kredit' ||
                tipeStr == 'income' ||
                tipeStr == '+' ||
                tipeStr == 'pemasukan') {
              isIncome = true;
            } else if (tipeStr == 'db' ||
                tipeStr == 'debit' ||
                tipeStr == 'debet' ||
                tipeStr == 'expense' ||
                tipeStr == '-' ||
                tipeStr == 'pengeluaran') {
              isIncome = false;
            }
          }

          return _ParsedTransaction(
            date: date,
            amount: amount.abs(),
            description: description,
            categoryName: categoryName,
            walletName: walletName,
            isIncome: isIncome,
          );
        })
        .toList();
  }

  // ─── Date parsing ──────────────────────────────────────────────────────

  static final _dateFormats = [
    DateFormat('dd/MM/yyyy'),
    DateFormat('yyyy-MM-dd'),
    DateFormat('dd-MM-yyyy'),
    DateFormat('MM/dd/yyyy'),
    DateFormat('dd/MM/yy'),
    DateFormat('yyyy/MM/dd'),
    DateFormat('d/M/yyyy'),
    DateFormat('d-M-yyyy'),
  ];

  String? _detectDateFormat(String sample) {
    for (final fmt in _dateFormats) {
      try {
        fmt.parseStrict(sample.trim());
        return fmt.pattern;
      } catch (_) {}
    }
    return null;
  }

  DateTime? _parseDate(String value, String? detectedFormat) {
    if (value.isEmpty) return null;

    // Try detected format first
    if (detectedFormat != null) {
      try {
        return DateFormat(detectedFormat).parseStrict(value.trim());
      } catch (_) {}
    }

    // Fallback: try all formats
    for (final fmt in _dateFormats) {
      try {
        return fmt.parseStrict(value.trim());
      } catch (_) {}
    }

    // Try DateTime.parse as last resort
    return DateTime.tryParse(value.trim());
  }

  // ─── Amount parsing ────────────────────────────────────────────────────

  double _parseAmount(String value) {
    if (value.isEmpty) return 0;

    // Remove currency symbols and whitespace
    var cleaned = value.replaceAll(RegExp(r'[Rr][Pp]\.?\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[\s]'), '');

    // Determine negative
    bool isNegative = cleaned.startsWith('-') || cleaned.startsWith('(');
    cleaned = cleaned.replaceAll(RegExp(r'[()]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^-'), '');

    // Handle thousand/decimal separators
    // If last separator is comma and has 2 digits after → comma is decimal
    // Indonesian format: 1.000.000,00 → dots are thousands, comma is decimal
    if (cleaned.contains(',') && cleaned.contains('.')) {
      final commaPos = cleaned.lastIndexOf(',');
      final dotPos = cleaned.lastIndexOf('.');
      if (commaPos > dotPos) {
        // 1.000.000,00 format (Indonesian)
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // 1,000,000.00 format (English)
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains(',')) {
      // Could be decimal comma (123,45) or thousand comma (1,000)
      final afterComma = cleaned.split(',').last;
      if (afterComma.length <= 2) {
        cleaned = cleaned.replaceAll(',', '.');
      } else {
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains('.')) {
      // Could be decimal dot (123.45) or thousand dot (1.000)
      final parts = cleaned.split('.');
      final afterDot = parts.last;
      if (parts.length > 2) {
        // Multiple dots: thousand separators → 1.000.000
        cleaned = cleaned.replaceAll('.', '');
      }
      // Single dot with 3+ digits after → thousand separator
      else if (afterDot.length >= 3 && parts.length == 2) {
        cleaned = cleaned.replaceAll('.', '');
      }
      // Otherwise keep as decimal
    }

    final result = double.tryParse(cleaned) ?? 0;
    return isNegative ? -result : result;
  }

  // ─── Duplicate check ───────────────────────────────────────────────────

  Future<bool> _isDuplicate({
    required DateTime date,
    required double amount,
    required String description,
    required int walletId,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final existing = await _db.transactionDao.getTransactionsByDateRange(
      startOfDay,
      endOfDay,
    );

    return existing.any(
      (t) =>
          t.walletId == walletId &&
          (t.amount - amount).abs() < 0.01 &&
          t.description.toLowerCase() == description.toLowerCase(),
    );
  }
}

// ─── Internal data class ─────────────────────────────────────────────────────

class _ParsedTransaction {
  final DateTime? date;
  final double amount;
  final String description;
  final String? categoryName;
  final String? walletName;
  final bool isIncome;

  const _ParsedTransaction({
    this.date,
    required this.amount,
    required this.description,
    this.categoryName,
    this.walletName,
    required this.isIncome,
  });
}
