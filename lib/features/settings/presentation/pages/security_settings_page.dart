import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  // State variables for toggles
  bool _isAppLockEnabled = true;
  bool _isBiometricEnabled = true;
  bool _isSecureScreenEnabled = false;
  bool _isBalanceSensorEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Light background
      appBar: AppBar(
        title: Text(
          'Pengaturan Keamanan',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.black, size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('AKSES APLIKASI'),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildToggleItem(
                    icon: Icons.lock_outline,
                    title: 'Kunci Aplikasi',
                    value: _isAppLockEnabled,
                    onChanged: (val) => setState(() => _isAppLockEnabled = val),
                  ),
                  _buildDivider(),
                  _buildToggleItem(
                    icon: Icons.fingerprint,
                    title: 'ID Biometrik',
                    value: _isBiometricEnabled,
                    onChanged: (val) =>
                        setState(() => _isBiometricEnabled = val),
                  ),
                  _buildDivider(),
                  _buildNavItem(
                    icon: Icons.dialpad,
                    title: 'Ganti PIN',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildNavItem(
                    icon: Icons.timer_outlined,
                    title: 'Waktu Kunci Otomatis',
                    valueText: 'Segera',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
            _buildSectionHeader('PRIVASI VISUAL'),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildToggleItem(
                    icon: Icons.security_update_good, // Shield icon
                    title: 'Layar Aman',
                    subtitle:
                        'Cegah screenshot & sembunyikan preview aplikasi.',
                    value: _isSecureScreenEnabled,
                    onChanged: (val) =>
                        setState(() => _isSecureScreenEnabled = val),
                  ),
                  _buildDivider(),
                  _buildToggleItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Sensor Saldo',
                    subtitle: 'Samarkan saldo di dashboard utama.',
                    value: _isBalanceSensorEnabled,
                    onChanged: (val) =>
                        setState(() => _isBalanceSensorEnabled = val),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),
            Center(
              child: Text(
                'Versi Keamanan 2.4.0 • Terlindungi Enkripsi AES-256',
                style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2.w,
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey[600], size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.black),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    String? valueText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey[600], size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            if (valueText != null) ...[
              Text(
                valueText,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1.h,
      thickness: 1.h,
      color: Colors.grey[100],
      indent: 60.w,
    );
  }
}
