import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../data/local/database/app_database.dart';

/// Represents a single row of exported transaction data.
class ExportRow {
  final String tanggal;
  final String tipe; // '+' or '-'
  final String kategori;
  final String deskripsi;
  final double jumlah;
  final String wallet;

  const ExportRow({
    required this.tanggal,
    required this.tipe,
    required this.kategori,
    required this.deskripsi,
    required this.jumlah,
    required this.wallet,
  });
}

class ExportService {
  final AppDatabase _db;

  ExportService(this._db);

  // ─── Gather data ────────────────────────────────────────────────────

  Future<List<ExportRow>> _gatherRows(DateTime start, DateTime end) async {
    final transactions = await _db.transactionDao.getTransactionsByDateRange(
      start,
      end,
    );

    // Pre-fetch categories and wallets into maps for fast lookup
    final categories = await _db.categoryDao.getAllCategories();
    final wallets = await _db.walletDao.getAllWallets();

    final catMap = {for (final c in categories) c.id: c.name};
    final walletMap = {for (final w in wallets) w.id: w.name};

    final dateFormat = DateFormat('dd/MM/yyyy');

    return transactions.map((t) {
      return ExportRow(
        tanggal: dateFormat.format(t.transactionDate),
        tipe: t.type == 'income' ? '+' : '-',
        kategori: catMap[t.categoryId] ?? '-',
        deskripsi: t.description,
        jumlah: t.amount,
        wallet: walletMap[t.walletId] ?? '-',
      );
    }).toList();
  }

  // ─── Column headers ─────────────────────────────────────────────────

  static const _headers = [
    'Tanggal',
    'Tipe',
    'Kategori',
    'Deskripsi',
    'Jumlah',
    'Wallet',
  ];

  // ─── Public API ─────────────────────────────────────────────────────

  /// Export transactions — generates the file and tries to share it.
  ///
  /// [format] 0 = PDF, 1 = Excel, 2 = CSV
  ///
  /// Returns the absolute path of the generated file so the UI can
  /// show a message even when sharing is unavailable.
  Future<String> exportAndShare({
    required int format,
    required DateTime startDate,
    required DateTime endDate,
    bool includeReceipts = false,
    bool passwordProtection = false,
    String? password,
  }) async {
    final rows = await _gatherRows(startDate, endDate);

    final dir = await getApplicationDocumentsDirectory();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    String filePath;

    switch (format) {
      case 0:
        filePath = '${dir.path}/saku_report_$dateStr.pdf';
        await _generatePdf(
          filePath,
          rows,
          startDate,
          endDate,
          passwordProtection: passwordProtection,
          password: password,
        );
        break;
      case 1:
        filePath = '${dir.path}/saku_report_$dateStr.xlsx';
        await _generateExcel(filePath, rows, startDate, endDate);
        break;
      case 2:
        filePath = '${dir.path}/saku_report_$dateStr.csv';
        await _generateCsv(filePath, rows);
        break;
      default:
        throw ArgumentError('Unknown format: $format');
    }

    // Try to share — gracefully handle missing plugin (e.g. Windows desktop)
    try {
      await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));
    } catch (_) {
      // Share not available on this platform; file is still saved.
    }

    return filePath;
  }

  // ─── PDF generation ─────────────────────────────────────────────────

  Future<void> _generatePdf(
    String path,
    List<ExportRow> rows,
    DateTime start,
    DateTime end, {
    bool passwordProtection = false,
    String? password,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    // Calculate totals
    double totalIncome = rows
        .where((r) => r.tipe == '+')
        .fold(0.0, (s, r) => s + r.jumlah);
    double totalExpense = rows
        .where((r) => r.tipe == '-')
        .fold(0.0, (s, r) => s + r.jumlah);
    final currencyFormat = NumberFormat('#,##0', 'id_ID');

    // Split rows into pages of ~25 rows each
    const rowsPerPage = 25;
    final totalPages = (rows.length / rowsPerPage).ceil().clamp(1, 9999);

    for (int page = 0; page < totalPages; page++) {
      final pageRows = rows.skip(page * rowsPerPage).take(rowsPerPage).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header (first page only)
                if (page == 0) ...[
                  pw.Text(
                    'Laporan Keuangan Saku',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Periode: ${dateFormat.format(start)} - ${dateFormat.format(end)}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Pemasukan: Rp ${currencyFormat.format(totalIncome)}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green700,
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Text(
                        'Pengeluaran: Rp ${currencyFormat.format(totalExpense)}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red700,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                ],

                // Table
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  cellPadding: const pw.EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 3,
                  ),
                  headers: _headers,
                  data: pageRows.map((r) {
                    return [
                      r.tanggal,
                      r.tipe,
                      r.kategori,
                      r.deskripsi,
                      currencyFormat.format(r.jumlah),
                      r.wallet,
                    ];
                  }).toList(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(3),
                    4: const pw.FlexColumnWidth(2),
                    5: const pw.FlexColumnWidth(2),
                  },
                ),

                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Halaman ${page + 1} / $totalPages',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final file = File(path);
    await file.writeAsBytes(await pdf.save());
  }

  // ─── Excel generation ───────────────────────────────────────────────

  Future<void> _generateExcel(
    String path,
    List<ExportRow> rows,
    DateTime start,
    DateTime end,
  ) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Transaksi'];

    // Remove default sheet if different
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat('#,##0', 'id_ID');

    // Title row
    sheet.appendRow([xl.TextCellValue('Laporan Keuangan Saku')]);
    sheet.appendRow([
      xl.TextCellValue(
        'Periode: ${dateFormat.format(start)} - ${dateFormat.format(end)}',
      ),
    ]);
    sheet.appendRow([]); // blank row

    // Header row
    sheet.appendRow(_headers.map((h) => xl.TextCellValue(h)).toList());

    // Style header row (row index 3)
    for (int col = 0; col < _headers.length; col++) {
      final cell = sheet.cell(
        xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 3),
      );
      cell.cellStyle = xl.CellStyle(
        bold: true,
        backgroundColorHex: xl.ExcelColor.fromHexString('#E0E0E0'),
      );
    }

    // Data rows
    for (final r in rows) {
      sheet.appendRow([
        xl.TextCellValue(r.tanggal),
        xl.TextCellValue(r.tipe),
        xl.TextCellValue(r.kategori),
        xl.TextCellValue(r.deskripsi),
        xl.TextCellValue('Rp ${currencyFormat.format(r.jumlah)}'),
        xl.TextCellValue(r.wallet),
      ]);
    }

    // Summary rows
    double totalIncome = rows
        .where((r) => r.tipe == '+')
        .fold(0.0, (s, r) => s + r.jumlah);
    double totalExpense = rows
        .where((r) => r.tipe == '-')
        .fold(0.0, (s, r) => s + r.jumlah);

    sheet.appendRow([]); // blank
    sheet.appendRow([
      xl.TextCellValue('Total Pemasukan'),
      xl.TextCellValue(''),
      xl.TextCellValue(''),
      xl.TextCellValue(''),
      xl.TextCellValue('Rp ${currencyFormat.format(totalIncome)}'),
      xl.TextCellValue(''),
    ]);
    sheet.appendRow([
      xl.TextCellValue('Total Pengeluaran'),
      xl.TextCellValue(''),
      xl.TextCellValue(''),
      xl.TextCellValue(''),
      xl.TextCellValue('Rp ${currencyFormat.format(totalExpense)}'),
      xl.TextCellValue(''),
    ]);

    // Adjust column widths
    sheet.setColumnWidth(0, 14);
    sheet.setColumnWidth(1, 6);
    sheet.setColumnWidth(2, 18);
    sheet.setColumnWidth(3, 25);
    sheet.setColumnWidth(4, 16);
    sheet.setColumnWidth(5, 16);

    final file = File(path);
    final bytes = excel.save();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
  }

  // ─── CSV generation ─────────────────────────────────────────────────

  Future<void> _generateCsv(String path, List<ExportRow> rows) async {
    final csvData = <List<dynamic>>[
      _headers,
      ...rows.map(
        (r) => [r.tanggal, r.tipe, r.kategori, r.deskripsi, r.jumlah, r.wallet],
      ),
    ];

    final buffer = StringBuffer();
    for (final row in csvData) {
      buffer.writeln(
        row
            .map((field) {
              final s = field.toString();
              // Escape fields containing commas, quotes, or newlines
              if (s.contains(',') || s.contains('"') || s.contains('\n')) {
                return '"${s.replaceAll('"', '""')}"';
              }
              return s;
            })
            .join(','),
      );
    }
    final file = File(path);
    await file.writeAsString(buffer.toString());
  }
}
