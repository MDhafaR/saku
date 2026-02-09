import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../components/custom_numpad.dart';
import 'category_selection_page.dart';
import 'wallet_selection_page.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool isExpense = true;
  String amount = '0';
  String note = '';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Map<String, dynamic>? selectedCategory;
  Map<String, dynamic>? selectedWallet;

  void _onKeyPressed(String value) {
    setState(() {
      if (amount == '0') {
        amount = value;
      } else {
        amount += value;
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (amount.isNotEmpty) {
        amount = amount.substring(0, amount.length - 1);
        if (amount.isEmpty) {
          amount = '0';
        }
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (selectedDay == today) {
      return 'Hari Ini';
    } else if (selectedDay == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMM yyyy', 'id').format(selectedDate);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String _getTimeLabel() {
    final now = TimeOfDay.now();
    if (selectedTime.hour == now.hour && selectedTime.minute == now.minute) {
      return 'Sekarang';
    } else {
      final hour = selectedTime.hour.toString().padLeft(2, '0');
      final minute = selectedTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine feedback color (Red/Green) but keep it subtle
    // Not filling the screen with it.

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Clean off-white
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, size: 20.sp),
          // Icon theme should handle color, but ensure it's visible
          color: Theme.of(context).iconTheme.color,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(24.r),
          ),
          padding: EdgeInsets.all(3.w),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 2;
              return Stack(
                children: [
                  // Sliding indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: isExpense ? 0 : tabWidth,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tab labels
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (!isExpense) {
                              setState(() {
                                isExpense = true;
                                selectedCategory = null;
                                selectedWallet = null;
                                note = '';
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Text(
                              'Pengeluaran',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isExpense
                                    ? AppTheme.semanticRed
                                    : AppTheme.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (isExpense) {
                              setState(() {
                                isExpense = false;
                                selectedCategory = null;
                                selectedWallet = null;
                                note = '';
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Text(
                              'Pemasukan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !isExpense
                                    ? AppTheme.semanticGreen
                                    : AppTheme.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, size: 20.sp),
            color: Theme.of(context).iconTheme.color,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Amount Section - Compact
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Masukkan Jumlah',
                                style: TextStyle(
                                  color: AppTheme.lightTextSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Rp ${CurrencyFormatter.format(amount)}',
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 28.sp,
                                      color: isExpense
                                          ? AppTheme.semanticRed
                                          : AppTheme.semanticGreen,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Details Card - fills remaining space
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            children: [
                              // Date & Time
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputChip(
                                      icon: Icons.calendar_today_outlined,
                                      label: _getDateLabel(),
                                      onTap: _selectDate,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildInputChip(
                                      icon: Icons.access_time_outlined,
                                      label: _getTimeLabel(),
                                      onTap: _selectTime,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // Category
                              _buildSelectionField(
                                icon: selectedCategory != null
                                    ? selectedCategory!['icon'] as IconData
                                    : Icons.category_outlined,
                                iconColor: selectedCategory != null
                                    ? selectedCategory!['color'] as Color
                                    : null,
                                label: 'Kategori',
                                value: selectedCategory != null
                                    ? selectedCategory!['name'] as String
                                    : 'Pilih kategori...',
                                isPlaceholder: selectedCategory == null,
                                onTap: () async {
                                  final result =
                                      await Navigator.push<
                                        Map<String, dynamic>
                                      >(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CategorySelectionPage(
                                                isExpense: isExpense,
                                              ),
                                        ),
                                      );
                                  if (result != null) {
                                    setState(() {
                                      selectedCategory = result;
                                      // Update type based on selected category
                                      if (result['isExpense'] != null) {
                                        isExpense = result['isExpense'] as bool;
                                      }
                                    });
                                  }
                                },
                              ),
                              SizedBox(height: 12.h),

                              // Wallet
                              GestureDetector(
                                onTap: () async {
                                  final result =
                                      await Navigator.push<
                                        Map<String, dynamic>
                                      >(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const WalletSelectionPage(),
                                        ),
                                      );
                                  if (result != null) {
                                    setState(() {
                                      selectedWallet = result;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selectedWallet != null
                                            ? selectedWallet!['icon']
                                                  as IconData
                                            : Icons
                                                  .account_balance_wallet_outlined,
                                        color: selectedWallet != null
                                            ? selectedWallet!['color'] as Color
                                            : AppTheme.lightTextSecondary,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Wallet',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color:
                                                    AppTheme.lightTextSecondary,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            if (selectedWallet != null)
                                              Row(
                                                children: [
                                                  Text(
                                                    selectedWallet!['name']
                                                        as String,
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                        0xFF1F2937,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 6.w),
                                                  Text(
                                                    '( Rp ${CurrencyFormatter.format((selectedWallet!['balance'] as double).toStringAsFixed(0))} )',
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              Text(
                                                'Pilih wallet...',
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme
                                                      .lightTextSecondary,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: AppTheme.lightTextSecondary,
                                        size: 20.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 12.h),

                              // Note
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: AppTheme.lightTextSecondary,
                                        size: 20.sp,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            note = value;
                                          });
                                        },
                                        maxLines: 3,
                                        minLines: 2,
                                        cursorColor: const Color(0xFF6B7280),
                                        decoration: InputDecoration(
                                          hintText: 'Tulis catatan...',
                                          hintStyle: TextStyle(
                                            color: AppTheme.lightTextSecondary,
                                            fontSize: 14.sp,
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Fixed Numpad and Submit Button at bottom
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20.w,
              16.h,
              20.w,
              MediaQuery.of(context).padding.bottom + 20.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              border: Border(
                top: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Numpad
                CustomNumpad(
                  onKeyPressed: _onKeyPressed,
                  onDelete: _onDelete,
                  onSubmit: () => Navigator.pop(context),
                  submitColor: AppTheme.primaryBlue,
                ),
                SizedBox(height: 16.h),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Simpan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: AppTheme.darkBackground),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionField({
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
    bool isPlaceholder = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppTheme.lightTextSecondary,
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppTheme.lightTextSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isPlaceholder
                          ? AppTheme.lightTextSecondary
                          : const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.lightTextSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
