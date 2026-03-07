import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection.dart';
import '../cubit/security_cubit.dart';
import '../cubit/security_state.dart';
import 'package:saku/features/settings/presentation/pages/pin_page.dart';
import 'package:local_auth/local_auth.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _checkBiometrics(SecurityCubit cubit, bool value) async {
    if (value) {
      try {
        final bool canAuthenticateWithBiometrics =
            await auth.canCheckBiometrics;
        final bool canAuthenticate =
            canAuthenticateWithBiometrics || await auth.isDeviceSupported();

        if (canAuthenticate) {
          final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'Verifikasi biometrik untuk mengaktifkan',
            biometricOnly: true,
          );

          if (didAuthenticate) {
            cubit.toggleBiometric(true);
          }
        } else {
          // Handle not supported or no biometrics enrolled
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Perangkat tidak mendukung biometrik atau tidak ada sidik jari yang terdaftar.',
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Biometric Error: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      cubit.toggleBiometric(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: locator<SecurityCubit>(),
      child: BlocBuilder<SecurityCubit, SecurityState>(
        builder: (context, state) {
          final cubit = context.read<SecurityCubit>();

          return Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
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
                          color: Colors.grey.withValues(alpha: 0.05),
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
                          value: state.isAppLockEnabled,
                          onChanged: (val) async {
                            if (val) {
                              if (state.hashedPin != null) {
                                // Verify existing PIN to enable
                                final bool? verified =
                                    await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PinPage(mode: PinMode.verify),
                                      ),
                                    );

                                if (verified == true) {
                                  cubit.toggleAppLock(true);
                                }
                              } else {
                                // Setup new PIN to enable (if not set)
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PinPage(
                                      mode: PinMode.setup,
                                      onVerified: () {
                                        cubit.toggleAppLock(true);
                                      },
                                    ),
                                  ),
                                );
                              }
                            } else {
                              cubit.toggleAppLock(false);
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.fingerprint,
                          title: 'ID Biometrik',
                          value: state.isBiometricEnabled,
                          onChanged: (val) => _checkBiometrics(cubit, val),
                        ),

                        _buildDivider(),
                        _buildNavItem(
                          icon: Icons.dialpad,
                          title: state.hashedPin == null
                              ? 'Set PIN'
                              : 'Ganti PIN',
                          onTap: () async {
                            if (state.hashedPin == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PinPage(mode: PinMode.setup),
                                ),
                              );
                            } else {
                              final bool? verified = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PinPage(
                                    mode: PinMode.verifyForChange,
                                  ),
                                ),
                              );

                              if (verified == true && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PinPage(mode: PinMode.setup),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildNavItem(
                          icon: Icons.timer_outlined,
                          title: 'Waktu Kunci Otomatis',
                          valueText: 'Segera',
                          isDisabled: true,
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
                          color: Colors.grey.withValues(alpha: 0.05),
                          spreadRadius: 1,
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildToggleItem(
                          icon: Icons.security_update_good,
                          title: 'Layar Aman',
                          subtitle:
                              'Cegah screenshot & sembunyikan preview aplikasi.',
                          value: state.isSecureScreenEnabled,
                          onChanged: (val) => cubit.toggleSecureScreen(val),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Sensor Saldo',
                          subtitle: 'Samarkan saldo di dashboard utama.',
                          value: state.isBalanceSensorEnabled,
                          onChanged: (val) => cubit.toggleBalanceSensor(val),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                  Center(
                    child: Text(
                      'Versi Keamanan 2.4.0 • Terlindungi Enkripsi AES-256',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Colors.black,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    String? valueText,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    final Color contentColor = isDisabled
        ? Colors.grey[350]!
        : const Color(0xFF1F2937);
    final Color iconBgColor = isDisabled
        ? Colors.grey[100]!
        : Colors.grey[100]!;
    final Color iconColor = isDisabled ? Colors.grey[350]! : Colors.grey[600]!;
    final Color arrowColor = isDisabled ? Colors.grey[300]! : Colors.grey[400]!;

    return InkWell(
      onTap: isDisabled ? null : onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: contentColor,
                ),
              ),
            ),
            if (valueText != null) ...[
              Text(
                valueText,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDisabled ? Colors.grey[350]! : Colors.grey[500]!,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: arrowColor),
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
