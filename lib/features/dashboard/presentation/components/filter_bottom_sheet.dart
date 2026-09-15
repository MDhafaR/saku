import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/local/database/app_database.dart';

enum DashboardTransactionType { all, income, expense }

enum DashboardDateRange { selectedMonth, last30Days, customRange }

class DashboardFilterResult {
  final DashboardTransactionType transactionType;
  final DashboardDateRange dateRange;
  final int? walletId;
  final Set<int> categoryIds;
  final RangeValues amountRange;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final double amountUpperBound;

  const DashboardFilterResult({
    this.transactionType = DashboardTransactionType.all,
    this.dateRange = DashboardDateRange.selectedMonth,
    this.walletId,
    this.categoryIds = const <int>{},
    this.amountRange = const RangeValues(0, 100),
    this.customStartDate,
    this.customEndDate,
    this.amountUpperBound = 0,
  });

  bool get hasActiveFilters {
    return transactionType != DashboardTransactionType.all ||
        dateRange != DashboardDateRange.selectedMonth ||
        walletId != null ||
        categoryIds.isNotEmpty ||
        (amountUpperBound > 0 &&
            (amountRange.start > 0 || amountRange.end < amountUpperBound)) ||
        (dateRange == DashboardDateRange.customRange &&
            customStartDate != null &&
            customEndDate != null);
  }
}

class FilterBottomSheet extends StatefulWidget {
  final DashboardFilterResult initialFilter;
  final List<Wallet> wallets;
  final List<Category> categories;
  final double maxSelectableAmount;

  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.wallets,
    required this.categories,
    required this.maxSelectableAmount,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late DashboardTransactionType _selectedTransactionType;
  late DashboardDateRange _selectedDateRange;
  int? _selectedWalletId;
  late Set<int> _selectedCategoryIds;
  late RangeValues _currentRangeValues;
  late double _amountUpperBound;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _selectedTransactionType = widget.initialFilter.transactionType;
    _selectedDateRange = widget.initialFilter.dateRange;
    _selectedWalletId = widget.initialFilter.walletId;
    _selectedCategoryIds = Set<int>.from(widget.initialFilter.categoryIds);
    _amountUpperBound = widget.maxSelectableAmount;
    if (widget.initialFilter.amountUpperBound > 0) {
      _currentRangeValues = RangeValues(
        widget.initialFilter.amountRange.start.clamp(0, _amountUpperBound),
        widget.initialFilter.amountRange.end.clamp(0, _amountUpperBound),
      );
    } else {
      _currentRangeValues = RangeValues(0, _amountUpperBound);
    }
    _customStartDate = widget.initialFilter.customStartDate;
    _customEndDate = widget.initialFilter.customEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 24.w),
                Text(
                  'Filter Pencarian',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24.r,
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3), height: 32.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Tipe Transaksi'),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildChip(
                        'Semua',
                        isSelected:
                            _selectedTransactionType ==
                            DashboardTransactionType.all,
                        onTap: () => setState(
                          () =>
                              _selectedTransactionType =
                                  DashboardTransactionType.all,
                        ),
                      ),
                      _buildChip(
                        'Pemasukan',
                        icon: Icons.south_west_rounded,
                        isSelected:
                            _selectedTransactionType ==
                            DashboardTransactionType.income,
                        onTap: () => setState(
                          () =>
                              _selectedTransactionType =
                                  DashboardTransactionType.income,
                        ),
                      ),
                      _buildChip(
                        'Pengeluaran',
                        icon: Icons.north_east_rounded,
                        isSelected:
                            _selectedTransactionType ==
                            DashboardTransactionType.expense,
                        onTap: () => setState(
                          () =>
                              _selectedTransactionType =
                                  DashboardTransactionType.expense,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Rentang Waktu'),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildChip(
                        'Bulan Dipilih',
                        icon: Icons.calendar_month_outlined,
                        isSelected:
                            _selectedDateRange ==
                            DashboardDateRange.selectedMonth,
                        onTap: () => setState(
                          () =>
                              _selectedDateRange =
                                  DashboardDateRange.selectedMonth,
                        ),
                      ),
                      _buildChip(
                        '30 Hari Terakhir',
                        icon: Icons.history_rounded,
                        isSelected:
                            _selectedDateRange == DashboardDateRange.last30Days,
                        onTap: () => setState(
                          () =>
                              _selectedDateRange = DashboardDateRange.last30Days,
                        ),
                      ),
                      _buildChip(
                        'Pilih Tanggal',
                        icon: Icons.calendar_today_outlined,
                        isSelected:
                            _selectedDateRange == DashboardDateRange.customRange,
                        onTap: () => setState(
                          () =>
                              _selectedDateRange = DashboardDateRange.customRange,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedDateRange == DashboardDateRange.customRange) ...[
                    SizedBox(height: 12.h),
                    _buildCustomDateRangePicker(),
                  ],
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Dompet'),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildChip(
                        'Semua',
                        icon: Icons.account_balance_wallet_outlined,
                        isSelected: _selectedWalletId == null,
                        onTap: () => setState(() => _selectedWalletId = null),
                      ),
                      ...widget.wallets.map(
                        (wallet) => _buildChip(
                          wallet.name,
                          iconName: wallet.icon,
                          iconColor: wallet.iconColor,
                          isSelected: _selectedWalletId == wallet.id,
                          onTap: () =>
                              setState(() => _selectedWalletId = wallet.id),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Kategori'),
                      TextButton(
                        onPressed: () =>
                            setState(() => _selectedCategoryIds.clear()),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.45)
                                : AppTheme.primaryBlue,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: widget.categories.map((category) {
                      final selected = _selectedCategoryIds.contains(category.id);
                      return _buildChip(
                        category.name,
                        iconName: category.icon,
                        iconColor: category.iconColor,
                        isSelected: selected,
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedCategoryIds.remove(category.id);
                            } else {
                              _selectedCategoryIds.add(category.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Nominal'),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${CurrencyFormatter.format(_currentRangeValues.start.toStringAsFixed(0))}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Rp ${CurrencyFormatter.format(_currentRangeValues.end.toStringAsFixed(0))}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Builder(builder: (context) {
                    final isDarkSlider = Theme.of(context).brightness == Brightness.dark;
                    return SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: isDarkSlider
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppTheme.primaryBlue,
                        inactiveTrackColor: isDarkSlider
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.grey[200],
                        thumbColor: Colors.white,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 12.r,
                          elevation: 2,
                        ),
                        overlayColor: isDarkSlider
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppTheme.primaryBlue.withValues(alpha: 0.1),
                      ),
                      child: RangeSlider(
                        values: _currentRangeValues,
                        min: 0,
                        max: _amountUpperBound,
                        onChanged: (RangeValues values) {
                          setState(() {
                            _currentRangeValues = values;
                          });
                        },
                      ),
                    );
                  }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Min',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Max',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          Builder(builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cs = Theme.of(context).colorScheme;
            return Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              decoration: BoxDecoration(
                color: isDark ? Colors.transparent : cs.surface,
                border: isDark
                    ? null // tidak ada divider di dark — terasa lebih ringan
                    : Border(
                        top: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  // Reset — outline pill subtle
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _resetFilter,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.18)
                              : cs.outlineVariant,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        foregroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.55)
                            : cs.onSurfaceVariant,
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Apply — solid putih di dark, solid biru di light
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _applyFilter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.92)
                            : AppTheme.primaryBlue,
                        foregroundColor: isDark
                            ? const Color(0xFF111111)
                            : Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Terapkan',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

        ],
      ),
    );
  }

  void _resetFilter() {
    setState(() {
      _selectedTransactionType = DashboardTransactionType.all;
      _selectedDateRange = DashboardDateRange.selectedMonth;
      _selectedWalletId = null;
      _selectedCategoryIds.clear();
      _currentRangeValues = RangeValues(0, _amountUpperBound);
      _customStartDate = null;
      _customEndDate = null;
    });
  }

  void _applyFilter() {
    if (_selectedDateRange == DashboardDateRange.customRange &&
        (_customStartDate == null || _customEndDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal awal dan akhir dulu.')),
      );
      return;
    }

    Navigator.pop(
      context,
      DashboardFilterResult(
        transactionType: _selectedTransactionType,
        dateRange: _selectedDateRange,
        walletId: _selectedWalletId,
        categoryIds: _selectedCategoryIds,
        amountRange: _currentRangeValues,
        customStartDate: _customStartDate,
        customEndDate: _customEndDate,
        amountUpperBound: _amountUpperBound,
      ),
    );
  }

  Widget _buildCustomDateRangePicker() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            label: 'Dari',
            value: _customStartDate,
            onTap: () => _pickDate(isStartDate: true),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildDateField(
            label: 'Sampai',
            value: _customEndDate,
            onTap: () => _pickDate(isStartDate: false),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    final formatter = DateFormat('dd MMM yyyy', 'id');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.event_outlined, size: 16.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                value == null ? label : formatter.format(value),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: value == null
                      ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final now = DateTime.now();
    final initialDate = isStartDate
        ? (_customStartDate ?? _customEndDate ?? now)
        : (_customEndDate ?? _customStartDate ?? now);
    final firstDate = DateTime(2000);
    final lastDate = DateTime(now.year + 2, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('id', 'ID'),
    );

    if (picked == null) return;

    setState(() {
      if (isStartDate) {
        _customStartDate = DateTime(picked.year, picked.month, picked.day);
        if (_customEndDate != null && _customEndDate!.isBefore(_customStartDate!)) {
          _customEndDate = _customStartDate;
        }
      } else {
        _customEndDate = DateTime(picked.year, picked.month, picked.day);
        if (_customStartDate != null && _customStartDate!.isAfter(_customEndDate!)) {
          _customStartDate = _customEndDate;
        }
      }
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildChip(
    String label, {
    IconData? icon,
    String? iconName,
    int? iconColor,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    // Dark mode: glassy white untuk selected, subtle border untuk unselected
    // Light mode: tetap biru sebagai aksen
    final textColor = isSelected
        ? (isDark ? Colors.white.withValues(alpha: 0.95) : cs.primary)
        : cs.onSurface.withValues(alpha: isDark ? 0.7 : 0.85);

    final borderColor = isSelected
        ? (isDark ? Colors.white.withValues(alpha: 0.40) : cs.primary)
        : (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : cs.outlineVariant.withValues(alpha: 0.5));

    final bgColor = isSelected
        ? (isDark
            ? Colors.white.withValues(alpha: 0.08) // frosted glass
            : cs.primaryContainer.withValues(alpha: 0.3))
        : Colors.transparent;

    final hasIcon = icon != null || iconName != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: hasIcon ? 8.w : 14.w,
          right: 14.w,
          top: 6.h,
          bottom: 6.h,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconName != null) ...[
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: iconColor != null
                      ? Color(iconColor).withValues(alpha: isSelected ? 0.25 : 0.15)
                      : (isSelected
                          ? cs.primary.withValues(alpha: 0.2)
                          : cs.surfaceContainerHighest),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: CategoryIcon(
                  iconName: iconName,
                  color: iconColor != null ? Color(iconColor) : textColor,
                  size: 13.sp,
                ),
              ),
              SizedBox(width: 6.w),
            ] else if (icon != null) ...[
              Icon(icon, size: 16.sp, color: textColor),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
