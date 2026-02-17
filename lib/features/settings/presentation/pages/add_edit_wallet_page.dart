import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../core/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';

class AddEditWalletPage extends StatefulWidget {
  /// If non-null, we're in edit mode; otherwise add mode.
  final Wallet? wallet;

  const AddEditWalletPage({super.key, this.wallet});

  @override
  State<AddEditWalletPage> createState() => _AddEditWalletPageState();
}

class _AddEditWalletPageState extends State<AddEditWalletPage> {
  late final TextEditingController _nameController;
  late final TextEditingController
  _initialBalanceController; // Changed from _balanceController to specific initial balance
  late final TextEditingController _accountNumberController;
  late String _selectedType;
  late String _selectedIcon;
  late int _selectedColor;
  late bool _isMain;
  late bool _isHidden;
  late bool _isNumberMasked;

  bool get _isEdit => widget.wallet != null;

  final _icons = {
    'wallet': Icons.account_balance_wallet,
    'bank': Icons.account_balance,
    'payment': Icons.payment,
    'mobile': Icons.mobile_friendly,
    'savings': Icons.savings,
    'credit_card': Icons.credit_card,
    'money': Icons.money,
    'investment': Icons.trending_up,
  };

  final _colors = [
    0xFF10B981,
    0xFF3B82F6,
    0xFF8A2BE2,
    0xFFF59E0B,
    0xFFEF4444,
    0xFF06B6D4,
    0xFFEC4899,
    0xFF111111,
  ];

  @override
  void initState() {
    super.initState();
    final w = widget.wallet;
    _nameController = TextEditingController(text: w?.name ?? '');
    // Initial balance is only relevant for new wallets or displaying current balance for existing (though we might not want to edit it easily)
    // For this task, we add "Saldo Awal" which maps to initialBalance.
    // However, the previous code used _balanceController for currentBalance.
    // The requirement is "add field saldo awal".
    // If it's a new wallet, we show 0. If it's edit, we probably shouldn't show "Initial Balance" as editable, or maybe show it as "Saldo Saat Ini".
    // But the request says "pada add wallet", so let's focus on that.

    // Valid logic:
    // New Wallet: Show "Saldo Awal" field (empty or 0).
    // Edit Wallet: Maybe hide it, or show "Saldo Saat Ini".
    // The plan said: "Only show this field (or make it editable) when adding a new wallet".

    _initialBalanceController = TextEditingController(
      text: w != null
          ? CurrencyFormatter.format(w.currentBalance.toStringAsFixed(0))
          : '',
    );
    _accountNumberController = TextEditingController(
      text: w?.accountNumber ?? '',
    );
    _selectedType = w?.type ?? 'cash';
    _selectedIcon = w?.icon ?? 'wallet';
    _selectedColor = w?.iconColor ?? 0xFF10B981;
    _isMain = w?.isMain ?? false;
    _isHidden = w?.isHidden ?? false;
    _isNumberMasked = w?.isNumberMasked ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama wallet tidak boleh kosong')),
      );
      return;
    }

    final accountNumber = _accountNumberController.text.trim();
    final db = locator<AppDatabase>();
    final rawBalance = CurrencyFormatter.parse(_initialBalanceController.text);
    final balance = double.tryParse(rawBalance) ?? 0.0;

    if (_isEdit) {
      final updated = widget.wallet!.copyWith(
        name: name,
        type: _selectedType,
        icon: _selectedIcon,
        iconColor: _selectedColor,
        accountNumber: Value(accountNumber.isEmpty ? null : accountNumber),
        isMain: _isMain,
        isHidden: _isHidden,
        isNumberMasked: _isNumberMasked,
        updatedAt: DateTime.now(),
        // We do NOT update balance here for edit mode based on this field
      );
      await db.walletDao.updateWallet(updated);
    } else {
      await db.walletDao.createWallet(
        WalletsCompanion(
          name: Value(name),
          type: Value(_selectedType),
          icon: Value(_selectedIcon),
          iconColor: Value(_selectedColor),
          initialBalance: Value(balance),
          currentBalance: Value(balance),
          accountNumber: Value(accountNumber.isEmpty ? null : accountNumber),
          isMain: Value(_isMain),
          isHidden: Value(_isHidden),
          isNumberMasked: Value(_isNumberMasked),
        ),
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: const Color(0xFF111111),
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Wallet' : 'Tambah Wallet',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isEdit)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_horiz,
                color: const Color(0xFF111111),
                size: 24.sp,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              color: Colors.white,
              elevation: 4,
              offset: Offset(0, 40.h),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog();
                } else if (value == 'move') {
                  _showMoveDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: const Color(0xFFEF4444),
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Hapus Wallet',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'move',
                  child: Row(
                    children: [
                      Icon(
                        Icons.drive_file_move_outline,
                        color: const Color(0xFF111111),
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Pindahkan Wallet',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview card
            _buildPreviewCard(),
            SizedBox(height: 24.h),

            // Name
            _buildSectionLabel('Nama Wallet'),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: _nameController,
              hint: 'Cash Wallet',
              onChanged: (_) => setState(() {}),
            ),

            // Initial Balance (Only for new wallets)
            if (!_isEdit) ...[
              SizedBox(height: 20.h),
              _buildSectionLabel('Saldo Awal'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: _initialBalanceController,
                hint: '1.000.000',
                prefix: 'Rp ',
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  // Re-format currency
                  final unformatted = CurrencyFormatter.parse(val);
                  final formatted = CurrencyFormatter.format(unformatted);

                  if (formatted != val) {
                    _initialBalanceController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
              ),
            ],
            SizedBox(height: 20.h),

            // Category (Type)
            _buildSectionLabel('Ikon'),
            SizedBox(height: 8.h),
            _buildIconSelector(),
            SizedBox(height: 24.h),

            // Color Selection
            _buildSectionLabel('Warna'),
            SizedBox(height: 8.h),
            _buildColorSelector(),
            SizedBox(height: 24.h),

            // Preferences Section
            _buildSectionLabel('Preferensi'),
            SizedBox(height: 12.h),

            _buildSwitchTile(
              title: 'Sembunyikan Saldo',
              value: _isHidden,
              onChanged: (val) => setState(() => _isHidden = val),
            ),
            SizedBox(height: 24.h),

            // Account Number Section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nomor Rekening / ID (Opsional)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      controller: _accountNumberController,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF111111),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: '5220123456',
                        hintStyle: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sensor & Kunci Nomor',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111111),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Jika aktif, nomor akan disensor dan membutuhkan PIN/FaceID untuk menyalin.',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF9CA3AF),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _isNumberMasked,
                          onChanged: (val) =>
                              setState(() => _isNumberMasked = val),
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF111111),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFE5E7EB),
                          trackOutlineColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Save button
            _buildSaveButton(),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final name = _nameController.text.trim().isEmpty
        ? 'Nama Wallet'
        : _nameController.text.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Color(_selectedColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _icons[_selectedIcon] ?? Icons.account_balance_wallet,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: const Color(0xFF111111),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF111111),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF111111)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 14.sp),
          prefixIcon: prefix != null
              ? Padding(
                  padding: EdgeInsets.only(left: 16.w, right: 8.w),
                  child: Text(
                    prefix,
                    style: TextStyle(
                      color: const Color(0xFF111111),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          prefixStyle: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1,
        ),
        itemCount: _icons.length,
        itemBuilder: (context, index) {
          final entry = _icons.entries.elementAt(index);
          final isSelected = _selectedIcon == entry.key;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIcon = entry.key;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF111111)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
                border: isSelected
                    ? Border.all(color: const Color(0xFF111111), width: 2)
                    : null,
              ),
              child: Icon(
                entry.value,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                size: 24.sp,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: _colors.map((colorValue) {
          final isSelected = _selectedColor == colorValue;
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = colorValue),
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: Color(colorValue),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: const Color(0xFF111111), width: 2)
                    : Border.all(color: Colors.transparent, width: 2),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Color(colorValue).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111111),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF111111),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFE5E7EB),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF111111),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        child: Text(
          _isEdit ? 'Simpan Perubahan' : 'Tambah Wallet',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showDeleteDialog() async {
    final db = locator<AppDatabase>();
    final walletName = widget.wallet?.name ?? '';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        String confirmText = '';
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final isConfirmed = confirmText.toLowerCase() == 'delete wallet';
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFEF4444),
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Hapus Wallet',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF6B7280),
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Anda akan menghapus wallet '),
                          TextSpan(
                            text: '"$walletName"',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const TextSpan(
                            text: '. Tindakan ini tidak dapat dibatalkan.',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data berikut akan DIHAPUS PERMANEN:',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _buildDeleteInfoRow(
                            Icons.receipt_long_outlined,
                            'Semua transaksi di wallet ini',
                          ),
                          SizedBox(height: 4.h),
                          _buildDeleteInfoRow(
                            Icons.money_off_outlined,
                            'Semua hutang/piutang terkait',
                          ),
                          SizedBox(height: 4.h),
                          _buildDeleteInfoRow(
                            Icons.payments_outlined,
                            'Semua pembayaran hutang terkait',
                          ),
                          SizedBox(height: 4.h),
                          _buildDeleteInfoRow(
                            Icons.account_balance_wallet_outlined,
                            'Saldo wallet',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Ketik "delete wallet" untuk konfirmasi:',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      onChanged: (val) {
                        setDialogState(() => confirmText = val);
                      },
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF111111),
                      ),
                      decoration: InputDecoration(
                        hintText: 'delete wallet',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFD1D5DB),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: isConfirmed
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: isConfirmed
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: isConfirmed
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF9CA3AF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isConfirmed
                      ? () async {
                          Navigator.pop(ctx);
                          await db.walletDao.deleteWalletWithAllData(
                            widget.wallet!.id,
                          );
                          if (mounted) {
                            Navigator.pop(context, true);
                            Navigator.pop(context, true);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    disabledBackgroundColor: const Color(0xFFFCA5A5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Hapus Semua',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDeleteInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFFDC2626)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFFDC2626),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showMoveDialog() async {
    final db = locator<AppDatabase>();
    final allWallets = await db.walletDao.getAllWallets();
    final otherWallets = allWallets
        .where((w) => w.id != widget.wallet!.id)
        .toList();

    if (otherWallets.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada wallet lain untuk dipindahkan.'),
          ),
        );
      }
      return;
    }

    Wallet? selectedTarget = otherWallets.first;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Pindahkan Wallet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet ini akan dihapus, tetapi semua transaksi dan saldo akan dipindahkan ke wallet lain.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Pindahkan ke:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111111),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10.r),
                  color: const Color(0xFFF9FAFB),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Wallet>(
                    isExpanded: true,
                    value: selectedTarget,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF6B7280),
                      size: 22.sp,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF111111),
                    ),
                    items: otherWallets
                        .map(
                          (w) => DropdownMenuItem<Wallet>(
                            value: w,
                            child: Row(
                              children: [
                                Container(
                                  width: 28.w,
                                  height: 28.w,
                                  decoration: BoxDecoration(
                                    color: Color(w.iconColor).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    _icons[w.icon] ??
                                        Icons.account_balance_wallet,
                                    color: Color(w.iconColor),
                                    size: 14.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    w.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedTarget = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedTarget == null) return;
                Navigator.pop(ctx);
                await db.walletDao.deleteWalletAndReassign(
                  widget.wallet!,
                  targetWalletId: selectedTarget!.id,
                );
                if (mounted) {
                  Navigator.pop(context, true);
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Pindahkan',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
