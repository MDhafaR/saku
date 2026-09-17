import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../cubit/statistics_state.dart';

class CategoryTransactionsInfoModal extends StatelessWidget {
  final String categoryName;
  final String iconName;
  final Color categoryColor;
  final double totalAmount;
  final double percentage;
  final String? trendValue;
  final bool isTrendUp;
  final List<Transaction> transactions;
  final String period;
  final DateTime targetDate;
  final AppDateTimeRange? customRange;

  const CategoryTransactionsInfoModal({
    super.key,
    required this.categoryName,
    required this.iconName,
    required this.categoryColor,
    required this.totalAmount,
    required this.percentage,
    this.trendValue,
    this.isTrendUp = false,
    required this.transactions,
    required this.period,
    required this.targetDate,
    this.customRange,
  });

  static void show(
    BuildContext context, {
    required String categoryName,
    required String iconName,
    required Color categoryColor,
    required double totalAmount,
    required double percentage,
    String? trendValue,
    bool isTrendUp = false,
    required List<Transaction> transactions,
    required String period,
    required DateTime targetDate,
    AppDateTimeRange? customRange,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CategoryTransactionsInfoModal(
        categoryName: categoryName,
        iconName: iconName,
        categoryColor: categoryColor,
        totalAmount: totalAmount,
        percentage: percentage,
        trendValue: trendValue,
        isTrendUp: isTrendUp,
        transactions: transactions,
        period: period,
        targetDate: targetDate,
        customRange: customRange,
      ),
    );
  }

  String _getPeriodContextLabel(
      String period, DateTime targetDate, AppDateTimeRange? customRange, AppLocalizations l10n) {
    if (l10n.isIndonesian) {
      switch (period.toLowerCase()) {
        case 'yearly':
          return 'tahun ${DateFormat('yyyy', l10n.dateLocaleCode).format(targetDate)}';
        case 'daily':
          return 'hari ini (${DateFormat('d MMMM yyyy', l10n.dateLocaleCode).format(targetDate)})';
        case 'monthly':
          return 'bulan ${DateFormat('MMMM yyyy', l10n.dateLocaleCode).format(targetDate)}';
        case 'custom':
          if (customRange != null) {
            final s = DateFormat('dd/MM/yyyy', l10n.dateLocaleCode).format(customRange.start);
            final e = DateFormat('dd/MM/yyyy', l10n.dateLocaleCode).format(customRange.end);
            return 'rentang waktu ($s - $e)';
          }
          return 'rentang waktu terpilih';
        case 'all':
        default:
          return 'seluruh riwayat keuangan';
      }
    } else {
      switch (period.toLowerCase()) {
        case 'yearly':
          return 'year ${DateFormat('yyyy', l10n.dateLocaleCode).format(targetDate)}';
        case 'daily':
          return 'today (${DateFormat('d MMMM yyyy', l10n.dateLocaleCode).format(targetDate)})';
        case 'monthly':
          return 'month ${DateFormat('MMMM yyyy', l10n.dateLocaleCode).format(targetDate)}';
        case 'custom':
          if (customRange != null) {
            final s = DateFormat('dd/MM/yyyy', l10n.dateLocaleCode).format(customRange.start);
            final e = DateFormat('dd/MM/yyyy', l10n.dateLocaleCode).format(customRange.end);
            return 'date range ($s - $e)';
          }
          return 'selected date range';
        case 'all':
        default:
          return 'all-time financial history';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor =
        isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB);
    final borderColor =
        isDark ? cs.outline.withValues(alpha: 0.15) : const Color(0xFFE5E7EB);

    final periodCtx = _getPeriodContextLabel(period, targetDate, customRange, l10n);

    // Calculations
    final int count = transactions.length;
    final double avgPerTx = count > 0 ? totalAmount / count : 0;

    Transaction? highestTx;
    if (transactions.isNotEmpty) {
      highestTx = transactions.reduce((a, b) => a.amount > b.amount ? a : b);
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
          child: Column(
            children: [
              // Fixed Header with Handle Bar
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 16.w, 14.h),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28.r)),
                  border: Border(
                    bottom: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    // Header Row
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: CategoryIcon(
                            iconName: iconName,
                            color: categoryColor,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.isIndonesian ? 'Rincian' : 'Details'}: $categoryName',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                l10n.isIndonesian
                                    ? 'Analisis transaksi pada $periodCtx'
                                    : 'Transaction analysis for $periodCtx',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: cs.onSurfaceVariant,
                            size: 20.sp,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metric Overview Cards (3-column grid)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.isIndonesian ? 'Total Biaya' : 'Total Expense',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      CurrencyFormatter.formatRupiah(totalAmount),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: categoryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.transactionFrequency,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      l10n.transactionCount(count),
                                      style: TextStyle(
                                        fontSize: 13.sp,
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
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.isIndonesian ? 'Rata-rata' : 'Average',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      CurrencyFormatter.formatRupiah(avgPerTx),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Section: Highest Transaction (Peak Spending)
                      if (highestTx != null) ...[
                        Text(
                          l10n.isIndonesian
                              ? 'Transaksi Terbesar (Peak Spending)'
                              : 'Largest Transaction (Peak Spending)',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.keyboard_double_arrow_up_rounded,
                                  color: const Color(0xFFEF4444),
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      highestTx.description.isNotEmpty
                                          ? highestTx.description
                                          : '${l10n.isIndonesian ? 'Transaksi' : 'Transaction'} $categoryName',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: cs.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      DateFormat('d MMMM yyyy', l10n.dateLocaleCode)
                                          .format(highestTx.transactionDate),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '-${CurrencyFormatter.formatRupiah(highestTx.amount)}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14.h),
                      ],

                      // Section: Budget Contribution & Trend
                      Text(
                        l10n.isIndonesian
                            ? 'Porsi & Tren Pengeluaran'
                            : 'Portion & Spending Trend',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.isIndonesian
                                      ? 'Kontribusi Anggaran'
                                      : 'Budget Share',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    '${percentage.toStringAsFixed(1)}% ${l10n.shareOfTotalExpense}',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: categoryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            // Progress bar
                            Stack(
                              children: [
                                Container(
                                  height: 6.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: cs.outlineVariant.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(3.r),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: (percentage / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    height: 6.h,
                                    decoration: BoxDecoration(
                                      color: categoryColor,
                                      borderRadius: BorderRadius.circular(3.r),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (trendValue != null) ...[
                              SizedBox(height: 8.h),
                              Text(
                                isTrendUp
                                    ? (l10n.isIndonesian
                                        ? 'Pengeluaran di kategori ini meningkat $trendValue dibanding periode sebelumnya.'
                                        : 'Expenses in this category increased by $trendValue compared to previous period.')
                                    : (l10n.isIndonesian
                                        ? 'Pengeluaran di kategori ini berhasil ditekan sebesar $trendValue dibanding periode sebelumnya. Terus pertahankan!'
                                        : 'Expenses in this category decreased by $trendValue compared to previous period. Keep it up!'),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: cs.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Section: Smart Financial Tip
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              color: const Color(0xFF6366F1),
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.isIndonesian
                                        ? 'Tips Manajemen Kategori'
                                        : 'Category Management Tips',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6366F1),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    percentage > 30
                                        ? (l10n.isIndonesian
                                            ? 'Kategori $categoryName menyerap lebih dari 30% anggaran Anda. Evaluasi apakah ada pos pengeluaran yang dapat dihemat atau dinegosiasikan.'
                                            : 'The $categoryName category takes over 30% of your total budget. Review if certain expenses can be trimmed or substituted.')
                                        : (l10n.isIndonesian
                                            ? 'Alokasi pengeluaran $categoryName terpantau proporsional. Pantau terus frekuensi transaksi agar pengeluaran tetap terkendali.'
                                            : 'The $categoryName category allocation remains well-proportioned. Keep monitoring transaction frequency to stay within budget.'),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: cs.onSurface,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18.h),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.understood,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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
}
