import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saku/core/services/xls_decoder.dart';
import 'package:saku/core/services/import_service.dart';
import 'package:saku/data/local/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('XlsDecoder & ImportService .xls testing', () {
    final xlsFile = File('walkthrough/DompetKu_01Sep2022_14Sep2026.xls');

    test('XlsDecoder parses DompetKu .xls file correctly', () {
      expect(xlsFile.existsSync(), isTrue);

      final bytes = xlsFile.readAsBytesSync();
      final rows = XlsDecoder.decodeBytes(bytes);

      expect(rows.isNotEmpty, isTrue);
      // Header row
      expect(rows.first, ['Kategori', 'Rekening', 'Jumlah', 'Tanggal', 'Catatan', 'Tipe']);
      // Should have over 4000 rows
      expect(rows.length, greaterThan(4000));

      final firstDataRow = rows[1];
      expect(firstDataRow.length, 6);
      expect(firstDataRow[0], isNotEmpty); // Kategori
      expect(firstDataRow[1], isNotEmpty); // Rekening
      expect(firstDataRow[2], isNotEmpty); // Jumlah
      expect(firstDataRow[3], isNotEmpty); // Tanggal
    });

    test('ImportService parses .xls file into ParsedFile with auto-mapping', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final importService = ImportService(db);

      final parsed = await importService.parseFile(xlsFile.path);

      expect(parsed.fileName, contains('DompetKu_01Sep2022_14Sep2026.xls'));
      expect(parsed.headers, ['Kategori', 'Rekening', 'Jumlah', 'Tanggal', 'Catatan', 'Tipe']);
      expect(parsed.rows.length, greaterThan(4000));

      // Check auto-mappings
      expect(parsed.autoMapping[0], ImportColumnType.kategori);
      expect(parsed.autoMapping[1], ImportColumnType.wallet);
      expect(parsed.autoMapping[2], ImportColumnType.nominal);
      expect(parsed.autoMapping[3], ImportColumnType.tanggal);
      expect(parsed.autoMapping[4], ImportColumnType.deskripsi);
      expect(parsed.autoMapping[5], ImportColumnType.tipe);

      final preview = await importService.previewImport(
        parsedFile: parsed,
        columnMapping: parsed.autoMapping,
        skipHeader: true,
        walletId: 1,
        categoryMap: {},
        walletMap: {},
        autoCreateCategories: true,
        defaultCategoryId: 1,
      );

      expect(preview.totalRows, 4422);
      expect(preview.incomeCount, 577);
      expect(preview.expenseCount, 3845);
      expect(preview.dateFrom, isNotNull);
      expect(preview.dateTo, isNotNull);

      final result = await importService.executeImport(
        parsedFile: parsed,
        columnMapping: parsed.autoMapping,
        walletId: 1,
        categoryMap: {},
        walletMap: {},
        autoCreateWallets: true,
        autoCreateCategories: true,
        defaultCategoryId: 1,
      );

      expect(result.imported, greaterThan(4400));

      await db.close();
    });
  });
}
