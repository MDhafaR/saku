import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../statistics/presentation/cubit/statistics_state.dart';

class FinancialMetricInfoModal extends StatelessWidget {
  final String metricType; // 'income', 'expense', 'total'
  final double currentAmount;
  final double prevAmount;
  final String percentageStr;
  final Color percentageColor;
  final bool isMasked;
  final String period;
  final DateTime targetDate;
  final AppDateTimeRange? customRange;

  const FinancialMetricInfoModal({
    super.key,
    required this.metricType,
    required this.currentAmount,
    required this.prevAmount,
    required this.percentageStr,
    required this.percentageColor,
    this.isMasked = false,
    this.period = 'Monthly',
    required this.targetDate,
    this.customRange,
  });

  static void show(
    BuildContext context, {
    required String metricType,
    required double currentAmount,
    required double prevAmount,
    required String percentageStr,
    required Color percentageColor,
    bool isMasked = false,
    String period = 'Monthly',
    DateTime? targetDate,
    AppDateTimeRange? customRange,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FinancialMetricInfoModal(
        metricType: metricType,
        currentAmount: currentAmount,
        prevAmount: prevAmount,
        percentageStr: percentageStr,
        percentageColor: percentageColor,
        isMasked: isMasked,
        period: period,
        targetDate: targetDate ?? DateTime.now(),
        customRange: customRange,
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
        return 'Tahun ${DateFormat('yyyy', 'id_ID').format(date)}';
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

  String _getCurrentPeriodLabel(String period, DateTime date) {
    switch (period.toLowerCase()) {
      case 'yearly':
        return 'Tahun Ini (${date.year})';
      case 'monthly':
        return 'Bulan Ini (${DateFormat('MMM', 'id_ID').format(date)})';
      case 'daily':
        return 'Hari Ini';
      case 'custom':
        return 'Rentang Ini';
      case 'all':
      default:
        return 'Periode Ini';
    }
  }

  String _getPrevPeriodLabel(String period, DateTime date) {
    switch (period.toLowerCase()) {
      case 'yearly':
        return 'Tahun Lalu (${date.year - 1})';
      case 'monthly':
        return 'Bulan Lalu';
      case 'daily':
        return 'Kemarin';
      case 'custom':
        return 'Rentang Lalu';
      case 'all':
      default:
        return 'Periode Lalu';
    }
  }

  String _getComparisonLabel(String period, DateTime date) {
    switch (period.toLowerCase()) {
      case 'yearly':
        return 'tahun sebelumnya (${date.year - 1})';
      case 'monthly':
        return 'bulan sebelumnya';
      case 'daily':
        return 'hari kemarin';
      case 'custom':
        return 'rentang waktu sebelumnya';
      case 'all':
      default:
        return 'periode sebelumnya';
    }
  }

  String _getCurrentContextLabel(String period, DateTime date) {
    switch (period.toLowerCase()) {
      case 'yearly':
        return 'di tahun ${date.year}';
      case 'monthly':
        return 'di bulan ${DateFormat('MMMM yyyy', 'id_ID').format(date)}';
      case 'daily':
        return 'pada hari ini (${DateFormat('d MMMM yyyy', 'id_ID').format(date)})';
      case 'custom':
        return 'pada rentang waktu ini';
      case 'all':
      default:
        return 'sepanjang riwayat tercatat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String title;
    final IconData icon;
    final Color themeColor;
    final String metricDefinition;
    final String percentageExplanation;
    final String financialTip;

    final double delta = currentAmount - prevAmount;
    final bool isDeltaPositive = delta >= 0;

    final comparisonLabel = _getComparisonLabel(period, targetDate);
    final currentCtx = _getCurrentContextLabel(period, targetDate);
    final currentPeriodColLabel = _getCurrentPeriodLabel(period, targetDate);
    final prevPeriodColLabel = _getPrevPeriodLabel(period, targetDate);

    switch (metricType.toLowerCase()) {
      case 'income':
        title = 'Pemasukan (Income)';
        icon = Icons.trending_up;
        themeColor = const Color(0xFF10B981);
        metricDefinition =
            'Menggambarkan seluruh akumulasi arus kas masuk (gaji, bisnis, transfer masuk, dividen, freelance, dll.) yang tercatat $currentCtx.';

        if (delta > 0) {
          percentageExplanation =
              'Persentase $percentageStr menandakan pemasukan Anda $currentCtx meningkat sebesar $percentageStr dibanding $comparisonLabel (+Rp ${CurrencyFormatter.format(delta.abs().toStringAsFixed(0))}). Ini tren positif!';
        } else if (delta < 0) {
          percentageExplanation =
              'Persentase $percentageStr menandakan pemasukan Anda $currentCtx berkurang sebesar $percentageStr dibanding $comparisonLabel (-Rp ${CurrencyFormatter.format(delta.abs().toStringAsFixed(0))}).';
        } else {
          percentageExplanation =
              'Persentase $percentageStr menandakan pemasukan Anda $currentCtx stabil dan sama dengan $comparisonLabel.';
        }

        financialTip =
            'Pertahankan kestabilan pemasukan dan usahakan alokasikan minimal 20% pemasukan untuk tabungan atau dana darurat.';
        break;

      case 'expense':
        title = 'Pengeluaran (Expense)';
        icon = Icons.trending_down;
        themeColor = const Color(0xFFEF4444);
        metricDefinition =
            'Menggambarkan total biaya hidup, konsumsi harian, tagihan berkala, belanja, dan biaya lainnya yang dikeluarkan $currentCtx.';

        if (delta < 0) {
          percentageExplanation =
              'Persentase $percentageStr (berwarna hijau) menandakan pengeluaran Anda $currentCtx berhasil ditekan / lebih hemat sebesar $percentageStr dibanding $comparisonLabel (-Rp ${CurrencyFormatter.format(delta.abs().toStringAsFixed(0))}). Manajemen budget Anda sangat efektif!';
        } else if (delta > 0) {
          percentageExplanation =
              'Persentase $percentageStr (berwarna merah) menandakan pengeluaran Anda $currentCtx naik membengkak $percentageStr dibanding $comparisonLabel (+Rp ${CurrencyFormatter.format(delta.abs().toStringAsFixed(0))}). Evaluasi pos pengeluaran terbesar Anda.';
        } else {
          percentageExplanation =
              'Persentase $percentageStr menandakan pengeluaran Anda $currentCtx sama persis dengan $comparisonLabel.';
        }

        financialTip =
            'Gunakan rumus 50/30/20 (50% Kebutuhan Pokok, 30% Keinginan, 20% Tabungan/Investasi) untuk menjaga arus pengeluaran tetap sehat.';
        break;

      case 'total':
      default:
        title = 'Arus Kas Bersih (Total Net)';
        icon = Icons.account_balance_wallet;
        themeColor = const Color(0xFF6366F1);
        metricDefinition =
            'Menggambarkan sisa uang riil yang Anda miliki dari selisih antara Pemasukan dan Pengeluaran (Net Cash Flow) $currentCtx. Nilai positif berarti Anda berhasil menabung (surplus), sedangkan nilai negatif berarti defisit kas.';

        if (currentAmount >= 0) {
          percentageExplanation =
              'Arus kas Anda $currentCtx berada dalam kondisi Surplus Kas (+Rp ${CurrencyFormatter.format(currentAmount.toStringAsFixed(0))}). Persentase $percentageStr membandingkan performa tabungan bersih Anda terhadap $comparisonLabel.';
        } else {
          percentageExplanation =
              'Arus kas Anda $currentCtx berada dalam kondisi Defisit Kas (-Rp ${CurrencyFormatter.format(currentAmount.abs().toStringAsFixed(0))}) karena total pengeluaran melampaui pemasukan.';
        }

        financialTip =
            'Fokus utama adalah menjaga angka total ini selalu surplus (berwarna hijau) setiap akhir periode agar kekayaan bersih Anda bertumbuh.';
        break;
    }

    final cardBgColor = isDark
        ? cs.surfaceContainerLow
        : const Color(0xFFF9FAFB);
    final borderColor = isDark
        ? cs.outline.withValues(alpha: 0.15)
        : const Color(0xFFE5E7EB);

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
                      color: themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(icon, color: themeColor, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
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
                            color: themeColor,
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
                      // Metrics Comparison Grid
                      Row(
                        children: [
                          // Card 1: Periode Ini
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      currentPeriodColLabel,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      isMasked
                                          ? '••••••'
                                          : 'Rp ${CurrencyFormatter.format(currentAmount.abs().toStringAsFixed(0))}',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w800,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Card 2: Periode Lalu
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      prevPeriodColLabel,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      isMasked
                                          ? '••••••'
                                          : 'Rp ${CurrencyFormatter.format(prevAmount.abs().toStringAsFixed(0))}',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w800,
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
                      SizedBox(height: 8.h),

                      // Selisih & Persentase Bar
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Selisih: ',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  isMasked
                                      ? '••••••'
                                      : '${isDeltaPositive ? '+' : '-'}Rp ${CurrencyFormatter.format(delta.abs().toStringAsFixed(0))}',
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: percentageColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    percentageStr.startsWith('-')
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    size: 13.sp,
                                    color: percentageColor,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    percentageStr,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: percentageColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Card Insight 1: Arti Metrik
                      _buildInfoSection(
                        context,
                        icon: Icons.info_outline_rounded,
                        iconColor: cs.primary,
                        title: 'Definisi Metrik',
                        description: metricDefinition,
                        bgColor: cardBgColor,
                        borderColor: borderColor,
                      ),
                      SizedBox(height: 10.h),

                      // Card Insight 2: Arti Persentase
                      _buildInfoSection(
                        context,
                        icon: Icons.insights_rounded,
                        iconColor: themeColor,
                        title: 'Arti Persentase ($percentageStr)',
                        description: percentageExplanation,
                        bgColor: themeColor.withValues(alpha: 0.08),
                        borderColor: themeColor.withValues(alpha: 0.25),
                      ),
                      SizedBox(height: 10.h),

                      // Card Insight 3: Tips Finansial
                      _buildInfoSection(
                        context,
                        icon: Icons.lightbulb_outline_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Tips Cerdas',
                        description: financialTip,
                        bgColor: cardBgColor,
                        borderColor: borderColor,
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
