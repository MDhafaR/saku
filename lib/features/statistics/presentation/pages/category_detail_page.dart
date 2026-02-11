import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../components/category_detail_card.dart';
import '../components/expense_comparison_chart.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/statistics_state.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({super.key});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  DateTime selectedDate = DateTime.now();
  int? _expandedIndex =
      0; // Default: first card is expanded, null = all collapsed

  String get selectedMonth => DateFormat('MMM yyyy').format(selectedDate);

  Future<void> _selectMonthYear(BuildContext context) async {
    DateTime tempDate = DateTime(selectedDate.year, selectedDate.month);

    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Year navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            tempDate = DateTime(
                              tempDate.year - 1,
                              tempDate.month,
                            );
                          });
                        },
                        icon: Icon(
                          Icons.chevron_left,
                          color: const Color(0xFF111111),
                          size: 24.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showYearPicker(context, tempDate).then((
                            selectedYear,
                          ) {
                            if (selectedYear != null) {
                              setModalState(() {
                                tempDate = DateTime(
                                  selectedYear,
                                  tempDate.month,
                                );
                              });
                            }
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${tempDate.year}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111111),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_drop_down,
                              color: const Color(0xFF111111),
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            tempDate = DateTime(
                              tempDate.year + 1,
                              tempDate.month,
                            );
                          });
                        },
                        icon: Icon(
                          Icons.chevron_right,
                          color: const Color(0xFF111111),
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Month grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 2.0,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = month == tempDate.month;

                      final monthNames = [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'Mei',
                        'Jun',
                        'Jul',
                        'Agu',
                        'Sep',
                        'Okt',
                        'Nov',
                        'Des',
                      ];

                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            tempDate = DateTime(tempDate.year, month);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF111111)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            monthNames[index],
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(tempDate);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Pilih',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),
                ],
              ),
            );
          },
        );
      },
    );

    if (picked != null) {
      if (!context.mounted) return;
      setState(() {
        selectedDate = picked;
      });

      // Load statistics for the selected month
      final start = DateTime(picked.year, picked.month, 1);
      final end = DateTime(picked.year, picked.month + 1, 0, 23, 59, 59);

      context.read<StatisticsCubit>().loadStatistics(
        'Custom',
        customRange: AppDateTimeRange(start: start, end: end),
      );
    }
  }

  Future<int?> _showYearPicker(BuildContext context, DateTime tempDate) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Text(
                'Pilih Tahun',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111111),
                ),
              ),
              SizedBox(height: 12.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2.0,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                ),
                itemCount: 11, // 2020-2030
                itemBuilder: (ctx, i) {
                  final year = 2020 + i;
                  final isYearSelected = year == tempDate.year;
                  return GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(year),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isYearSelected
                            ? const Color(0xFF111111)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$year',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isYearSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isYearSelected
                              ? Colors.white
                              : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }

  void _onCardTap(int index) {
    setState(() {
      // Toggle: if already expanded, collapse it; otherwise expand this one
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final start = DateTime(selectedDate.year, selectedDate.month, 1);
        final end = DateTime(
          selectedDate.year,
          selectedDate.month + 1,
          0,
          23,
          59,
          59,
        );
        return locator<StatisticsCubit>()..loadStatistics(
          'Custom',
          customRange: AppDateTimeRange(start: start, end: end),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAFAFA),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: const Color(0xFF1F2937),
              size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Rincian Kategori',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: const Color(0xFF1F2937),
                size: 24.sp,
              ),
              onPressed: () {},
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is StatisticsError) {
              return Center(child: Text(state.message));
            }

            if (state is StatisticsLoaded) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Total & Month
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Pengeluaran',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              CurrencyFormatter.formatRupiah(
                                state.totalExpense,
                              ),
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111111),
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _selectMonthYear(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  selectedMonth,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111111),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 14.sp,
                                  color: const Color(0xFF111111),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Comparison Chart
                    ExpenseComparisonChart(categories: state.categoryBreakdown),
                    SizedBox(height: 16.h),

                    // Category Cards with expand/collapse
                    if (state.categoryBreakdown.isEmpty)
                      SizedBox(
                        height: 200.h,
                        child: const Center(
                          child: Text('Tidak ada data transaksi'),
                        ),
                      )
                    else
                      ...List.generate(state.categoryBreakdown.length, (index) {
                        final item = state.categoryBreakdown[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: CategoryDetailCard(
                            item: item,
                            isExpanded: _expandedIndex == index,
                            onTap: () => _onCardTap(index),
                          ),
                        );
                      }),
                    SizedBox(height: 16.h),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
