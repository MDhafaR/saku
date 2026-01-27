import 'package:flutter/material.dart';
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
          icon: const Icon(Icons.close, size: 24),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pindah Buku',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
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
            padding: const EdgeInsets.only(bottom: 24, top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Total Aset Anda',
                  style: TextStyle(
                    color: AppTheme.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rp 158.450.000',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source & Destination Card (Combined)
                  SakuCard(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'SUMBER DANA',
                                      style: TextStyle(
                                        color: AppTheme.lightTextSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Icon(
                                      _isSourceDropdownOpen
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: AppTheme.lightTextSecondary,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _isSourceDropdownOpen
                                        ? Colors.grey[100]
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              (sourceWallet?['color']
                                                          as Color? ??
                                                      const Color(0xFFE8F0FE))
                                                  .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            12,
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
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sourceWallet?['name']
                                                      as String? ??
                                                  'Pilih Sumber Dana',
                                              style: const TextStyle(
                                                color: Color(0xFF111111),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Saldo: Rp ${CurrencyFormatter.format(sourceWallet != null ? (sourceWallet!['balance'] as double).toStringAsFixed(0) : '0')}',
                                              style: const TextStyle(
                                                color:
                                                    AppTheme.lightTextSecondary,
                                                fontSize: 12,
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
                          height: _isSourceDropdownOpen ? 300 : 0, // Max height
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: (wallet['color'] as Color)
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              wallet['icon'] as IconData,
                                              color: wallet['color'] as Color,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  wallet['name'] as String,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF1F2937),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Rp ${CurrencyFormatter.format((wallet['balance'] as double).toStringAsFixed(0))}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (sourceWallet?['id'] ==
                                              wallet['id'])
                                            const Icon(
                                              Icons.check_circle,
                                              color: AppTheme.primaryBlue,
                                              size: 20,
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
                            margin: const EdgeInsets.symmetric(vertical: 4),
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
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.swap_vert,
                                    color: Colors.white,
                                    size: 20,
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'PENERIMA',
                                      style: TextStyle(
                                        color: AppTheme.lightTextSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Icon(
                                      _isDestinationDropdownOpen
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: AppTheme.lightTextSecondary,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _isDestinationDropdownOpen
                                        ? Colors.grey[100]
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              (destinationWallet?['color']
                                                          as Color? ??
                                                      const Color(0xFFE8F5E9))
                                                  .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            12,
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
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              destinationWallet?['name']
                                                      as String? ??
                                                  'Pilih Penerima',
                                              style: const TextStyle(
                                                color: Color(0xFF111111),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              destinationWallet != null
                                                  ? '0812-3456-7890'
                                                  : '-',
                                              style: const TextStyle(
                                                color:
                                                    AppTheme.lightTextSecondary,
                                                fontSize: 12,
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
                              ? 300
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: (wallet['color'] as Color)
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              wallet['icon'] as IconData,
                                              color: wallet['color'] as Color,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  wallet['name'] as String,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF1F2937),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Rp ${CurrencyFormatter.format((wallet['balance'] as double).toStringAsFixed(0))}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (destinationWallet?['id'] ==
                                              wallet['id'])
                                            const Icon(
                                              Icons.check_circle,
                                              color: AppTheme.primaryBlue,
                                              size: 20,
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
                  const SizedBox(height: 16),

                  // Amount Input Card
                  SakuCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      key: _amountKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nominal Transfer',
                              style: TextStyle(
                                color: AppTheme.lightTextSecondary,
                                fontSize: 12,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFFF0F0,
                                  ), // Keep subtle red tint for MAX
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'MAX',
                                  style: TextStyle(
                                    color: AppTheme.semanticRed,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Rp ',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111111),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                focusNode: _amountFocusNode,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111111),
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
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
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
                              const Text(
                                'Biaya Admin',
                                style: TextStyle(
                                  color: AppTheme.lightTextSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              if (!_isCustomAdminFee)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Gratis',
                                    style: TextStyle(
                                      color: Color(0xFF43A047),
                                      fontSize: 12,
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
                              ? 60
                              : 0, // Adjust height as needed
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text(
                                      'Rp ',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111111),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _adminFeeController,
                                        focusNode: _adminFeeFocusNode,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111111),
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

                  const SizedBox(height: 24),

                  // Note Input (Restored, Styled)
                  Column(
                    key: _noteKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Catatan ',
                          style: TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                          children: [
                            TextSpan(
                              text: '(Opsional)',
                              style: TextStyle(
                                color: AppTheme.lightTextSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Bayar makan siang',
                          hintStyle: const TextStyle(
                            color: AppTheme.lightTextSecondary,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,

              side: const BorderSide(color: Color(0xFFE5E7EB)),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
            ),
            child: const Text(
              'Lanjut Transfer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Consistent with 'Simpan' button
              ),
            ),
          ),
        ),
      ),
    );
  }
}
