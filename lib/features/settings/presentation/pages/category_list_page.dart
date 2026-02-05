import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  int _selectedTab = 0; // 0 = Pengeluaran, 1 = Pemasukan

  final List<Map<String, dynamic>> _expenseCategories = [
    {
      'name': 'Makanan & Minuman',
      'icon': Icons.fastfood,
      'color': const Color(0xFFF87171),
    },
    {
      'name': 'Transportasi',
      'icon': Icons.directions_bus,
      'color': const Color(0xFF34D399),
    },
    {
      'name': 'Belanja Bulanan',
      'icon': Icons.shopping_bag,
      'color': const Color(0xFFFBBF24),
    },
    {
      'name': 'Hiburan & Hobi',
      'icon': Icons.movie,
      'color': const Color(0xFF818CF8),
    },
    {
      'name': 'Tagihan Rumah',
      'icon': Icons.home,
      'color': const Color(0xFFFB923C),
    },
    {
      'name': 'Kesehatan',
      'icon': Icons.medical_services,
      'color': const Color(0xFFF87171),
    },
    {
      'name': 'Pendidikan',
      'icon': Icons.school,
      'color': const Color(0xFF3B82F6),
    },
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {
      'name': 'Gaji',
      'icon': Icons.attach_money,
      'color': const Color(0xFF10B981),
    },
    {
      'name': 'Hadiah',
      'icon': Icons.card_giftcard,
      'color': const Color(0xFFF472B6),
    },
    {
      'name': 'Investasi',
      'icon': Icons.trending_up,
      'color': const Color(0xFF3B82F6),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final categories = _selectedTab == 0
        ? _expenseCategories
        : _incomeCategories;

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
            color: const Color(0xFF1F2937),
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Atur Kategori',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: const Color(0xFF1F2937),
              size: 22.sp,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          // Tab Selector - Sliding Pill style (matching design system)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / 2;
                  return Stack(
                    children: [
                      // Sliding indicator
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        left: _selectedTab == 0 ? 0 : tabWidth,
                        top: 0,
                        bottom: 0,
                        width: tabWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Tab labels
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (_selectedTab != 0) {
                                  setState(() => _selectedTab = 0);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_downward_rounded,
                                      size: 16.sp,
                                      color: _selectedTab == 0
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF9CA3AF),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Pengeluaran',
                                      style: TextStyle(
                                        color: _selectedTab == 0
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (_selectedTab != 1) {
                                  setState(() => _selectedTab = 1);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 16.sp,
                                      color: _selectedTab == 1
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF9CA3AF),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Pemasukan',
                                      style: TextStyle(
                                        color: _selectedTab == 1
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Category List
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: ListView.separated(
                key: ValueKey(_selectedTab),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 0,
                  bottom: 86.h,
                ),
                itemCount: categories.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: (category['color'] as Color).withOpacity(
                              0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category['icon'] as IconData,
                            color: category['color'] as Color,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Name
                        Expanded(
                          child: Text(
                            category['name'] as String,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ),
                        // Edit Button
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20.sp,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {},
                        ),
                        // Drag Handle
                        Icon(
                          Icons.drag_handle,
                          color: Colors.grey[400],
                          size: 24.sp,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF111111),
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }
}
