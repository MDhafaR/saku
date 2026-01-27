import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../components/custom_numpad.dart';
import 'category_selection_page.dart';
import 'wallet_selection_page.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool isExpense = true;
  String amount = '0';
  String note = '';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Map<String, dynamic>? selectedCategory;
  Map<String, dynamic>? selectedWallet;

  void _onKeyPressed(String value) {
    setState(() {
      if (amount == '0') {
        amount = value;
      } else {
        amount += value;
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (amount.isNotEmpty) {
        amount = amount.substring(0, amount.length - 1);
        if (amount.isEmpty) {
          amount = '0';
        }
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (selectedDay == today) {
      return 'Hari Ini';
    } else if (selectedDay == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMM yyyy', 'id').format(selectedDate);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
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
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String _getTimeLabel() {
    final now = TimeOfDay.now();
    if (selectedTime.hour == now.hour && selectedTime.minute == now.minute) {
      return 'Sekarang';
    } else {
      final hour = selectedTime.hour.toString().padLeft(2, '0');
      final minute = selectedTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine feedback color (Red/Green) but keep it subtle
    // Not filling the screen with it.

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Clean off-white
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          // Icon theme should handle color, but ensure it's visible
          color: Theme.of(context).iconTheme.color,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6), // Light grey background for toggle
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTypeToggle('Pengeluaran', true),
              _buildTypeToggle('Pemasukan', false),
            ],
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
                        // Amount Section - Compact
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Masukkan Jumlah',
                                style: TextStyle(
                                  color: AppTheme.lightTextSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rp ${CurrencyFormatter.format(amount)}',
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isExpense
                                          ? AppTheme.semanticRed
                                          : AppTheme.semanticGreen,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Details Card - fills remaining space
                        Container(
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
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Date & Time
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputChip(
                                      icon: Icons.calendar_today_outlined,
                                      label: _getDateLabel(),
                                      onTap: _selectDate,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInputChip(
                                      icon: Icons.access_time_outlined,
                                      label: _getTimeLabel(),
                                      onTap: _selectTime,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Category
                              _buildSelectionField(
                                icon: selectedCategory != null
                                    ? selectedCategory!['icon'] as IconData
                                    : Icons.category_outlined,
                                iconColor: selectedCategory != null
                                    ? selectedCategory!['color'] as Color
                                    : null,
                                label: 'Kategori',
                                value: selectedCategory != null
                                    ? selectedCategory!['name'] as String
                                    : 'Pilih kategori...',
                                isPlaceholder: selectedCategory == null,
                                onTap: () async {
                                  final result =
                                      await Navigator.push<
                                        Map<String, dynamic>
                                      >(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CategorySelectionPage(
                                                isExpense: isExpense,
                                              ),
                                        ),
                                      );
                                  if (result != null) {
                                    setState(() {
                                      selectedCategory = result;
                                      // Update type based on selected category
                                      if (result['isExpense'] != null) {
                                        isExpense = result['isExpense'] as bool;
                                      }
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 12),

                              // Wallet
                              GestureDetector(
                                onTap: () async {
                                  final result =
                                      await Navigator.push<
                                        Map<String, dynamic>
                                      >(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const WalletSelectionPage(),
                                        ),
                                      );
                                  if (result != null) {
                                    setState(() {
                                      selectedWallet = result;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selectedWallet != null
                                            ? selectedWallet!['icon']
                                                  as IconData
                                            : Icons
                                                  .account_balance_wallet_outlined,
                                        color: selectedWallet != null
                                            ? selectedWallet!['color'] as Color
                                            : AppTheme.lightTextSecondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Wallet',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppTheme.lightTextSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            if (selectedWallet != null)
                                              Row(
                                                children: [
                                                  Text(
                                                    selectedWallet!['name']
                                                        as String,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF1F2937),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '( Rp ${CurrencyFormatter.format((selectedWallet!['balance'] as double).toStringAsFixed(0))} )',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              const Text(
                                                'Pilih wallet...',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme
                                                      .lightTextSecondary,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: AppTheme.lightTextSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Note
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
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
                                        onChanged: (value) {
                                          setState(() {
                                            note = value;
                                          });
                                        },
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
                              ),

                              const SizedBox(height: 24),

                              // Numpad
                              CustomNumpad(
                                onKeyPressed: _onKeyPressed,
                                onDelete: _onDelete,
                                onSubmit: () => Navigator.pop(context),
                                submitColor: AppTheme.primaryBlue,
                              ),
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

          // Fixed Submit Button at bottom
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            color: Theme.of(context).cardTheme.color,
            child: SizedBox(
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
    );
  }

  Widget _buildTypeToggle(String text, bool isExp) {
    final isSelected = isExpense == isExp;
    return GestureDetector(
      onTap: () {
        if (isExpense != isExp) {
          setState(() {
            isExpense = isExp;
            selectedCategory = null;
            selectedWallet = null;
            note = '';
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? (isExp ? AppTheme.semanticRed : AppTheme.semanticGreen)
                : AppTheme.lightTextSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInputChip({
    required IconData icon,
    required String label,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppTheme.darkBackground),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionField({
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
    bool isPlaceholder = false,
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
            Icon(
              icon,
              color: iconColor ?? AppTheme.lightTextSecondary,
              size: 20,
            ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isPlaceholder
                          ? AppTheme.lightTextSecondary
                          : const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.lightTextSecondary),
          ],
        ),
      ),
    );
  }
}
