import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/presentation/components/saku_toast.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../components/custom_numpad.dart';

/// Halaman untuk menyelaraskan/mengepaskan saldo riil dompet dengan saldo tercatat
class AdjustBalancePage extends StatefulWidget {
  final Wallet? preselectedWallet;
  final List<Wallet>? wallets;

  const AdjustBalancePage({
    super.key,
    this.preselectedWallet,
    this.wallets,
  });

  @override
  State<AdjustBalancePage> createState() => _AdjustBalancePageState();
}

class _AdjustBalancePageState extends State<AdjustBalancePage> {
  late final AppDatabase _db;
  List<Wallet> _wallets = [];
  Wallet? _selectedWallet;
  String _targetAmount = '0';
  bool _isNumpadVisible = false;
  bool _isLoading = true;

  final FocusNode _noteFocusNode = FocusNode();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _db = locator<AppDatabase>();
    _initData();
  }

  Future<void> _initData() async {
    if (widget.wallets != null && widget.wallets!.isNotEmpty) {
      _wallets = widget.wallets!;
    } else {
      _wallets = await _db.walletDao.getAllWallets();
    }

    if (_wallets.isNotEmpty) {
      if (widget.preselectedWallet != null) {
        _selectedWallet = _wallets.firstWhere(
          (w) => w.id == widget.preselectedWallet!.id,
          orElse: () => _wallets.first,
        );
      } else {
        _selectedWallet = _wallets.first;
      }
      _targetAmount = _selectedWallet!.currentBalance.toStringAsFixed(0);
      _updateDefaultNote();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateDefaultNote() {
    if (_selectedWallet != null && _noteController.text.isEmpty) {
      final isIndo = context.l10n.isIndonesian;
      _noteController.text = isIndo
          ? 'Penyesuaian saldo ${_selectedWallet!.name}'
          : 'Balance adjustment ${_selectedWallet!.name}';
    }
  }

  @override
  void dispose() {
    _noteFocusNode.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (_targetAmount == '0') {
        _targetAmount = value;
      } else {
        _targetAmount += value;
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_targetAmount.isNotEmpty) {
        _targetAmount = _targetAmount.substring(0, _targetAmount.length - 1);
        if (_targetAmount.isEmpty) {
          _targetAmount = '0';
        }
      }
    });
  }

  double get _currentBalance => _selectedWallet?.currentBalance ?? 0.0;
  double get _targetBalance => double.tryParse(_targetAmount) ?? 0.0;
  double get _diff => _targetBalance - _currentBalance;
  bool get _isIncome => _diff > 0;
  bool get _isExpense => _diff < 0;
  double get _absDiff => _diff.abs();

  Future<void> _selectDate() async {
    _noteFocusNode.unfocus();
    FocusScope.of(context).unfocus();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: const Color(0xFF10B981),
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (!mounted) return;
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
    _noteFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  Future<void> _selectTime() async {
    _noteFocusNode.unfocus();
    FocusScope.of(context).unfocus();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: const Color(0xFF10B981),
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (!mounted) return;
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
    _noteFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  void _showWalletPicker() {
    _noteFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    setState(() => _isNumpadVisible = false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final cs = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final l10n = ctx.l10n;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
                blurRadius: 20.r,
                offset: Offset(0, -3.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              SizedBox(height: 8.h),
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Header Title & Close Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.selectWallet,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16.sp,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),
              Divider(
                height: 1.h,
                thickness: 1.h,
                color: cs.outlineVariant.withValues(alpha: 0.2),
              ),

              // Balanced Modern Wallet List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  itemCount: _wallets.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (ctx, i) {
                    final w = _wallets[i];
                    final isSelected = w.id == _selectedWallet?.id;
                    final walletColor = Color(w.iconColor);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedWallet = w;
                            _targetAmount =
                                w.currentBalance.toStringAsFixed(0);
                            _updateDefaultNote();
                          });
                        },
                        borderRadius: BorderRadius.circular(14.r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(
                            horizontal: 13.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                    : const Color(0xFF10B981).withValues(alpha: 0.06))
                                : (isDark
                                    ? cs.surfaceContainerLow
                                    : cs.surface),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF10B981)
                                  : cs.outline.withValues(alpha: 0.08),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon container
                              Container(
                                width: 38.w,
                                height: 38.w,
                                decoration: BoxDecoration(
                                  color: walletColor,
                                  borderRadius: BorderRadius.circular(11.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: walletColor.withValues(alpha: 0.25),
                                      blurRadius: 6.r,
                                      offset: Offset(0, 2.h),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CategoryIcon(
                                    iconName: w.icon,
                                    color: Colors.white,
                                    size: 17.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 11.w),

                              // Info Column (Name, Type & Balance)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 5.5.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cs.onSurface
                                                .withValues(alpha: 0.06),
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                          ),
                                          child: Text(
                                            w.type.toUpperCase(),
                                            style: TextStyle(
                                              color: cs.onSurfaceVariant,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 8.5.sp,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 7.w),
                                        Expanded(
                                          child: Text(
                                            w.name,
                                            style: TextStyle(
                                              fontSize: 13.5.sp,
                                              fontWeight: FontWeight.w600,
                                              color: cs.onSurface,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 3.h),
                                    Row(
                                      children: [
                                        Text(
                                          '${l10n.isIndonesian ? 'Saldo' : 'Balance'}: ',
                                          style: TextStyle(
                                            fontSize: 11.5.sp,
                                            color: cs.onSurfaceVariant
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                        Text(
                                          'Rp ${CurrencyFormatter.format(w.currentBalance.toStringAsFixed(0))}',
                                          style: TextStyle(
                                            fontSize: 11.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: w.currentBalance < 0
                                                ? const Color(0xFFEF4444)
                                                : cs.onSurface.withValues(alpha: 0.85),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Selection Indicator (Radio checkmark)
                              SizedBox(width: 8.w),
                              if (isSelected)
                                Container(
                                  width: 18.w,
                                  height: 18.w,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 12.sp,
                                  ),
                                )
                              else
                                Container(
                                  width: 18.w,
                                  height: 18.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: cs.outline.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
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
              SizedBox(height: 6.h),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveAdjustment() async {
    final l10n = context.l10n;
    if (_selectedWallet == null) return;
    if (_diff == 0) {
      SakuToast.showInfo(context, l10n.noAdjustmentNeeded);
      return;
    }

    final type = _isIncome ? 'income' : 'expense';
    final category = await _db.categoryDao.getOrCreateAdjustmentCategory(type);

    final fullDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final noteText = _noteController.text.trim();
    final descriptionText = noteText.isNotEmpty
        ? noteText
        : (_isIncome
            ? (l10n.isIndonesian ? 'Penyesuaian Masuk' : 'Adjustment In')
            : (l10n.isIndonesian ? 'Penyesuaian Keluar' : 'Adjustment Out'));

    final detailedNote = l10n.isIndonesian
        ? 'Penyesuaian saldo ${_selectedWallet!.name} dari Rp ${CurrencyFormatter.format(_currentBalance.toStringAsFixed(0))} ke Rp ${CurrencyFormatter.format(_targetBalance.toStringAsFixed(0))}${noteText.isNotEmpty ? ' ($noteText)' : ''}'
        : 'Balance adjustment ${_selectedWallet!.name} from Rp ${CurrencyFormatter.format(_currentBalance.toStringAsFixed(0))} to Rp ${CurrencyFormatter.format(_targetBalance.toStringAsFixed(0))}${noteText.isNotEmpty ? ' ($noteText)' : ''}';

    await _db.transactionDao.createTransaction(
      TransactionsCompanion(
        walletId: Value(_selectedWallet!.id),
        categoryId: Value(category.id),
        amount: Value(_absDiff),
        type: Value(type),
        description: Value(descriptionText),
        note: Value(detailedNote),
        transactionDate: Value(fullDateTime),
      ),
    );

    if (!mounted) return;

    SakuToast.showSuccess(
      context,
      l10n.balanceAdjustedSuccess(
        _selectedWallet!.name,
        CurrencyFormatter.format(_targetBalance.toStringAsFixed(0)),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(l10n.adjustBalanceTitle),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _noteFocusNode.unfocus();
        FocusScope.of(context).unfocus();
        setState(() => _isNumpadVisible = false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: cs.onSurface,
              size: 18.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.adjustBalanceTitle,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Kartu Pemilihan Dompet
                      _buildWalletCard(cs, isDark),
                      SizedBox(height: 10.h),

                      // 2. Kartu Input Saldo Riil Target
                      _buildTargetInputCard(cs, isDark),
                      SizedBox(height: 10.h),

                      // 3. Komparasi Selisih Real-Time
                      _buildDifferenceCard(cs, isDark),
                      SizedBox(height: 10.h),

                      // 4. Tanggal & Catatan
                      _buildDetailsCard(cs, isDark),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),

              // 5. Numpad Section
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {}, // Prevent taps inside numpad from bubbling to root onTap
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  child: _isNumpadVisible
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.3 : 0.05,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 6.h,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          l10n.isIndonesian
                                              ? 'Keypad Numerik'
                                              : 'Numeric Keypad',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => setState(
                                            () => _isNumpadVisible = false,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(4.w),
                                            child: Icon(
                                              Icons.keyboard_hide_rounded,
                                              size: 18.sp,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomNumpad(
                                    onKeyPressed: _onKeyPressed,
                                    onDelete: _onDelete,
                                    onSubmit: () => setState(
                                      () => _isNumpadVisible = false,
                                    ),
                                    submitColor: _isExpense
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF10B981),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),

              // 6. Tombol Aksi Simpan
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {}, // Prevent taps on button bar from closing numpad unexpectedly
                child: _buildBottomButton(cs, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(ColorScheme cs, bool isDark) {
    if (_selectedWallet == null) return const SizedBox.shrink();
    final w = _selectedWallet!;
    final l10n = context.l10n;

    return SakuCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      borderRadius: 16.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.isIndonesian
                    ? 'Rekening yang Disesuaikan'
                    : 'Account to Adjust',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              InkWell(
                onTap: _showWalletPicker,
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Text(
                        l10n.changeWallet,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14.sp,
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          InkWell(
            onTap: _showWalletPicker,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Color(w.iconColor),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: CategoryIcon(
                        iconName: w.icon,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.name,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Text(
                              '${l10n.recordedBalance}: ',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: cs.onSurfaceVariant.withValues(alpha: 0.75),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Rp ${CurrencyFormatter.format(w.currentBalance.toStringAsFixed(0))}',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: w.currentBalance < 0
                                      ? const Color(0xFFEF4444)
                                      : cs.onSurface.withValues(alpha: 0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.unfold_more_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetInputCard(ColorScheme cs, bool isDark) {
    final l10n = context.l10n;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _noteFocusNode.unfocus();
        FocusScope.of(context).unfocus();
        setState(() => _isNumpadVisible = !_isNumpadVisible);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: _isNumpadVisible
              ? Border.all(color: const Color(0xFF10B981), width: 1.5)
              : null,
        ),
        child: SakuCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          borderRadius: 16.r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.actualBalance,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Icon(
                        _isNumpadVisible
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.edit_note_rounded,
                        size: 16.sp,
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      l10n.physicalBankMoney,
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Rp',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      CurrencyFormatter.format(_targetAmount),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (_targetAmount != '0')
                    GestureDetector(
                      onTap: () => setState(() => _targetAmount = '0'),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: cs.onSurfaceVariant,
                          size: 15.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifferenceCard(ColorScheme cs, bool isDark) {
    final l10n = context.l10n;
    Color badgeColor;
    Color badgeBg;
    String badgeText;
    String statusTitle;
    String explanation;
    IconData statusIcon;

    if (_diff > 0) {
      badgeColor = const Color(0xFF10B981);
      badgeBg = const Color(0xFF10B981).withValues(alpha: 0.12);
      badgeText = '+ Rp ${CurrencyFormatter.format(_absDiff.toStringAsFixed(0))}';
      statusTitle = l10n.adjustIncome;
      explanation = l10n.adjustIncomeDesc(
        CurrencyFormatter.format(_absDiff.toStringAsFixed(0)),
      );
      statusIcon = Icons.trending_up_rounded;
    } else if (_diff < 0) {
      badgeColor = const Color(0xFFEF4444);
      badgeBg = const Color(0xFFEF4444).withValues(alpha: 0.12);
      badgeText = '- Rp ${CurrencyFormatter.format(_absDiff.toStringAsFixed(0))}';
      statusTitle = l10n.adjustExpense;
      explanation = l10n.adjustExpenseDesc(
        CurrencyFormatter.format(_absDiff.toStringAsFixed(0)),
      );
      statusIcon = Icons.trending_down_rounded;
    } else {
      badgeColor = cs.onSurfaceVariant;
      badgeBg = cs.surfaceContainerHighest;
      badgeText = l10n.isIndonesian ? 'Rp 0 (Pas)' : 'Rp 0 (Matched)';
      statusTitle = l10n.balanceMatched;
      explanation = l10n.balanceMatchedDesc;
      statusIcon = Icons.check_circle_outline_rounded;
    }

    return SakuCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      borderRadius: 16.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(7.r),
                ),
                child: Icon(statusIcon, color: badgeColor, size: 15.sp),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  statusTitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(7.r),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14.sp,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                      height: 1.35,
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

  Widget _buildDetailsCard(ColorScheme cs, bool isDark) {
    final l10n = context.l10n;
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', l10n.dateLocaleCode);
    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    final timeString = timeFormat.format(
      DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute),
    );

    return SakuCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      borderRadius: 16.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tanggal & Waktu
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(9.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14.sp,
                          color: const Color(0xFF10B981),
                        ),
                        SizedBox(width: 7.w),
                        Expanded(
                          child: Text(
                            dateFormat.format(_selectedDate),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(9.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14.sp,
                        color: const Color(0xFF10B981),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),

          // Catatan Field
          Text(
            l10n.noteOptional,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 5.h),
          TextField(
            controller: _noteController,
            focusNode: _noteFocusNode,
            onTap: () {
              setState(() => _isNumpadVisible = false);
            },
            style: TextStyle(
              fontSize: 12.5.sp,
              color: cs.onSurface,
            ),
            decoration: InputDecoration(
              hintText: l10n.isIndonesian
                  ? 'Tulis keterangan penyesuaian...'
                  : 'Write adjustment note...',
              hintStyle: TextStyle(
                fontSize: 11.5.sp,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: cs.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(ColorScheme cs, bool isDark) {
    final l10n = context.l10n;
    final canSave = _diff != 0 && _selectedWallet != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: canSave ? _saveAdjustment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF10B981) : const Color(0xFF111111),
            disabledBackgroundColor: isDark
                ? cs.surfaceContainerHigh
                : const Color(0xFFE5E7EB),
            foregroundColor: Colors.white,
            disabledForegroundColor: isDark
                ? cs.onSurfaceVariant.withValues(alpha: 0.4)
                : const Color(0xFF9CA3AF),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Text(
            l10n.saveAdjustment,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
