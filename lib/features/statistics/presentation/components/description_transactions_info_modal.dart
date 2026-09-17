import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../components/search_and_merge_modal.dart';
import '../cubit/statistics_state.dart';
import '../pages/description_transactions_page.dart';

class DescriptionTransactionsInfoModal extends StatefulWidget {
  final String description;
  final int categoryId;
  final String categoryName;
  final String iconName;
  final Color categoryColor;
  final double categoryTotalAmount;
  final List<Transaction> allCategoryTransactions;
  final String period;
  final DateTime targetDate;
  final AppDateTimeRange? customRange;

  const DescriptionTransactionsInfoModal({
    super.key,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.iconName,
    required this.categoryColor,
    required this.categoryTotalAmount,
    required this.allCategoryTransactions,
    required this.period,
    required this.targetDate,
    this.customRange,
  });

  static void show(
    BuildContext context, {
    required String description,
    required int categoryId,
    required String categoryName,
    required String iconName,
    required Color categoryColor,
    required double categoryTotalAmount,
    required List<Transaction> allCategoryTransactions,
    required String period,
    required DateTime targetDate,
    AppDateTimeRange? customRange,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DescriptionTransactionsInfoModal(
        description: description,
        categoryId: categoryId,
        categoryName: categoryName,
        iconName: iconName,
        categoryColor: categoryColor,
        categoryTotalAmount: categoryTotalAmount,
        allCategoryTransactions: allCategoryTransactions,
        period: period,
        targetDate: targetDate,
        customRange: customRange,
      ),
    );
  }

  @override
  State<DescriptionTransactionsInfoModal> createState() =>
      _DescriptionTransactionsInfoModalState();
}

class _DescriptionTransactionsInfoModalState
    extends State<DescriptionTransactionsInfoModal> {
  late Set<String> _activeKeywords;

  @override
  void initState() {
    super.initState();
    final initialDesc = widget.description.trim();
    if (initialDesc.isNotEmpty) {
      _activeKeywords = {initialDesc.toLowerCase()};
    } else {
      _activeKeywords = {'transaksi'};
    }
  }

  static Set<String> extractTokens(String text) {
    final clean = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\d]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (clean.isEmpty) return {};
    final rawTokens = clean.split(' ');
    const stopWords = {
      'dan', 'di', 'ke', 'dari', 'yang', 'untuk', 'ini', 'itu',
      'pada', 'dengan', 'atau', 'ada', 'buat', 'sama', 'pas', 'beli',
      'bayar', 'transaksi', 'rp', 'juta', 'ribu', 'k', 'sd', 's/d',
    };
    return rawTokens
        .where((w) =>
            w.length >= 2 &&
            !stopWords.contains(w) &&
            !RegExp(r'^\d+$').hasMatch(w))
        .toSet();
  }

  bool _matchesKeywords(Transaction tx, Set<String> keywords) {
    if (keywords.isEmpty) return true;
    final desc = tx.description.toLowerCase().trim();
    for (final kw in keywords) {
      final cleanKw = kw.toLowerCase().trim();
      if (cleanKw.isNotEmpty && desc.contains(cleanKw)) {
        return true;
      }
    }
    return false;
  }

  String _getPeriodContextLabel(
    String period,
    DateTime targetDate,
    AppDateTimeRange? customRange,
    AppLocalizations l10n,
  ) {
    switch (period.toLowerCase()) {
      case 'yearly':
        return l10n.isIndonesian
            ? 'tahun ${DateFormat('yyyy', l10n.dateLocaleCode).format(targetDate)}'
            : 'year ${DateFormat('yyyy', l10n.dateLocaleCode).format(targetDate)}';
      case 'daily':
        return l10n.isIndonesian
            ? 'hari ini (${DateFormat('d MMMM yyyy', l10n.dateLocaleCode).format(targetDate)})'
            : 'today (${DateFormat('d MMMM yyyy', l10n.dateLocaleCode).format(targetDate)})';
      case 'monthly':
        return l10n.isIndonesian
            ? 'bulan ${DateFormat('MMMM yyyy', l10n.dateLocaleCode).format(targetDate)}'
            : 'month ${DateFormat('MMMM yyyy', l10n.dateLocaleCode).format(targetDate)}';
      case 'custom':
        if (customRange != null) {
          final s =
              DateFormat('dd/MM/yyyy', l10n.dateLocaleCode).format(customRange.start);
          final e =
              DateFormat('dd/MM/yyyy', l10n.dateLocaleCode).format(customRange.end);
          return l10n.isIndonesian
              ? 'rentang waktu ($s - $e)'
              : 'custom range ($s - $e)';
        }
        return l10n.customRangeDateShort;
      case 'all':
      default:
        return l10n.allTimeHistory;
    }
  }

  void _showSearchAndMergeModal(
    BuildContext context,
    List<Transaction> allCategoryTxs,
  ) {
    SearchAndMergeModal.show(
      context,
      categoryName: widget.categoryName,
      categoryColor: widget.categoryColor,
      iconName: widget.iconName,
      allCategoryTransactions: allCategoryTxs,
      activeKeywords: _activeKeywords,
      onKeywordsMerged: (newKeywords) {
        setState(() {
          _activeKeywords.addAll(
            newKeywords.map((e) => e.toLowerCase().trim()),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor =
        isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB);
    final borderColor =
        isDark ? cs.outlineVariant.withValues(alpha: 0.25) : const Color(0xFFE5E7EB);

    final matchingTxs = widget.allCategoryTransactions.where((t) {
      return _matchesKeywords(t, _activeKeywords);
    }).toList();

    final count = matchingTxs.length;
    final totalAmount =
        matchingTxs.fold<double>(0.0, (sum, t) => sum + t.amount);
    final avgAmount = count > 0 ? totalAmount / count : 0.0;
    final percentageOfCategory = widget.categoryTotalAmount > 0
        ? (totalAmount / widget.categoryTotalAmount) * 100
        : 0.0;

    Transaction? maxTx;
    Transaction? minTx;
    if (matchingTxs.isNotEmpty) {
      maxTx = matchingTxs.reduce(
        (curr, next) => curr.amount > next.amount ? curr : next,
      );
      minTx = matchingTxs.reduce(
        (curr, next) => curr.amount < next.amount ? curr : next,
      );
    }

    final sortedByDate = List<Transaction>.from(matchingTxs)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
    final earliestDate = sortedByDate.isNotEmpty
        ? DateFormat('d MMM yyyy', l10n.dateLocaleCode)
            .format(sortedByDate.first.transactionDate)
        : '';
    final latestDate = sortedByDate.isNotEmpty
        ? DateFormat('d MMM yyyy', l10n.dateLocaleCode)
            .format(sortedByDate.last.transactionDate)
        : '';

    // Find candidate recommendation tokens from matching transactions
    final matchedTokens = <String>{};
    for (final tx in matchingTxs) {
      matchedTokens.addAll(extractTokens(tx.description));
    }
    final candidateTokens = matchedTokens.difference(_activeKeywords);
    final recommendations = <String, int>{};
    for (final candidate in candidateTokens) {
      final otherCount = widget.allCategoryTransactions
          .where((t) =>
              !matchingTxs.contains(t) &&
              _matchesKeywords(t, {candidate}))
          .length;
      if (otherCount > 0) {
        recommendations[candidate] = otherCount;
      }
    }

    final displayTitle = _activeKeywords.isNotEmpty
        ? _activeKeywords.join(' + ')
        : widget.description;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.35,
      maxChildSize: 0.88,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Fixed Top Header & Drag Handle
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 8.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24.r)),
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 36.w,
                        height: 4.h,
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: widget.categoryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: CategoryIcon(
                            iconName: widget.iconName,
                            color: widget.categoryColor,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.isIndonesian
                                    ? 'Transaksi "$displayTitle"'
                                    : '"$displayTitle" Transactions',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${widget.categoryName} • ${_getPeriodContextLabel(widget.period, widget.targetDate, widget.customRange, l10n)}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: cs.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: cs.onSurfaceVariant,
                            size: 20.sp,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Scrollable Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  children: [
                    // Active Keywords Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tag_rounded,
                              size: 14.sp,
                              color: widget.categoryColor,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              l10n.activeKeywordsTagLabel,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _showSearchAndMergeModal(
                            context,
                            widget.allCategoryTransactions,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  size: 14.sp,
                                  color: widget.categoryColor,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  l10n.mergeKeywordsButton,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: widget.categoryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: _activeKeywords.map((kw) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: widget.categoryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: widget.categoryColor
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                kw,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: widget.categoryColor,
                                ),
                              ),
                              if (_activeKeywords.length > 1) ...[
                                SizedBox(width: 4.w),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _activeKeywords.remove(kw);
                                    });
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 14.sp,
                                    color: widget.categoryColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 12.h),

                    // Smart Merge Recommendations
                    if (recommendations.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 14.sp,
                                  color: const Color(0xFF3B82F6),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    l10n.suggestedRelatedWords,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              l10n.isIndonesian
                                  ? 'Ditemukan transaksi lain di kategori ${widget.categoryName} yang memuat kata berikut. Ingin disatukan?'
                                  : 'Found other transactions in category ${widget.categoryName} containing these words. Merge them?',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 6.w,
                              runSpacing: 6.h,
                              children: recommendations.entries.map((entry) {
                                return ActionChip(
                                  avatar: Icon(
                                    Icons.add_rounded,
                                    size: 14.sp,
                                    color: const Color(0xFF2563EB),
                                  ),
                                  label: Text(
                                    '${entry.key} (+${entry.value} ${l10n.isIndonesian ? 'data' : 'items'})',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                  backgroundColor:
                                      const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                  side: BorderSide(
                                    color: const Color(0xFF3B82F6)
                                        .withValues(alpha: 0.3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _activeKeywords.add(entry.key);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // Section 1: Ringkasan Biaya Transaksi
                    Text(
                      l10n.totalAccumulatedExpense,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildMetricCard(
                            cs: cs,
                            bgColor: cardBgColor,
                            borderColor: borderColor,
                            title: l10n.totalExpense,
                            value: CurrencyFormatter.formatRupiah(totalAmount),
                            valueColor: const Color(0xFFEF4444),
                            icon: Icons.account_balance_wallet_rounded,
                            iconColor: const Color(0xFFEF4444),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          flex: 3,
                          child: _buildMetricCard(
                            cs: cs,
                            bgColor: cardBgColor,
                            borderColor: borderColor,
                            title: l10n.transactionFrequency,
                            value: '$count ${l10n.timesUnit}',
                            valueColor: cs.onSurface,
                            icon: Icons.repeat_rounded,
                            iconColor: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _buildMetricCard(
                      cs: cs,
                      bgColor: cardBgColor,
                      borderColor: borderColor,
                      title: l10n.averagePerTxLabel.replaceAll(':', ''),
                      value: CurrencyFormatter.formatRupiah(avgAmount),
                      valueColor: cs.onSurface,
                      icon: Icons.analytics_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      subtitle: l10n.isIndonesian
                          ? 'Berdasarkan $count transaksi yang memuat kata kunci terpilih'
                          : 'Based on $count transactions matching selected keywords',
                    ),
                    SizedBox(height: 14.h),

                    // Section 2: Porsi & Detail Insight
                    Text(
                      l10n.comparativeAnalysis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart_rounded,
                                size: 16.sp,
                                color: widget.categoryColor,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  l10n.isIndonesian
                                      ? 'Porsi terhadap Kategori ${widget.categoryName}'
                                      : 'Share of Category ${widget.categoryName}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.categoryColor
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '${percentageOfCategory.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    color: widget.categoryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: LinearProgressIndicator(
                              value: (percentageOfCategory / 100)
                                  .clamp(0.0, 1.0),
                              minHeight: 6.h,
                              backgroundColor: cs.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.categoryColor),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            l10n.isIndonesian
                                ? 'Transaksi dengan kata kunci ini menyumbang ${percentageOfCategory.toStringAsFixed(1)}% dari total pengeluaran kategori ${widget.categoryName} (${CurrencyFormatter.formatRupiah(widget.categoryTotalAmount)}).'
                                : 'Transactions with these keywords contribute ${percentageOfCategory.toStringAsFixed(1)}% of total expenses in category ${widget.categoryName} (${CurrencyFormatter.formatRupiah(widget.categoryTotalAmount)}).',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: cs.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          if (count > 1 && earliestDate.isNotEmpty) ...[
                            SizedBox(height: 10.h),
                            Divider(color: borderColor, height: 1),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.date_range_rounded,
                                  size: 14.sp,
                                  color: cs.onSurfaceVariant,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    l10n.isIndonesian
                                        ? 'Rentang: $earliestDate s/d $latestDate'
                                        : 'Range: $earliestDate to $latestDate',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (maxTx != null && minTx != null && count > 1) ...[
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${l10n.highest}: ${CurrencyFormatter.formatRupiah(maxTx.amount)}',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${l10n.lowest}: ${CurrencyFormatter.formatRupiah(minTx.amount)}',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Section 3: Call to Action to See Full Details
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: widget.categoryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: widget.categoryColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.format_list_bulleted_rounded,
                                size: 16.sp,
                                color: widget.categoryColor,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  l10n.isIndonesian
                                      ? 'Ingin melihat riwayat lengkap & menyesuaikan transaksi?'
                                      : 'Want to view full history & customize transactions?',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            l10n.isIndonesian
                                ? 'Jelajahi seluruh transaksi, keluarkan data yang kurang cocok (satuan atau pilih banyak), dan tambahkan kata kunci penggabungan lainnya.'
                                : 'Explore all transactions, exclude mismatched records (single or bulk), and merge additional keywords.',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: cs.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.categoryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Close bottom sheet
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DescriptionTransactionsPage(
                                      description: widget.description,
                                      initialKeywords: _activeKeywords,
                                      categoryId: widget.categoryId,
                                      categoryName: widget.categoryName,
                                      iconName: widget.iconName,
                                      categoryColor: widget.categoryColor,
                                      period: widget.period,
                                      targetDate: widget.targetDate,
                                      customRange: widget.customRange,
                                      initialTransactions: matchingTxs,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.openFullTransactionDetails,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 15.sp,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required ColorScheme cs,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
    required Color iconColor,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: iconColor),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: valueColor,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.sp,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
