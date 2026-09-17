import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/local/database/app_database.dart';
import '../../debts/presentation/pages/add_loan_page.dart';
import '../../transactions/presentation/pages/transfer_page.dart';
import '../../transactions/presentation/pages/adjust_balance_page.dart';
import '../../settings/presentation/pages/add_edit_wallet_page.dart';

class AnimatedFab extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback? onShowAddTransaction;

  const AnimatedFab({
    super.key,
    required this.onPressed,
    this.onShowAddTransaction,
  });

  @override
  State<AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab> {
  bool _isFabVisible = true;
  bool _isArrowVisible = false;
  bool _isFabExpanded = false;
  Timer? _hideTimer;
  int _animationKey = 0;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && !_isFabExpanded) {
        setState(() {
          _isFabVisible = false;
          _isArrowVisible = true;
          _animationKey++;
        });
      }
    });
  }

  void _showFab() {
    setState(() {
      _isArrowVisible = false;
      _animationKey++;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isFabVisible = true;
          _animationKey++;
        });
        _startHideTimer();
      }
    });
  }

  void _toggleFabExpansion() {
    if (_isFabExpanded) {
      setState(() {
        _isFabExpanded = false;
        _animationKey++;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _animationKey++;
          });
          _startHideTimer();
        }
      });
    } else {
      setState(() {
        _isFabExpanded = true;
        _animationKey++;
      });
      _hideTimer?.cancel();
    }
  }

  Widget _buildExpandedButton({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    required int delay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dark: card-style gelap dengan icon berwarna (seperti card income/expense)
    // Light: putih solid seperti sebelumnya
    final bgColor = isDark
        ? const Color(0xFF1E293B) // dark slate — mirip tone card dark
        : Colors.white;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.transparent;

    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : const Color(0xFF333333);

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.10);

    return GestureDetector(
      onTap: onTap,
      child: Container(
            key: ValueKey('expanded_${icon}_$_animationKey'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon container bergaya card summary (warna + opacity 15%)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
          .animate()
          .slideY(
            begin: _isFabExpanded ? 1.0 : 0.0,
            end: _isFabExpanded ? 0.0 : 1.0,
            duration: 300.ms,
            delay: _isFabExpanded ? delay.ms : (200 - delay).ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(
            duration: 200.ms,
            delay: _isFabExpanded ? delay.ms : (200 - delay).ms,
          )
          .scale(
            begin: _isFabExpanded
                ? const Offset(0.8, 0.8)
                : const Offset(1.0, 1.0),
            end: _isFabExpanded
                ? const Offset(1.0, 1.0)
                : const Offset(0.8, 0.8),
            duration: 300.ms,
            delay: _isFabExpanded ? delay.ms : (200 - delay).ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // FAB utama — putih di light, dark slate di dark
    final fabBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final fabIconColor = isDark ? Colors.white : Colors.black;
    final l10n = context.l10n;

    // Arrow indicator — adaptif
    final arrowColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppTheme.darkBackground;

    return Stack(
      children: [
        // Expanded Buttons
        if (_isFabExpanded) ...[
          // Transaction
          Positioned(
            right: 20,
            bottom: 354,
            child: _buildExpandedButton(
              context: context,
              icon: Icons.add,
              iconColor: const Color(0xFF10B981), // hijau seperti income card
              label: l10n.navTransactions,
              onTap: () {
                _toggleFabExpansion();
                widget.onPressed();
              },
              delay: 0,
            ),
          ),
          // Transfer
          Positioned(
            right: 20,
            bottom: 292,
            child: _buildExpandedButton(
              context: context,
              icon: Icons.swap_horiz,
              iconColor: const Color(0xFF6366F1), // ungu seperti total card
              label: l10n.transferTitle,
              onTap: () async {
                _toggleFabExpansion();
                final db = locator<AppDatabase>();
                final wallets = await db.walletDao.getAllWallets();
                if (!context.mounted) return;
                if (wallets.length < 2) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.isIndonesian ? 'Wallet Tidak Cukup' : 'Not Enough Wallets'),
                      content: Text(
                        l10n.isIndonesian
                            ? 'Anda memerlukan minimal 2 wallet untuk melakukan transfer antar akun. Silakan tambahkan wallet baru terlebih dahulu.'
                            : 'You need at least 2 wallets to perform a transfer between accounts. Please add a new wallet first.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.isIndonesian ? 'Nanti' : 'Later',
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddEditWalletPage(),
                              ),
                            );
                          },
                          child: Text(
                            l10n.isIndonesian ? 'Tambah Wallet' : 'Add Wallet',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransferPage(wallets: wallets),
                    ),
                  );
                }
              },
              delay: 80,
            ),
          ),
          // Loan
          Positioned(
            right: 20,
            bottom: 230,
            child: _buildExpandedButton(
              context: context,
              icon: Icons.account_balance_wallet,
              iconColor: const Color(0xFFEF4444), // merah seperti expense card
              label: l10n.navDebts,
              onTap: () {
                _toggleFabExpansion();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddLoanPage()),
                );
              },
              delay: 160,
            ),
          ),
          // Ngepasin Saldo
          Positioned(
            right: 20,
            bottom: 168,
            child: _buildExpandedButton(
              context: context,
              icon: Icons.tune_rounded,
              iconColor: const Color(0xFF0D9488), // teal modern
              label: l10n.adjustBalanceTitle,
              onTap: () {
                _toggleFabExpansion();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdjustBalancePage(),
                  ),
                );
              },
              delay: 240,
            ),
          ),
        ],

        // FAB Utama
        if (_isFabVisible)
          Positioned(
            right: 20,
            bottom: 100,
            child: GestureDetector(
              onTap: _toggleFabExpansion,
              child: FloatingActionButton(
                    key: ValueKey('fab_$_animationKey'),
                    onPressed: _toggleFabExpansion,
                    backgroundColor: fabBg,
                    elevation: isDark ? 0 : 4,
                    child: Icon(
                      _isFabExpanded ? Icons.close : Icons.add,
                      color: fabIconColor,
                    ),
                  )
                  .animate()
                  .slideX(
                    begin: 0.3,
                    end: 0.0,
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
                  .rotate(
                    begin: _isFabExpanded ? 0 : 0.5,
                    end: _isFabExpanded ? 0.5 : 0,
                    duration: 300.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
          ),

        // Arrow Button — kecil, adaptif theme
        if (_isArrowVisible)
          Positioned(
            right: 20,
            bottom: 100,
            child: GestureDetector(
              onTap: _showFab,
              child: Container(
                    key: ValueKey('arrow_$_animationKey'),
                    width: 24,
                    height: 56,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: arrowColor,
                      size: 24,
                    ),
                  )
                  .animate()
                  .slideX(
                    begin: 0.3,
                    end: 0.0,
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                  )
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
          ),
      ],
    );
  }
}
