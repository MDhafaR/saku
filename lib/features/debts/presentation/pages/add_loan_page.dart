import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class AddLoanPage extends StatefulWidget {
  const AddLoanPage({super.key});

  @override
  State<AddLoanPage> createState() => _AddLoanPageState();
}

class _AddLoanPageState extends State<AddLoanPage> {
  bool isDebt = true; // "Saya Hutang" = true, "Pinjamkan" = false
  String amount = '0';
  final TextEditingController _contactController = TextEditingController(
    text: 'Budi Santoso',
  );
  final TextEditingController _noteController = TextEditingController();
  DateTime _transactionDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _hasDueDate = true;

  @override
  void dispose() {
    _contactController.dispose();
    _noteController.dispose();
    super.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Hutang/Piutang',
          style: TextStyle(
            fontSize: 18,
            // Color handled by theme usually, but explicit if needed
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top Section (Toggle & Amount)
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Type Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTypeToggle(
                        'Saya Hutang',
                        true,
                        AppTheme.semanticRed,
                      ),
                      _buildTypeToggle(
                        'Pinjamkan',
                        false,
                        AppTheme.semanticGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Amount Display
                const Text(
                  'Jumlah Nominal',
                  style: TextStyle(
                    color: AppTheme.lightTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Open numpad
                  },
                  child: Text(
                    'Rp $amount',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: feedbackColor, // Use semantic color for amount
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Form Section
          Expanded(
            flex: 6,
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact Field
                    _buildLabel('Kontak'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _contactController,
                      icon: Icons.person_outline,
                      hint: 'Pilih kontak...',
                    ),
                    const SizedBox(height: 20),

                    // Transaction Date
                    _buildLabel('Tanggal Transaksi'),
                    const SizedBox(height: 8),
                    _buildDatePickerField(
                      date: _transactionDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _transactionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _transactionDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Due Date Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Atur Jatuh Tempo',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            value: _hasDueDate,
                            activeColor: AppTheme.primaryBlue,
                            onChanged: (val) =>
                                setState(() => _hasDueDate = val),
                          ),
                        ),
                      ],
                    ),

                    // Animated Due Date Picker
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _hasDueDate ? 80 : 0,
                      curve: Curves.easeInOut,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            _buildDatePickerField(
                              date: _dueDate,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _dueDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => _dueDate = picked);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Notes
                    _buildLabel('Catatan'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tulis catatan...',
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        // Theme handles defaults, but if we want semantic color for button:
                        // "Monochromatic with One Accent": use Blue (AppTheme.primaryBlue).
                        // BUT, user might expect Red button for "Debt".
                        // "One Accent" rule usually overrides semantic buttons unless critical.
                        // I will stick to Theme Default (Blue) for clean look, or allow override?
                        // Let's use Blue to be consistent with "Clean & Airy" instructions.
                        child: const Text('Simpan'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(
    String text,
    bool targetIsDebt,
    Color activeSemanticColor,
  ) {
    final isSelected = isDebt == targetIsDebt;
    return GestureDetector(
      onTap: () => setState(() => isDebt = targetIsDebt),
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
                ? activeSemanticColor
                : AppTheme.lightTextSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.lightTextSecondary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: AppTheme.lightTextSecondary,
            size: 20,
          ), // Prefix icon looks cleaner
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDatePickerField({
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: AppTheme.lightTextSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd MMMM yyyy').format(date),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.lightTextSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
