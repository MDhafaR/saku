import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../../core/injection.dart';

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

  final ScrollController _scrollController = ScrollController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();
  final FocusNode _adminFeeFocusNode = FocusNode();

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

    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        _scrollToField(_amountKey);
      }
    });

    _noteFocusNode.addListener(() {
      if (_noteFocusNode.hasFocus) {
        _scrollToField(_noteKey);
      }
    });

    _adminFeeFocusNode.addListener(() {
      if (_adminFeeFocusNode.hasFocus) {
        _scrollToField(_adminFeeKey);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _adminFeeController.dispose();
    _noteController.dispose();
    _scrollController.dispose();
    _amountFocusNode.dispose();
    _noteFocusNode.dispose();
    _adminFeeFocusNode.dispose();
    super.dispose();
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

  IconData _getIconData(String iconPath) {
    switch (iconPath) {
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      case 'payment':
        return Icons.payment;
      case 'mobile':
        return Icons.mobile_friendly;
      case 'credit_card':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      case 'money':
        return Icons.monetization_on;
      case 'store':
        return Icons.store;
      default:
        return Icons.account_balance_wallet;
    }
  }

  double get _totalAssets {
    return widget.wallets.fold<double>(
      0.0,
      (sum, wallet) => sum + wallet.currentBalance,
    );
  }

  Future<void> _submitTransfer() async {
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

    // Validate sufficient balance (amount + fee)
    final totalDeduction = amount + fee;
    if (totalDeduction > sourceWallet!.currentBalance) {
      _showError(
        'Saldo tidak cukup. Saldo tersedia: Rp ${CurrencyFormatter.format(sourceWallet!.currentBalance.toStringAsFixed(0))}',
      );
      return;
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
            color: Color(wallet.iconColor).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Icon(
            _getIconData(wallet.icon),
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isOpen ? (widget.wallets.length * 60.0.h).clamp(0, 200.h) : 0,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: SingleChildScrollView(
          child: Column(
            children: widget.wallets.map((wallet) {
              return InkWell(
                onTap: () => onSelect(wallet),
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: Color(wallet.iconColor).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          _getIconData(wallet.icon),
                          color: Color(wallet.iconColor),
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                              'Rp ${CurrencyFormatter.format(wallet.currentBalance.toStringAsFixed(0))}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selectedWallet?.id == wallet.id)
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryBlue,
                          size: 18.sp,
                        ),
                    ],
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
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Section with Balance
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(bottom: 16.h, top: 6.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Total Aset Anda',
                  style: TextStyle(
                    color: AppTheme.lightTextSecondary,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Rp ${CurrencyFormatter.format(_totalAssets.toStringAsFixed(0))}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 16.h,
                bottom: 20.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source & Destination Card (Combined)
                  SakuCard(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source (Interactive with Inline Expansion)
                        GestureDetector(
                          onTap: _toggleSourceDropdown,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                                SizedBox(height: 8.h),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: _isSourceDropdownOpen
                                        ? Colors.grey[100]
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: sourceWallet != null
                                      ? _buildWalletRow(sourceWallet!)
                                      : Row(
                                          children: [
                                            Container(
                                              width: 36.w,
                                              height: 36.w,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F0FE),
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.account_balance_wallet,
                                                color: const Color(0xFF1976D2),
                                                size: 18.sp,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              'Pilih Sumber Dana',
                                              style: TextStyle(
                                                color:
                                                    AppTheme.lightTextSecondary,
                                                fontSize: 13.sp,
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
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
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
                                  width: 36.w,
                                  height: 36.w,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.swap_vert,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Destination
                        GestureDetector(
                          onTap: _toggleDestinationDropdown,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                                SizedBox(height: 8.h),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: _isDestinationDropdownOpen
                                        ? Colors.grey[100]
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: destinationWallet != null
                                      ? _buildWalletRow(destinationWallet!)
                                      : Row(
                                          children: [
                                            Container(
                                              width: 36.w,
                                              height: 36.w,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F5E9),
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.wallet,
                                                color: const Color(0xFF43A047),
                                                size: 18.sp,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              'Pilih Penerima',
                                              style: TextStyle(
                                                color:
                                                    AppTheme.lightTextSecondary,
                                                fontSize: 13.sp,
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
                  SizedBox(height: 12.h),

                  // Amount Input Card
                  SakuCard(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      key: _amountKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nominal Transfer',
                              style: TextStyle(
                                color: AppTheme.lightTextSecondary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (sourceWallet != null) {
                                  final balance = sourceWallet!.currentBalance;
                                  _amountController.text =
                                      CurrencyFormatter.format(
                                        balance.toStringAsFixed(0),
                                      );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F0),
                                  borderRadius: BorderRadius.circular(4.r),
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
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Text(
                              'Rp ',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                focusNode: _amountFocusNode,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '0',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  // Auto-format while typing
                                  final raw = CurrencyFormatter.parse(value);
                                  if (raw.isNotEmpty && raw != '0') {
                                    final formatted = CurrencyFormatter.format(
                                      raw,
                                    );
                                    if (formatted != value) {
                                      _amountController.value =
                                          TextEditingValue(
                                            text: formatted,
                                            selection: TextSelection.collapsed(
                                              offset: formatted.length,
                                            ),
                                          );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        const Divider(),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCustomAdminFee = true;
                              _adminFeeFocusNode.requestFocus();
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Biaya Admin',
                                style: TextStyle(
                                  color: AppTheme.lightTextSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                              if (!_isCustomAdminFee)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    'Gratis',
                                    style: TextStyle(
                                      color: const Color(0xFF43A047),
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
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
                          height: _isCustomAdminFee ? 60.h : 0,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Text(
                                      'Rp ',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF111111),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _adminFeeController,
                                        focusNode: _adminFeeFocusNode,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF111111),
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: '0',
                                        ),
                                        keyboardType: TextInputType.number,
                                        onSubmitted: (value) {
                                          if (value.isEmpty || value == '0') {
                                            setState(() {
                                              _isCustomAdminFee = false;
                                              _adminFeeController.clear();
                                            });
                                          }
                                        },
                                        onTapOutside: (event) {
                                          if (_adminFeeController
                                                  .text
                                                  .isEmpty ||
                                              _adminFeeController.text == '0') {
                                            setState(() {
                                              _isCustomAdminFee = false;
                                              _adminFeeController.clear();
                                            });
                                          }
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Note Input
                  Column(
                    key: _noteKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Catatan ',
                          style: TextStyle(
                            color: const Color(0xFF111111),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                          children: [
                            TextSpan(
                              text: '(Opsional)',
                              style: TextStyle(
                                color: AppTheme.lightTextSecondary,
                                fontWeight: FontWeight.w400,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Bayar makan siang',
                          hintStyle: TextStyle(
                            color: AppTheme.lightTextSecondary,
                            fontSize: 13.sp,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(14.w),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 60.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.all(16.w),
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitTransfer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111111),
              disabledBackgroundColor: Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
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
      ),
    );
  }
}
