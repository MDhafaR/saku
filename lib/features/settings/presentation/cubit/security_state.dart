import 'package:equatable/equatable.dart';

class SecurityState extends Equatable {
  final bool isAppLockEnabled;
  final bool isBiometricEnabled;
  final bool isSecureScreenEnabled;
  final bool isBalanceSensorEnabled;
  final String? hashedPin;
  final bool isLocked;

  const SecurityState({
    this.isAppLockEnabled = false,
    this.isBiometricEnabled = false,
    this.isSecureScreenEnabled = false,
    this.isBalanceSensorEnabled = false,
    this.hashedPin,
    this.isLocked = false,
  });

  SecurityState copyWith({
    bool? isAppLockEnabled,
    bool? isBiometricEnabled,
    bool? isSecureScreenEnabled,
    bool? isBalanceSensorEnabled,
    String? hashedPin,
    bool? isLocked,
    bool clearPin = false,
  }) {
    return SecurityState(
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isSecureScreenEnabled:
          isSecureScreenEnabled ?? this.isSecureScreenEnabled,
      isBalanceSensorEnabled:
          isBalanceSensorEnabled ?? this.isBalanceSensorEnabled,
      hashedPin: clearPin ? null : (hashedPin ?? this.hashedPin),
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  List<Object?> get props => [
    isAppLockEnabled,
    isBiometricEnabled,
    isSecureScreenEnabled,
    isBalanceSensorEnabled,
    hashedPin,
    isLocked,
  ];
}
