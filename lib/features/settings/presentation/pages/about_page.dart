import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: const Color(0xFF111111), // Primary Dark
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF111111).withOpacity(0.2),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 48.sp,
              ),
            ),
            SizedBox(height: 24.h),

            // App Name & Tagline
            Text(
              'Saku App',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your personal finance companion.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 16.h),

            // Version Chip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'v1.2.3 (Build 45)',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 48.h),

            // Menu
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    false,
                  ),
                  Divider(height: 1.h, color: Colors.grey[100]),
                  _buildMenuItem(
                    Icons.description_outlined,
                    'Terms of Service',
                    false,
                  ),
                  Divider(height: 1.h, color: Colors.grey[100]),
                  _buildMenuItem(Icons.code, 'Open Source Licenses', false),
                  Divider(height: 1.h, color: Colors.grey[100]),
                  _buildMenuItem(
                    Icons.cloud_sync_outlined,
                    'Check for Updates',
                    true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 60.h),

            // Footer
            Text(
              '© 2026 Saku Team.',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Made with ',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                Icon(Icons.favorite, size: 12.sp, color: Colors.red[400]),
                Text(
                  ' in Indonesia.',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isAction) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isAction ? const Color(0xFF111111) : Colors.grey[500],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isAction
                      ? const Color(0xFF111111)
                      : const Color(0xFF1F2937),
                ),
              ),
            ),
            if (!isAction)
              Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
                color: Colors.grey[300],
              ),
          ],
        ),
      ),
    );
  }
}
