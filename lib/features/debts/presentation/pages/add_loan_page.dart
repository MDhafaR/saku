import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class AddLoanPage extends StatefulWidget {
  const AddLoanPage({super.key});

  @override
  State<AddLoanPage> createState() => _AddLoanPageState();
}

class _AddLoanPageState extends State<AddLoanPage> {
  // Mock wallet data
  static final List<Map<String, dynamic>> _mockWallets = [
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

  bool isDebt = true; // "Saya Hutang" = true, "Pinjamkan" = false
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _transactionDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _hasDueDate = true;

  // Wallet selection
  Map<String, dynamic>? _selectedWallet;
  bool _isWalletDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    if (_mockWallets.isNotEmpty) {
      _selectedWallet = _mockWallets[0];
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _contactController.dispose();
    _noteController.dispose();
    super.dispose();
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
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(4),
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
                        borderRadius: BorderRadius.circular(24),
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
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Saya Hutang',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDebt
                                    ? AppTheme.semanticRed
                                    : AppTheme.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Pinjamkan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !isDebt
                                    ? AppTheme.semanticGreen
                                    : AppTheme.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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
            icon: const Icon(Icons.more_horiz),
            color: Theme.of(context).iconTheme.color,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Amount Section - Compact (outside the card)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Jumlah Nominal',
                  style: TextStyle(
                    color: AppTheme.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Editable Amount
                IntrinsicWidth(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Rp ',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: feedbackColor,
                            ),
                      ),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: feedbackColor,
                              ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onChanged: (value) {
                            // Format the amount while typing
                            final cleanValue = value
                                .replaceAll('.', '')
                                .replaceAll(',', '');
                            if (cleanValue.isEmpty) {
                              _amountController.text = '0';
                              _amountController.selection =
                                  TextSelection.fromPosition(
                                    const TextPosition(offset: 1),
                                  );
                            } else {
                              final formatted = CurrencyFormatter.format(
                                cleanValue,
                              );
                              if (formatted != value) {
                                _amountController.text = formatted;
                                _amountController.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(offset: formatted.length),
                                    );
                              }
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details Card - Expanded to fill remaining space
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Scrollable form fields
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contact Field - Text Input
                          _buildContactField(),
                          const SizedBox(height: 12),

                          // Transaction Date
                          _buildDateField(
                            icon: Icons.calendar_today_outlined,
                            label: 'Tanggal Transaksi',
                            value: _getDateLabel(_transactionDate),
                            onTap: _selectTransactionDate,
                          ),
                          const SizedBox(height: 12),

                          // Due Date Toggle Row
                          _buildDueDateField(),
                          const SizedBox(height: 12),

                          // Wallet Field
                          _buildWalletField(),
                          const SizedBox(height: 12),

                          // Notes
                          _buildNotesField(),
                        ],
                      ),
                    ),
                  ),

                  // Submit Button (inside the card)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      16,
                      24,
                      MediaQuery.of(context).padding.bottom + 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(
                            color: Color.fromARGB(255, 236, 236, 236),
                          ),
                          backgroundColor: Colors.white,
                          shadowColor: Colors.black,
                          elevation: 2,
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline,
            color: AppTheme.lightTextSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kontak',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.lightTextSecondary,
                  ),
                ),
                TextField(
                  controller: _contactController,
                  cursorColor: const Color(0xFF6B7280),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama kontak...',
                    hintStyle: TextStyle(
                      color: AppTheme.lightTextSecondary,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.lightTextSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_available_outlined,
              color: AppTheme.lightTextSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jatuh Tempo',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _hasDueDate ? _getDateLabel(_dueDate) : 'Tidak ada',
                    style: TextStyle(
                      fontSize: 16,
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
              scale: 0.8,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(
              Icons.edit_outlined,
              color: AppTheme.lightTextSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _noteController,
              maxLines: 3,
              minLines: 2,
              cursorColor: const Color(0xFF6B7280),
              decoration: const InputDecoration(
                hintText: 'Tulis catatan...',
                hintStyle: TextStyle(
                  color: AppTheme.lightTextSecondary,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
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
        borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Wallet Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          (_selectedWallet?['color'] as Color? ??
                                  const Color(0xFFE8F0FE))
                              .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _selectedWallet?['icon'] as IconData? ??
                          Icons.account_balance_wallet,
                      color:
                          _selectedWallet?['color'] as Color? ??
                          const Color(0xFF1976D2),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Akun / Wallet',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedWallet?['name'] as String? ?? 'Pilih Wallet',
                          style: TextStyle(
                            fontSize: 16,
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
                    size: 20,
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
                ? (_mockWallets.length * 64.0).clamp(0.0, 256.0)
                : 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(11),
                bottomRight: Radius.circular(11),
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: _mockWallets.map((wallet) {
                    final isSelected = _selectedWallet?['id'] == wallet['id'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedWallet = wallet;
                          _isWalletDropdownOpen = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF3F4F6)
                              : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: (wallet['color'] as Color).withOpacity(
                                  0.15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                wallet['icon'] as IconData,
                                color: wallet['color'] as Color,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    'Saldo: Rp ${CurrencyFormatter.format((wallet['balance'] as double).toStringAsFixed(0))}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
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
    );
  }
}
