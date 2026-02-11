import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/local/database/app_database.dart';

class CategorySelectionPage extends StatefulWidget {
  final bool isExpense;

  const CategorySelectionPage({super.key, required this.isExpense});

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = locator<AppDatabase>();
    final type = widget.isExpense ? 'expense' : 'income';
    final categories = await db.categoryDao.getCategoriesByType(type);
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  IconData _iconFromName(String name) {
    const iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_cart': Icons.shopping_cart,
      'receipt': Icons.receipt,
      'movie': Icons.movie,
      'medical_services': Icons.medical_services,
      'school': Icons.school,
      'flight': Icons.flight,
      'payments': Icons.payments,
      'business': Icons.business,
      'card_giftcard': Icons.card_giftcard,
      'trending_up': Icons.trending_up,
      'category': Icons.category,
      'fastfood': Icons.fastfood,
      'directions_bus': Icons.directions_bus,
      'shopping_bag': Icons.shopping_bag,
      'home': Icons.home,
      'attach_money': Icons.attach_money,
      'stars': Icons.stars,
    };
    return iconMap[name] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.isExpense ? 'Kategori Pengeluaran' : 'Kategori Pemasukan',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          SizedBox(height: 20.h),

          // Category List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 0,
                    ),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final color = Color(category.iconColor);
                      final icon = _iconFromName(category.icon);

                      return GestureDetector(
                        onTap: () {
                          // Return the category data
                          Navigator.pop(context, {
                            'id': category.id,
                            'name': category.name,
                            'icon': icon,
                            'color': color,
                            'isExpense': widget.isExpense,
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.grey[100]!),
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color, size: 22.sp),
                              ),
                              SizedBox(width: 16.w),
                              // Name
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                              // Arrow
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey[400],
                                size: 24.sp,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add category page
        },
        backgroundColor: AppTheme.primaryBlue,
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }
}
