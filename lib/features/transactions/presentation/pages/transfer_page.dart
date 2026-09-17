import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../../core/injection.dart';
import '../components/custom_numpad.dart';

enum TransferNumpadTarget { none, amount, adminFee }

class TransferPage extends StatefulWidget {
  final List<Wallet> wallets;

  const TransferPage({super.key, required this.wallets});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _adminFeeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isCustomAdminFee = false;
  bool _isSubmitting = false;
  TransferNumpadTarget _numpadTarget = TransferNumpadTarget.none;
  bool get _isNumpadVisible => _numpadTarget != TransferNumpadTarget.none;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _noteFocusNode = FocusNode();

  final GlobalKey _amountKey = GlobalKey();
  final GlobalKey _adminFeeKey = GlobalKey();
  final GlobalKey _noteKey = GlobalKey();

  // Selected Wallets
  Wallet? sourceWallet;
  Wallet? destinationWallet;

  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = locator<AppDatabase>();

    if (widget.wallets.isNotEmpty) {
      sourceWallet = widget.wallets[0];
    }
    if (widget.wallets.length > 1) {
      destinationWallet = widget.wallets[1];
    }

    _noteFocusNode.addListener(() {
      if (_noteFocusNode.hasFocus) {
        if (_numpadTarget != TransferNumpadTarget.none) {
          setState(() => _numpadTarget = TransferNumpadTarget.none);
        }
        _scrollToField(_noteKey);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _adminFeeController.dispose();
    _noteController.dispose();
    _scrollController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _onNumpadKeyPressed(String value) {
    if (_numpadTarget == TransferNumpadTarget.amount) {
      final currentRaw = CurrencyFormatter.parse(_amountController.text);
      String newRaw;
      if (currentRaw.isEmpty || currentRaw == '0') {
        newRaw = value == '000' ? '0' : value;
      } else {
        newRaw = currentRaw + value;
      }
      setState(() {
        _amountController.text = CurrencyFormatter.format(newRaw);
      });
    } else if (_numpadTarget == TransferNumpadTarget.adminFee) {
      final currentRaw = CurrencyFormatter.parse(_adminFeeController.text);
      String newRaw;
      if (currentRaw.isEmpty || currentRaw == '0') {
        newRaw = value == '000' ? '0' : value;
      } else {
        newRaw = currentRaw + value;
      }
      setState(() {
        _adminFeeController.text = CurrencyFormatter.format(newRaw);
      });
    }
  }

  void _onNumpadDelete() {
    if (_numpadTarget == TransferNumpadTarget.amount) {
      final currentRaw = CurrencyFormatter.parse(_amountController.text);
      if (currentRaw.isNotEmpty) {
        final newRaw = currentRaw.substring(0, currentRaw.length - 1);
        setState(() {
          _amountController.text =
              newRaw.isEmpty ? '0' : CurrencyFormatter.format(newRaw);
        });
      }
    } else if (_numpadTarget == TransferNumpadTarget.adminFee) {
      final currentRaw = CurrencyFormatter.parse(_adminFeeController.text);
      if (currentRaw.isNotEmpty) {
        final newRaw = currentRaw.substring(0, currentRaw.length - 1);
        setState(() {
          _adminFeeController.text =
              newRaw.isEmpty ? '' : CurrencyFormatter.format(newRaw);
          if (_adminFeeController.text.isEmpty) {
            _isCustomAdminFee = false;
          }
        });
      }
    }
  }

  void _scrollToField(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0,
        ).then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              final currentOffset = _scrollController.offset;
              final maxOffset = _scrollController.position.maxScrollExtent;
              final targetOffset = (currentOffset + 200).clamp(0.0, maxOffset);
              _scrollController.animateTo(
                targetOffset,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          });
        });
      }
    });
  }

  double get _totalAssets {
    return widget.wallets.fold<double>(
      0.0,
      (sum, wallet) => sum + wallet.currentBalance,
    );
  }

  Future<void> _submitTransfer() async {
    _noteFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    if (_isSubmitting) return;

    // Validate wallets selected
    if (sourceWallet == null || destinationWallet == null) {
      _showError('Pilih sumber dana dan penerima terlebih dahulu.');
      return;
    }

    // Validate not same wallet
    if (sourceWallet!.id == destinationWallet!.id) {
      _showError('Sumber dana dan penerima tidak boleh sama.');
      return;
    }

    // Parse amount
    final amountStr = CurrencyFormatter.parse(_amountController.text);
    final amount = double.tryParse(amountStr) ?? 0;
    if (amount <= 0) {
      _showError('Masukkan nominal transfer yang valid.');
      return;
    }

    // Parse fee
    double fee = 0;
    if (_isCustomAdminFee && _adminFeeController.text.isNotEmpty) {
      final feeStr = CurrencyFormatter.parse(_adminFeeController.text);
      fee = double.tryParse(feeStr) ?? 0;
    }

    setState(() => _isSubmitting = true);

    try {
      await _db.transferDao.createTransfer(
        TransfersCompanion(
          fromWalletId: Value(sourceWallet!.id),
          toWalletId: Value(destinationWallet!.id),
          amount: Value(amount),
          fee: Value(fee),
          description: Value(_noteController.text),
          transferDate: Value(DateTime.now()),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transfer Rp ${CurrencyFormatter.format(amount.toStringAsFixed(0))} berhasil!',
            ),
            backgroundColor: const Color(0xFF43A047),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true); // return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal melakukan transfer: $e');
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.semanticRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  bool _isSourceDropdownOpen = false;
  bool _isDestinationDropdownOpen = false;

  void _toggleSourceDropdown() {
    setState(() {
      _isSourceDropdownOpen = !_isSourceDropdownOpen;
      if (_isSourceDropdownOpen) {
        _isDestinationDropdownOpen = false;
      }
    });
  }

  void _toggleDestinationDropdown() {
    setState(() {
      _isDestinationDropdownOpen = !_isDestinationDropdownOpen;
      if (_isDestinationDropdownOpen) {
        _isSourceDropdownOpen = false;
      }
    });
  }

  Widget _buildWalletRow(Wallet wallet) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: Color(wallet.iconColor).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: CategoryIcon(
            iconName: wallet.icon,
            color: Color(wallet.iconColor),
            size: 18.sp,
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
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Saldo: Rp ${CurrencyFormatter.format(wallet.currentBalance.toStringAsFixed(0))}',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletDropdownList({
    required Wallet? selectedWallet,
    required bool isOpen,
    required ValueChanged<Wallet> onSelect,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listBgColor = isDark
        ? Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
        : const Color(0xFFF5F7FA);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isOpen ? (widget.wallets.length * 56.0.h).clamp(0, 200.h) : 0,
      child: Container(
        margin: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 6.h),
        decoration: BoxDecoration(
          color: listBgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            children: widget.wallets.map((wallet) {
              final isSelected = selectedWallet?.id == wallet.id;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelect(wallet),
                  child: Container(
                    color: isSelected
                        ? (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03))
                        : Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 9.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            color: Color(
                              wallet.iconColor,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                          alignment: Alignment.center,
                          child: CategoryIcon(
                            iconName: wallet.icon,
                            color: Color(wallet.iconColor),
                            size: 17.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                wallet.name,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Rp ${CurrencyFormatter.format(wallet.currentBalance.toStringAsFixed(0))}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryBlue,
                            size: 17.sp,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, size: 20.sp),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pindah Buku',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _noteFocusNode.unfocus();
          FocusScope.of(context).unfocus();
          if (_numpadTarget != TransferNumpadTarget.none) {
            setState(() => _numpadTarget = TransferNumpadTarget.none);
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Assets Summary Row Inside Page
                    Container(
                      margin: EdgeInsets.only(bottom: 10.h, top: 10.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 16.sp,
                                color: AppTheme.lightTextSecondary,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Total Aset',
                                style: TextStyle(
                                  color: AppTheme.lightTextSecondary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Rp ${CurrencyFormatter.format(_totalAssets.toStringAsFixed(0))}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Source & Destination Card (Combined)
                    SakuCard(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Source (Interactive with Inline Expansion)
                          GestureDetector(
                            onTap: () {
                              _noteFocusNode.unfocus();
                              FocusScope.of(context).unfocus();
                              if (_numpadTarget != TransferNumpadTarget.none) {
                                setState(
                                  () =>
                                      _numpadTarget = TransferNumpadTarget.none,
                                );
                              }
                              _toggleSourceDropdown();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'SUMBER DANA',
                                        style: TextStyle(
                                          color: AppTheme.lightTextSecondary,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Icon(
                                        _isSourceDropdownOpen
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: AppTheme.lightTextSecondary,
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isSourceDropdownOpen
                                          ? Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.5)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: sourceWallet != null
                                        ? _buildWalletRow(sourceWallet!)
                                        : Row(
                                            children: [
                                              Container(
                                                width: 34.w,
                                                height: 34.w,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE8F0FE),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.r,
                                                      ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.account_balance_wallet,
                                                  color:
                                                      const Color(0xFF1976D2),
                                                  size: 17.sp,
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
                                              Text(
                                                'Pilih Sumber Dana',
                                                style: TextStyle(
                                                  color: AppTheme
                                                      .lightTextSecondary,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Inline Expandable List
                          _buildWalletDropdownList(
                            selectedWallet: sourceWallet,
                            isOpen: _isSourceDropdownOpen,
                            onSelect: (wallet) {
                              _noteFocusNode.unfocus();
                              FocusScope.of(context).unfocus();
                              setState(() {
                                if (destinationWallet?.id == wallet.id) {
                                  destinationWallet = sourceWallet;
                                }
                                sourceWallet = wallet;
                                _isSourceDropdownOpen = false;
                              });
                            },
                          ),

                          // Swap Button
                          Center(
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    _noteFocusNode.unfocus();
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      final temp = sourceWallet;
                                      sourceWallet = destinationWallet;
                                      destinationWallet = temp;
                                      _isSourceDropdownOpen = false;
                                      _isDestinationDropdownOpen = false;
                                    });
                                  },
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    width: 32.w,
                                    height: 32.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.swap_vert_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      size: 17.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Destination (Interactive with Inline Expansion)
                          GestureDetector(
                            onTap: () {
                              _noteFocusNode.unfocus();
                              FocusScope.of(context).unfocus();
                              if (_numpadTarget != TransferNumpadTarget.none) {
                                setState(
                                  () =>
                                      _numpadTarget = TransferNumpadTarget.none,
                                );
                              }
                              _toggleDestinationDropdown();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'PENERIMA',
                                        style: TextStyle(
                                          color: AppTheme.lightTextSecondary,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Icon(
                                        _isDestinationDropdownOpen
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: AppTheme.lightTextSecondary,
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isDestinationDropdownOpen
                                          ? Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.5)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: destinationWallet != null
                                        ? _buildWalletRow(destinationWallet!)
                                        : Row(
                                            children: [
                                              Container(
                                                width: 34.w,
                                                height: 34.w,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE8F5E9),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.r,
                                                      ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.wallet,
                                                  color:
                                                      const Color(0xFF43A047),
                                                  size: 17.sp,
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
                                              Text(
                                                'Pilih Penerima',
                                                style: TextStyle(
                                                  color: AppTheme
                                                      .lightTextSecondary,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Inline Expandable List for Destination
                          _buildWalletDropdownList(
                            selectedWallet: destinationWallet,
                            isOpen: _isDestinationDropdownOpen,
                            onSelect: (wallet) {
                              _noteFocusNode.unfocus();
                              FocusScope.of(context).unfocus();
                              setState(() {
                                if (sourceWallet?.id == wallet.id) {
                                  sourceWallet = destinationWallet;
                                }
                                destinationWallet = wallet;
                                _isDestinationDropdownOpen = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Amount & Admin Fee Input Card (Interactive Numpad Integration)
                    SakuCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      child: Column(
                        key: _amountKey,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Nominal Transfer',
                                    style: TextStyle(
                                      color: AppTheme.lightTextSecondary,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    _numpadTarget == TransferNumpadTarget.amount
                                        ? Icons.keyboard_arrow_down_rounded
                                        : Icons.edit_note_rounded,
                                    size: 15.sp,
                                    color: AppTheme.lightTextSecondary,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  _noteFocusNode.unfocus();
                                  FocusScope.of(context).unfocus();
                                  if (sourceWallet != null) {
                                    final balance =
                                        sourceWallet!.currentBalance;
                                    setState(() {
                                      _amountController.text =
                                          CurrencyFormatter.format(
                                            balance.toStringAsFixed(0),
                                          );
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F0),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'MAX',
                                    style: TextStyle(
                                      color: AppTheme.semanticRed,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _noteFocusNode.unfocus();
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _numpadTarget =
                                    _numpadTarget == TransferNumpadTarget.amount
                                        ? TransferNumpadTarget.none
                                        : TransferNumpadTarget.amount;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                vertical: 4.h,
                                horizontal: 6.w,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _numpadTarget == TransferNumpadTarget.amount
                                        ? AppTheme.primaryBlue.withValues(
                                          alpha: 0.06,
                                        )
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color:
                                      _numpadTarget ==
                                              TransferNumpadTarget.amount
                                          ? AppTheme.primaryBlue.withValues(
                                            alpha: 0.25,
                                          )
                                          : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rp ',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _amountController.text.isEmpty
                                          ? '0'
                                          : _amountController.text,
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () {
                              _noteFocusNode.unfocus();
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _isCustomAdminFee = true;
                                _numpadTarget =
                                    _numpadTarget ==
                                            TransferNumpadTarget.adminFee
                                        ? TransferNumpadTarget.none
                                        : TransferNumpadTarget.adminFee;
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Biaya Admin : ',
                                      style: TextStyle(
                                        color: AppTheme.lightTextSecondary,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                    if (_isCustomAdminFee) ...[
                                      SizedBox(width: 4.w),
                                      Icon(
                                        _numpadTarget ==
                                                TransferNumpadTarget.adminFee
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons.edit_note_rounded,
                                        size: 14.sp,
                                        color: AppTheme.lightTextSecondary,
                                      ),
                                    ],
                                  ],
                                ),
                                if (!_isCustomAdminFee)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      'Gratis',
                                      style: TextStyle(
                                        color: const Color(0xFF43A047),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () {
                                      _noteFocusNode.unfocus();
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        _isCustomAdminFee = false;
                                        _adminFeeController.clear();
                                        if (_numpadTarget ==
                                            TransferNumpadTarget.adminFee) {
                                          _numpadTarget =
                                              TransferNumpadTarget.none;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Reset (Gratis)',
                                        style: TextStyle(
                                          color: AppTheme.lightTextSecondary,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            key: _adminFeeKey,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: _isCustomAdminFee ? 42.h : 0,
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  SizedBox(height: 6.h),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      _noteFocusNode.unfocus();
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        _numpadTarget =
                                            _numpadTarget ==
                                                    TransferNumpadTarget
                                                        .adminFee
                                                ? TransferNumpadTarget.none
                                                : TransferNumpadTarget.adminFee;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 4.h,
                                        horizontal: 6.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _numpadTarget ==
                                                    TransferNumpadTarget
                                                        .adminFee
                                                ? AppTheme.primaryBlue
                                                    .withValues(alpha: 0.06)
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(
                                          color:
                                              _numpadTarget ==
                                                      TransferNumpadTarget
                                                          .adminFee
                                                  ? AppTheme.primaryBlue
                                                      .withValues(alpha: 0.25)
                                                  : Colors.transparent,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Rp ',
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              _adminFeeController.text.isEmpty
                                                  ? '0'
                                                  : _adminFeeController.text,
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Catatan (Opsional) Label
                    Padding(
                      padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
                      child: RichText(
                        text: TextSpan(
                          text: 'Catatan ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                          children: [
                            TextSpan(
                              text: '(Opsional)',
                              style: TextStyle(
                                color: AppTheme.lightTextSecondary,
                                fontWeight: FontWeight.w400,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Catatan Input Card
                    SakuCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      child: Column(
                        key: _noteKey,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _noteController,
                            focusNode: _noteFocusNode,
                            minLines: 2,
                            maxLines: 4,
                            onTap: () {
                              if (_numpadTarget != TransferNumpadTarget.none) {
                                setState(
                                  () =>
                                      _numpadTarget = TransferNumpadTarget.none,
                                );
                              }
                            },
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.4,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Tulis catatan transfer, keperluan, atau keterangan di sini...',
                              hintStyle: TextStyle(
                                color: AppTheme.lightTextSecondary.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 12.sp,
                                height: 1.4,
                              ),
                              filled: false,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
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
                                onKeyPressed: _onNumpadKeyPressed,
                                onDelete: _onNumpadDelete,
                                onSubmit: () {
                                  setState(
                                    () =>
                                        _numpadTarget =
                                            TransferNumpadTarget.none,
                                  );
                                },
                                submitColor: AppTheme.primaryBlue,
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
                      onPressed: _isSubmitting ? null : _submitTransfer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Lanjut Transfer',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
}
