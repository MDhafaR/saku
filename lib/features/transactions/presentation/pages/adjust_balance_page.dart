import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/injection.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/presentation/components/saku_card.dart';
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
      _noteController.text = 'Penyesuaian saldo ${_selectedWallet!.name}';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Pilih Rekening / Dompet',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 12.h),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _wallets.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (ctx, i) {
                      final w = _wallets[i];
                      final isSelected = w.id == _selectedWallet?.id;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedWallet = w;
                            _targetAmount =
                                w.currentBalance.toStringAsFixed(0);
                            _updateDefaultNote();
                          });
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF10B981)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
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
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      w.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Saldo: Rp ${CurrencyFormatter.format(w.currentBalance.toStringAsFixed(0))}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: const Color(0xFF10B981),
                                  size: 20.sp,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAdjustment() async {
    if (_selectedWallet == null) return;
    if (_diff == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Saldo riil sama dengan saldo tercatat, tidak ada perubahan yang perlu disimpan.',
          ),
          backgroundColor: Colors.grey.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
        : (_isIncome ? 'Penyesuaian Masuk' : 'Penyesuaian Keluar');

    final detailedNote =
        'Penyesuaian saldo ${_selectedWallet!.name} dari Rp ${CurrencyFormatter.format(_currentBalance.toStringAsFixed(0))} ke Rp ${CurrencyFormatter.format(_targetBalance.toStringAsFixed(0))}${noteText.isNotEmpty ? ' ($noteText)' : ''}';

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Saldo ${_selectedWallet!.name} berhasil disesuaikan menjadi Rp ${CurrencyFormatter.format(_targetBalance.toStringAsFixed(0))}',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: const Text('Ngepasin Saldo'),
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
            'Ngepasin Saldo',
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
                      SizedBox(height: 12.h),

                      // 2. Kartu Input Saldo Riil Target
                      _buildTargetInputCard(cs, isDark),
                      SizedBox(height: 12.h),

                      // 3. Komparasi Selisih Real-Time
                      _buildDifferenceCard(cs, isDark),
                      SizedBox(height: 12.h),

                      // 4. Tanggal & Catatan
                      _buildDetailsCard(cs, isDark),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),

              // 5. Numpad Section
              AnimatedSize(
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
                                        'Keypad Numerik',
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

              // 6. Tombol Aksi Simpan
              _buildBottomButton(cs, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(ColorScheme cs, bool isDark) {
    if (_selectedWallet == null) return const SizedBox.shrink();
    final w = _selectedWallet!;

    return SakuCard(
      padding: EdgeInsets.all(14.w),
      borderRadius: 16.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rekening yang Disesuaikan',
                style: TextStyle(
                  fontSize: 11.sp,
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
                        'Ganti',
                        style: TextStyle(
                          fontSize: 11.sp,
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
          SizedBox(height: 10.h),
          InkWell(
            onTap: _showWalletPicker,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: Color(w.iconColor),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: CategoryIcon(
                        iconName: w.icon,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Saldo Tercatat di Saku: Rp ${CurrencyFormatter.format(w.currentBalance.toStringAsFixed(0))}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.unfold_more_rounded,
                    color: cs.onSurfaceVariant,
                    size: 20.sp,
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Saldo Riil Sebenarnya',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 6.w),
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
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Uang Fisik / Bank',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Rp',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      CurrencyFormatter.format(_targetAmount),
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (_targetAmount != '0')
                    IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 20.sp,
                      ),
                      onPressed: () => setState(() => _targetAmount = '0'),
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
      statusTitle = 'Pendapatan Penyesuaian Saldo';
      explanation =
          'Saldo riil lebih besar dari saldo di aplikasi. Saku akan mencatat penyesuaian masuk sebesar Rp ${CurrencyFormatter.format(_absDiff.toStringAsFixed(0))} agar saldo menjadi pas.';
      statusIcon = Icons.trending_up_rounded;
    } else if (_diff < 0) {
      badgeColor = const Color(0xFFEF4444);
      badgeBg = const Color(0xFFEF4444).withValues(alpha: 0.12);
      badgeText = '- Rp ${CurrencyFormatter.format(_absDiff.toStringAsFixed(0))}';
      statusTitle = 'Pengeluaran Penyesuaian Saldo';
      explanation =
          'Saldo riil lebih kecil dari saldo di aplikasi. Saku akan mencatat penyesuaian keluar sebesar Rp ${CurrencyFormatter.format(_absDiff.toStringAsFixed(0))} agar saldo menjadi pas.';
      statusIcon = Icons.trending_down_rounded;
    } else {
      badgeColor = cs.onSurfaceVariant;
      badgeBg = cs.surfaceContainerHighest;
      badgeText = 'Rp 0 (Pas)';
      statusTitle = 'Saldo Sudah Sesuai';
      explanation =
          'Saldo riil sama persis dengan saldo tercatat di aplikasi. Tidak ada transaksi penyesuaian yang perlu dibuat.';
      statusIcon = Icons.check_circle_outline_rounded;
    }

    return SakuCard(
      padding: EdgeInsets.all(14.w),
      borderRadius: 16.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(statusIcon, color: badgeColor, size: 16.sp),
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
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15.sp,
                  color: cs.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: cs.onSurfaceVariant,
                      height: 1.4,
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
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    final timeString = timeFormat.format(
      DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute),
    );

    return SakuCard(
      padding: EdgeInsets.all(14.w),
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
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 15.sp,
                          color: const Color(0xFF10B981),
                        ),
                        SizedBox(width: 8.w),
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
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 15.sp,
                        color: const Color(0xFF10B981),
                      ),
                      SizedBox(width: 6.w),
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
          SizedBox(height: 12.h),

          // Catatan Field
          Text(
            'Catatan (Opsional)',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _noteController,
            focusNode: _noteFocusNode,
            onTap: () {
              setState(() => _isNumpadVisible = false);
            },
            style: TextStyle(
              fontSize: 13.sp,
              color: cs.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Tulis keterangan penyesuaian...',
              hintStyle: TextStyle(
                fontSize: 12.sp,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: cs.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(ColorScheme cs, bool isDark) {
    final canSave = _diff != 0 && _selectedWallet != null;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? cs.surface,
        border: Border(
          top: BorderSide(
            color: cs.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: canSave ? _saveAdjustment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.12),
            foregroundColor: Colors.white,
            disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_rounded,
                size: 18.sp,
                color: canSave ? Colors.white : cs.onSurface.withValues(alpha: 0.38),
              ),
              SizedBox(width: 8.w),
              Text(
                'Simpan Penyesuaian Saldo',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
