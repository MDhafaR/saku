import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/statistics_state.dart';

class IncomeExpenseChartInfoModal extends StatelessWidget {
  final List<ChartDataPoint> chartData;
  final String period;
  final DateTime targetDate;
  final AppDateTimeRange? customRange;
  final double totalIncome;
  final double totalExpense;

  const IncomeExpenseChartInfoModal({
    super.key,
    required this.chartData,
    required this.period,
    required this.targetDate,
    this.customRange,
    required this.totalIncome,
    required this.totalExpense,
  });

  static void show(
    BuildContext context, {
    required List<ChartDataPoint> chartData,
    required String period,
    required DateTime targetDate,
    AppDateTimeRange? customRange,
    required double totalIncome,
    required double totalExpense,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IncomeExpenseChartInfoModal(
        chartData: chartData,
        period: period,
        targetDate: targetDate,
        customRange: customRange,
        totalIncome: totalIncome,
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

  String _formatPointDate(DateTime date, String period) {
    switch (period.toLowerCase()) {
      case 'yearly':
      case 'all':
        return DateFormat('MMMM yyyy', 'id_ID').format(date);
      case 'daily':
        return DateFormat('HH:mm', 'id_ID').format(date);
      case 'monthly':
      case 'custom':
      default:
        return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    }
  }

  String _formatPointDateBadge(DateTime date, String period) {
    switch (period.toLowerCase()) {
      case 'yearly':
      case 'all':
        return DateFormat('MMM yyyy', 'id_ID').format(date);
      case 'daily':
        return DateFormat('HH:mm', 'id_ID').format(date);
      case 'monthly':
      case 'custom':
      default:
        return DateFormat('d MMM yyyy', 'id_ID').format(date);
    }
  }

  String _getTemporalPreposition(String period) {
    switch (period.toLowerCase()) {
      case 'yearly':
      case 'all':
        return 'pada bulan';
      case 'daily':
        return 'pada pukul';
      case 'monthly':
      case 'custom':
      default:
        return 'pada tanggal';
    }
  }

  String _getPeriodContextLabel(String period, DateTime targetDate, AppDateTimeRange? customRange) {
    switch (period.toLowerCase()) {
      case 'yearly':
        return 'grafik tahun ${DateFormat('yyyy', 'id_ID').format(targetDate)}';
      case 'daily':
        return 'grafik harian ${DateFormat('d MMMM yyyy', 'id_ID').format(targetDate)}';
      case 'monthly':
        return 'grafik bulan ${DateFormat('MMMM yyyy', 'id_ID').format(targetDate)}';
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

    // 1. Calculate Peak Income and Peak Expense from real chartData
    ChartDataPoint? peakIncomePoint;
    double maxIncome = 0;
    ChartDataPoint? peakExpensePoint;
    double maxExpense = 0;

    for (final pt in chartData) {
      if (pt.income > maxIncome) {
        maxIncome = pt.income;
        peakIncomePoint = pt;
      }
      if (pt.expense > maxExpense) {
        maxExpense = pt.expense;
        peakExpensePoint = pt;
      }
    }

    final double netBalance = totalIncome - totalExpense;
    final bool isSurplus = netBalance >= 0;

    // Smart contextual prepositions and context labels
    final prep = _getTemporalPreposition(period);
    final periodCtx = _getPeriodContextLabel(period, targetDate, customRange);

    // Dynamic narrative construction
    final String narrativeText;
    if (maxIncome > 0 && maxExpense > 0) {
      final incDate = _formatPointDate(peakIncomePoint!.date, period);
      final expDate = _formatPointDate(peakExpensePoint!.date, period);
      narrativeText =
          'Berdasarkan $periodCtx, garis hijau sempat melonjak mencapai puncaknya di angka Rp ${CurrencyFormatter.format(maxIncome.toStringAsFixed(0))} $prep $incDate. Sementara itu, titik pengeluaran tertinggi (garis merah) berada di angka Rp ${CurrencyFormatter.format(maxExpense.toStringAsFixed(0))} $prep $expDate.';
    } else if (maxIncome > 0 && maxExpense == 0) {
      final incDate = _formatPointDate(peakIncomePoint!.date, period);
      narrativeText =
          'Berdasarkan $periodCtx, garis hijau mencapai puncaknya di angka Rp ${CurrencyFormatter.format(maxIncome.toStringAsFixed(0))} $prep $incDate, tanpa adanya catatan pengeluaran.';
    } else if (maxExpense > 0 && maxIncome == 0) {
      final expDate = _formatPointDate(peakExpensePoint!.date, period);
      narrativeText =
          'Berdasarkan $periodCtx, garis merah mencapai titik belanja terbesar di angka Rp ${CurrencyFormatter.format(maxExpense.toStringAsFixed(0))} $prep $expDate, tanpa adanya catatan pemasukan.';
    } else {
      narrativeText =
          'Belum ada riwayat transaksi pemasukan maupun pengeluaran pada $periodCtx sehingga kurva tampak mendatar di angka 0.';
    }

    final periodLabel = _formatPeriodTitle(period, targetDate, customRange);

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
                      color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.insights_rounded,
                      color: const Color(0xFF6366F1),
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Income vs Expense',
                          style: TextStyle(
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Analisis Riil • $periodLabel',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6366F1),
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
                      // SEKSI 1: ANALISIS DATA RIIL PERIODE INI
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: const Color(0xFF6366F1),
                                  size: 16.sp,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Temuan Nyata dari Grafik Anda',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            // 2 Cards: Puncak Pemasukan vs Puncak Pengeluaran
                            Row(
                              children: [
                                // Puncak Pemasukan
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? cs.surfaceContainerLow
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(3.w),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10B981)
                                                    .withValues(alpha: 0.15),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.trending_up_rounded,
                                                color: const Color(0xFF10B981),
                                                size: 12.sp,
                                              ),
                                            ),
                                            SizedBox(width: 5.w),
                                            Expanded(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Puncak Pemasukan',
                                                  style: TextStyle(
                                                    fontSize: 10.5.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            maxIncome > 0
                                                ? 'Rp ${CurrencyFormatter.format(maxIncome.toStringAsFixed(0))}'
                                                : 'Rp 0',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            peakIncomePoint != null && maxIncome > 0
                                                ? _formatPointDateBadge(
                                                    peakIncomePoint.date,
                                                    period,
                                                  )
                                                : 'Tidak ada data',
                                            style: TextStyle(
                                              fontSize: 10.5.sp,
                                              fontWeight: FontWeight.w600,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),

                                // Puncak Pengeluaran
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? cs.surfaceContainerLow
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFFEF4444)
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(3.w),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEF4444)
                                                    .withValues(alpha: 0.15),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.trending_down_rounded,
                                                color: const Color(0xFFEF4444),
                                                size: 12.sp,
                                              ),
                                            ),
                                            SizedBox(width: 5.w),
                                            Expanded(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Puncak Pengeluaran',
                                                  style: TextStyle(
                                                    fontSize: 10.5.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            maxExpense > 0
                                                ? 'Rp ${CurrencyFormatter.format(maxExpense.toStringAsFixed(0))}'
                                                : 'Rp 0',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFFEF4444),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            peakExpensePoint != null &&
                                                    maxExpense > 0
                                                ? _formatPointDateBadge(
                                                    peakExpensePoint.date,
                                                    period,
                                                  )
                                                : 'Tidak ada data',
                                            style: TextStyle(
                                              fontSize: 10.5.sp,
                                              fontWeight: FontWeight.w600,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
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

                      // SEKSI 2: PANDUAN LEGENDA WARNA
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12.w,
                                  height: 12.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Garis / Batang Hijau: Pemasukan (Income)',
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 20.w, top: 4.h, bottom: 8.h),
                              child: Text(
                                'Menunjukkan laju dan akumulasi uang yang masuk ke rekening pada setiap titik waktu. Total: Rp ${CurrencyFormatter.format(totalIncome.toStringAsFixed(0))}.',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: cs.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            Divider(
                              height: 12.h,
                              color: borderColor,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 12.w,
                                  height: 12.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Garis / Batang Merah: Pengeluaran (Expense)',
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20.w, top: 4.h),
                              child: Text(
                                'Menunjukkan total biaya konsumsi, tagihan, dan belanja yang dikeluarkan pada setiap titik waktu. Total: Rp ${CurrencyFormatter.format(totalExpense.toStringAsFixed(0))}.',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: cs.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // SEKSI 3: SURPLUS VS DEFISIT STATUS
                      _buildInfoSection(
                        context,
                        icon: isSurplus
                            ? Icons.savings_rounded
                            : Icons.warning_amber_rounded,
                        iconColor: isSurplus
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        title: isSurplus
                            ? 'Status Riil: Surplus Kas (+Rp ${CurrencyFormatter.format(netBalance.abs().toStringAsFixed(0))})'
                            : 'Status Riil: Defisit Kas (-Rp ${CurrencyFormatter.format(netBalance.abs().toStringAsFixed(0))})',
                        description: isSurplus
                            ? 'Pada periode ini total pemasukan Anda lebih tinggi dari pengeluaran. Garis hijau dominan berada di atas garis merah, menandakan ada ruang saldo yang berhasil disisihkan.'
                            : 'Pada periode ini total pengeluaran Anda melampaui total pemasukan. Garis merah berada di atas garis hijau, menandakan pengeluaran memakan tabungan saldo sebelumnya.',
                        bgColor: (isSurplus
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            .withValues(alpha: 0.08),
                        borderColor: (isSurplus
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            .withValues(alpha: 0.25),
                      ),
                      SizedBox(height: 10.h),

                      // SEKSI 4: TIPS MEMBACA MODE GRAFIK
                      _buildInfoSection(
                        context,
                        icon: Icons.bar_chart_rounded,
                        iconColor: const Color(0xFF0EA5E9),
                        title: 'Mode Grafik Garis & Batang',
                        description:
                            'Gunakan tombol di pojok kanan atas grafik untuk berganti mode:\n'
                            '• Line Chart: Cocok untuk melihat tren kontinuitas dan kelancaran arus kas.\n'
                            '• Bar Chart: Memudahkan perbandingan volume nominal pemasukan vs pengeluaran secara berdampingan.',
                        bgColor: cardBgColor,
                        borderColor: borderColor,
                      ),
                      SizedBox(height: 10.h),

                      // SEKSI 5: TIPS CERDAS
                      _buildInfoSection(
                        context,
                        icon: Icons.lightbulb_outline_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Tips Cerdas',
                        description:
                            'Perhatikan titik lonjakan (spike) tajam pada garis merah untuk mendeteksi pengeluaran tak terduga, dan usahakan garis hijau selalu konsisten berada di atas garis merah.',
                        bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                        borderColor:
                            const Color(0xFFF59E0B).withValues(alpha: 0.25),
                      ),
                      SizedBox(height: 16.h),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
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
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
