import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../core/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/presentation/components/custom_color_picker_dialog.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../components/category_icon_picker_modal.dart';

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

  final List<String> _icons = [
    'wallet',
    'bank',
    'credit_card',
    'cash',
    'savings',
    'money',
    'investment',
    'mobile',
    'store',
    'coins',
  ];

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
    if (!_icons.contains(_selectedIcon)) {
      _icons.insert(0, _selectedIcon);
    }
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
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.walletNameCannotBeEmpty)),
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
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
            size: 18.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? l10n.editWalletTitle : l10n.addWalletTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.onSurface,
                size: 20.sp,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              color: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
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
                        size: 18.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        l10n.isIndonesian ? 'Hapus Wallet' : 'Delete Wallet',
                        style: TextStyle(
                          fontSize: 13.sp,
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
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 18.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        l10n.isIndonesian ? 'Pindahkan Wallet' : 'Move Wallet',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview card
            _buildPreviewCard(),
            SizedBox(height: 12.h),

            // Name
            _buildSectionLabel(l10n.walletNameLabel),
            SizedBox(height: 6.h),
            _buildTextField(
              controller: _nameController,
              hint: 'Cash Wallet',
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 12.h),

            // Initial Balance (Only for new wallets)
            if (!_isEdit) ...[
              _buildSectionLabel(l10n.initialBalanceLabel),
              SizedBox(height: 6.h),
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
              SizedBox(height: 12.h),
            ],

            // Icon Selector
            _buildIconSelector(),
            SizedBox(height: 12.h),

            // Color Selection
            _buildSectionLabel(l10n.colorLabel),
            SizedBox(height: 6.h),
            _buildColorSelector(),
            SizedBox(height: 12.h),

            // Preferences Section
            _buildSectionLabel(l10n.preferencesLabel),
            SizedBox(height: 6.h),

            _buildSwitchTile(
              title: l10n.hideBalanceLabel,
              value: _isHidden,
              onChanged: (val) => setState(() => _isHidden = val),
            ),
            SizedBox(height: 12.h),

            // Account Number Section
            _buildAccountNumberSection(),
            SizedBox(height: 18.h),

            // Save button
            _buildSaveButton(),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final l10n = context.l10n;
    final name = _nameController.text.trim().isEmpty
        ? l10n.walletNameLabel
        : _nameController.text.trim();

    return SakuCard(
      borderRadius: 14,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: Color(_selectedColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: CategoryIcon(
                 iconName: _selectedIcon,
                 color: Colors.white,
                 size: 20.sp,
               ),
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
                    color: Theme.of(context).colorScheme.onSurface,
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
        color: Theme.of(context).colorScheme.onSurface,
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
    return SakuCard(
      borderRadius: 14,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14.sp,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.35),
            fontSize: 13.sp,
          ),
          prefixIcon: prefix != null
              ? Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: Text(
                    prefix,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel(l10n.iconLabel),
            TextButton.icon(
              onPressed: () async {
                final selected = await CategoryIconPickerModal.show(
                  context,
                  currentIcon: _selectedIcon,
                  activeColor: Color(_selectedColor),
                );
                if (selected != null) {
                  setState(() {
                    _selectedIcon = selected;
                    if (!_icons.contains(selected)) {
                      _icons.insert(0, selected);
                    }
                  });
                }
              },
              icon: Icon(
                Icons.grid_view_rounded,
                size: 15.sp,
                color: Color(_selectedColor),
              ),
              label: Text(
                l10n.fullCatalogLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(_selectedColor),
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        SakuCard(
          borderRadius: 14,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(10.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 1,
            ),
            itemCount: _icons.length,
            itemBuilder: (context, index) {
              final iconName = _icons[index];
              final isSelected = _selectedIcon == iconName;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = iconName;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(_selectedColor).withValues(alpha: 0.15)
                        : (Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow
                              : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(10.r),
                    border: isSelected
                        ? Border.all(color: Color(_selectedColor), width: 2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: CategoryIcon(
                    iconName: iconName,
                    color: isSelected
                        ? Color(_selectedColor)
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 19.sp,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return SakuCard(
      borderRadius: 14,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(10.w),
      child: Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: [
          ..._colors.map((colorValue) {
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
                      ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
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
          }),
          // Custom Color Button
          GestureDetector(
            onTap: () async {
              final picked = await showCustomColorPickerDialog(
                context,
                initialColor: Color(_selectedColor),
              );
              if (picked != null) {
                setState(() => _selectedColor = picked.toARGB32());
              }
            },
            child: Builder(
              builder: (context) {
                final isCustomSelected = !_colors.contains(_selectedColor);
                return Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isCustomSelected
                        ? null
                        : const SweepGradient(
                            colors: [
                              Colors.red,
                              Colors.amber,
                              Colors.green,
                              Colors.cyan,
                              Colors.blue,
                              Colors.purple,
                              Colors.red,
                            ],
                          ),
                    color: isCustomSelected ? Color(_selectedColor) : null,
                    border: isCustomSelected
                        ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                        : Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.2),
                            width: 1,
                          ),
                    boxShadow: [
                      if (isCustomSelected)
                        BoxShadow(
                          color: Color(_selectedColor).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: isCustomSelected
                      ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                      : Container(
                          margin: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 16.sp,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SakuCard(
      borderRadius: 14,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : const Color(0xFFE5E7EB),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountNumberSection() {
    final l10n = context.l10n;
    return SakuCard(
      borderRadius: 14,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accountNumberLabel,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerLow
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: TextField(
              controller: _accountNumberController,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: '5220123456',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                  fontSize: 13.sp,
                ),
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.maskAndLockNumber,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.maskAndLockNumberDesc,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: _isNumberMasked,
                  onChanged: (val) =>
                      setState(() => _isNumberMasked = val),
                  activeThumbColor: Colors.white,
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surfaceContainerHigh
                      : const Color(0xFFE5E7EB),
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final l10n = context.l10n;
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Text(
          _isEdit ? l10n.saveChangesButton : l10n.addWalletTitle,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }


  void _showDeleteDialog() async {
    final db = locator<AppDatabase>();
    final walletName = widget.wallet?.name ?? '';
    final l10n = context.l10n;

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
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
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
                      l10n.isIndonesian ? 'Hapus Wallet' : 'Delete Wallet',
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
                          TextSpan(
                            text: l10n.isIndonesian
                                ? 'Anda akan menghapus wallet '
                                : 'You are about to delete wallet ',
                          ),
                          TextSpan(
                            text: '"$walletName"',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                            ),
                          ),
                          TextSpan(
                            text: l10n.isIndonesian
                                ? '. Tindakan ini tidak dapat dibatalkan.'
                                : '. This action cannot be undone.',
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
                            l10n.isIndonesian
                                ? 'Data berikut akan DIHAPUS PERMANEN:'
                                : 'The following data will be PERMANENTLY DELETED:',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _buildDeleteInfoRow(
                            Icons.receipt_long_outlined,
                            l10n.isIndonesian
                                ? 'Semua transaksi di wallet ini'
                                : 'All transactions in this wallet',
                          ),
                          SizedBox(height: 4.h),
                          _buildDeleteInfoRow(
                            Icons.money_off_outlined,
                            l10n.isIndonesian
                                ? 'Semua hutang/piutang terkait'
                                : 'All related debts/loans',
                          ),
                          SizedBox(height: 4.h),
                          _buildDeleteInfoRow(
                            Icons.payments_outlined,
                            l10n.isIndonesian
                                ? 'Semua pembayaran hutang terkait'
                                : 'All related debt payments',
                          ),
                          SizedBox(height: 4.h),
                          _buildDeleteInfoRow(
                            Icons.account_balance_wallet_outlined,
                            l10n.isIndonesian ? 'Saldo wallet' : 'Wallet balance',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.isIndonesian
                          ? 'Ketik "delete wallet" untuk konfirmasi:'
                          : 'Type "delete wallet" to confirm:',
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
                    l10n.cancel,
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
                    l10n.isIndonesian ? 'Hapus Semua' : 'Delete All',
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
    final l10n = context.l10n;
    final db = locator<AppDatabase>();
    final allWallets = await db.walletDao.getAllWallets();
    final otherWallets = allWallets
        .where((w) => w.id != widget.wallet!.id)
        .toList();

    if (otherWallets.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noOtherWalletsToMove),
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
            l10n.isIndonesian ? 'Pindahkan Wallet' : 'Move Wallet',
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
                l10n.isIndonesian
                    ? 'Wallet ini akan dihapus, tetapi semua transaksi dan saldo akan dipindahkan ke wallet lain.'
                    : 'This wallet will be deleted, but all transactions and balance will be moved to another wallet.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.moveToLabel,
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
                                    color: Color(
                                      w.iconColor,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  alignment: Alignment.center,
                                  child: CategoryIcon(
                                    iconName: w.icon,
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
                l10n.cancel,
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
                l10n.moveButton,
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
