import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/localization/app_localizations.dart';
import '../cubit/security_cubit.dart';

enum PinMode { setup, verify, verifyForChange }

class PinPage extends StatefulWidget {
  final PinMode mode;
  final VoidCallback? onVerified;

  const PinPage({super.key, required this.mode, this.onVerified});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final List<int> _pin = [];
  final LocalAuthentication auth = LocalAuthentication();
  String _message = '';
  String? _firstPin; // For setup mode

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_message.isEmpty) {
      _setInitialMessage();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.mode == PinMode.verify) {
      _checkBiometrics();
    }
  }

  void _setInitialMessage() {
    final l10n = context.l10n;
    setState(() {
      switch (widget.mode) {
        case PinMode.setup:
          _message = l10n.createNewPin;
          break;
        case PinMode.verify:
          final securityCubit = context.read<SecurityCubit>();
          _message = securityCubit.state.hashedPin == null
              ? l10n.useBiometricId
              : l10n.enterYourPin;
          break;
        case PinMode.verifyForChange:
          _message = l10n.enterOldPin;
          break;
      }
    });
  }

  Future<void> _checkBiometrics() async {
    final securityCubit = context.read<SecurityCubit>();
    if (!securityCubit.state.isBiometricEnabled) return;

    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (canAuthenticate && mounted) {
        final l10n = context.l10n;
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: l10n.biometricLoginReason,
          biometricOnly: true,
        );

        if (didAuthenticate) {
          securityCubit.unlockApp();
          widget.onVerified?.call();
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      debugPrint('Biometric Error: $e');
    }
  }

  void _onKeyTap(int value) {
    if (_pin.length < 4) {
      final securityCubit = context.read<SecurityCubit>();
      if (widget.mode == PinMode.verify &&
          securityCubit.state.hashedPin == null) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pinNotSetUseBiometric),
          ),
        );
        return;
      }

      setState(() {
        _pin.add(value);
      });

      if (_pin.length == 4) {
        _processPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
      });
    }
  }

  void _processPin() {
    final pinStr = _pin.join();
    final cubit = context.read<SecurityCubit>();
    final l10n = context.l10n;

    Future.delayed(const Duration(milliseconds: 200), () {
      if (widget.mode == PinMode.setup) {
        if (_firstPin == null) {
          _firstPin = pinStr;
          setState(() {
            _pin.clear();
            _message = l10n.confirmYourPin;
          });
        } else {
          if (_firstPin == pinStr) {
            cubit.setPin(pinStr);
            widget.onVerified?.call();
            if (mounted) Navigator.pop(context);
          } else {
            setState(() {
              _pin.clear();
              _message = l10n.pinMismatch;
              _firstPin = null;
            });
          }
        }
      } else {
        if (cubit.verifyPin(pinStr)) {
          widget.onVerified?.call();
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context, true);
          }
        } else {
          setState(() {
            _pin.clear();
            _message = l10n.pinWrong;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF111111).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_person_outlined,
                size: 40.sp,
                color: const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              _message,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 24.h),
            // PIN Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _pin.length;
                return Container(
                  width: 16.w,
                  height: 16.h,
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? const Color(0xFF111111)
                        : Colors.transparent,
                    border: Border.all(
                      color: const Color(0xFF111111),
                      width: 1.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const Spacer(),
            // Keypad
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Column(
                children: [
                  _buildKeyRow([1, 2, 3]),
                  SizedBox(height: 16.h),
                  _buildKeyRow([4, 5, 6]),
                  SizedBox(height: 16.h),
                  _buildKeyRow([7, 8, 9]),
                  SizedBox(height: 16.h),
                  _buildLastRow(),
                ],
              ),
            ),
            if (widget.mode == PinMode.verifyForChange &&
                context.read<SecurityCubit>().state.hashedPin != null)
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: TextButton(
                  onPressed: _onDeletePin,
                  child: Text(
                    l10n.deletePin,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  void _onDeletePin() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deletePinConfirmTitle),
        content: Text(l10n.deletePinConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<SecurityCubit>().deletePin();
              Navigator.pop(dialogCtx); // Close dialog
              Navigator.pop(context); // Close PinPage
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<int> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: values
          .map((v) => _buildKey(v.toString(), onTap: () => _onKeyTap(v)))
          .toList(),
    );
  }

  Widget _buildLastRow() {
    final securityCubit = context.read<SecurityCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Action (Biometric if enabled and in verify mode)
        (widget.mode != PinMode.setup && securityCubit.state.isBiometricEnabled)
            ? _buildActionKey(Icons.fingerprint, onTap: _checkBiometrics)
            : SizedBox(width: 70.w),
        _buildKey('0', onTap: () => _onKeyTap(0)),
        _buildActionKey(Icons.backspace_outlined, onTap: _onDelete),
      ],
    );
  }

  Widget _buildKey(String label, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35.r),
      child: Container(
        width: 70.w,
        height: 70.h,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111111),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35.r),
      child: Container(
        width: 70.w,
        height: 70.h,
        alignment: Alignment.center,
        child: Icon(icon, size: 28.sp, color: const Color(0xFF111111)),
      ),
    );
  }
}
