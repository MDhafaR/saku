import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/presentation/components/saku_toast.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../cubit/debt_cubit.dart';

class DebtDetailPage extends StatefulWidget {
  final Debt debt;
  final String personName;
  final String? phone;

  const DebtDetailPage({
    super.key,
    required this.debt,
    required this.personName,
    this.phone,
  });

  @override
  State<DebtDetailPage> createState() => _DebtDetailPageState();
}

class _DebtDetailPageState extends State<DebtDetailPage> {
  final DebtCubit _cubit = locator<DebtCubit>();
  List<DebtPayment> _payments = [];
  bool _isLoading = true;
  Debt? _debt;

  Future<void> _handleCall() async {
    final l10n = context.l10n;
    final phone = widget.phone;
    if (phone == null || phone.trim().isEmpty) {
      if (mounted) {
        SakuToast.showInfo(
          context,
          l10n.isIndonesian
              ? 'Nomor telepon tidak tersimpan'
              : 'Phone number not saved',
        );
      }
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  void initState() {
    super.initState();
    _debt = widget.debt;
    _loadData();
  }

  Future<void> _loadData() async {
    final debt = await _cubit.getDebt(widget.debt.id);
    final payments = await _cubit.getPayments(widget.debt.id);

    if (mounted) {
      if (debt == null) {
        // Debt might have been deleted
        Navigator.pop(context);
        return;
      }
      setState(() {
        _debt = debt;
        _payments = payments;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.isIndonesian ? 'Hapus Data?' : 'Delete Record?'),
        content: Text(
          l10n.isIndonesian
              ? 'Data yang dihapus tidak dapat dikembalikan. Lanjutkan?'
              : 'Deleted data cannot be recovered. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.semanticRed),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _cubit.deleteDebt(widget.debt.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleMarkAsPaid(double remaining) async {
    await _showPaymentDialog(initialAmount: remaining);
  }

  Future<void> _handleUndoPayment() async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.isIndonesian ? 'Batalkan Pelunasan?' : 'Cancel Settlement?',
        ),
        content: Text(
          l10n.isIndonesian
              ? 'Pembayaran terakhir akan dihapus dan status akan kembali ke sebelumnya.'
              : 'The last payment will be removed and status will revert.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.isIndonesian ? 'Tidak' : 'No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.semanticRed),
            child: Text(l10n.isIndonesian ? 'Ya, Batalkan' : 'Yes, Undo'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _cubit.deleteLastPayment(widget.debt.id);
      _loadData();
    }
  }

  Future<void> _showPaymentDialog({double? initialAmount}) async {
    final l10n = context.l10n;
    final debt = _debt ?? widget.debt;
    final remaining = (debt.totalAmount - debt.paidAmount).clamp(0.0, double.infinity);
    final wallets = await _cubit.getWallets();
    if (wallets.isEmpty) {
      if (mounted) {
        SakuToast.showWarning(
          context,
          l10n.isIndonesian ? 'Belum ada wallet' : 'No wallet available',
        );
      }
      return;
    }

    if (!mounted) return;

    Wallet selectedWallet = wallets.first;
    final amountController = TextEditingController(
      text: initialAmount != null && initialAmount > 0
          ? initialAmount.toStringAsFixed(0)
          : (remaining > 0 ? remaining.toStringAsFixed(0) : ''),
    );
    final noteController = TextEditingController(
      text: initialAmount != null
          ? (l10n.isIndonesian ? 'Pelunasan' : 'Settlement')
          : '',
    );
    bool isWalletDropdownOpen = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final cs = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag Handle
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
                    SizedBox(height: 12.h),

                    // Header: Title & Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.isIndonesian ? 'Catat Pembayaran' : 'Record Payment',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (remaining > 0) ...[
                              SizedBox(height: 2.h),
                              Text(
                                '${l10n.isIndonesian ? 'Sisa tagihan' : 'Remaining'}: Rp ${_formatPrice(remaining)}',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
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

                    SizedBox(height: 16.h),

                    // 1. Amount Field Card (Clean Borderless Input)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isDark
                              ? cs.outline.withValues(alpha: 0.2)
                              : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.amountLabel,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              if (remaining > 0)
                                GestureDetector(
                                  onTap: () {
                                    amountController.text = remaining.toStringAsFixed(0);
                                    setModalState(() {});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.semanticGreen.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      l10n.isIndonesian ? 'Bayar Penuh' : 'Pay Full',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.semanticGreen,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Rp ',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppTheme.semanticGreen
                                      : const Color(0xFF111111),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: amountController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: isDark
                                      ? AppTheme.semanticGreen
                                      : const Color(0xFF111111),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurface.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                              ),
                              if (amountController.text.isNotEmpty && amountController.text != '0')
                                GestureDetector(
                                  onTap: () {
                                    amountController.clear();
                                    setModalState(() {});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: cs.onSurface.withValues(alpha: 0.06),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: cs.onSurfaceVariant,
                                      size: 14.sp,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // 2. Source Wallet Selector Card (Inline Expandable Accordion)
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isDark
                              ? cs.outline.withValues(alpha: 0.2)
                              : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header (Tappable Row)
                          InkWell(
                            onTap: () {
                              setModalState(() {
                                isWalletDropdownOpen = !isWalletDropdownOpen;
                              });
                            },
                            borderRadius: BorderRadius.circular(14.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32.w,
                                    height: 32.w,
                                    decoration: BoxDecoration(
                                      color: Color(selectedWallet.iconColor),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Center(
                                      child: CategoryIcon(
                                        iconName: selectedWallet.icon,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.isIndonesian ? 'Sumber Dana' : 'Source Wallet',
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            fontWeight: FontWeight.w500,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        Text(
                                          selectedWallet.name,
                                          style: TextStyle(
                                            fontSize: 13.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: cs.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Rp ${CurrencyFormatter.format(selectedWallet.currentBalance.toStringAsFixed(0))}',
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: selectedWallet.currentBalance < 0
                                              ? AppTheme.semanticRed
                                              : cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    isWalletDropdownOpen
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: cs.onSurfaceVariant,
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expandable Options
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 200),
                            crossFadeState: isWalletDropdownOpen
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: const SizedBox.shrink(),
                            secondChild: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Divider(
                                  height: 1,
                                  color: isDark
                                      ? cs.outline.withValues(alpha: 0.15)
                                      : const Color(0xFFE5E7EB),
                                ),
                                ...wallets.map((w) {
                                  final isSelected = w.id == selectedWallet.id;
                                  return InkWell(
                                    onTap: () {
                                      setModalState(() {
                                        selectedWallet = w;
                                        isWalletDropdownOpen = false;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                        vertical: 9.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isDark
                                                ? AppTheme.semanticGreen.withValues(alpha: 0.1)
                                                : AppTheme.semanticGreen.withValues(alpha: 0.06))
                                            : Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 26.w,
                                            height: 26.w,
                                            decoration: BoxDecoration(
                                              color: Color(w.iconColor),
                                              borderRadius: BorderRadius.circular(7.r),
                                            ),
                                            child: Center(
                                              child: CategoryIcon(
                                                iconName: w.icon,
                                                color: Colors.white,
                                                size: 13.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Text(
                                              w.name,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? (isDark ? AppTheme.semanticGreen : const Color(0xFF111111))
                                                    : cs.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            'Rp ${CurrencyFormatter.format(w.currentBalance.toStringAsFixed(0))}',
                                            style: TextStyle(
                                              fontSize: 11.5.sp,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: w.currentBalance < 0
                                                  ? AppTheme.semanticRed
                                                  : cs.onSurfaceVariant,
                                            ),
                                          ),
                                          if (isSelected) ...[
                                            SizedBox(width: 6.w),
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: AppTheme.semanticGreen,
                                              size: 15.sp,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // 3. Note Field Card
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isDark
                              ? cs.outline.withValues(alpha: 0.2)
                              : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.isIndonesian ? 'Catatan (Opsional)' : 'Note (Optional)',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.edit_note_rounded,
                                size: 18.sp,
                                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: noteController,
                                  cursorColor: isDark
                                      ? AppTheme.semanticGreen
                                      : const Color(0xFF111111),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: cs.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: l10n.isIndonesian
                                        ? 'Contoh: Pembayaran cicilan ke-1'
                                        : 'e.g., 1st installment payment',
                                    hintStyle: TextStyle(
                                      fontSize: 13.sp,
                                      color: cs.onSurface.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 18.h),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          final amount = double.tryParse(amountController.text.replaceAll('.', '').replaceAll(',', ''));
                          if (amount == null || amount <= 0) return;

                          await _cubit.addPayment(
                            debtId: widget.debt.id,
                            walletId: selectedWallet.id,
                            amount: amount,
                            paymentDate: DateTime.now(),
                            note: noteController.text.trim().isNotEmpty
                                ? noteController.text.trim()
                                : (l10n.isIndonesian ? 'Pembayaran' : 'Payment'),
                          );

                          if (context.mounted) Navigator.pop(context);
                          _loadData(); // Refresh history
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppTheme.semanticGreen
                              : const Color(0xFF111111),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.saveButton,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final debt = _debt ?? widget.debt;
    final remaining = debt.totalAmount - debt.paidAmount;
    final percentPaid = debt.totalAmount > 0
        ? (debt.paidAmount / debt.totalAmount).clamp(0.0, 1.0)
        : 0.0;

    // Status text logic
    String statusText = l10n.isIndonesian ? 'Belum Lunas' : 'Pending';
    Color statusColor = AppTheme.primaryBlue;
    Color statusBg = const Color(0xFFEFF6FF);

    if (debt.status == 'paid') {
      statusText = l10n.statusPaid;
      statusColor = AppTheme.semanticGreen;
      statusBg = const Color(0xFFECFDF5);
    } else if (debt.dueDate != null) {
      final now = DateTime.now();
      final diff = debt.dueDate!.difference(now).inDays;
      if (diff < 0) {
        statusText = l10n.isIndonesian
            ? 'Terlambat ${diff.abs()} Hari'
            : 'Overdue ${diff.abs()} Days';
        statusColor = AppTheme.semanticRed;
        statusBg = const Color(0xFFFFF0F0);
      } else if (diff <= 7) {
        statusText = l10n.isIndonesian
            ? 'Jatuh Tempo ${diff == 0 ? "Hari Ini" : "$diff Hari Lagi"}'
            : 'Due ${diff == 0 ? "Today" : "in $diff Days"}';
        statusColor = const Color(0xFFF59E0B);
        statusBg = const Color(0xFFFFFBEB);
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
            size: 18.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          debt.type == 'debt'
              ? (l10n.isIndonesian ? 'Detail Hutang' : 'Debt Details')
              : (l10n.isIndonesian ? 'Detail Pinjaman' : 'Loan Details'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            SakuCard(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: _getAvatarBackgroundColor(
                            widget.personName,
                          ).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(widget.personName),
                            style: TextStyle(
                              color: _getAvatarBackgroundColor(
                                widget.personName,
                              ),
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.personName,
                              style: TextStyle(
                                fontSize: 15.5.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.5.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.isIndonesian ? 'Sisa Tagihan' : 'Remaining Balance',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Rp ${_formatPrice(remaining)}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.isIndonesian ? 'Total' : 'Total',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Rp ${_formatPrice(debt.totalAmount)}',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // Progress Card
            SakuCard(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.isIndonesian ? 'Status Pelunasan' : 'Payment Status',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      InkWell(
                        onTap: percentPaid >= 1.0
                            ? _handleUndoPayment
                            : () => _handleMarkAsPaid(remaining),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: percentPaid >= 1.0
                                ? const Color(0xFFFFFBEB)
                                : AppTheme.semanticGreen.withValues(
                                    alpha: 0.1,
                                  ),
                            borderRadius: BorderRadius.circular(10.r),
                            border: percentPaid >= 1.0
                                ? Border.all(color: Colors.orange, width: 0.8)
                                : Border.all(color: AppTheme.semanticGreen, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                percentPaid >= 1.0
                                    ? Icons.undo
                                    : Icons.check_circle,
                                size: 13.sp,
                                color: percentPaid >= 1.0
                                    ? Colors.orange
                                    : AppTheme.semanticGreen,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                percentPaid >= 1.0
                                    ? (l10n.isIndonesian ? 'Batalkan' : 'Undo')
                                    : l10n.markAsPaid,
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: percentPaid >= 1.0
                                      ? Colors.orange
                                      : AppTheme.semanticGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: LinearProgressIndicator(
                      value: percentPaid,
                      minHeight: 6.h,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.semanticGreen,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.isIndonesian
                            ? '${(percentPaid * 100).toInt()}% Terbayar'
                            : '${(percentPaid * 100).toInt()}% Paid',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.semanticGreen,
                        ),
                      ),
                      Text(
                        l10n.isIndonesian
                            ? 'Sisa ${(100 - (percentPaid * 100)).toInt()}%'
                            : 'Remaining ${(100 - (percentPaid * 100)).toInt()}%',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // Action Buttons (Paired Structured Cards)
            Row(
              children: [
                // Call Button
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleCall,
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: AppTheme.semanticGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppTheme.semanticGreen.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppTheme.semanticGreen.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.phone_rounded,
                                color: AppTheme.semanticGreen,
                                size: 16.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              l10n.isIndonesian ? 'Hubungi' : 'Contact',
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.semanticGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // Delete Button
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleDelete,
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: AppTheme.semanticRed.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppTheme.semanticRed.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppTheme.semanticRed.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: AppTheme.semanticRed,
                                size: 16.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              l10n.delete,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.semanticRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // History Section Header
            Text(
              l10n.isIndonesian ? 'Riwayat Pembayaran' : 'Payment History',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_payments.isEmpty)
              SakuCard(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.isIndonesian
                            ? 'Belum Ada Pembayaran'
                            : 'No Payments Yet',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        l10n.isIndonesian
                            ? 'Riwayat cicilan atau pelunasan akan tercatat di sini'
                            : 'Payment installments or settlements will appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._payments.map(
                (payment) => _buildHistoryItem(
                  title: payment.note ??
                      (l10n.isIndonesian ? 'Pembayaran' : 'Payment'),
                  date: intl.DateFormat(
                    'dd MMM yyyy',
                    l10n.dateLocaleCode,
                  ).format(payment.paymentDate),
                  amount: '+Rp ${_formatPrice(payment.amount)}',
                  isSuccess: true,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: debt.status != 'paid'
          ? Container(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _showPaymentDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.semanticGreen
                          : const Color(0xFF111111),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.isIndonesian ? 'Catat Pembayaran' : 'Record Payment',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String date,
    required String amount,
    bool isSuccess = false,
  }) {
    return SakuCard(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isSuccess
                  ? const Color(0xFFECFDF5)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.payments_outlined,
              color: isSuccess
                  ? AppTheme.semanticGreen
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.semanticGreen,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return CurrencyFormatter.format(price.toStringAsFixed(0));
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getAvatarBackgroundColor(String name) {
    final colors = [
      const Color(0xFF6366F1), // Purple
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFFEC4899), // Pink
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}
