import 'package:flutter/material.dart';
import '../../../../domain/entities/account.dart';
import '../../widgets/account_card.dart';
import '../../widgets/settings_item.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  // Sample data untuk accounts
  final List<Account> accounts = [
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
      id: '8',
      title: 'About App',
      subtitle: 'Version 1.2.3',
      iconPath: 'about',
      iconColor: const Color(0xFF9CA3AF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalBalance = accounts.fold<double>(
      0,
      (sum, account) => sum + account.balance,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accounts Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Accounts',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Total Balance',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Rp ${_formatCurrency(totalBalance)}',
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF999999),
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...accounts.map((account) => AccountCard(account: account)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // General Settings
            ...settingsItems.map((item) => SettingsItemWidget(item: item)),
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
