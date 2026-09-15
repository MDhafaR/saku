import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/statistics_state.dart';
import '../pages/category_detail_page.dart';

class CategoryBreakdownInfoModal extends StatelessWidget {
  final List<CategoryBreakdownItem> categories;
  final String period;
  final DateTime targetDate;
  final AppDateTimeRange? customRange;
  final double totalExpense;

  const CategoryBreakdownInfoModal({
    super.key,
    required this.categories,
    required this.period,
    required this.targetDate,
    this.customRange,
    required this.totalExpense,
  });

  static void show(
    BuildContext context, {
    required List<CategoryBreakdownItem> categories,
    required String period,
    required DateTime targetDate,
    AppDateTimeRange? customRange,
    required double totalExpense,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CategoryBreakdownInfoModal(
        categories: categories,
        period: period,
        targetDate: targetDate,
        customRange: customRange,
        totalExpense: totalExpense,
      ),
    );
  }

  String _formatPeriodTitle(String period, DateTime date, AppDateTimeRange? range) {
    switch (period.toLowerCase()) {
      case 'daily':
        return DateFormat('d MMMM yyyy', 'id_ID').format(date);
      case 'monthly':
        return DateFormat('MMMM yyyy', 'id_ID').format(date);
      case 'yearly':
        return DateFormat('yyyy', 'id_ID').format(date);
      case 'custom':
        if (range != null) {
          final s = DateFormat('dd/MM/yyyy', 'id_ID').format(range.start);
          final e = DateFormat('dd/MM/yyyy', 'id_ID').format(range.end);
          return '$s - $e';
        }
        return 'Kustom';
      case 'all':
      default:
        return 'Semua Waktu';
    }
  }

  String _getPeriodContextLabel(String period, DateTime targetDate, AppDateTimeRange? customRange) {
    switch (period.toLowerCase()) {
      case 'yearly':
        return 'tahun ${DateFormat('yyyy', 'id_ID').format(targetDate)}';
      case 'daily':
        return 'hari ini (${DateFormat('d MMMM yyyy', 'id_ID').format(targetDate)})';
      case 'monthly':
        return 'bulan ${DateFormat('MMMM yyyy', 'id_ID').format(targetDate)}';
      case 'custom':
        if (customRange != null) {
          final s = DateFormat('dd/MM/yyyy', 'id_ID').format(customRange.start);
          final e = DateFormat('dd/MM/yyyy', 'id_ID').format(customRange.end);
          return 'rentang waktu ($s - $e)';
        }
        return 'rentang waktu terpilih';
      case 'all':
      default:
        return 'seluruh riwayat keuangan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor =
        isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB);
    final borderColor =
        isDark ? cs.outline.withValues(alpha: 0.15) : const Color(0xFFE5E7EB);

    final periodLabel = _formatPeriodTitle(period, targetDate, customRange);
    final periodCtx = _getPeriodContextLabel(period, targetDate, customRange);

    // Dynamic real data analysis
    final bool hasData = categories.isNotEmpty && totalExpense > 0;
    final topCategory = hasData ? categories.first : null;
    final secondCategory = (categories.length > 1) ? categories[1] : null;

    final String narrativeText;
    if (hasData && topCategory != null) {
      if (secondCategory != null) {
        narrativeText =
            'Pada $periodCtx, pengeluaran Anda didominasi oleh kategori ${topCategory.name} (${topCategory.percentage.toStringAsFixed(1)}% • Rp ${CurrencyFormatter.format(topCategory.amount.toStringAsFixed(0))}) dan disusul oleh ${secondCategory.name} (${secondCategory.percentage.toStringAsFixed(1)}%). Sebanyak ${categories.length} kategori pengeluaran aktif tercatat.';
      } else {
        narrativeText =
            'Seluruh pengeluaran Anda pada $periodCtx terkonsentrasi 100% pada kategori ${topCategory.name} sebesar Rp ${CurrencyFormatter.format(topCategory.amount.toStringAsFixed(0))}.';
      }
    } else {
      narrativeText =
          'Belum ada transaksi pengeluaran yang tercatat pada $periodCtx.';
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.84,
      minChildSize: 0.35,
      maxChildSize: 0.88,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.5.h,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Header Row (Fixed at top)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.pie_chart_rounded,
                      color: const Color(0xFFF97316),
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category Breakdown',
                          style: TextStyle(
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Komposisi Pengeluaran • $periodLabel',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // Scrollable Body connected to scrollController
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SEKSI 1: TEMUAN DATA RIIL
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFFF97316).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: const Color(0xFFF97316),
                                  size: 16.sp,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Temuan Nyata Distribusi Belanja',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            // 2 Columns: Kategori Terbesar vs Total Kategori Aktif
                            Row(
                              children: [
                                // Pos Terbesar
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? cs.surfaceContainerLow
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFFF97316)
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pos Terbesar',
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          topCategory != null
                                              ? topCategory.name
                                              : 'Belum ada',
                                          style: TextStyle(
                                            fontSize: 13.5.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFFF97316),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          topCategory != null
                                              ? '${topCategory.percentage.toStringAsFixed(1)}% (Rp ${CurrencyFormatter.format(topCategory.amount.toStringAsFixed(0))})'
                                              : 'Rp 0',
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: cs.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),

                                // Total Kategori Aktif
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? cs.surfaceContainerLow
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: cs.primary.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Kategori Aktif',
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '${categories.length} Kategori',
                                          style: TextStyle(
                                            fontSize: 13.5.sp,
                                            fontWeight: FontWeight.w800,
                                            color: cs.primary,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'Total: Rp ${CurrencyFormatter.format(totalExpense.toStringAsFixed(0))}',
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: cs.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            // Narasi Rangkuman Real
                            Text(
                              narrativeText,
                              style: TextStyle(
                                fontSize: 12.sp,
                                height: 1.45,
                                color: cs.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // SEKSI 2: PANDUAN MEMBACA DIAGRAM DONUT
                      _buildInfoSection(
                        context,
                        icon: Icons.donut_large_rounded,
                        iconColor: const Color(0xFFF97316),
                        title: 'Cara Membaca Diagram Donat',
                        description:
                            '• Pembagian Warna: Setiap potongan busur warna mewakili satu kategori pengeluaran tertentu.\n'
                            '• Luas Potongan: Semakin lebar lengkungan busur, semakin besar persentase anggaran belanja yang diserap oleh kategori tersebut.\n'
                            '• Angka di Tengah: Menunjukkan total nilai seluruh pengeluaran yang teragregasi pada periode aktif.',
                        bgColor: cardBgColor,
                        borderColor: borderColor,
                      ),
                      SizedBox(height: 10.h),

                      // SEKSI 3: TIPS EVALUASI POS BOCOR HALUS
                      _buildInfoSection(
                        context,
                        icon: Icons.lightbulb_outline_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Tips Budgeting & Deteksi Pos Bocor',
                        description:
                            '• Waspadai jika 1 kategori menghabiskan lebih dari 40-50% total anggaran belanja bulanan Anda.\n'
                            '• Tekan pos sekunder dengan frekuensi transaksi tinggi untuk menghentikan efek "bocor halus" pada keuangan harian.',
                        bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                        borderColor:
                            const Color(0xFFF59E0B).withValues(alpha: 0.25),
                      ),
                      SizedBox(height: 16.h),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 46.h,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryDetailPage(
                                        period: period,
                                        targetDate: targetDate,
                                        customRange: customRange,
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: cs.onSurface,
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                child: Text(
                                  'Lihat Rincian',
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: SizedBox(
                              height: 46.h,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.onSurface,
                                  foregroundColor: cs.surface,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                child: Text(
                                  'Mengerti',
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required Color bgColor,
    required Color borderColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.4,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
