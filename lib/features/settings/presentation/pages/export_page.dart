import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/export_service.dart';
import '../../../../data/local/database/app_database.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  int _selectedFormat = 0; // 0: PDF, 1: Excel, 2: CSV
  int _selectedDateFilter =
      0; // 0: Bulan Ini, 1: Bulan Lalu, 2: Tahun Ini, 3: Semua
  bool _includeReceipts = false;
  bool _passwordProtection = false;
  bool _isExporting = false;

  late DateTime _startDate;
  late DateTime _endDate;

  late final ExportService _exportService;

  @override
  void initState() {
    super.initState();
    _exportService = ExportService(locator<AppDatabase>());
    _applyDateFilter(0);
  }

  // ─── Date logic ─────────────────────────────────────────────────────

  /// Returns the last day of a given month/year.
  DateTime _lastDayOfMonth(int year, int month) {
    // The 0th day of the next month = last day of this month
    return DateTime(year, month + 1, 0, 23, 59, 59);
  }

  void _applyDateFilter(int index) {
    final now = DateTime.now();
    switch (index) {
      case 0: // Bulan Ini
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = _lastDayOfMonth(now.year, now.month);
        break;
      case 1: // Bulan Lalu
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        _startDate = DateTime(lastMonth.year, lastMonth.month, 1);
        _endDate = _lastDayOfMonth(lastMonth.year, lastMonth.month);
        break;
      case 2: // Tahun Ini
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      case 3: // Semua
        _startDate = DateTime(2000, 1, 1);
        _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final l10n = context.l10n;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Locale(l10n.dateLocaleCode),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            23,
            59,
            59,
          );
        }
      });
    }
  }

  // ─── Export action ──────────────────────────────────────────────────

  Future<void> _doExport() async {
    final l10n = context.l10n;
    // If password protection is enabled (PDF only), ask for password first
    String? password;
    if (_selectedFormat == 0 && _passwordProtection) {
      password = await _showPasswordDialog();
      if (password == null || password.isEmpty) return; // cancelled
    }

    setState(() => _isExporting = true);

    try {
      final filePath = await _exportService.exportAndShare(
        format: _selectedFormat,
        startDate: _startDate,
        endDate: _endDate,
        includeReceipts: _includeReceipts,
        passwordProtection: _passwordProtection,
        password: password,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.fileSavedSuccess} $filePath'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.exportFailed} $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<String?> _showPasswordDialog() {
    final controller = TextEditingController();
    final l10n = context.l10n;
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.passwordProtectionTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: l10n.enterPasswordHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111111),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(l10n.confirm, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.reportBuilderTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.onSurface, size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.selectFormatHeader),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildFormatCard(
                    0,
                    Icons.picture_as_pdf,
                    const Color(0xFFEF4444),
                    'PDF',
                    l10n.neatReportPdf,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildFormatCard(
                    1,
                    Icons.table_view,
                    const Color(0xFF10B981),
                    'Excel',
                    l10n.processedDataExcel,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildFormatCard(
                    2,
                    Icons.code,
                    const Color(0xFF6B7280),
                    'CSV',
                    l10n.backupCsv,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),
            _buildSectionHeader(l10n.timeRangeHeader),
            SizedBox(height: 12.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(0, l10n.thisMonth),
                  SizedBox(width: 8.w),
                  _buildFilterChip(1, l10n.lastMonth),
                  SizedBox(width: 8.w),
                  _buildFilterChip(2, l10n.thisYear),
                  SizedBox(width: 8.w),
                  _buildFilterChip(3, l10n.allTime),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    l10n.fromDateLabel,
                    _startDate,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildDatePicker(
                    l10n.toDateLabel,
                    _endDate,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),
            _buildSectionHeader(l10n.additionalOptionsHeader),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildToggleItem(
                    icon: Icons.receipt_long,
                    title: l10n.includeReceiptsLabel,
                    subtitle: l10n.includeReceiptsSub,
                    value: _includeReceipts,
                    onChanged: (val) => setState(() => _includeReceipts = val),
                  ),
                  if (_selectedFormat == 0) ...[
                    Divider(height: 1.h, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
                    _buildToggleItem(
                      icon: Icons.lock_outline,
                      title: l10n.passwordProtectionTitle,
                      subtitle: l10n.passwordProtectionSub,
                      value: _passwordProtection,
                      onChanged: (val) =>
                          setState(() => _passwordProtection = val),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, -5.h),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isExporting ? null : _doExport,
          icon: _isExporting
              ? SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(Icons.share, color: Colors.white, size: 24.sp),
          label: Text(
            _isExporting ? l10n.processingExport : l10n.exportAndShare,
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
    );
  }

  // ─── Widget builders ────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2.w,
      ),
    );
  }

  Widget _buildFormatCard(
    int index,
    IconData icon,
    Color color,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedFormat == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedFormat = index;
        // Reset password protection when switching away from PDF
        if (index != 0) _passwordProtection = false;
      }),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          children: [
            if (isSelected)
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 16.sp,
                ),
              )
            else
              SizedBox(height: 16.sp),

            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedDateFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDateFilter = index;
          _applyDateFilter(index);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.onSurface
              : (Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerLow
                  : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF111111) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, {VoidCallback? onTap}) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(fontSize: 10.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              DateFormat('d MMM yyyy', l10n.dateLocaleCode).format(date),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF111111),
          ),
        ],
      ),
    );
  }
}
