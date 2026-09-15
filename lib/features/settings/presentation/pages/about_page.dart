import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
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
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/splash/splash_logo_dark.png'
                    : 'assets/icons/foreground.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 24.h),

            // App Name & Tagline
            Text(
              'Saku App',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your personal finance companion.',
              style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
            ),
            SizedBox(height: 16.h),

            // Version Chip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
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
                color: Theme.of(context).colorScheme.surface,
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
                    context,
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    false,
                  ),
                  Divider(height: 1.h, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
                  _buildMenuItem(
                    context,
                    Icons.description_outlined,
                    'Terms of Service',
                    false,
                  ),
                  Divider(height: 1.h, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
                  _buildMenuItem(context, Icons.code, 'Open Source Licenses', false),
                  Divider(height: 1.h, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
                  _buildMenuItem(
                    context,
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
              style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Made with ',
                  style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                ),
                Icon(Icons.favorite, size: 12.sp, color: Colors.red[400]),
                Text(
                  ' in Indonesia.',
                  style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, bool isAction) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isAction ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isAction
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (!isAction)
              Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
          ],
        ),
      ),
    );
  }
}
