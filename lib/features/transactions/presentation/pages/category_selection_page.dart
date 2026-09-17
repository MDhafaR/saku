import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../settings/presentation/pages/add_edit_category_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isExpense ? l10n.categoryExpenseTitle : l10n.categoryIncomeTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Category List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      top: 20.h,
                      bottom: 76.h,
                    ),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final color = Color(category.iconColor);

                      return GestureDetector(
                        onTap: () {
                          // Return the category data
                          Navigator.pop(context, {
                            'id': category.id,
                            'name': category.name,
                            'iconName': category.icon,
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
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: CategoryIcon(
                                  iconName: category.icon,
                                  color: color,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              // Name
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              // Arrow
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                size: 22.sp,
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditCategoryPage(
                type: widget.isExpense ? 'expense' : 'income',
              ),
            ),
          );
          _loadCategories();
        },
        backgroundColor: const Color(0xFF111111),
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }
}
