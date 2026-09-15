import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';

class MergeSuggestionItem {
  final String text;
  final int count;
  final double totalAmount;

  const MergeSuggestionItem({
    required this.text,
    required this.count,
    required this.totalAmount,
  });
}

class SearchAndMergeModal extends StatefulWidget {
  final String categoryName;
  final Color categoryColor;
  final String iconName;
  final List<Transaction> allCategoryTransactions;
  final Set<String> activeKeywords;
  final ValueChanged<Set<String>> onKeywordsMerged;

  const SearchAndMergeModal({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.iconName,
    required this.allCategoryTransactions,
    required this.activeKeywords,
    required this.onKeywordsMerged,
  });

  static void show(
    BuildContext context, {
    required String categoryName,
    required Color categoryColor,
    required String iconName,
    required List<Transaction> allCategoryTransactions,
    required Set<String> activeKeywords,
    required ValueChanged<Set<String>> onKeywordsMerged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SearchAndMergeModal(
        categoryName: categoryName,
        categoryColor: categoryColor,
        iconName: iconName,
        allCategoryTransactions: allCategoryTransactions,
        activeKeywords: activeKeywords,
        onKeywordsMerged: onKeywordsMerged,
      ),
    );
  }

  @override
  State<SearchAndMergeModal> createState() => _SearchAndMergeModalState();
}

class _SearchAndMergeModalState extends State<SearchAndMergeModal> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedItems = <String>{};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MergeSuggestionItem> _buildSuggestions() {
    final Map<String, List<Transaction>> descMap = {};

    for (final tx in widget.allCategoryTransactions) {
      final desc = tx.description.trim();
      if (desc.isEmpty) continue;
      final key = desc.toLowerCase();
      // Skip if already in activeKeywords
      if (widget.activeKeywords.contains(key)) continue;

      descMap.putIfAbsent(desc, () => []).add(tx);
    }

    final List<MergeSuggestionItem> items = [];
    descMap.forEach((desc, txList) {
      final total = txList.fold<double>(0.0, (sum, t) => sum + t.amount);
      items.add(MergeSuggestionItem(
        text: desc,
        count: txList.length,
        totalAmount: total,
      ));
    });

    // Sort by count (frequency) descending, then total amount descending
    items.sort((a, b) {
      final cmp = b.count.compareTo(a.count);
      if (cmp != 0) return cmp;
      return b.totalAmount.compareTo(a.totalAmount);
    });

    if (_searchQuery.isEmpty) {
      return items;
    }

    // Filter by search query substring
    return items.where((item) {
      return item.text.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor =
        isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB);
    final borderColor =
        isDark ? cs.outlineVariant.withValues(alpha: 0.25) : const Color(0xFFE5E7EB);

    final suggestions = _buildSuggestions();
    final hasExactMatch = suggestions.any(
      (item) => item.text.toLowerCase() == _searchQuery,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Fixed Header & Drag Handle
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 10.h),
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
                                'Cari & Gabungkan Transaksi',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Pilih satu atau lebih transaksi untuk disatukan datanya',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: cs.onSurfaceVariant,
                                ),
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
                    SizedBox(height: 12.h),

                    // Search Field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            'Cari nama transaksi (misal: sat, padang)...',
                        hintStyle: TextStyle(
                          fontSize: 12.sp,
                          color: cs.outline,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: widget.categoryColor,
                          size: 20.sp,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  size: 18.sp,
                                  color: cs.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: widget.categoryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Selection Summary & Quick Actions
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedItems.isEmpty
                          ? '${suggestions.length} Transaksi Ditemukan'
                          : '${_selectedItems.length} Transaksi Dipilih',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: _selectedItems.isNotEmpty
                            ? widget.categoryColor
                            : cs.onSurfaceVariant,
                      ),
                    ),
                    if (suggestions.isNotEmpty)
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_selectedItems.length == suggestions.length) {
                              _selectedItems.clear();
                            } else {
                              _selectedItems.clear();
                              for (final item in suggestions) {
                                _selectedItems.add(item.text.toLowerCase());
                              }
                            }
                          });
                        },
                        child: Text(
                          _selectedItems.length == suggestions.length
                              ? 'Batal Pilih Semua'
                              : 'Pilih Semua',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: widget.categoryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Suggestion List
              Expanded(
                child: suggestions.isEmpty && _searchQuery.isNotEmpty && !hasExactMatch
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 40.sp,
                              color: cs.outline,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Tidak ada transaksi bernama "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.categoryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 10.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: Text(
                                'Gunakan "$_searchQuery" sebagai kata kunci',
                                style: TextStyle(fontSize: 11.sp),
                              ),
                              onPressed: () {
                                widget.onKeywordsMerged({_searchQuery});
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        itemCount: suggestions.length +
                            (_searchQuery.isNotEmpty && !hasExactMatch ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == 0 &&
                              _searchQuery.isNotEmpty &&
                              !hasExactMatch) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (_selectedItems.contains(_searchQuery)) {
                                      _selectedItems.remove(_searchQuery);
                                    } else {
                                      _selectedItems.add(_searchQuery);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.categoryColor
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: widget.categoryColor
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value:
                                            _selectedItems.contains(_searchQuery),
                                        activeColor: widget.categoryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              _selectedItems.add(_searchQuery);
                                            } else {
                                              _selectedItems
                                                  .remove(_searchQuery);
                                            }
                                          });
                                        },
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Gunakan kata: "$_searchQuery"',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w700,
                                                color: widget.categoryColor,
                                              ),
                                            ),
                                            Text(
                                              'Cocokkan semua transaksi yang memuat kata ini',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: cs.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          final itemIndex =
                              _searchQuery.isNotEmpty && !hasExactMatch
                                  ? index - 1
                                  : index;
                          final item = suggestions[itemIndex];
                          final itemKey = item.text.toLowerCase();
                          final isSelected = _selectedItems.contains(itemKey);

                          return Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedItems.remove(itemKey);
                                  } else {
                                    _selectedItems.add(itemKey);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? widget.categoryColor
                                          .withValues(alpha: 0.12)
                                      : cardBgColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? widget.categoryColor
                                        : borderColor,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      activeColor: widget.categoryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedItems.add(itemKey);
                                          } else {
                                            _selectedItems.remove(itemKey);
                                          }
                                        });
                                      },
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.text,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                              color: cs.onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            '${item.count} Transaksi',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '-${CurrencyFormatter.formatRupiah(item.totalAmount)}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFEF4444),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Action Button
              SafeArea(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: borderColor.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SizedBox(
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
                      onPressed: _selectedItems.isEmpty
                          ? null
                          : () {
                              widget.onKeywordsMerged(_selectedItems);
                              Navigator.pop(context);
                            },
                      child: Text(
                        _selectedItems.isEmpty
                            ? 'Pilih Transaksi untuk Digabungkan'
                            : 'Gabungkan (${_selectedItems.length}) Kata / Data',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
