import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../debts/presentation/pages/add_loan_page.dart';
import '../../transactions/presentation/pages/transfer_page.dart';

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

    // Delay untuk animasi sederhana
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
      // Menutup dengan animasi kebalikan
      setState(() {
        _isFabExpanded = false;
        _animationKey++;
      });

      // Delay untuk animasi menutup
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _animationKey++;
          });
          _startHideTimer();
        }
      });
    } else {
      // Membuka
      setState(() {
        _isFabExpanded = true;
        _animationKey++;
      });
      _hideTimer?.cancel();
    }
  }

  Widget _buildExpandedButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child:
          Container(
                key: ValueKey('expanded_${icon}_$_animationKey'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 14,
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
    return Stack(
      children: [
        // Expanded Buttons
        if (_isFabExpanded) ...[
          // Add Transaction Button
          Positioned(
            right: 20,
            bottom: 280,
            child: _buildExpandedButton(
              icon: Icons.add,
              label: 'Transaction',
              onTap: () {
                _toggleFabExpansion();
                widget.onPressed();
              },
              delay: 0,
            ),
          ),
          // Transfer Button
          Positioned(
            right: 20,
            bottom: 230,
            child: _buildExpandedButton(
              icon: Icons.swap_horiz,
              label: 'Transfer',
              onTap: () {
                _toggleFabExpansion();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TransferPage()),
                );
              },
              delay: 100,
            ),
          ),
          // Loan Button
          Positioned(
            right: 20,
            bottom: 180,
            child: _buildExpandedButton(
              icon: Icons.account_balance_wallet,
              label: 'Loan',
              onTap: () {
                _toggleFabExpansion();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddLoanPage()),
                );
              },
              delay: 200,
            ),
          ),
        ],

        // FAB
        if (_isFabVisible)
          Positioned(
            right: 20,
            bottom: 100,
            child: GestureDetector(
              onTap: _toggleFabExpansion,
              child:
                  FloatingActionButton(
                        key: ValueKey('fab_$_animationKey'),
                        onPressed: _toggleFabExpansion,
                        backgroundColor: AppTheme.primaryBlue,
                        child: Icon(
                          _isFabExpanded ? Icons.close : Icons.add,
                          color: Colors.white,
                        ),
                      )
                      .animate()
                      .slideX(
                        begin: 0.3, // Mulai dari sedikit ke kanan
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

        // Arrow Button - Small icon without background
        if (_isArrowVisible)
          Positioned(
            right: 20,
            bottom: 100,
            child: GestureDetector(
              onTap: _showFab,
              child:
                  Container(
                        key: ValueKey('arrow_$_animationKey'),
                        width: 24,
                        height: 56,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                      )
                      .animate()
                      .slideX(
                        begin: 0.3, // Mulai dari sedikit ke kanan
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
