import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF111111), // Primary Dark
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF111111).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),

            // App Name & Tagline
            const Text(
              'Saku App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your personal finance companion.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Version Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'v1.2.3 (Build 45)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Menu
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                  Divider(height: 1, color: Colors.grey[100]),
                  _buildMenuItem(
                    Icons.description_outlined,
                    'Terms of Service',
                    false,
                  ),
                  Divider(height: 1, color: Colors.grey[100]),
                  _buildMenuItem(Icons.code, 'Open Source Licenses', false),
                  Divider(height: 1, color: Colors.grey[100]),
                  _buildMenuItem(
                    Icons.cloud_sync_outlined,
                    'Check for Updates',
                    true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Footer
            const Text(
              '© 2026 Saku Team.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Made with ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Icon(Icons.favorite, size: 12, color: Colors.red[400]),
                const Text(
                  ' in Indonesia.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isAction ? const Color(0xFF111111) : Colors.grey[500],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isAction
                      ? const Color(0xFF111111)
                      : const Color(0xFF1F2937),
                ),
              ),
            ),
            if (!isAction)
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
