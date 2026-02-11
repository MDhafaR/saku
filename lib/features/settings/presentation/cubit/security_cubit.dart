import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'security_state.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:screen_protector/screen_protector.dart';

class SecurityCubit extends Cubit<SecurityState> {
  final SharedPreferences _prefs;

  SecurityCubit(this._prefs) : super(const SecurityState()) {
    _loadSettings();
  }

  static const String _keyAppLock = 'security_app_lock';
  static const String _keyBiometric = 'security_biometric';
  static const String _keySecureScreen = 'security_secure_screen';
  static const String _keyBalanceSensor = 'security_balance_sensor';
  static const String _keyPin = 'security_pin';

  void _loadSettings() {
    final isAppLockEnabled = _prefs.getBool(_keyAppLock) ?? false;
    final isBiometricEnabled = _prefs.getBool(_keyBiometric) ?? false;
    final isSecureScreenEnabled = _prefs.getBool(_keySecureScreen) ?? false;
    final isBalanceSensorEnabled = _prefs.getBool(_keyBalanceSensor) ?? false;
    final hashedPin = _prefs.getString(_keyPin);

    emit(
      SecurityState(
        isAppLockEnabled: isAppLockEnabled,
        isBiometricEnabled: isBiometricEnabled,
        isSecureScreenEnabled: isSecureScreenEnabled,
        isBalanceSensorEnabled: isBalanceSensorEnabled,
        hashedPin: hashedPin,
        isLocked: isAppLockEnabled && (hashedPin != null || isBiometricEnabled),
      ),
    );

    // If app is locked but no PIN and no Biometric (shouldn't happen if logic is correct, but for safety)
    // Actually if isAppLockEnabled is true but neither method is available, we should probably disable lock or allow open?
    // But user wants "lock even if no pin". Implies Biometric is the key.
    // If Biometric is also OFF, then we can't unlock! So we must ensure at least one is ON if App Lock is ON.
    // I will enforce this in the UI or here.

    if (isSecureScreenEnabled) {
      _enableScreenProtection();
    }
  }

  Future<void> toggleAppLock(bool value) async {
    if (!value) {
      await _prefs.remove(_keyPin);
      emit(
        state.copyWith(
          isAppLockEnabled: false,
          hashedPin: null,
          isLocked: false,
        ),
      );
    } else {
      emit(state.copyWith(isAppLockEnabled: true));
    }
    await _prefs.setBool(_keyAppLock, value);
  }

  Future<void> toggleBiometric(bool value) async {
    await _prefs.setBool(_keyBiometric, value);
    emit(state.copyWith(isBiometricEnabled: value));
  }

  Future<void> toggleSecureScreen(bool value) async {
    await _prefs.setBool(_keySecureScreen, value);
    emit(state.copyWith(isSecureScreenEnabled: value));
    if (value) {
      await _enableScreenProtection();
    } else {
      await _disableScreenProtection();
    }
  }

  Future<void> _enableScreenProtection() async {
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageWithBlur();
  }

  Future<void> _disableScreenProtection() async {
    await ScreenProtector.preventScreenshotOff();
    await ScreenProtector.protectDataLeakageWithColor(Colors.transparent);
  }

  Future<void> toggleBalanceSensor(bool value) async {
    await _prefs.setBool(_keyBalanceSensor, value);
    emit(state.copyWith(isBalanceSensorEnabled: value));
  }

  Future<void> setPin(String pin) async {
    final hashed = _hashPin(pin);
    await _prefs.setString(_keyPin, hashed);
    emit(
      state.copyWith(
        hashedPin: hashed,
        isAppLockEnabled: true,
        isLocked: false,
      ),
    );
    await _prefs.setBool(_keyAppLock, true);
  }

  Future<void> deletePin() async {
    await _prefs.remove(_keyPin);
    // User requested that deleting PIN should turn off App Lock.
    // However, if we want to support Biometric only, we might need a way to keep it.
    // But based on "harusnya ... switch nya on jadi off", I will disable it.
    // If the user wants to enable Biometric lock, they can toggle App Lock ON again (which might require PIN setup? No, we said we support bio only... wait).
    // If we support Bio only, then we shouldn't force PIN setup when enabling App Lock if Bio is enrolled?
    // Let's look at toggleAppLock logic. It requires PIN setup.
    // So if I disable App Lock here, the user can't re-enable it without setting a PIN!
    // This contradicts "Flexible App Lock: App can now be locked with only Biometrics".

    // User complaint: "pin nya masih ada padahal sudah konfirmasi hapus".
    // This implies the UI didn't update or the state wasn't emitted correctly?
    // emit(state.copyWith(hashedPin: null)) should work.

    // Let's implement the user's specific request: "switch nya on jadi off".
    // And I will ensure hashedPin is null.
    await _prefs.setBool(_keyAppLock, false);
    emit(
      state.copyWith(
        hashedPin: null,
        isAppLockEnabled: false,
        isLocked: false,
        clearPin: true,
      ),
    );
  }

  bool verifyPin(String pin) {
    if (state.hashedPin == null) return false;
    final hashed = _hashPin(pin);
    final isValid = hashed == state.hashedPin;
    if (isValid) {
      unlockApp();
    }
    return isValid;
  }

  void unlockApp() {
    emit(state.copyWith(isLocked: false));
  }

  void lockApp() {
    if (state.isAppLockEnabled &&
        (state.hashedPin != null || state.isBiometricEnabled)) {
      emit(state.copyWith(isLocked: true));
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }
}
