import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../data/local/database/app_database.dart';

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
    'pets',
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

  IconData _getIconData(String name) {
    switch (name) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'receipt':
        return Icons.receipt;
      case 'movie':
        return Icons.movie;
      case 'medical_services':
        return Icons.medical_services;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'payments':
        return Icons.payments;
      case 'business':
        return Icons.business;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'trending_up':
        return Icons.trending_up;
      case 'home':
        return Icons.home;
      case 'pets':
        return Icons.pets;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'work':
        return Icons.work;
      case 'child_care':
        return Icons.child_care;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'local_bar':
        return Icons.local_bar;
      default:
        return Icons.category;
    }
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Hapus Kategori',
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
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Semua item yang berkategori '),
                  TextSpan(
                    text: '"$categoryName"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const TextSpan(text: ' akan menjadi '),
                  const TextSpan(
                    text: 'Uncategorized',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Apakah Anda yakin ingin menghapus kategori ini?',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
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
              'Hapus',
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
          const SnackBar(
            content: Text('Tidak ada kategori lain untuk dipindahkan.'),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Pindahkan Kategori',
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
                'Kategori ini akan dihapus, tetapi semua item dengan kategori ini akan dipindahkan ke kategori lain.',
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
                      color: const Color(0xFF111111),
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
                                    ).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIconData(cat.icon),
                                    color: Color(cat.iconColor),
                                    size: 14.sp,
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: const Color(0xFF111111),
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Kategori' : 'Tambah Kategori',
          style: TextStyle(
            color: const Color(0xFF111111),
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
                        'Hapus Kategori',
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
                        'Pindahkan Kategori',
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
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Input
            Text(
              'Nama Kategori',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Contoh: Makanan, Transportasi',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Icon Selector
            Text(
              'Ikon',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 16.h,
                  crossAxisSpacing: 16.w,
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
                            ? Color(_selectedColor).withOpacity(0.1)
                            : Colors.grey[50],
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Color(_selectedColor), width: 2)
                            : null,
                      ),
                      child: Icon(
                        _getIconData(iconName),
                        color: isSelected
                            ? Color(_selectedColor)
                            : Colors.grey[400],
                        size: 24.sp,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),

            // Color Selector
            Text(
              'Warna',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 16.h,
                  crossAxisSpacing: 16.w,
                ),
                itemCount: _colors.length,
                itemBuilder: (context, index) {
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
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                          : null,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 40.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
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
                  'Simpan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
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
