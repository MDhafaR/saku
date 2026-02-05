import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// --- Import Menu Page ---
class ImportMenuPage extends StatefulWidget {
  const ImportMenuPage({super.key});

  @override
  State<ImportMenuPage> createState() => _ImportMenuPageState();
}

class _ImportMenuPageState extends State<ImportMenuPage> {
  int _selectedOption = 0; // 0: Bank/Excel, 1: Backup

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Import Data',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  // Cloud Icon
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 80.sp,
                    color: const Color(0xFF111111),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Pindahkan Data Keuangan',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Pindahkan data keuanganmu dari aplikasi lain atau rekening koran bank dengan mudah.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),

                  // Options
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pilih Jenis File',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildOptionCard(
                    index: 0,
                    icon: Icons.table_chart_outlined,
                    iconColor: const Color(0xFF111111),
                    title: 'Bank Statement / Excel',
                    subtitle:
                        'Import transaksi dari file CSV atau Excel eksternal.',
                  ),
                  SizedBox(height: 12.h),
                  _buildOptionCard(
                    index: 1,
                    icon: Icons.storage_outlined,
                    iconColor: const Color(0xFF111111),
                    title: 'Saku Backup File',
                    subtitle: 'Restore data dari cadangan aplikasi Saku.',
                  ),

                  SizedBox(height: 32.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Import',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            fontSize: 14.sp,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Lihat Semua',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildHistoryItem(
                    'BCA_Januari_2024.csv',
                    'Hari ini, 10:00',
                    true,
                  ),
                  _buildHistoryItem('Expense_Report.xlsx', 'Kemarin', false),
                ],
              ),
            ),
          ),
          // Bottom Button
          Padding(
            padding: EdgeInsets.all(20.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImportWizardPage(),
                    ),
                  );
                },
                icon: Icon(Icons.add, color: Colors.white, size: 24.sp),
                label: Text(
                  'Pilih File dari Penyimpanan',
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
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedOption == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF111111) : Colors.grey[200]!,
            width: isSelected ? 1.5.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
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
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF111111)
                      : Colors.grey[400]!,
                  width: isSelected ? 5.w : 1.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String name, String date, bool isSuccess) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.grey,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              isSuccess ? 'Sukses' : 'Gagal',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Import Wizard Page ---
class ImportWizardPage extends StatefulWidget {
  const ImportWizardPage({super.key});

  @override
  State<ImportWizardPage> createState() => _ImportWizardPageState();
}

class _ImportWizardPageState extends State<ImportWizardPage> {
  int _currentStep = 1; // 1, 2, 3

  // Step 2 State
  bool _autoCreateCategory = true;

  @override
  Widget build(BuildContext context) {
    String title = 'Petakan Kolom';
    if (_currentStep == 2) title = 'Petakan Kategori';
    if (_currentStep == 3) title = 'Konfirmasi Import';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Light grey bg
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: const Color(0xFF111111),
            size: 20.sp,
          ),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: const Color(0xFF111111),
              size: 24.sp,
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0.h),
          child: LinearProgressIndicator(
            value: _currentStep / 3,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF111111)),
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicator text for > 1
          if (_currentStep > 1)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                'Langkah $_currentStep dari 3: ${_getStepName()}',
                style: TextStyle(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: _buildCurrentStep(),
            ),
          ),

          // Bottom Button
          Container(
            padding: EdgeInsets.all(20.w),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < 3) {
                    setState(() => _currentStep++);
                  } else {
                    // Start Import Action
                    Navigator.pop(context); // Go back to menu
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import Started!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentStep == 1
                      ? 'Lanjut ke Konfirmasi'
                      : (_currentStep == 2
                            ? 'Simpan & Lanjut'
                            : 'Mulai Import Sekarang'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ),
          if (_currentStep == 3)
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(bottom: 20.h),
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batalkan',
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getStepName() {
    if (_currentStep == 2) return 'Kategori';
    if (_currentStep == 3) return 'Konfirmasi';
    return '';
  }

  Widget _buildCurrentStep() {
    if (_currentStep == 1) return _buildStep1();
    if (_currentStep == 2) return _buildStep2();
    return _buildStep3();
  }

  // --- Step 1: Kolom ---
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File Info
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.table_chart,
                  color: Colors.green,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'mutasi_bca_januari.csv',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    '24 KB • 150 Baris',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Abaikan baris pertama (Header)',
              style: TextStyle(color: Colors.grey[800], fontSize: 14.sp),
            ),
            Checkbox(
              value: true,
              onChanged: (v) {},
              activeColor: const Color(0xFF111111),
            ),
          ],
        ),

        SizedBox(height: 12.h),
        Text(
          'Tentukan jenis data untuk setiap kolom',
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
        ),
        SizedBox(height: 16.h),

        // Mapping Cards (Scrollable Horizontally ideally, but vertical for simplicity here)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMappingColumn('Tanggal', [
                '01/01/2024',
                '02/01/2024',
                '05/01/2024',
              ]),
              SizedBox(width: 12.w),
              _buildMappingColumn('Deskripsi', [
                'TRSF E-BANKING',
                'QRIS KOPI KEN...',
                'BIAYA ADMIN',
              ]),
              SizedBox(width: 12.w),
              _buildMappingColumn('Abaikan / Hide', [
                'DB',
                'CR',
                'DB',
              ], isIgnored: true),
            ],
          ),
        ),

        SizedBox(height: 32.h),
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 16.sp),
            SizedBox(width: 8.w),
            Text(
              '2 kolom wajib (Tanggal, Nominal) ditemukan',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMappingColumn(
    String selectedType,
    List<String> previews, {
    bool isIgnored = false,
  }) {
    return Container(
      width: 140.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isIgnored ? Colors.grey[200]! : Colors.green[200]!,
          width: isIgnored ? 1.w : 1.5.w,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isIgnored ? Colors.grey[50] : Colors.green[50],
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedType,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: isIgnored ? Colors.grey : Colors.green[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16.sp,
                  color: isIgnored ? Colors.grey : Colors.green[800],
                ),
              ],
            ),
          ),
          ...previews.map(
            (p) => Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[100]!)),
              ),
              child: Text(
                p,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF6B7280),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(height: 20.h), // Spacer
        ],
      ),
    );
  }

  // --- Step 2: Kategori ---
  Widget _buildStep2() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buat kategori baru untuk yang tidak cocok',
                      style: TextStyle(
                        color: const Color(0xFF1F2937),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Otomatis buat kategori jika tidak ada di Saku',
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoCreateCategory,
                onChanged: (v) => setState(() => _autoCreateCategory = v),
                activeColor: const Color(0xFF111111),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DARI CSV (SUMBER)',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            Text(
              'KE SAKU (TUJUAN)',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        _buildCategoryMappingItem('Gofood', 'Food & Dining', Colors.green),
        _buildCategoryMappingItem('Indomaret', 'Groceries', Colors.green),
        _buildCategoryMappingItem(
          'TRSF E-BANKING',
          'Pilih Kategori...',
          Colors.grey,
        ),
        _buildCategoryMappingItem(
          'Netflix Sub...',
          'Entertainment',
          Colors.grey,
        ),
        _buildCategoryMappingItem('Biaya Admin', 'Abaikan / Hide', Colors.grey),

        SizedBox(height: 20.h),
        Text(
          '5 kategori dipetakan, 2 baru akan dibuat',
          style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildCategoryMappingItem(String source, String dest, Color color) {
    bool isSelect = dest == 'Pilih Kategori...';
    bool isIgnore = dest == 'Abaikan / Hide';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              source,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
                fontSize: 14.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Icon(Icons.arrow_forward, size: 16.sp, color: Colors.grey),
          ),
          Container(
            width: 150.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isIgnore
                  ? Colors.grey[50]
                  : (isSelect ? Colors.white : Colors.green[50]),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isIgnore
                    ? Colors.grey[200]!
                    : (isSelect ? Colors.grey[300]! : Colors.green[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dest,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isSelect
                          ? Colors.grey
                          : (isIgnore ? Colors.grey : Colors.green[800]),
                      fontWeight: isSelect
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16.sp,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 3: Konfirmasi ---
  Widget _buildStep3() {
    return Column(
      children: [
        // Stats Card
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.blue[100]!),
            boxShadow: [
              BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10.r),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.file_present,
                      color: const Color(0xFF2563EB),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '150 Transaksi',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      Text(
                        'Siap untuk diimport',
                        style: TextStyle(
                          color: const Color(0xFF3B82F6),
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Divider(height: 1.h),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengeluaran',
                          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              '120',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_downward,
                                size: 8.sp,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1.w, height: 30.h, color: Colors.grey[200]),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pemasukan',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Text(
                                '30',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_upward,
                                  size: 8.sp,
                                  color: Colors.green,
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
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Duplicate Warning
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB), // Yellow bg
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFFEF3C7)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFD97706),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '2 transaksi duplikat ditemukan dan akan dilewati otomatis.',
                  style: TextStyle(
                    color: const Color(0xFF92400E),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Date Info
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey[600]),
              SizedBox(width: 12.w),
              Text(
                'Data dari 01 Jan 2026 s/d 31 Jan 2026',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 40.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 12.sp, color: Colors.grey[400]),
            SizedBox(width: 6.w),
            Text(
              'Data Anda aman dan terenkripsi',
              style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
            ),
          ],
        ),
      ],
    );
  }
}
