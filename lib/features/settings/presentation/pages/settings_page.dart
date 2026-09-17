import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../../domain/entities/account.dart';

import '../../widgets/settings_item.dart';
import '../../widgets/account_card.dart';
import 'wallet_list_page.dart';
import 'category_list_page.dart';
import 'security_settings_page.dart';
import 'import_pages.dart';
import 'reminder_page.dart';
import 'export_page.dart';
import 'backup_page.dart';
import 'about_page.dart';
import '../cubit/backup_cubit.dart';
import '../cubit/backup_state.dart';
import '../cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection.dart' show locator;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final Stream<List<Wallet>> _walletsStream;

  @override
  void initState() {
    super.initState();
    _walletsStream = locator<AppDatabase>().walletDao.watchAllWallets();
    // Refresh backup status saat halaman Settings dibuka
    locator<BackupCubit>().checkSignInStatus();
  }

  List<SettingsItem> get settingsItems => [
    SettingsItem(
      id: '1',
      title: 'Categories',
      subtitle: 'Manage custom categories',
      iconPath: 'categories',
      iconColor: const Color(0xFF14B8A6),
    ),
    SettingsItem(
      id: '2',
      title: 'Security',
      subtitle: 'PIN & biometric settings',
      iconPath: 'security',
      iconColor: const Color(0xFFEF4444),
    ),
    SettingsItem(
      id: 'import',
      title: 'Import Data',
      subtitle: 'Import from CSV/Excel',
      iconPath: 'import',
      iconColor: const Color(0xFF8B5CF6),
    ),
    SettingsItem(
      id: 'reminder',
      title: 'Reminder',
      subtitle: 'Set daily reminders',
      iconPath: 'notification',
      iconColor: const Color(0xFFEC4899),
    ),
    SettingsItem(
      id: '3',
      title: 'Export Data',
      subtitle: 'Excel/Spreadsheet export',
      iconPath: 'export',
      iconColor: const Color(0xFF3B82F6),
    ),
    SettingsItem(
      id: '4',
      title: 'Backup & Sync',
      subtitle: 'Connect to Google Drive',
      iconPath: 'backup',
      iconColor: const Color(0xFFF59E0B),
    ),
    SettingsItem(
      id: '5',
      title: 'Language',
      subtitle: 'English',
      iconPath: 'language',
      iconColor: const Color(0xFF8A2BE2),
    ),
    SettingsItem(
      id: '6',
      title: 'Theme',
      subtitle: 'Light/Dark mode',
      iconPath: 'theme',
      iconColor: const Color(0xFF8A2BE2),
      isToggle: true,
      toggleValue: locator<ThemeCubit>().isDark,
    ),
    SettingsItem(
      id: '7',
      title: 'Share App',
      subtitle: 'Tell your friends about Saku',
      iconPath: 'share',
      iconColor: const Color(0xFF10B981),
    ),
    SettingsItem(
      id: 'about',
      title: 'About App',
      subtitle: 'Version 1.2.3',
      iconPath: 'about',
      iconColor: const Color(0xFF9CA3AF),
    ),
  ];

  String _selectedLanguage = 'English'; // Default

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(24.0.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildLanguageOption(
                    'English',
                    '🇺🇸',
                    _selectedLanguage == 'English',
                    () => setModalState(
                      () => setState(() => _selectedLanguage = 'English'),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildLanguageOption(
                    'Bahasa Indonesia',
                    '🇮🇩',
                    _selectedLanguage == 'Bahasa Indonesia',
                    () => setModalState(
                      () => setState(
                        () => _selectedLanguage = 'Bahasa Indonesia',
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showUnderDevelopmentDialog({
    required String featureName,
    String? description,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cs = Theme.of(context).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: cs.surface,
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.construction_rounded,
                    color: const Color(0xFF10B981),
                    size: 28.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Fitur Dalam Pengembangan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  description ??
                      'Fitur $featureName saat ini masih dalam tahap pengembangan dan akan segera hadir pada pembaruan mendatang. Terima kasih atas dukungan Anda!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: cs.onSurface.withValues(alpha: 0.65),
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 22.h),
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? cs.primary
                          : const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Oke, Mengerti',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String title,
    String flag,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Colors.transparent, // Light Gray
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14.sp,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.radio_button_checked,
                color: Theme.of(context).colorScheme.primary,
                size: 24.sp,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Pengaturan',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 150.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accounts Section - loaded from database
            StreamBuilder<List<Wallet>>(
              stream: _walletsStream,
              builder: (context, snapshot) {
                final wallets = snapshot.data ?? [];
                final totalBalance = wallets
                    .where((w) => !w.isHidden)
                    .fold<double>(0, (sum, w) => sum + w.currentBalance);

                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WalletListPage(),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wallet',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Total Balance',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                                Row(
                              children: [
                                Text(
                                  'Rp ${CurrencyFormatter.format(totalBalance.toStringAsFixed(0))}',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 12.sp,
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Display top 3 wallets preview
                        ...wallets
                            .take(3)
                            .map((wallet) => AccountCard(wallet: wallet)),
                        if (wallets.length > 3) ...[
                          Padding(
                            padding: EdgeInsets.only(top: 6.0.h),
                            child: Center(
                              child: Text(
                                '+ ${wallets.length - 3} More',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),

            // General Settings
            ...settingsItems.map(
              (item) {
                void handleTap() {
                  if (item.id == '1') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryListPage(),
                      ),
                    );
                  } else if (item.id == '2') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecuritySettingsPage(),
                      ),
                    );
                  } else if (item.id == 'import') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ImportMenuPage(),
                      ),
                    );
                  } else if (item.id == '3') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExportPage(),
                      ),
                    );
                  } else if (item.id == '4') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BackupPage(),
                      ),
                    );
                  } else if (item.id == '5') {
                    _showLanguageBottomSheet();
                  } else if (item.id == '6') {
                    // Theme — handled by toggle switch
                  } else if (item.id == '7') {
                    _showUnderDevelopmentDialog(
                      featureName: 'Bagikan Aplikasi (Share App)',
                    );
                  } else if (item.id == 'about') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  } else if (item.id == 'reminder') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReminderPage(),
                      ),
                    );
                  }
                }

                if (item.id == '4') {
                  return BlocProvider.value(
                    value: locator<BackupCubit>(),
                    child: BlocBuilder<BackupCubit, BackupState>(
                      builder: (context, backupState) {
                        final isConnected =
                            backupState.status == BackupStatus.signedIn ||
                            backupState.status == BackupStatus.backingUp ||
                            backupState.status == BackupStatus.restoring ||
                            backupState.status == BackupStatus.success;
                        return SettingsItemWidget(
                          item: item.copyWith(
                            subtitle: isConnected
                                ? backupState.email ?? 'Terhubung'
                                : 'Connect to Google Drive',
                            status: isConnected ? 'Connected' : null,
                            clearStatus: !isConnected,
                          ),
                          onTap: handleTap,
                        );
                      },
                    ),
                  );
                } else if (item.id == '6') {
                  return BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      final isDark = themeMode == ThemeMode.dark;
                      return SettingsItemWidget(
                        item: item.copyWith(toggleValue: isDark),
                        onToggleChanged: (_) {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      );
                    },
                  );
                }

                return SettingsItemWidget(
                  item: item,
                  onTap: handleTap,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
