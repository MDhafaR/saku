import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/injection.dart';
import '../../../../core/localization/app_localizations.dart';
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
  bool _isNumpadVisible = false;
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _contactFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();
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
    _contactFocusNode.dispose();
    _noteFocusNode.dispose();
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
    _contactFocusNode.unfocus();
    _noteFocusNode.unfocus();
    FocusScope.of(context).unfocus();

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

    _contactFocusNode.unfocus();
    _noteFocusNode.unfocus();
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    if (picked != null) {
      setState(() => _transactionDate = picked);
    }
  }

  Future<void> _selectDueDate() async {
    _contactFocusNode.unfocus();
    _noteFocusNode.unfocus();
    FocusScope.of(context).unfocus();

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

    _contactFocusNode.unfocus();
    _noteFocusNode.unfocus();
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveDebt() async {
    final l10n = context.l10n;
    if (_amount == '0' || _contactController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.completeDataError)));
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

  String _getDateLabel(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return l10n.today;
    } else if (selectedDay == yesterday) {
      return l10n.yesterday;
    } else {
      return DateFormat('dd MMM yyyy', l10n.dateLocaleCode).format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
        actions: [
          SizedBox(width: 48.w), // Counterbalance leading IconButton for perfect screen centering
        ],
        centerTitle: true,
        title: SizedBox(
          width: 215.w,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerLow
                  : const Color(0xFFF3F4F6),
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
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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
                              _contactFocusNode.unfocus();
                              _noteFocusNode.unfocus();
                              FocusScope.of(context).unfocus();
                              setState(() => isDebt = true);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text(
                                l10n.iOwe,
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
                            onTap: () {
                              _contactFocusNode.unfocus();
                              _noteFocusNode.unfocus();
                              FocusScope.of(context).unfocus();
                              setState(() => isDebt = false);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text(
                                l10n.iLend,
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
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _contactFocusNode.unfocus();
          _noteFocusNode.unfocus();
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Amount Section - Interactive with Numpad Toggle
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _contactFocusNode.unfocus();
                            _noteFocusNode.unfocus();
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _isNumpadVisible = !_isNumpadVisible;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      l10n.nominalAmount,
                                      style: TextStyle(
                                        color: AppTheme.lightTextSecondary,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      _isNumpadVisible
                                          ? Icons.keyboard_arrow_down_rounded
                                          : Icons.edit_note_rounded,
                                      size: 16.sp,
                                      color: AppTheme.lightTextSecondary,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isNumpadVisible
                                        ? feedbackColor.withValues(alpha: 0.08)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: _isNumpadVisible
                                          ? feedbackColor.withValues(alpha: 0.3)
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Rp ${CurrencyFormatter.format(_amount)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: feedbackColor,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Details Card (Extends all the way down seamlessly)
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: (constraints.maxHeight - 88.h).clamp(
                              0.0,
                              double.infinity,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Contact Field - Text Input
                              _buildContactField(),
                              SizedBox(height: 10.h),

                              // Transaction Date
                              _buildDateField(
                                icon: Icons.calendar_today_outlined,
                                label: l10n.transactionDateLabel,
                                value: _getDateLabel(context, _transactionDate),
                                onTap: () {
                                  _contactFocusNode.unfocus();
                                  _noteFocusNode.unfocus();
                                  FocusScope.of(context).unfocus();
                                  if (_isNumpadVisible) {
                                    setState(() => _isNumpadVisible = false);
                                  }
                                  _selectTransactionDate();
                                },
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
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Collapsible Animated Numpad and Submit Button at bottom
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                20.w,
                10.h,
                20.w,
                MediaQuery.of(context).padding.bottom + 12.h,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Slide-Up / Slide-Down Numpad
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.topCenter,
                    child: _isNumpadVisible
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomNumpad(
                                onKeyPressed: _onKeyPressed,
                                onDelete: _onDelete,
                                onSubmit: () {
                                  setState(() => _isNumpadVisible = false);
                                },
                                submitColor: feedbackColor,
                              ),
                              SizedBox(height: 12.h),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

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
                        l10n.saveButton,
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
      ),
    );
  }

  Widget _buildContactField() {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark
              ? cs.outline.withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            color: cs.onSurface.withValues(alpha: 0.5),
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.contactLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                TextField(
                  controller: _contactController,
                  focusNode: _contactFocusNode,
                  cursorColor: cs.primary,
                  onTap: () {
                    if (_isNumpadVisible) {
                      setState(() => _isNumpadVisible = false);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: l10n.enterContactNameHint,
                    hintStyle: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontSize: 14.sp,
                    ),
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark
                ? cs.outline.withValues(alpha: 0.3)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: cs.onSurface.withValues(alpha: 0.5), size: 18.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
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
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        _contactFocusNode.unfocus();
        _noteFocusNode.unfocus();
        FocusScope.of(context).unfocus();
        if (_isNumpadVisible) {
          setState(() => _isNumpadVisible = false);
        }
        if (_hasDueDate) _selectDueDate();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark
                ? cs.outline.withValues(alpha: 0.3)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_available_outlined,
              color: cs.onSurface.withValues(alpha: 0.5),
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dueDateLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _hasDueDate ? _getDateLabel(context, _dueDate) : l10n.noDueDate,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: _hasDueDate
                          ? cs.onSurface
                          : cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.7,
              child: CupertinoSwitch(
                value: _hasDueDate,
                activeTrackColor: AppTheme.primaryBlue,
                onChanged: (val) => setState(() => _hasDueDate = val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark
              ? cs.outline.withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_outlined,
            color: cs.onSurface.withValues(alpha: 0.5),
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _noteController,
              focusNode: _noteFocusNode,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: cs.primary,
              onTap: () {
                if (_isNumpadVisible) {
                  setState(() => _isNumpadVisible = false);
                }
              },
              decoration: InputDecoration(
                hintText: l10n.writeNoteHint,
                hintStyle: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.4),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                ),
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletField() {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark
              ? cs.outline.withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Wallet Header Row
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _contactFocusNode.unfocus();
              _noteFocusNode.unfocus();
              FocusScope.of(context).unfocus();
              if (_isNumpadVisible) {
                setState(() => _isNumpadVisible = false);
              }
              setState(() => _isWalletDropdownOpen = !_isWalletDropdownOpen);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                          l10n.accountWalletLabel,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          _selectedWallet?.name ?? l10n.selectWallet,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: _selectedWallet != null
                                ? cs.onSurface
                                : cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isWalletDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: cs.onSurface.withValues(alpha: 0.5),
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),

          // Divider when open
          if (_isWalletDropdownOpen)
            Container(
              height: 1,
              color: isDark
                  ? cs.outline.withValues(alpha: 0.3)
                  : const Color(0xFFE5E7EB),
            ),

          // Expandable Wallet List
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isWalletDropdownOpen
                ? (_wallets.length * 52.0).clamp(0.0, 208.0)
                : 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(11.r),
                bottomRight: Radius.circular(11.r),
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
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFF3F4F6))
                              : Colors.transparent,
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
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    '${l10n.isIndonesian ? 'Saldo' : 'Balance'}: Rp ${CurrencyFormatter.format(wallet.currentBalance.toStringAsFixed(0))}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: cs.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
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
