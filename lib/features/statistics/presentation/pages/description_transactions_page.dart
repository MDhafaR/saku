import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../components/search_and_merge_modal.dart';
import '../cubit/statistics_state.dart';

enum DescriptionSortOption {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
}

extension DescriptionSortOptionExt on DescriptionSortOption {
  String label(AppLocalizations l10n) {
    switch (this) {
      case DescriptionSortOption.dateDesc:
        return l10n.sortNewest;
      case DescriptionSortOption.dateAsc:
        return l10n.sortOldest;
      case DescriptionSortOption.amountDesc:
        return l10n.sortHighestAmount;
      case DescriptionSortOption.amountAsc:
        return l10n.sortLowestAmount;
    }
  }

  String description(AppLocalizations l10n) {
    switch (this) {
      case DescriptionSortOption.dateDesc:
        return l10n.sortNewestToOldest;
      case DescriptionSortOption.dateAsc:
        return l10n.sortOldestToNewest;
      case DescriptionSortOption.amountDesc:
        return l10n.sortHighestExpense;
      case DescriptionSortOption.amountAsc:
        return l10n.sortLowestExpense;
    }
  }

  IconData get icon {
    switch (this) {
      case DescriptionSortOption.dateDesc:
        return Icons.calendar_today_rounded;
      case DescriptionSortOption.dateAsc:
        return Icons.history_rounded;
      case DescriptionSortOption.amountDesc:
        return Icons.trending_up_rounded;
      case DescriptionSortOption.amountAsc:
        return Icons.trending_down_rounded;
    }
  }
}

class DescriptionTransactionsPage extends StatefulWidget {
  final String description;
  final Set<String>? initialKeywords;
  final int categoryId;
  final String categoryName;
  final String iconName;
  final Color categoryColor;
  final String period;
  final DateTime targetDate;
  final AppDateTimeRange? customRange;
  final List<Transaction> initialTransactions;

  const DescriptionTransactionsPage({
    super.key,
    required this.description,
    this.initialKeywords,
    required this.categoryId,
    required this.categoryName,
    required this.iconName,
    required this.categoryColor,
    this.period = 'Monthly',
    required this.targetDate,
    this.customRange,
    this.initialTransactions = const [],
  });

  @override
  State<DescriptionTransactionsPage> createState() =>
      _DescriptionTransactionsPageState();
}

class _DescriptionTransactionsPageState
    extends State<DescriptionTransactionsPage> {
  late Future<List<Transaction>> _allCategoryTransactionsFuture;
  late Set<String> _activeKeywords;
  final Set<int> _excludedTransactionIds = <int>{};
  final Set<int> _selectedForExclusionIds = <int>{};
  bool _isSelectionMode = false;
  DescriptionSortOption _selectedSort = DescriptionSortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    if (widget.initialKeywords != null &&
        widget.initialKeywords!.isNotEmpty) {
      _activeKeywords = Set<String>.from(widget.initialKeywords!);
    } else {
      final clean = widget.description.trim().toLowerCase();
      _activeKeywords = clean.isNotEmpty ? {clean} : {'transaksi'};
    }
    _loadAllCategoryTransactions();
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

  DateTimeRange _computeRange(
    String period,
    DateTime anchor,
    AppDateTimeRange? customRange,
  ) {
    DateTime start;
    DateTime end;
    switch (period.toLowerCase()) {
      case 'daily':
        start = DateTime(anchor.year, anchor.month, anchor.day);
        end = DateTime(anchor.year, anchor.month, anchor.day, 23, 59, 59);
        break;
      case 'monthly':
        start = DateTime(anchor.year, anchor.month, 1);
        final daysInMonth = DateTime(anchor.year, anchor.month + 1, 0).day;
        end = DateTime(anchor.year, anchor.month, daysInMonth, 23, 59, 59);
        break;
      case 'yearly':
        start = DateTime(anchor.year, 1, 1);
        end = DateTime(anchor.year, 12, 31, 23, 59, 59);
        break;
      case 'custom':
        if (customRange != null) {
          start = customRange.start;
          end = DateTime(
            customRange.end.year,
            customRange.end.month,
            customRange.end.day,
            23,
            59,
            59,
          );
        } else {
          start = DateTime(anchor.year, anchor.month, 1);
          end = DateTime.now();
        }
        break;
      case 'all':
      default:
        start = DateTime(2000);
        end = DateTime.now();
        break;
    }
    return DateTimeRange(start: start, end: end);
  }

  void _loadAllCategoryTransactions() {
    final range = _computeRange(
      widget.period,
      widget.targetDate,
      widget.customRange,
    );

    _allCategoryTransactionsFuture = locator<AppDatabase>()
        .transactionDao
        .getTransactionsByCategory(
          widget.categoryId,
          range.start,
          range.end,
        )
        .then((list) {
          if (list.isEmpty && widget.initialTransactions.isNotEmpty) {
            return widget.initialTransactions;
          }
          return list;
        });
  }

  List<Transaction> _sortTransactions(List<Transaction> txList) {
    final list = List<Transaction>.from(txList);
    switch (_selectedSort) {
      case DescriptionSortOption.dateDesc:
        list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        break;
      case DescriptionSortOption.dateAsc:
        list.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
        break;
      case DescriptionSortOption.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case DescriptionSortOption.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return list;
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

  void _showSortBottomSheet(BuildContext context, ColorScheme cs) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Text(
                  l10n.sortTransactionHistory,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.sortDescriptionSubtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 14.h),
                ...DescriptionSortOption.values.map((option) {
                  final isSelected = _selectedSort == option;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSort = option;
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 11.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.categoryColor.withValues(alpha: 0.12)
                              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected
                                ? widget.categoryColor
                                : cs.outlineVariant.withValues(alpha: 0.4),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? widget.categoryColor.withValues(alpha: 0.2)
                                    : cs.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                option.icon,
                                size: 16.sp,
                                color: isSelected
                                    ? widget.categoryColor
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.label(l10n),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? cs.onSurface
                                          : cs.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    option.description(l10n),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: widget.categoryColor,
                                size: 20.sp,
                              )
                            else
                              Container(
                                width: 18.w,
                                height: 18.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.outlineVariant
                                        .withValues(alpha: 0.6),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _excludeSingleTransaction(Transaction tx) {
    final l10n = context.l10n;
    setState(() {
      _excludedTransactionIds.add(tx.id);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.excludeSingleItem(
            tx.description.isNotEmpty
                ? tx.description
                : (l10n.isIndonesian ? 'Transaksi' : 'Transaction'),
          ),
          style: TextStyle(fontSize: 12.sp),
        ),
        action: SnackBarAction(
          label: l10n.cancel,
          textColor: widget.categoryColor,
          onPressed: () {
            setState(() {
              _excludedTransactionIds.remove(tx.id);
            });
          },
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  void _excludeSelectedBatch() {
    if (_selectedForExclusionIds.isEmpty) return;
    final l10n = context.l10n;
    final count = _selectedForExclusionIds.length;
    final copy = Set<int>.from(_selectedForExclusionIds);

    setState(() {
      _excludedTransactionIds.addAll(_selectedForExclusionIds);
      _selectedForExclusionIds.clear();
      _isSelectionMode = false;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.excludeItemsCount(count),
          style: TextStyle(fontSize: 12.sp),
        ),
        action: SnackBarAction(
          label: l10n.cancel,
          textColor: widget.categoryColor,
          onPressed: () {
            setState(() {
              _excludedTransactionIds.removeAll(copy);
            });
          },
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            _isSelectionMode ? Icons.close_rounded : Icons.arrow_back_ios_new,
            color: cs.onSurface,
            size: 20.sp,
          ),
          onPressed: () {
            if (_isSelectionMode) {
              setState(() {
                _isSelectionMode = false;
                _selectedForExclusionIds.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _isSelectionMode
              ? l10n.selectedItemsCount(_selectedForExclusionIds.length)
              : (_activeKeywords.isNotEmpty
                  ? _activeKeywords.join(', ')
                  : widget.description),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          if (!_isSelectionMode)
            IconButton(
              icon: Icon(
                Icons.checklist_rounded,
                color: cs.onSurface,
                size: 22.sp,
              ),
              tooltip: l10n.selectModeMulti,
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
            ),
          SizedBox(width: 8.w),
        ],
      ),
      bottomNavigationBar: _isSelectionMode
          ? SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isSelectionMode = false;
                            _selectedForExclusionIds.clear();
                          });
                        },
                        child: Text(l10n.cancel),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        icon: const Icon(Icons.remove_circle_outline_rounded,
                            size: 18),
                        label: Text(
                          l10n.excludeSelectedDataButton(_selectedForExclusionIds.length),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: _selectedForExclusionIds.isEmpty
                            ? null
                            : _excludeSelectedBatch,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: FutureBuilder<List<Transaction>>(
        future: _allCategoryTransactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allCategoryTxs =
              snapshot.data ?? widget.initialTransactions;

          // 1. Filter matching transactions based on active keywords
          final matchedTxs = allCategoryTxs.where((t) {
            return _matchesKeywords(t, _activeKeywords);
          }).toList();

          // 2. Active transactions (excluding manually removed IDs)
          final activeTxs = matchedTxs.where((t) {
            return !_excludedTransactionIds.contains(t.id);
          }).toList();

          // 3. Extract recommendations from matched transactions
          final matchedTokens = <String>{};
          for (final tx in matchedTxs) {
            matchedTokens.addAll(extractTokens(tx.description));
          }
          final candidateTokens = matchedTokens.difference(_activeKeywords);
          final recommendations = <String, int>{};
          for (final candidate in candidateTokens) {
            final otherCount = allCategoryTxs
                .where((t) =>
                    !matchedTxs.contains(t) &&
                    _matchesKeywords(t, {candidate}))
                .length;
            if (otherCount > 0) {
              recommendations[candidate] = otherCount;
            }
          }

          final sortedActiveTxs = _sortTransactions(activeTxs);
          final totalAmount =
              activeTxs.fold<double>(0.0, (sum, t) => sum + t.amount);

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: sortedActiveTxs.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader(
                  cs: cs,
                  l10n: l10n,
                  totalCount: activeTxs.length,
                  totalAmount: totalAmount,
                  recommendations: recommendations,
                  allCategoryTxs: allCategoryTxs,
                  matchedTxs: matchedTxs,
                );
              }
              final tx = sortedActiveTxs[index - 1];
              return _buildTransactionItem(cs, l10n, tx);
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader({
    required ColorScheme cs,
    required AppLocalizations l10n,
    required int totalCount,
    required double totalAmount,
    required Map<String, int> recommendations,
    required List<Transaction> allCategoryTxs,
    required List<Transaction> matchedTxs,
  }) {
    final avgAmount = totalCount > 0 ? totalAmount / totalCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Keywords Management Bar
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
                  l10n.activeKeywordsLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => _showSearchAndMergeModal(context, allCategoryTxs),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        size: 14.sp, color: widget.categoryColor),
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
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: widget.categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: widget.categoryColor.withValues(alpha: 0.4),
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
        SizedBox(height: 10.h),

        // Smart Word Recommendations
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
                SizedBox(height: 4.h),
                Text(
                  l10n.suggestedRelatedWordsDesc,
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
                        color:
                            const Color(0xFF3B82F6).withValues(alpha: 0.3),
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
          SizedBox(height: 10.h),
        ],

        // Excluded Data Banner
        if (_excludedTransactionIds.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16.sp,
                  color: const Color(0xFFD97706),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    l10n.excludeItemsCount(_excludedTransactionIds.length),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    setState(() {
                      _excludedTransactionIds.clear();
                    });
                  },
                  child: Text(
                    l10n.restoreAll,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],

        // Total Summary Card
        SakuCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.totalAccumulatedExpense,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            CurrencyFormatter.formatRupiah(totalAmount),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      l10n.transactionCount(totalCount),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.averagePerTxLabel,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(avgAmount),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Section Title & Filter / Sort & Select All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.transactionHistory,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            Row(
              children: [
                if (_isSelectionMode)
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_selectedForExclusionIds.length ==
                            totalCount) {
                          _selectedForExclusionIds.clear();
                        } else {
                          for (final t in matchedTxs) {
                            if (!_excludedTransactionIds.contains(t.id)) {
                              _selectedForExclusionIds.add(t.id);
                            }
                          }
                        }
                      });
                    },
                    child: Text(
                      _selectedForExclusionIds.length == totalCount
                          ? l10n.deselectAll
                          : l10n.selectAll,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: widget.categoryColor,
                      ),
                    ),
                  )
                else
                  _buildSortFilterButton(cs, l10n),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildSortFilterButton(ColorScheme cs, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSortBottomSheet(context, cs),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _selectedSort.icon,
                size: 13.sp,
                color: widget.categoryColor,
              ),
              SizedBox(width: 5.w),
              Text(
                _selectedSort.label(l10n),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(width: 3.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14.sp,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(ColorScheme cs, AppLocalizations l10n, Transaction tx) {
    final formattedDate =
        DateFormat('d MMMM yyyy', l10n.dateLocaleCode).format(tx.transactionDate);
    final isSelectedForExclusion = _selectedForExclusionIds.contains(tx.id);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: SakuCard(
        margin: EdgeInsets.zero,
        onTap: () {
          if (_isSelectionMode) {
            setState(() {
              if (isSelectedForExclusion) {
                _selectedForExclusionIds.remove(tx.id);
              } else {
                _selectedForExclusionIds.add(tx.id);
              }
            });
          }
        },
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            if (_isSelectionMode) ...[
              Checkbox(
                value: isSelectedForExclusion,
                activeColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedForExclusionIds.add(tx.id);
                    } else {
                      _selectedForExclusionIds.remove(tx.id);
                    }
                  });
                },
              ),
              SizedBox(width: 4.w),
            ] else ...[
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: CategoryIcon(
                  iconName: widget.iconName,
                  color: cs.onSurfaceVariant,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description.isNotEmpty
                        ? tx.description
                        : '${l10n.isIndonesian ? 'Transaksi' : 'Transaction'} ${widget.categoryName}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${CurrencyFormatter.formatRupiah(tx.amount)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            if (!_isSelectionMode) ...[
              SizedBox(width: 6.w),
              IconButton(
                icon: Icon(
                  Icons.remove_circle_outline_rounded,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  size: 18.sp,
                ),
                tooltip: l10n.excludeSingleTooltip,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _excludeSingleTransaction(tx),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
