import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/statistics_state.dart';

class TopCategoriesInfoModal extends StatelessWidget {
  final List<CategoryBreakdownItem> categories;
  final String period;
  final DateTime targetDate;
  final AppDateTimeRange? customRange;
  final double totalExpense;

  const TopCategoriesInfoModal({
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
      builder: (ctx) => TopCategoriesInfoModal(
        categories: categories,
        period: period,
        targetDate: targetDate,
        customRange: customRange,
        totalExpense: totalExpense,
      ),
    );
  }

  String _formatPeriodTitle(
      String period, DateTime date, AppDateTimeRange? range, AppLocalizations l10n) {
    switch (period.toLowerCase()) {
      case 'daily':
        return DateFormat('d MMMM yyyy', l10n.dateLocaleCode).format(date);
      case 'monthly':
        return DateFormat('MMMM yyyy', l10n.dateLocaleCode).format(date);
      case 'yearly':
        return DateFormat('yyyy', l10n.dateLocaleCode).format(date);
      case 'custom':
        if (range != null) {
          final s = DateFormat('dd/MM/yyyy', l10n.dateLocaleCode).format(range.start);
          final e = DateFormat('dd/MM/yyyy', l10n.dateLocaleCode).format(range.end);
          return '$s - $e';
        }
        return l10n.periodCustom;
      case 'all':
      default:
        return l10n.periodAll;
    }
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

    final periodLabel = _formatPeriodTitle(period, targetDate, customRange, l10n);
    final periodCtx = _getPeriodContextLabel(period, targetDate, customRange, l10n);

    final bool hasData = categories.isNotEmpty && totalExpense > 0;
    final top3 = categories.take(3).toList();
    final double top3Total = top3.fold(0.0, (sum, item) => sum + item.amount);
    final double top3Percentage =
        totalExpense > 0 ? (top3Total / totalExpense) * 100 : 0.0;

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
                      color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.leaderboard_rounded,
                      color: const Color(0xFF0D9488),
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.topCategories,
                          style: TextStyle(
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${l10n.spendingRank} • $periodLabel',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0D9488),
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
                      // SEKSI 1: KONSENTRASI PENGELUARAN TERATAS
                      if (hasData) ...[
                        Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0D9488).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: const Color(0xFF0D9488)
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    color: const Color(0xFF0D9488),
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    l10n.isIndonesian
                                        ? 'Konsentrasi 3 Kategori Teratas'
                                        : 'Top 3 Category Concentration',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                l10n.isIndonesian
                                    ? 'Pada $periodCtx, sebanyak ${top3Percentage.toStringAsFixed(1)}% dari seluruh pengeluaran Anda (${CurrencyFormatter.formatRupiah(top3Total)}) terkonsentrasi pada ${top3.length} kategori berikut:'
                                    : 'During $periodCtx, ${top3Percentage.toStringAsFixed(1)}% of your total expenses (${CurrencyFormatter.formatRupiah(top3Total)}) is concentrated in the following ${top3.length} categories:',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: cs.onSurface,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 10.h),

                              // Item Peringkat
                              ...List.generate(top3.length, (index) {
                                final item = top3[index];
                                final rank = index + 1;
                                final medalColor = rank == 1
                                    ? const Color(0xFFF59E0B)
                                    : (rank == 2
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFFB45309));

                                return Container(
                                  margin: EdgeInsets.only(bottom: 6.h),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? cs.surfaceContainerLow
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 22.w,
                                        height: 22.w,
                                        decoration: BoxDecoration(
                                          color: medalColor.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '#$rank',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w800,
                                            color: medalColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: TextStyle(
                                                fontSize: 12.5.sp,
                                                fontWeight: FontWeight.w700,
                                                color: cs.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              l10n.transactionCount(item.transactionCount),
                                              style: TextStyle(
                                                fontSize: 10.5.sp,
                                                color: cs.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            CurrencyFormatter.formatRupiah(item.amount),
                                            style: TextStyle(
                                              fontSize: 12.5.sp,
                                              fontWeight: FontWeight.w800,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                          Text(
                                            '${item.percentage.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              fontSize: 10.5.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFFEF4444),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],

                      // SEKSI 2: FUNGSI DAFTAR TOP CATEGORIES
                      _buildInfoSection(
                        context,
                        icon: Icons.filter_list_rounded,
                        iconColor: const Color(0xFF0D9488),
                        title: l10n.isIndonesian
                            ? 'Tujuan Analisis Top Categories'
                            : 'Purpose of Top Categories Analysis',
                        description: l10n.isIndonesian
                            ? '• Mengidentifikasi Kebocoran Terbesar: Memberikan gambaran seketika mengenai pos mana yang paling dominan menghabiskan dana kas Anda.\n'
                              '• Evaluasi Frekuensi Transaksi: Membedakan antara pengeluaran yang besar karena sekali beli (nominal tinggi) vs yang besar akibat belanja kecil berkali-kali.'
                            : '• Identify Major Cash Drains: Instantly reveals which categories absorb the highest portion of your spending.\n'
                              '• Transaction Frequency Evaluation: Differentiates one-time high-ticket expenses from recurring small leaky purchases.',
                        bgColor: cardBgColor,
                        borderColor: borderColor,
                      ),
                      SizedBox(height: 10.h),

                      // SEKSI 3: PRINSIP PARETO 80/20
                      _buildInfoSection(
                        context,
                        icon: Icons.lightbulb_outline_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: l10n.paretoLawTitle,
                        description: l10n.isIndonesian
                            ? 'Fokuskan penghematan pada kategori peringkat 1 dan 2. Memangkas 10% pengeluaran dari pos terbesar memberikan dampak tabungan yang jauh lebih signifikan daripada menekan pos kecil.'
                            : 'Focus your savings on top-ranked categories. Trimming 10% from your biggest spending buckets creates a far greater financial cushion than cutting small incidental items.',
                        bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                        borderColor:
                            const Color(0xFFF59E0B).withValues(alpha: 0.25),
                      ),
                      SizedBox(height: 20.h),

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
                            l10n.understood,
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
