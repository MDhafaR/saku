import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/injection.dart';
import '../../../../core/services/import_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../data/local/database/app_database.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Import Menu Page
// ═══════════════════════════════════════════════════════════════════════════

class ImportMenuPage extends StatefulWidget {
  const ImportMenuPage({super.key});

  @override
  State<ImportMenuPage> createState() => _ImportMenuPageState();
}

class _ImportMenuPageState extends State<ImportMenuPage> {
  bool _isPickingFile = false;
  List<ImportHistory> _importHistory = [];
  final ImportService _importService = ImportService(locator<AppDatabase>());

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _importService.getImportHistory();
    if (mounted) {
      setState(() => _importHistory = history);
    }
  }

  Future<void> _pickFile() async {
    setState(() => _isPickingFile = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        if (mounted) {
          final didImport = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => ImportWizardPage(filePath: filePath),
            ),
          );
          // Refresh history after returning
          if (didImport == true) _loadHistory();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memilih file: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Import Data',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 80.sp,
                    color: const Color(0xFF111111),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Pindahkan Data Keuangan',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Pindahkan data keuanganmu dari aplikasi lain atau rekening koran bank dengan mudah.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Import',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (_importHistory.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text(
                        'Belum ada riwayat import.',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13.sp,
                        ),
                      ),
                    )
                  else
                    ..._importHistory.map((h) => _buildHistoryItem(h)),
                ],
              ),
            ),
          ),

          // Bottom button
          Padding(
            padding: EdgeInsets.all(20.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPickingFile ? null : _pickFile,
                icon: _isPickingFile
                    ? SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.add, color: Colors.white, size: 24.sp),
                label: Text(
                  _isPickingFile
                      ? 'Memilih file...'
                      : 'Pilih File dari Penyimpanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ImportHistory history) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final dateStr = dateFormat.format(history.importedAt);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.grey,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.fileName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                if (history.isSuccess)
                  Text(
                    '${history.importedCount} transaksi${history.skippedDuplicates > 0 ? ', ${history.skippedDuplicates} duplikat' : ''}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: history.isSuccess ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              history.isSuccess ? 'Sukses' : 'Gagal',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: history.isSuccess ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Import Wizard Page
// ═══════════════════════════════════════════════════════════════════════════

class ImportWizardPage extends StatefulWidget {
  final String filePath;

  const ImportWizardPage({super.key, required this.filePath});

  @override
  State<ImportWizardPage> createState() => _ImportWizardPageState();
}

class _ImportWizardPageState extends State<ImportWizardPage> {
  final ImportService _importService = ImportService(locator<AppDatabase>());

  int _currentStep = 1;
  bool _isLoading = true;
  bool _isImporting = false;
  String? _error;
  int _defaultWalletId = 0;

  // Step 1 state
  ParsedFile? _parsedFile;
  List<ImportColumnType> _columnMapping = [];
  bool _skipHeader = true; // already skipped during parse

  // Step 2 state
  bool _autoCreateCategory = true;
  List<CategoryMatch> _categoryMatches = [];
  List<Category> _dbCategories = [];
  int _defaultCategoryId = 0;

  // Step 3 state (wallet mapping)
  bool _autoCreateWallet = true;
  List<WalletMatch> _walletMatches = [];
  List<Wallet> _dbWallets = [];
  bool _hasWalletColumn = false;

  // Step 4 state
  ImportSummary? _previewSummary;

  @override
  void initState() {
    super.initState();
    _parseFile();
  }

  Future<void> _parseFile() async {
    try {
      final parsed = await _importService.parseFile(widget.filePath);
      final dbCats = await locator<AppDatabase>().categoryDao
          .getAllCategories();

      // Set default category (first expense category)
      final defaultCat = dbCats.firstWhere(
        (c) => c.type == 'expense',
        orElse: () => dbCats.first,
      );

      // Get default wallet first (may auto-create one if none exist)
      final defaultWalletId = await _importService.getDefaultWalletId();
      // Load wallets AFTER getDefaultWalletId so auto-created wallet is included
      final dbWallets = await locator<AppDatabase>().walletDao.getAllWallets();

      if (mounted) {
        setState(() {
          _parsedFile = parsed;
          _columnMapping = List.from(parsed.autoMapping);
          _dbCategories = dbCats;
          _dbWallets = dbWallets;
          _defaultCategoryId = defaultCat.id;
          _defaultWalletId = defaultWalletId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCategoryMatches() async {
    if (_parsedFile == null) return;

    final kategoriIdx = _columnMapping.indexOf(ImportColumnType.kategori);
    if (kategoriIdx < 0) {
      setState(() => _categoryMatches = []);
      return;
    }

    // Extract unique category values from data
    final uniqueCategories = <String>{};
    for (final row in _parsedFile!.rows) {
      if (kategoriIdx < row.length) {
        final val = row[kategoriIdx].trim();
        if (val.isNotEmpty) uniqueCategories.add(val);
      }
    }

    final matches = await _importService.matchCategories(
      uniqueCategories.toList(),
    );
    if (mounted) setState(() => _categoryMatches = matches);
  }

  Future<void> _loadWalletMatches() async {
    if (_parsedFile == null) return;

    final walletIdx = _columnMapping.indexOf(ImportColumnType.wallet);
    _hasWalletColumn = walletIdx >= 0;
    if (!_hasWalletColumn) {
      setState(() => _walletMatches = []);
      return;
    }

    // Extract unique wallet values from data
    final uniqueWallets = <String>{};
    for (final row in _parsedFile!.rows) {
      if (walletIdx < row.length) {
        final val = row[walletIdx].trim();
        if (val.isNotEmpty) uniqueWallets.add(val);
      }
    }

    final matches = await _importService.matchWallets(uniqueWallets.toList());
    if (mounted) setState(() => _walletMatches = matches);
  }

  Future<void> _loadPreview() async {
    if (_parsedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final categoryMap = <String, int>{};
      for (final match in _categoryMatches) {
        if (match.matchedCategoryId != null) {
          categoryMap[match.sourceName] = match.matchedCategoryId!;
        }
      }

      final walletMap = <String, int>{};
      for (final match in _walletMatches) {
        if (match.matchedWalletId != null) {
          walletMap[match.sourceName] = match.matchedWalletId!;
        }
      }

      final summary = await _importService.previewImport(
        parsedFile: _parsedFile!,
        columnMapping: _columnMapping,
        skipHeader: _skipHeader,
        walletId: _defaultWalletId,
        categoryMap: categoryMap,
        walletMap: walletMap,
        autoCreateCategories: _autoCreateCategory,
        defaultCategoryId: _defaultCategoryId,
      );

      if (mounted) {
        setState(() {
          _previewSummary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _doImport() async {
    if (_parsedFile == null) return;

    // Prepare data before popping
    final categoryMap = <String, int>{};
    for (final match in _categoryMatches) {
      if (match.matchedCategoryId != null) {
        categoryMap[match.sourceName] = match.matchedCategoryId!;
      }
    }

    final walletMap = <String, int>{};
    for (final match in _walletMatches) {
      if (match.matchedWalletId != null) {
        walletMap[match.sourceName] = match.matchedWalletId!;
      }
    }

    final parsedFile = _parsedFile!;
    final columnMapping = List<ImportColumnType>.from(_columnMapping);
    final defaultWalletId = _defaultWalletId;
    final autoCreateWallet = _autoCreateWallet;
    final autoCreateCategory = _autoCreateCategory;
    final defaultCategoryId = _defaultCategoryId;
    final filePath = widget.filePath;
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final importService = _importService;
    final notificationService = NotificationService();

    // Pop all the way to dashboard — import runs in background
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);

    // Show initial progress notification
    await notificationService.showProgressNotification(
      title: 'Mengimport $fileName',
      body: 'Memulai import...',
      progress: 0,
      maxProgress: 100,
    );

    // Fire-and-forget background import
    _runBackgroundImport(
      importService: importService,
      notificationService: notificationService,
      parsedFile: parsedFile,
      columnMapping: columnMapping,
      walletId: defaultWalletId,
      categoryMap: categoryMap,
      walletMap: walletMap,
      autoCreateWallets: autoCreateWallet,
      autoCreateCategories: autoCreateCategory,
      defaultCategoryId: defaultCategoryId,
      fileName: fileName,
      filePath: filePath,
    );
  }

  static Future<void> _runBackgroundImport({
    required ImportService importService,
    required NotificationService notificationService,
    required ParsedFile parsedFile,
    required List<ImportColumnType> columnMapping,
    required int walletId,
    required Map<String, int> categoryMap,
    required Map<String, int> walletMap,
    required bool autoCreateWallets,
    required bool autoCreateCategories,
    required int defaultCategoryId,
    required String fileName,
    required String filePath,
  }) async {
    try {
      final result = await importService.executeImport(
        parsedFile: parsedFile,
        columnMapping: columnMapping,
        walletId: walletId,
        categoryMap: categoryMap,
        walletMap: walletMap,
        autoCreateWallets: autoCreateWallets,
        autoCreateCategories: autoCreateCategories,
        defaultCategoryId: defaultCategoryId,
        onProgress: (current, total) {
          final percent = (current * 100 ~/ total).clamp(0, 100);
          notificationService.showProgressNotification(
            title: 'Mengimport $fileName',
            body: '$current / $total baris diproses',
            progress: percent,
            maxProgress: 100,
          );
        },
      );

      // Save success history
      await importService.saveImportHistory(
        fileName: fileName,
        filePath: filePath,
        summary: result,
        isSuccess: true,
      );

      // Show success notification
      final dupText = result.skippedDuplicates > 0
          ? ', ${result.skippedDuplicates} duplikat dilewati'
          : '';
      await notificationService.showImportResultNotification(
        title: 'Import Berhasil ✅',
        body: '${result.imported} transaksi diimport dari $fileName$dupText',
      );
    } catch (e) {
      // Save failed history
      await importService.saveImportHistory(
        fileName: fileName,
        filePath: filePath,
        summary: const ImportSummary(
          totalRows: 0,
          imported: 0,
          skippedDuplicates: 0,
          incomeCount: 0,
          expenseCount: 0,
        ),
        isSuccess: false,
        errorMessage: e.toString(),
      );

      // Show error notification
      await notificationService.showImportResultNotification(
        title: 'Import Gagal ❌',
        body: 'Gagal import $fileName: $e',
      );
    }
  }

  bool _canProceed() {
    if (_currentStep == 1) {
      return _columnMapping.contains(ImportColumnType.tanggal) &&
          _columnMapping.contains(ImportColumnType.nominal);
    }
    return true;
  }

  Future<void> _nextStep() async {
    if (_currentStep == 1) {
      await _loadCategoryMatches();
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      await _loadWalletMatches();
      // If no wallet column detected, skip wallet mapping step
      if (!_hasWalletColumn) {
        await _loadPreview();
        setState(() => _currentStep = 4);
      } else {
        setState(() => _currentStep = 3);
      }
    } else if (_currentStep == 3) {
      await _loadPreview();
      setState(() => _currentStep = 4);
    } else {
      await _doImport();
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Petakan Kolom';
    if (_currentStep == 2) title = 'Petakan Kategori';
    if (_currentStep == 3) title = 'Petakan Wallet';
    if (_currentStep == 4) title = 'Konfirmasi Import';

    final totalSteps = _hasWalletColumn ? 4 : 3;
    final displayStep = _hasWalletColumn
        ? _currentStep
        : (_currentStep <= 2 ? _currentStep : _currentStep - 1);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: const Color(0xFF111111),
            size: 20.sp,
          ),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: const Color(0xFF111111),
              size: 24.sp,
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0.h),
          child: LinearProgressIndicator(
            value: displayStep / totalSteps,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF111111)),
          ),
        ),
      ),
      body: _error != null
          ? _buildError()
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_currentStep > 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'Langkah $displayStep dari $totalSteps: ${_getStepName()}',
                      style: TextStyle(
                        color: const Color(0xFF1F2937),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: _buildCurrentStep(),
                  ),
                ),

                // Bottom button
                Container(
                  padding: EdgeInsets.all(20.w),
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_canProceed() && !_isImporting)
                          ? _nextStep
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        disabledBackgroundColor: Colors.grey[300],
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        elevation: 0,
                      ),
                      child: _isImporting
                          ? SizedBox(
                              width: 24.sp,
                              height: 24.sp,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentStep == 1
                                  ? 'Lanjut ke Kategori'
                                  : (_currentStep == 2
                                        ? 'Lanjut ke Wallet'
                                        : (_currentStep == 3
                                              ? 'Simpan & Lanjut'
                                              : 'Mulai Import Sekarang')),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                    ),
                  ),
                ),
                if (_currentStep == 3)
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(bottom: 20.h),
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batalkan',
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red[300]),
            SizedBox(height: 16.h),
            Text(
              'Gagal membaca file',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepName() {
    if (_currentStep == 2) return 'Kategori';
    if (_currentStep == 3) return 'Wallet';
    if (_currentStep == 4) return 'Konfirmasi';
    return '';
  }

  Widget _buildCurrentStep() {
    if (_currentStep == 1) return _buildStep1();
    if (_currentStep == 2) return _buildStep2();
    if (_currentStep == 3) return _buildStep3();
    return _buildStep4();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Step 1: Column Mapping
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildStep1() {
    final file = _parsedFile;
    if (file == null) return const SizedBox.shrink();

    final fileSizeStr = file.fileSize > 1024
        ? '${(file.fileSize / 1024).toStringAsFixed(0)} KB'
        : '${file.fileSize} B';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File info card
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.table_chart,
                  color: Colors.green,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.fileName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$fileSizeStr • ${file.rows.length} Baris',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        SizedBox(height: 12.h),
        Text(
          'Tentukan jenis data untuk setiap kolom',
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
        ),
        SizedBox(height: 16.h),

        // Column mapping cards (scrollable horizontally)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(file.headers.length, (colIdx) {
              // Get first 3 data rows for preview
              final previews = <String>[];
              for (int i = 0; i < file.rows.length && i < 3; i++) {
                if (colIdx < file.rows[i].length) {
                  previews.add(file.rows[i][colIdx]);
                }
              }

              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: _buildMappingColumn(
                  colIdx: colIdx,
                  header: file.headers[colIdx],
                  previews: previews,
                  selectedType: _columnMapping[colIdx],
                ),
              );
            }),
          ),
        ),

        SizedBox(height: 32.h),
        _buildValidationStatus(),
      ],
    );
  }

  Widget _buildMappingColumn({
    required int colIdx,
    required String header,
    required List<String> previews,
    required ImportColumnType selectedType,
  }) {
    final isIgnored = selectedType == ImportColumnType.abaikan;
    final isMapped = !isIgnored;

    return Container(
      width: 150.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isIgnored ? Colors.grey[200]! : Colors.green[200]!,
          width: isIgnored ? 1.w : 1.5.w,
        ),
      ),
      child: Column(
        children: [
          // Header text (original column name from file)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
            ),
            width: double.infinity,
            child: Text(
              header,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Dropdown for column type
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: isMapped ? Colors.green[50] : Colors.grey[50],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ImportColumnType>(
                value: selectedType,
                isExpanded: true,
                isDense: true,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isMapped ? Colors.green[800] : Colors.grey,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16.sp,
                  color: isMapped ? Colors.green[800] : Colors.grey,
                ),
                items: ImportColumnType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.label));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _columnMapping[colIdx] = val);
                  }
                },
              ),
            ),
          ),

          // Preview rows
          ...previews.map(
            (p) => Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[100]!)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  p,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildValidationStatus() {
    final hasTanggal = _columnMapping.contains(ImportColumnType.tanggal);
    final hasNominal = _columnMapping.contains(ImportColumnType.nominal);
    final bothOk = hasTanggal && hasNominal;

    return Row(
      children: [
        Icon(
          bothOk ? Icons.check_circle : Icons.warning_amber_rounded,
          color: bothOk ? Colors.green[600] : Colors.orange[700],
          size: 16.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            bothOk
                ? '2 kolom wajib (Tanggal, Nominal) ditemukan'
                : 'Kolom wajib belum lengkap: ${!hasTanggal ? "Tanggal" : ""}${!hasTanggal && !hasNominal ? " & " : ""}${!hasNominal ? "Nominal" : ""}',
            style: TextStyle(
              color: bothOk ? Colors.green[700] : Colors.orange[700],
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Step 2: Category Mapping
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildStep2() {
    final hasKategoriColumn = _columnMapping.contains(
      ImportColumnType.kategori,
    );

    if (!hasKategoriColumn) {
      return Column(
        children: [
          SizedBox(height: 40.h),
          Icon(Icons.info_outline, size: 48.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'Tidak ada kolom Kategori',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Semua transaksi akan menggunakan kategori default. Anda bisa mengubahnya nanti.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      );
    }

    final matched = _categoryMatches
        .where((m) => m.matchedCategoryId != null)
        .length;
    final unmatched = _categoryMatches
        .where((m) => m.matchedCategoryId == null)
        .length;

    return Column(
      children: [
        // Auto-create toggle
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buat kategori baru untuk yang tidak cocok',
                      style: TextStyle(
                        color: const Color(0xFF1F2937),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Otomatis buat kategori jika tidak ada di Saku',
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoCreateCategory,
                onChanged: (v) => setState(() => _autoCreateCategory = v),
                activeColor: const Color(0xFF111111),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        // Column headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DARI FILE (SUMBER)',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            Text(
              'KE SAKU (TUJUAN)',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Category mapping items
        ..._categoryMatches.map((match) => _buildCategoryMappingItem(match)),

        SizedBox(height: 20.h),
        Text(
          '$matched kategori dipetakan${unmatched > 0 ? ', $unmatched belum dipetakan' : ''}',
          style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildCategoryMappingItem(CategoryMatch match) {
    final isMatched = match.matchedCategoryId != null;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              match.sourceName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
                fontSize: 14.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Icon(Icons.arrow_forward, size: 16.sp, color: Colors.grey),
          ),
          Container(
            width: 150.w,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: isMatched ? Colors.green[50] : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isMatched ? Colors.green[200]! : Colors.grey[300]!,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: match.matchedCategoryId,
                isExpanded: true,
                isDense: true,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isMatched ? Colors.green[800] : Colors.grey,
                  fontWeight: isMatched ? FontWeight.w600 : FontWeight.normal,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16.sp,
                  color: Colors.grey[500],
                ),
                hint: Text(
                  'Pilih Kategori...',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'Buat Baru',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ..._dbCategories.map(
                    (c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(
                        c.name,
                        style: TextStyle(fontSize: 12.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    match.matchedCategoryId = val;
                    match.matchedCategoryName = val != null
                        ? _dbCategories.firstWhere((c) => c.id == val).name
                        : null;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Step 3: Wallet Mapping
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildStep3() {
    final matched = _walletMatches
        .where((m) => m.matchedWalletId != null)
        .length;
    final unmatched = _walletMatches
        .where((m) => m.matchedWalletId == null)
        .length;

    return Column(
      children: [
        // Auto-create toggle
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buat wallet baru otomatis',
                      style: TextStyle(
                        color: const Color(0xFF1F2937),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Otomatis buat wallet jika belum ada di Saku',
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoCreateWallet,
                onChanged: (v) => setState(() => _autoCreateWallet = v),
                activeColor: const Color(0xFF111111),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        // Column headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DARI FILE (SUMBER)',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            Text(
              'KE SAKU (TUJUAN)',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Wallet mapping items
        ..._walletMatches.map((match) => _buildWalletMappingItem(match)),

        SizedBox(height: 20.h),
        Text(
          '$matched wallet dipetakan${unmatched > 0 ? ', $unmatched belum dipetakan' : ''}',
          style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildWalletMappingItem(WalletMatch match) {
    final isMatched = match.matchedWalletId != null;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              match.sourceName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
                fontSize: 14.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Icon(Icons.arrow_forward, size: 16.sp, color: Colors.grey),
          ),
          Container(
            width: 150.w,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: isMatched ? Colors.green[50] : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isMatched ? Colors.green[200]! : Colors.grey[300]!,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: match.matchedWalletId,
                isExpanded: true,
                isDense: true,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isMatched ? Colors.green[800] : Colors.grey,
                  fontWeight: isMatched ? FontWeight.w600 : FontWeight.normal,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16.sp,
                  color: Colors.grey[500],
                ),
                hint: Text(
                  'Pilih Wallet...',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'Buat Baru',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ..._dbWallets.map(
                    (w) => DropdownMenuItem<int?>(
                      value: w.id,
                      child: Text(
                        w.name,
                        style: TextStyle(fontSize: 12.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    match.matchedWalletId = val;
                    match.matchedWalletName = val != null
                        ? _dbWallets.firstWhere((w) => w.id == val).name
                        : null;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Step 4: Confirmation
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildStep4() {
    final summary = _previewSummary;
    if (summary == null) return const SizedBox.shrink();

    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Column(
      children: [
        // Stats card
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.blue[100]!),
            boxShadow: [
              BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10.r),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.file_present,
                      color: const Color(0xFF2563EB),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${summary.imported} Transaksi',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      Text(
                        'Siap untuk diimport',
                        style: TextStyle(
                          color: const Color(0xFF3B82F6),
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Divider(height: 1.h),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengeluaran',
                          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              '${summary.expenseCount}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_downward,
                                size: 8.sp,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1.w, height: 30.h, color: Colors.grey[200]),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pemasukan',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Text(
                                '${summary.incomeCount}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_upward,
                                  size: 8.sp,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Duplicate warning
        if (summary.skippedDuplicates > 0)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFFEF3C7)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: const Color(0xFFD97706),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '${summary.skippedDuplicates} transaksi duplikat ditemukan dan akan dilewati otomatis.',
                    style: TextStyle(
                      color: const Color(0xFF92400E),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: 16.h),

        // Date info
        if (summary.dateFrom != null && summary.dateTo != null)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 12.w),
                Text(
                  'Data dari ${dateFormat.format(summary.dateFrom!)} s/d ${dateFormat.format(summary.dateTo!)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: 40.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 12.sp, color: Colors.grey[400]),
            SizedBox(width: 6.w),
            Text(
              'Data Anda aman dan terenkripsi',
              style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
            ),
          ],
        ),
      ],
    );
  }
}
