import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _selectedTransactionType = 'Semua';
  String _selectedDateRange = 'Bulan Ini';
  String _selectedWallet = 'Semua';
  RangeValues _currentRangeValues = const RangeValues(0, 100);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Spacer for title centering
                const Text(
                  'Filter Pencarian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111111),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFFF3F4F6), height: 32),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Type
                  _buildSectionTitle('Tipe Transaksi'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        'Semua',
                        isSelected: _selectedTransactionType == 'Semua',
                        onTap: () =>
                            setState(() => _selectedTransactionType = 'Semua'),
                      ),
                      _buildChip(
                        'Pemasukan',
                        isSelected: _selectedTransactionType == 'Pemasukan',
                        onTap: () => setState(
                          () => _selectedTransactionType = 'Pemasukan',
                        ),
                      ),
                      _buildChip(
                        'Pengeluaran',
                        isSelected: _selectedTransactionType == 'Pengeluaran',
                        onTap: () => setState(
                          () => _selectedTransactionType = 'Pengeluaran',
                        ),
                      ),
                      _buildChip(
                        'Transfer',
                        isSelected: _selectedTransactionType == 'Transfer',
                        onTap: () => setState(
                          () => _selectedTransactionType = 'Transfer',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Date Range
                  _buildSectionTitle('Rentang Waktu'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        'Bulan Ini',
                        isSelected: _selectedDateRange == 'Bulan Ini',
                        onTap: () =>
                            setState(() => _selectedDateRange = 'Bulan Ini'),
                      ),
                      _buildChip(
                        '30 Hari Terakhir',
                        isSelected: _selectedDateRange == '30 Hari Terakhir',
                        onTap: () => setState(
                          () => _selectedDateRange = '30 Hari Terakhir',
                        ),
                      ),
                      _buildChip(
                        'Pilih Tanggal',
                        icon: Icons.calendar_today_outlined,
                        isSelected: _selectedDateRange == 'Pilih Tanggal',
                        onTap: () => setState(
                          () => _selectedDateRange = 'Pilih Tanggal',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Wallet
                  _buildSectionTitle('Dompet'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        'Semua',
                        icon: Icons.account_balance_wallet_outlined,
                        isSelected: _selectedWallet == 'Semua',
                        onTap: () => setState(() => _selectedWallet = 'Semua'),
                      ),
                      _buildChip(
                        'BCA',
                        labelPrefix: 'BCA',
                        isWallet: true,
                        isSelected: _selectedWallet == 'BCA',
                        onTap: () => setState(() => _selectedWallet = 'BCA'),
                      ),
                      _buildChip(
                        'Cash',
                        icon: Icons.payments_outlined,
                        isSelected: _selectedWallet == 'Cash',
                        onTap: () => setState(() => _selectedWallet = 'Cash'),
                      ),
                      _buildChip(
                        'OVO',
                        labelPrefix: 'OVO',
                        isWallet: true,
                        isSelected: _selectedWallet == 'OVO',
                        onTap: () => setState(() => _selectedWallet = 'OVO'),
                      ),
                      _buildChip(
                        'GoPay',
                        icon: Icons.stay_current_portrait,
                        isSelected: _selectedWallet == 'GoPay',
                        onTap: () => setState(() => _selectedWallet = 'GoPay'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Kategori'),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: AppTheme.primaryBlue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                    children: [
                      _buildCategoryItem(
                        Icons.restaurant,
                        'Makan',
                        Colors.orange,
                      ),
                      _buildCategoryItem(
                        Icons.directions_car,
                        'Transport',
                        Colors.blue,
                      ),
                      _buildCategoryItem(
                        Icons.shopping_bag,
                        'Belanja',
                        Colors.pink,
                      ),
                      _buildCategoryItem(
                        Icons.receipt_long,
                        'Tagihan',
                        Colors.green,
                      ),
                      _buildCategoryItem(Icons.movie, 'Hiburan', Colors.purple),
                      _buildCategoryItem(
                        Icons.favorite,
                        'Kesehatan',
                        Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Nominal Slider
                  _buildSectionTitle('Nominal'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Rp 0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      Text(
                        'Rp 10.000.000+',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primaryBlue,
                      inactiveTrackColor: Colors.grey[200],
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                        elevation: 2,
                      ),
                      overlayColor: AppTheme.primaryBlue.withOpacity(0.1),
                    ),
                    child: RangeSlider(
                      values: _currentRangeValues,
                      min: 0,
                      max: 100,
                      onChanged: (RangeValues values) {
                        setState(() {
                          _currentRangeValues = values;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      Text(
                        'Max',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Terapkan Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4B5563),
      ),
    );
  }

  Widget _buildChip(
    String label, {
    IconData? icon,
    bool isSelected = false,
    String? labelPrefix,
    bool isWallet = false,
    VoidCallback? onTap,
  }) {
    Color textColor = isSelected
        ? AppTheme.primaryBlue
        : const Color(0xFF4B5563);
    Color borderColor = isSelected
        ? AppTheme.primaryBlue
        : const Color(0xFFE5E7EB);
    Color bgColor = isSelected ? const Color(0xFFEFF6FF) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 8),
            ],
            if (labelPrefix != null) ...[
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  labelPrefix,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, MaterialColor color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
