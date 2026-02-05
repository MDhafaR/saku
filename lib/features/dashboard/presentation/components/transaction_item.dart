import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/saku_card.dart';

class TransactionItem extends StatelessWidget {
  final String category;
  final String paymentMethod;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool isIncome;

  const TransactionItem({
    super.key,
    required this.category,
    required this.paymentMethod,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {
    return SakuCard(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildBottomSheet(context),
        );
      },
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111), // Darker black
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  paymentMethod,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: isIncome
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFD32F2F),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32.r),
        ), // More rounded top
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey[200], // Lighter handle
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Icon
          Container(
            width: 88.w,
            height: 88.w,
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(
                0.15,
              ), // Consistent soft background
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 40.sp),
          ),
          SizedBox(height: 12.h),

          // Amount
          Text(
            amount,
            style: TextStyle(
              fontSize: 36.sp, // Larger
              fontWeight: FontWeight.w800, // Thicker
              color: isIncome
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFD32F2F),
              letterSpacing: -1.0,
            ),
          ),
          SizedBox(height: 12.h),

          // Voice Input Badge (Softened)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(
                0xFFF3F4F6,
              ), // Very light grey instead of purple for neutrality
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mic_none_rounded,
                  size: 16.sp,
                  color: Colors.grey[700],
                ), // Line icon
                SizedBox(width: 8.w),
                Text(
                  "Voice Input",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Info Row (Date & Method) - Centered and Clean
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Today, 12:30 PM",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey[400], // Softer grey
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                paymentMethod,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey[800], // Darker for emphasis
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Description Box (Cleaner, less boxy)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA), // Almost white
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: const Color(0xFFF0F0F0),
              ), // Subtle border
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Team lunch at Saku Diner. Discussed Q4 marketing strategy with the creative team.",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF444444),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20.h),
                // Mock Image (Rounded)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    height: 140.h,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&auto=format&fit=crop&q=60",
                            fit: BoxFit.cover,
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.remove_red_eye_rounded,
                              color: Colors.black87,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Action Buttons (Modern Pills)
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(color: Colors.grey[200]!, width: 1.5),
                    ),
                    overlayColor: Colors.grey[100],
                  ),
                  child: Text(
                    "Edit",
                    style: TextStyle(
                      color: Colors.black, // Stark black
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF111111,
                    ), // Black instead of Red for modern monochrome feel
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
