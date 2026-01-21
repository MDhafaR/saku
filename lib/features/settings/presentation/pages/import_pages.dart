import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Import Data',
          style: TextStyle(
            color: Color(0xFF333333),
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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Cloud Icon
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 80,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pindahkan Data Keuangan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pindahkan data keuanganmu dari aplikasi lain atau rekening koran bank dengan mudah.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Options
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pilih Jenis File',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    index: 0,
                    icon: Icons.table_chart_outlined,
                    iconColor: Colors.green,
                    title: 'Bank Statement / Excel',
                    subtitle:
                        'Import transaksi dari file CSV atau Excel eksternal.',
                  ),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    index: 1,
                    icon: Icons.storage_outlined,
                    iconColor: Colors.blue,
                    title: 'Saku Backup File',
                    subtitle: 'Restore data dari cadangan aplikasi Saku.',
                  ),

                  const SizedBox(height: 32),
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
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Lihat Semua'),
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
            padding: const EdgeInsets.all(20),
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
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Pilih File dari Penyimpanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : Colors.grey[400]!,
                  width: isSelected ? 5 : 1,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isSuccess ? 'Sukses' : 'Gagal',
              style: TextStyle(
                fontSize: 10,
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
      backgroundColor: const Color(0xFFF5F7FA), // Light grey bg
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF333333),
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
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: LinearProgressIndicator(
            value: _currentStep / 3,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicator text for > 1
          if (_currentStep > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Langkah $_currentStep dari 3: ${_getStepName()}',
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStep(),
            ),
          ),

          // Bottom Button
          Container(
            padding: const EdgeInsets.all(20),
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
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentStep == 1
                      ? 'Lanjut ke Konfirmasi'
                      : (_currentStep == 2
                            ? 'Simpan & Lanjut'
                            : 'Mulai Import Sekarang'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          if (_currentStep == 3)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 20),
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batalkan',
                  style: TextStyle(color: Colors.grey),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.table_chart, color: Colors.green),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'mutasi_bca_januari.csv',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '24 KB • 150 Baris',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Abaikan baris pertama (Header)',
              style: TextStyle(color: Colors.grey[800]),
            ),
            Checkbox(
              value: true,
              onChanged: (v) {},
              activeColor: const Color(0xFF2563EB),
            ),
          ],
        ),

        const SizedBox(height: 12),
        const Text(
          'Tentukan jenis data untuk setiap kolom',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

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
              const SizedBox(width: 12),
              _buildMappingColumn('Deskripsi', [
                'TRSF E-BANKING',
                'QRIS KOPI KEN...',
                'BIAYA ADMIN',
              ]),
              const SizedBox(width: 12),
              _buildMappingColumn('Abaikan / Hide', [
                'DB',
                'CR',
                'DB',
              ], isIgnored: true),
            ],
          ),
        ),

        const SizedBox(height: 32),
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 16),
            const SizedBox(width: 8),
            Text(
              '2 kolom wajib (Tanggal, Nominal) ditemukan',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
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
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isIgnored ? Colors.grey[200]! : Colors.green[200]!,
          width: isIgnored ? 1 : 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isIgnored ? Colors.grey[50] : Colors.green[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isIgnored ? Colors.grey : Colors.green[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: isIgnored ? Colors.grey : Colors.green[800],
                ),
              ],
            ),
          ),
          ...previews.map(
            (p) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[100]!)),
              ),
              child: Text(
                p,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(height: 20), // Spacer
        ],
      ),
    );
  }

  // --- Step 2: Kategori ---
  Widget _buildStep2() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buat kategori baru untuk yang tidak cocok',
                      style: TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Otomatis buat kategori jika tidak ada di Saku',
                      style: TextStyle(color: Colors.blue[600], fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoCreateCategory,
                onChanged: (v) => setState(() => _autoCreateCategory = v),
                activeColor: const Color(0xFF2563EB),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DARI CSV (SUMBER)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            Text(
              'KE SAKU (TUJUAN)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

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

        const SizedBox(height: 20),
        Text(
          '5 kategori dipetakan, 2 baru akan dibuat',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCategoryMappingItem(String source, String dest, Color color) {
    bool isSelect = dest == 'Pilih Kategori...';
    bool isIgnore = dest == 'Abaikan / Hide';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              source,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          ),
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isIgnore
                  ? Colors.grey[50]
                  : (isSelect ? Colors.white : Colors.green[50]),
              borderRadius: BorderRadius.circular(8),
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
                      fontSize: 12,
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
                  size: 16,
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue[100]!),
            boxShadow: [
              BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.file_present,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '150 Transaksi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      Text(
                        'Siap untuk diimport',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengeluaran',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              '120',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_downward,
                                size: 8,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: Colors.grey[200]),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pemasukan',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                '30',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_upward,
                                  size: 8,
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

        const SizedBox(height: 16),

        // Duplicate Warning
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB), // Yellow bg
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFEF3C7)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '2 transaksi duplikat ditemukan dan akan dilewati otomatis.',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Date Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'Data dari 01 Jan 2026 s/d 31 Jan 2026',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 12, color: Colors.grey[400]),
            const SizedBox(width: 6),
            Text(
              'Data Anda aman dan terenkripsi',
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
