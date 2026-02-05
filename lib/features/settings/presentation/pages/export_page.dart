import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        title: Text(
          'Report Builder',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.black, size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('PILIH FORMAT'),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildFormatCard(
                    0,
                    Icons.picture_as_pdf,
                    const Color(0xFFEF4444),
                    'PDF',
                    'Laporan Rapi',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildFormatCard(
                    1,
                    Icons.table_view,
                    const Color(0xFF10B981),
                    'Excel',
                    'Data Olahan',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildFormatCard(
                    2,
                    Icons.code,
                    const Color(0xFF6B7280),
                    'CSV',
                    'Backup',
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),
            _buildSectionHeader('RENTANG WAKTU'),
            SizedBox(height: 12.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(0, 'Bulan Ini'),
                  SizedBox(width: 8.w),
                  _buildFilterChip(1, 'Bulan Lalu'),
                  SizedBox(width: 8.w),
                  _buildFilterChip(2, 'Tahun Ini'),
                  SizedBox(width: 8.w),
                  _buildFilterChip(3, 'Semua'),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildDatePicker('Dari Tanggal', _startDate)),
                SizedBox(width: 12.w),
                Expanded(child: _buildDatePicker('Sampai Tanggal', _endDate)),
              ],
            ),

            SizedBox(height: 24.h),
            _buildSectionHeader('OPSI TAMBAHAN'),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
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
                    Divider(height: 1.h, color: Colors.grey[100]),
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
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, -5.h),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Exporting...')));
          },
          icon: Icon(Icons.share, color: Colors.white, size: 24.sp),
          label: Text(
            'Export & Share',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF111111),
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
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
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2.w,
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
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF111111) : Colors.transparent,
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          children: [
            if (isSelected)
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.check_circle,
                  color: const Color(0xFF111111),
                  size: 16.sp,
                ),
              )
            else
              SizedBox(
                height: 16.sp,
              ), // Spacer to keep icon centered relative to card

            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF111111) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF111111) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey[400]),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "${date.day} ${_getMonthName(date.month)} ${date.year}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: const Color(0xFF111111),
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
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF111111),
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
