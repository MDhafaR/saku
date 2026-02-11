import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;

  const SearchBar({
    super.key,
    this.hintText = 'Search transactions...',
    this.onFilterTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(Icons.search, color: const Color(0xFF9CA3AF), size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 13.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  bottom: 2.h,
                ), // Align text vertically
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          if (onFilterTap != null)
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: const Color(0xFF9CA3AF),
                  size: 18.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
