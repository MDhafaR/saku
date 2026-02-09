import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';

class TransferPage extends StatefulWidget {
  static final List<Map<String, dynamic>> mockWallets = [
    {
      'id': '1',
      'name': 'BCA',
      'balance': 15000000.0,
      'icon': Icons.account_balance,
      'color': const Color(0xFF1976D2),
    },
    {
      'id': '2',
      'name': 'Gopay',
      'balance': 250000.0,
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFF00AED6),
    },
    {
      'id': '3',
      'name': 'OVO',
      'balance': 750000.0,
      'icon': Icons.monetization_on,
      'color': const Color(0xFF4B2C82),
    },
    {
      'id': '4',
      'name': 'Dana',
      'balance': 1250000.0,
      'icon': Icons.mobile_friendly,
      'color': const Color(0xFF06B6D4),
    },
  ];

  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController _amountController = TextEditingController(
    text: '150.000',
  );
  final TextEditingController _adminFeeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isCustomAdminFee = false;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();
  final FocusNode _adminFeeFocusNode = FocusNode();

  final GlobalKey _amountKey = GlobalKey();
  final GlobalKey _adminFeeKey = GlobalKey();
  final GlobalKey _noteKey = GlobalKey();

  // Selected Wallets
  Map<String, dynamic>? sourceWallet;
  Map<String, dynamic>? destinationWallet;

  @override
  void initState() {
    super.initState();
    if (TransferPage.mockWallets.isNotEmpty) {
      sourceWallet = TransferPage.mockWallets[0];
    }
    if (TransferPage.mockWallets.length > 1) {
      destinationWallet = TransferPage.mockWallets[1];
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
    // Wait longer for keyboard to fully appear before scrolling
    Future.delayed(const Duration(milliseconds: 500), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0,
        ).then((_) {
          // Add extra scroll to push field higher above keyboard
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Section with Balance (Restored but Styled Clean)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(bottom: 16.h, top: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
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
                  'Rp 158.450.000',
                  style: TextStyle(
                    color: Colors.black,
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
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                    ), // Removed padding to handle styling manually
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source (Interactive with Dropdown)
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
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36.w,
                                        height: 36.w,
                                        decoration: BoxDecoration(
                                          color:
                                              (sourceWallet?['color']
                                                          as Color? ??
                                                      const Color(0xFFE8F0FE))
                                                  .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          sourceWallet?['icon'] as IconData? ??
                                              Icons.account_balance_wallet,
                                          color:
                                              sourceWallet?['color']
                                                  as Color? ??
                                              const Color(0xFF1976D2),
                                          size: 18.sp,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sourceWallet?['name']
                                                      as String? ??
                                                  'Pilih Sumber Dana',
                                              style: TextStyle(
                                                color: const Color(0xFF111111),
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              'Saldo: Rp ${CurrencyFormatter.format(sourceWallet != null ? (sourceWallet!['balance'] as double).toStringAsFixed(0) : '0')}',
                                              style: TextStyle(
                                                color:
                                                    AppTheme.lightTextSecondary,
                                                fontSize: 11.sp,
                                              ),
                                            ),
                                          ],
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
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _isSourceDropdownOpen
                              ? 200.h
                              : 0, // Max height
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: TransferPage.mockWallets.map((
                                  wallet,
                                ) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (destinationWallet?['id'] ==
                                            wallet['id']) {
                                          destinationWallet = sourceWallet;
                                        }
                                        sourceWallet = wallet;
                                        _isSourceDropdownOpen = false;
                                      });
                                    },
                                    child: Container(
                                      color: Colors.white,
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
                                              color: (wallet['color'] as Color)
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            child: Icon(
                                              wallet['icon'] as IconData,
                                              color: wallet['color'] as Color,
                                              size: 18.sp,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  wallet['name'] as String,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFF1F2937,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 1.h),
                                                Text(
                                                  'Rp ${CurrencyFormatter.format((wallet['balance'] as double).toStringAsFixed(0))}',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (sourceWallet?['id'] ==
                                              wallet['id'])
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
                                  color: Colors.black.withOpacity(0.05),
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
                        // Destination (Interactive with Inline Expansion)
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
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36.w,
                                        height: 36.w,
                                        decoration: BoxDecoration(
                                          color:
                                              (destinationWallet?['color']
                                                          as Color? ??
                                                      const Color(0xFFE8F5E9))
                                                  .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          destinationWallet?['icon']
                                                  as IconData? ??
                                              Icons.wallet,
                                          color:
                                              destinationWallet?['color']
                                                  as Color? ??
                                              const Color(0xFF43A047),
                                          size: 18.sp,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              destinationWallet?['name']
                                                      as String? ??
                                                  'Pilih Penerima',
                                              style: TextStyle(
                                                color: const Color(0xFF111111),
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              destinationWallet != null
                                                  ? '0812-3456-7890'
                                                  : '-',
                                              style: TextStyle(
                                                color:
                                                    AppTheme.lightTextSecondary,
                                                fontSize: 11.sp,
                                              ),
                                            ),
                                          ],
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
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _isDestinationDropdownOpen
                              ? 200.h
                              : 0, // Max height
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: TransferPage.mockWallets.map((
                                  wallet,
                                ) {
                                  // Filter out selected source wallet if needed, or allow transfer to same wallet type (usually blocked but simplifying here)
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (sourceWallet?['id'] ==
                                            wallet['id']) {
                                          sourceWallet = destinationWallet;
                                        }
                                        destinationWallet = wallet;
                                        _isDestinationDropdownOpen = false;
                                      });
                                    },
                                    child: Container(
                                      color: Colors.white,
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
                                              color: (wallet['color'] as Color)
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            child: Icon(
                                              wallet['icon'] as IconData,
                                              color: wallet['color'] as Color,
                                              size: 18.sp,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  wallet['name'] as String,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFF1F2937,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 1.h),
                                                Text(
                                                  'Rp ${CurrencyFormatter.format((wallet['balance'] as double).toStringAsFixed(0))}',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (destinationWallet?['id'] ==
                                              wallet['id'])
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
                                  final balance =
                                      sourceWallet!['balance'] as double;
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
                                  color: const Color(
                                    0xFFFFF0F0,
                                  ), // Keep subtle red tint for MAX
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
                                color: const Color(0xFF111111),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                focusNode: _amountFocusNode,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF111111),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                keyboardType: TextInputType.number,
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
                          height: _isCustomAdminFee
                              ? 60.h
                              : 0, // Adjust height as needed
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

                  // Note Input (Restored, Styled)
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
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111111),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            child: Text(
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
