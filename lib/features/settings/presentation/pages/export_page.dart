import 'package:flutter/material.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  int _selectedFormat = 0; // 0: PDF, 1: Excel, 2: CSV
  int _selectedDateFilter =
      0; // 0: This Month, 1: Last Month, 2: This Year, 3: All
  bool _includeReceipts = false;
  bool _passwordProtection = false;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Report Builder',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('PILIH FORMAT'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFormatCard(
                    0,
                    Icons.picture_as_pdf,
                    Colors.red,
                    'PDF',
                    'Laporan Rapi',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormatCard(
                    1,
                    Icons.table_view,
                    Colors.green,
                    'Excel',
                    'Data Olahan',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormatCard(
                    2,
                    Icons.code,
                    Colors.grey,
                    'CSV',
                    'Backup',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('RENTANG WAKTU'),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(0, 'Bulan Ini'),
                  const SizedBox(width: 8),
                  _buildFilterChip(1, 'Bulan Lalu'),
                  const SizedBox(width: 8),
                  _buildFilterChip(2, 'Tahun Ini'),
                  const SizedBox(width: 8),
                  _buildFilterChip(3, 'Semua'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDatePicker('Dari Tanggal', _startDate)),
                const SizedBox(width: 12),
                Expanded(child: _buildDatePicker('Sampai Tanggal', _endDate)),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('OPSI TAMBAHAN'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildToggleItem(
                    icon: Icons.receipt_long,
                    title: 'Sertakan Foto Struk',
                    subtitle: 'Ukuran file akan lebih besar',
                    value: _includeReceipts,
                    onChanged: (val) => setState(() => _includeReceipts = val),
                  ),
                  if (_selectedFormat == 0) ...[
                    Divider(height: 1, color: Colors.grey[100]),
                    _buildToggleItem(
                      icon: Icons.lock_outline,
                      title: 'Proteksi Password',
                      subtitle: 'Khusus format PDF',
                      value: _passwordProtection,
                      onChanged: (val) =>
                          setState(() => _passwordProtection = val),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Exporting...')));
          },
          icon: const Icon(Icons.share, color: Colors.white),
          label: const Text(
            'Export & Share',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFormatCard(
    int index,
    IconData icon,
    Color color,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedFormat == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            if (isSelected)
              const Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF2563EB),
                  size: 16,
                ),
              )
            else
              const SizedBox(
                height: 16,
              ), // Spacer to keep icon centered relative to card

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedDateFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedDateFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${date.day} ${_getMonthName(date.month)} ${date.year}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
