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
import '../cubit/language_cubit.dart';
import '../../../../core/localization/app_localizations.dart';
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

  List<SettingsItem> _getSettingsItems(BuildContext context) {
    final l10n = context.l10n;
    final isIndonesian = context.watch<LanguageCubit>().isIndonesian;

    return [
      SettingsItem(
        id: '1',
        title: l10n.settingCategories,
        subtitle: l10n.settingCategoriesSub,
        iconPath: 'categories',
        iconColor: const Color(0xFF14B8A6),
      ),
      SettingsItem(
        id: '2',
        title: l10n.settingSecurity,
        subtitle: l10n.settingSecuritySub,
        iconPath: 'security',
        iconColor: const Color(0xFFEF4444),
      ),
      SettingsItem(
        id: 'import',
        title: l10n.settingImport,
        subtitle: l10n.settingImportSub,
        iconPath: 'import',
        iconColor: const Color(0xFF8B5CF6),
      ),
      SettingsItem(
        id: 'reminder',
        title: l10n.settingReminder,
        subtitle: l10n.settingReminderSub,
        iconPath: 'notification',
        iconColor: const Color(0xFFEC4899),
      ),
      SettingsItem(
        id: '3',
        title: l10n.settingExport,
        subtitle: l10n.settingExportSub,
        iconPath: 'export',
        iconColor: const Color(0xFF3B82F6),
      ),
      SettingsItem(
        id: '4',
        title: l10n.settingBackup,
        subtitle: l10n.settingBackupSub,
        iconPath: 'backup',
        iconColor: const Color(0xFFF59E0B),
      ),
      SettingsItem(
        id: '5',
        title: l10n.settingLanguage,
        subtitle: isIndonesian ? 'Bahasa Indonesia' : 'English',
        iconPath: 'language',
        iconColor: const Color(0xFF8A2BE2),
      ),
      SettingsItem(
        id: '6',
        title: l10n.settingTheme,
        subtitle: l10n.settingThemeSub,
        iconPath: 'theme',
        iconColor: const Color(0xFF8A2BE2),
        isToggle: true,
        toggleValue: locator<ThemeCubit>().isDark,
      ),
      SettingsItem(
        id: '7',
        title: l10n.settingShare,
        subtitle: l10n.settingShareSub,
        iconPath: 'share',
        iconColor: const Color(0xFF10B981),
      ),
      SettingsItem(
        id: 'about',
        title: l10n.settingAbout,
        subtitle: 'Version 1.2.3',
        iconPath: 'about',
        iconColor: const Color(0xFF9CA3AF),
      ),
    ];
  }

  void _showLanguageBottomSheet() {
    final languageCubit = context.read<LanguageCubit>();
    final l10n = context.l10n;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final activeCode = languageCubit.state.languageCode;
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    l10n.selectLanguageTitle,
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
                    activeCode == 'en',
                    () async {
                      await languageCubit.changeLanguage('en');
                      if (modalContext.mounted) {
                        Navigator.of(modalContext).pop();
                      }
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildLanguageOption(
                    'Bahasa Indonesia',
                    '🇮🇩',
                    activeCode == 'id',
                    () async {
                      await languageCubit.changeLanguage('id');
                      if (modalContext.mounted) {
                        Navigator.of(modalContext).pop();
                      }
                    },
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
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        final cs = Theme.of(dialogCtx).colorScheme;
        final l10n = dialogCtx.l10n;
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
                  l10n.featureUnderDevTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  description ?? l10n.shareAppUnderDevDesc,
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
                    onPressed: () => Navigator.pop(dialogCtx),
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
                      l10n.okUnderstand,
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
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
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
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.settingsTitle,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
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
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.1),
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
                                  l10n.selectWalletTitle.replaceAll('Pilih ', '').replaceAll('Select ', ''),
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  l10n.totalBalance,
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
                                l10n.moreWalletsCount(wallets.length - 3),
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
            ..._getSettingsItems(context).map((item) {
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
                    MaterialPageRoute(builder: (context) => const ExportPage()),
                  );
                } else if (item.id == '4') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BackupPage()),
                  );
                } else if (item.id == '5') {
                  _showLanguageBottomSheet();
                } else if (item.id == '6') {
                  // Theme — handled by toggle switch
                } else if (item.id == '7') {
                  _showUnderDevelopmentDialog(
                    featureName: l10n.settingShare,
                  );
                } else if (item.id == 'about') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
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
                              ? backupState.email ?? l10n.connectedStatus
                              : l10n.settingBackupSub,
                          status: isConnected ? l10n.connectedStatus : null,
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

              return SettingsItemWidget(item: item, onTap: handleTap);
            }),
          ],
        ),
      ),
    );
  }
}
