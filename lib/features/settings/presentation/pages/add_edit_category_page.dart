import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/presentation/components/custom_color_picker_dialog.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../statistics/presentation/pages/category_transactions_page.dart';
import '../components/category_icon_picker_modal.dart';

class AddEditCategoryPage extends StatefulWidget {
  final Category? category;
  final String type; // 'income' or 'expense'

  const AddEditCategoryPage({super.key, this.category, required this.type});

  @override
  State<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  late TextEditingController _nameController;
  late String _selectedIcon;
  late int _selectedColor;
  late final AppDatabase _db;

  final List<String> _icons = [
    'restaurant',
    'directions_car',
    'shopping_cart',
    'receipt',
    'movie',
    'medical_services',
    'school',
    'flight',
    'payments',
    'business',
    'card_giftcard',
    'trending_up',
    'home',
    'favorite',
    'fitness_center',
    'work',
    'child_care',
    'sports_esports',
    'local_cafe',
    'local_bar',
  ];

  final List<int> _colors = [
    0xFFFF5722, // Deep Orange
    0xFF2196F3, // Blue
    0xFF9C27B0, // Purple
    0xFF607D8B, // Blue Grey
    0xFFE91E63, // Pink
    0xFFE53935, // Red
    0xFF3F51B5, // Indigo
    0xFF00BCD4, // Cyan
    0xFF4CAF50, // Green
    0xFF8BC34A, // Light Green
    0xFFFF9800, // Orange
    0xFF009688, // Teal
    0xFF795548, // Brown
    0xFF9E9E9E, // Grey
    0xFF000000, // Black
  ];

  @override
  void initState() {
    super.initState();
    _db = locator<AppDatabase>();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.icon ?? 'category';
    _selectedColor = widget.category?.iconColor ?? 0xFF2196F3;

    // Set default icon/color if new
    if (widget.category == null) {
      _selectedIcon = _icons.first;
      _selectedColor = _colors.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final companion = CategoriesCompanion(
      name: drift.Value(name),
      type: drift.Value(widget.type),
      icon: drift.Value(_selectedIcon),
      iconColor: drift.Value(_selectedColor),
      isDefault: const drift.Value(false),
    );

    if (widget.category != null) {
      await _db.categoryDao.updateCategory(
        widget.category!.copyWith(
          name: name,
          icon: _selectedIcon,
          iconColor: _selectedColor,
        ),
      );
    } else {
      await _db.categoryDao.createCategory(companion);
    }

    if (mounted) Navigator.pop(context);
  }

  void _showDeleteDialog() {
    final categoryName = widget.category?.name ?? '';
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.deleteCategory,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Column(
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
                        ? 'Semua item yang berkategori '
                        : 'All items categorized as ',
                  ),
                  TextSpan(
                    text: '"$categoryName"',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: l10n.isIndonesian
                        ? ' akan menjadi '
                        : ' will become ',
                  ),
                  TextSpan(
                    text: 'Uncategorized',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.isIndonesian
                  ? 'Apakah Anda yakin ingin menghapus kategori ini?'
                  : 'Are you sure you want to delete this category?',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
              Navigator.pop(ctx);
              await _db.categoryDao.deleteCategoryAndReassign(
                widget.category!.id,
                widget.type,
              );
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.delete,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoveDialog() async {
    final l10n = context.l10n;
    // Fetch categories of the same type, excluding current
    final allCategories = await _db.categoryDao.getCategoriesByType(
      widget.type,
    );
    final otherCategories = allCategories
        .where((c) => c.id != widget.category!.id)
        .toList();

    if (otherCategories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noOtherCategoriesToMove),
          ),
        );
      }
      return;
    }

    Category? selectedTarget = otherCategories.first;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            l10n.moveCategory,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.isIndonesian
                    ? 'Kategori ini akan dihapus, tetapi semua item dengan kategori ini akan dipindahkan ke kategori lain.'
                    : 'This category will be deleted, but all items in this category will be moved to another category.',
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10.r),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surfaceContainerLow
                      : const Color(0xFFF9FAFB),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Category>(
                    isExpanded: true,
                    value: selectedTarget,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF6B7280),
                      size: 22.sp,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    items: otherCategories
                        .map(
                          (cat) => DropdownMenuItem<Category>(
                            value: cat,
                            child: Row(
                              children: [
                                Container(
                                  width: 28.w,
                                  height: 28.w,
                                  decoration: BoxDecoration(
                                    color: Color(
                                      cat.iconColor,
                                    ).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: CategoryIcon(
                                      iconName: cat.icon,
                                      color: Color(cat.iconColor),
                                      size: 14.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    cat.name,
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
                await _db.categoryDao.deleteCategoryAndReassign(
                  widget.category!.id,
                  widget.type,
                  targetCategoryId: selectedTarget!.id,
                );
                if (mounted) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditing = widget.category != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? l10n.editCategoryTitle : l10n.addCategoryTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_horiz,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24.sp,
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
                } else if (value == 'history') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryTransactionsPage(
                        categoryId: widget.category!.id,
                        categoryName: widget.category!.name,
                        iconName: widget.category!.icon,
                        color: Color(widget.category!.iconColor),
                        totalAmount: 0.0,
                        period: 'Monthly',
                        targetDate: DateTime.now(),
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'history',
                  child: Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        l10n.transactionHistory,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
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
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        l10n.moveCategory,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
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
                        l10n.deleteCategory,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFEF4444),
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
            // Name Input
            Text(
              l10n.categoryNameLabel,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 6.h),
            SakuCard(
              borderRadius: 14,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
              child: TextField(
                controller: _nameController,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: l10n.categoryNameHint,
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.35),
                  ),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Icon Selector Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.iconLabel,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await CategoryIconPickerModal.show(
                      context,
                      currentIcon: _selectedIcon,
                      activeColor: Color(_selectedColor),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedIcon = picked;
                        if (!_icons.contains(picked)) {
                          _icons.insert(0, picked);
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
                    foregroundColor: Color(_selectedColor),
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
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
                            ? Color(_selectedColor).withValues(alpha: 0.12)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.04),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Color(_selectedColor), width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: CategoryIcon(
                        iconName: iconName,
                        color: isSelected
                            ? Color(_selectedColor)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                        size: 19.sp,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),

            // Color Selector Header
            Text(
              l10n.colorLabel,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 6.h),
            SakuCard(
              borderRadius: 14,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(10.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8.h,
                  crossAxisSpacing: 8.w,
                ),
                itemCount: _colors.length + 1,
                itemBuilder: (context, index) {
                  // Custom Color Picker Button (The 16th item)
                  if (index == _colors.length) {
                    final isCustomSelected = !_colors.contains(_selectedColor);
                    return GestureDetector(
                      onTap: () async {
                        final picked = await showCustomColorPickerDialog(
                          context,
                          initialColor: Color(_selectedColor),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedColor = picked.toARGB32();
                          });
                        }
                      },
                      child: Container(
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
                              ? Border.all(color: Colors.white, width: 2.5)
                              : Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: isCustomSelected
                                  ? Color(_selectedColor).withValues(alpha: 0.35)
                                  : Colors.black.withValues(alpha: 0.08),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: isCustomSelected
                            ? Icon(Icons.check, color: Colors.white, size: 15.sp)
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
                      ),
                    );
                  }

                  final colorValue = _colors[index];
                  final isSelected = _selectedColor == colorValue;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorValue;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2.5)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 3,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 15.sp)
                          : null,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 18.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.saveButton,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
