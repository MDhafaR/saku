import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Sample data untuk accounts
  List<Account> accounts = [
    Account(
      id: '1',
      name: 'Cash Wallet',
      type: 'cash',
      balance: 1200000,
      iconPath: 'wallet',
      iconColor: const Color(0xFF10B981),
    ),
    Account(
      id: '2',
      name: 'BCA Bank',
      type: 'bank',
      balance: 3500000,
      iconPath: 'bank',
      iconColor: const Color(0xFF3B82F6),
    ),
    Account(
      id: '3',
      name: 'OVO',
      type: 'ewallet',
      balance: 520000,
      iconPath: 'ovo',
      iconColor: const Color(0xFF8A2BE2),
    ),
    Account(
      id: '4',
      name: 'DANA',
      type: 'ewallet',
      balance: 200000,
      iconPath: 'dana',
      iconColor: const Color(0xFFF59E0B),
    ),
  ];

  // Sample data untuk settings items
  final List<SettingsItem> settingsItems = [
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
      iconColor: const Color(0xFF8B5CF6), // Violet
    ),
    SettingsItem(
      id: 'reminder',
      title: 'Reminder',
      subtitle: 'Set daily reminders',
      iconPath: 'notification',
      iconColor: const Color(0xFFEC4899), // Pink
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
      status: 'Connected',
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
      toggleValue: false,
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

  void _updateAccount(Account updatedAccount) {
    setState(() {
      final index = accounts.indexWhere((a) => a.id == updatedAccount.id);
      if (index != -1) {
        accounts[index] = updatedAccount;
      }
    });
  }

  String _selectedLanguage = 'English'; // Default

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
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
                        color: const Color(0xFF9CA3AF),
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
                      color: const Color(0xFF1F2937),
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

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24.0.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Link Preview Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yuk atur keuangan bareng Saku!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: const Color(0xFF1F2937),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'saku.app',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Contacts Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildContactItem('Dika', Colors.brown),
                    SizedBox(width: 20.w),
                    _buildContactItem('Putri', Colors.pink),
                    SizedBox(width: 20.w),
                    _buildContactItem('Mama', Colors.orange),
                    SizedBox(width: 20.w),
                    _buildContactItem('Budi', Colors.blue),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Apps Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShareAppItem(
                    Icons.link,
                    'Copy Link',
                    Colors.grey[200]!,
                    Colors.black,
                  ),
                  _buildShareAppItem(
                    Icons.chat_bubble,
                    'WhatsApp',
                    const Color(0xFF25D366),
                    Colors.white,
                  ),
                  _buildShareAppItem(
                    Icons.camera_alt,
                    'Instagram',
                    const Color(0xFFE1306C),
                    Colors.white,
                  ),
                  _buildShareAppItem(
                    Icons.message,
                    'Messages',
                    const Color(0xFF007AFF),
                    Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactItem(String name, Color color) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor: color.withOpacity(0.2),
              child: Text(
                name[0],
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble,
                  size: 12.sp,
                  color: const Color(0xFF25D366),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          name,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563)),
        ),
      ],
    );
  }

  Widget _buildShareAppItem(
    IconData icon,
    String label,
    Color bg,
    Color iconColor,
  ) {
    return Column(
      children: [
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(icon, color: iconColor),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563)),
        ),
      ],
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
              ? const Color(0xFFF3F4F6)
              : Colors.transparent, // Light Gray
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF111111) : Colors.transparent,
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
                  color: const Color(0xFF1F2937),
                  fontSize: 14.sp,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.radio_button_checked,
                color: const Color(0xFF111111),
                size: 24.sp,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: const Color(0xFF9CA3AF),
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total balance excluding hidden accounts
    final totalBalance = accounts
        .where((a) => !a.isHidden)
        .fold<double>(0, (sum, account) => sum + account.balance);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Pengaturan',
          style: TextStyle(
            color: const Color(0xFF111111),
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
            // Accounts Section
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
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
                      builder: (context) => WalletListPage(
                        accounts: accounts,
                        onAccountUpdate: _updateAccount,
                      ),
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
                              'Accounts',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Total Balance',
                              style: TextStyle(
                                color: const Color(0xFF666666),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Rp ${_formatCurrency(totalBalance)}',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: const Color(0xFF999999),
                              size: 12.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Display top 3 accounts (Preview, even if hidden? User said "in data but not read in total". Usually hidden wallets are hidden from lists too, but let's keep them visible in list for management, maybe with an icon. For preview, let's just show them all for now or filter. Let's show all but maybe with dimming or icon if I had design. User just said "not read in total balance".)
                    ...accounts
                        .take(3)
                        .map((account) => AccountCard(account: account)),
                    if (accounts.length > 3) ...[
                      Padding(
                        padding: EdgeInsets.only(top: 6.0.h),
                        child: Center(
                          child: Text(
                            '+ ${accounts.length - 3} More',
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
            ),
            SizedBox(height: 24.h),

            // General Settings
            ...settingsItems.map(
              (item) => InkWell(
                onTap: () {
                  if (item.id == '1') {
                    // Categories
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryListPage(),
                      ),
                    );
                  } else if (item.id == '2') {
                    // Security
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
                    // Export
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExportPage(),
                      ),
                    );
                  } else if (item.id == '4') {
                    // Backup & Sync
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BackupPage(),
                      ),
                    );
                  } else if (item.id == '5') {
                    // Language
                    _showLanguageBottomSheet();
                  } else if (item.id == '6') {
                    // Theme - handled by toggle, but just in case
                  } else if (item.id == '7') {
                    // Share
                    _showShareBottomSheet();
                  } else if (item.id == 'about') {
                    // About
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
                },
                child: SettingsItemWidget(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
