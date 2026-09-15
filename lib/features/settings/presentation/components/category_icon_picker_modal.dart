import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/constants/category_icon_catalog.dart';

/// Interactive modal bottom sheet for picking category icons with search and group tabs.
class CategoryIconPickerModal extends StatefulWidget {
  final String selectedIcon;
  final Color activeColor;

  const CategoryIconPickerModal({
    super.key,
    required this.selectedIcon,
    required this.activeColor,
  });

  static Future<String?> show(
    BuildContext context, {
    required String currentIcon,
    Color? activeColor,
    Color? iconColor,
  }) {
    final effectiveColor = activeColor ?? iconColor ?? const Color(0xFF3B82F6);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryIconPickerModal(
        selectedIcon: currentIcon,
        activeColor: effectiveColor,
      ),
    );
  }

  @override
  State<CategoryIconPickerModal> createState() => _CategoryIconPickerModalState();
}

class _CategoryIconPickerModalState extends State<CategoryIconPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGroupId = 'all';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryIconItem> get _filteredItems {
    if (_searchQuery.isNotEmpty) {
      return CategoryIconCatalog.search(_searchQuery);
    }
    if (_selectedGroupId == 'all') {
      return CategoryIconCatalog.groups.expand((g) => g.items).toList();
    }
    final group = CategoryIconCatalog.groups.firstWhere(
      (g) => g.id == _selectedGroupId,
      orElse: () => CategoryIconCatalog.groups.first,
    );
    return group.items;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          // Drag Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Ikon Kategori',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  iconSize: 20.sp,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? cs.surfaceContainerLow : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari ikon... (contoh: kopi, bensin, baju)',
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20.sp,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Category Group Chips (hidden when searching)
          if (_searchQuery.isEmpty)
            SizedBox(
              height: 36.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  _buildGroupChip('all', 'Semua', HugeIcons.strokeRoundedGrid),
                  ...CategoryIconCatalog.groups.map(
                    (g) => _buildGroupChip(g.id, g.title, g.groupIcon),
                  ),
                ],
              ),
            ),

          if (_searchQuery.isEmpty) SizedBox(height: 12.h),

          // Grid of Icons
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48.sp,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Ikon tidak ditemukan',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = item.key == widget.selectedIcon;

                      return InkWell(
                        onTap: () {
                          Navigator.pop(context, item.key);
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? widget.activeColor.withValues(alpha: 0.15)
                                : (isDark ? cs.surfaceContainerLow : const Color(0xFFF9FAFB)),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected
                                  ? widget.activeColor
                                  : (isDark ? cs.outline.withValues(alpha: 0.2) : const Color(0xFFE5E7EB)),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: item.icon,
                                color: isSelected ? widget.activeColor : cs.onSurface.withValues(alpha: 0.8),
                                size: 24.sp,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                item.label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? widget.activeColor : cs.onSurface.withValues(alpha: 0.7),
                                ),
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
    );
  }

  Widget _buildGroupChip(String id, String label, List<List<dynamic>> icon) {
    final isSelected = _selectedGroupId == id;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: HugeIcon(
          icon: icon,
          color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.7),
          size: 14.sp,
        ),
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.8),
        ),
        backgroundColor: isDark ? cs.surfaceContainerLow : const Color(0xFFF3F4F6),
        selectedColor: cs.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: isSelected ? Colors.transparent : (isDark ? cs.outline.withValues(alpha: 0.2) : Colors.transparent),
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedGroupId = id;
          });
        },
      ),
    );
  }
}
