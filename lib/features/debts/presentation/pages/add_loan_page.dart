import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/injection.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/presentation/components/custom_numpad.dart';
import '../../../../data/local/database/app_database.dart';
import '../cubit/debt_cubit.dart';

class AddLoanPage extends StatefulWidget {
  const AddLoanPage({super.key});

  @override
  State<AddLoanPage> createState() => _AddLoanPageState();
}

class _AddLoanPageState extends State<AddLoanPage> {
  final DebtCubit _cubit = locator<DebtCubit>();
  List<Wallet> _wallets = [];
  Wallet? _selectedWallet;
  bool _isWalletDropdownOpen = false;

  bool isDebt = true; // "Saya Hutang" = true, "Pinjamkan" = false
  String _amount = '0';
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _transactionDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _hasDueDate = true;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final wallets = await _cubit.getWallets();
    setState(() {
      _wallets = wallets;
      if (wallets.isNotEmpty) {
        _selectedWallet = wallets.first;
      }
    });
  }

  @override
  void dispose() {
    _contactController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (_amount == '0') {
        _amount = value;
      } else {
        _amount += value;
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_amount.isNotEmpty) {
        _amount = _amount.substring(0, _amount.length - 1);
        if (_amount.isEmpty) {
          _amount = '0';
        }
      }
    });
  }

  Future<void> _selectTransactionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
    if (picked != null) {
      setState(() => _transactionDate = picked);
    }
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveDebt() async {
    if (_amount == '0' || _contactController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mohon lengkapi data')));
      return;
    }

    final amount = double.parse(_amount);

    await _cubit.addDebt(
      contactName: _contactController.text,
      totalAmount: amount,
      type: isDebt ? 'debt' : 'loan',
      transactionDate: _transactionDate,
      dueDate: _hasDueDate ? _dueDate : null,
      description: _noteController.text,
      walletId: _selectedWallet?.id,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Hari Ini';
    } else if (selectedDay == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMM yyyy', 'id').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine active semantic color
    final feedbackColor = isDebt
        ? AppTheme.semanticRed
        : AppTheme.semanticGreen;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
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
                    left: isDebt ? 0 : tabWidth,
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
                          onTap: () => setState(() => isDebt = true),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Text(
                              'Saya Hutang',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDebt
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
                          onTap: () => setState(() => isDebt = false),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Text(
                              'Pinjamkan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !isDebt
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
                        // Amount Section - Larger
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Jumlah Nominal',
                                style: TextStyle(
                                  color: AppTheme.lightTextSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              // Amount Display (no keyboard input)
                              Text(
                                'Rp ${CurrencyFormatter.format(_amount)}',
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: feedbackColor,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Details Card
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
                                offset: const Offset(0, -3),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Contact Field - Text Input
                              _buildContactField(),
                              SizedBox(height: 10.h),

                              // Transaction Date
                              _buildDateField(
                                icon: Icons.calendar_today_outlined,
                                label: 'Tanggal Transaksi',
                                value: _getDateLabel(_transactionDate),
                                onTap: _selectTransactionDate,
                              ),
                              SizedBox(height: 10.h),

                              // Due Date Toggle Row
                              _buildDueDateField(),
                              SizedBox(height: 10.h),

                              // Wallet Field
                              _buildWalletField(),
                              SizedBox(height: 10.h),

                              // Notes
                              _buildNotesField(),
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
              12.h,
              20.w,
              MediaQuery.of(context).padding.bottom + 16.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              border: const Border(
                top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Numpad
                CustomNumpad(
                  onKeyPressed: _onKeyPressed,
                  onDelete: _onDelete,
                  onSubmit: _saveDebt,
                  submitColor: feedbackColor,
                ),
                SizedBox(height: 12.h),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _saveDebt,
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

  Widget _buildContactField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            color: AppTheme.lightTextSecondary,
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kontak',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.lightTextSecondary,
                  ),
                ),
                TextField(
                  controller: _contactController,
                  cursorColor: const Color(0xFF6B7280),
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama kontak...',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.lightTextSecondary, size: 18.sp),
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
                  SizedBox(height: 1.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueDateField() {
    return GestureDetector(
      onTap: _hasDueDate ? _selectDueDate : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_available_outlined,
              color: AppTheme.lightTextSecondary,
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jatuh Tempo',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppTheme.lightTextSecondary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _hasDueDate ? _getDateLabel(_dueDate) : 'Tidak ada',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: _hasDueDate
                          ? const Color(0xFF1F2937)
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.7,
              child: CupertinoSwitch(
                value: _hasDueDate,
                activeColor: AppTheme.primaryBlue,
                onChanged: (val) => setState(() => _hasDueDate = val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: AppTheme.lightTextSecondary,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Catatan',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _noteController,
            maxLines: 4,
            minLines: 2,
            cursorColor: const Color(0xFF6B7280),
            decoration: InputDecoration(
              hintText: 'Tulis catatan di sini...',
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
        ],
      ),
    );
  }

  Widget _buildWalletField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Wallet Header Row
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => _isWalletDropdownOpen = !_isWalletDropdownOpen);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  // Wallet Icon
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: (Color(
                        _selectedWallet?.iconColor ?? 0xFFE8F0FE,
                      )).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: CategoryIcon(
                      iconName: _selectedWallet?.icon ?? 'wallet',
                      color: Color(_selectedWallet?.iconColor ?? 0xFF1976D2),
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Akun / Wallet',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppTheme.lightTextSecondary,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          _selectedWallet?.name ?? 'Pilih Wallet',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: _selectedWallet != null
                                ? const Color(0xFF1F2937)
                                : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isWalletDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.lightTextSecondary,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),

          // Divider when open
          if (_isWalletDropdownOpen)
            Container(height: 1, color: const Color(0xFFE5E7EB)),

          // Expandable Wallet List
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isWalletDropdownOpen
                ? (_wallets.length * 52.0).clamp(0.0, 208.0)
                : 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(9.r),
                bottomRight: Radius.circular(9.r),
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: _wallets.map((wallet) {
                    final isSelected = _selectedWallet?.id == wallet.id;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedWallet = wallet;
                          _isWalletDropdownOpen = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF3F4F6)
                              : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: Color(
                                  wallet.iconColor,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              alignment: Alignment.center,
                              child: CategoryIcon(
                                iconName: wallet.icon,
                                color: Color(wallet.iconColor),
                                size: 16.sp,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wallet.name,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Saldo: Rp ${CurrencyFormatter.format(wallet.currentBalance.toStringAsFixed(0))}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppTheme.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
