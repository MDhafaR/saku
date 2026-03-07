import 'package:equatable/equatable.dart';
import 'package:saku/core/services/google_drive_service.dart';

enum BackupStatus {
  initial,
  loading,
  signedIn,
  signedOut,
  backingUp,
  restoring,
  success,
  error,
}

class BackupState extends Equatable {
  final BackupStatus status;
  final String? email;
  final String? message;
  final DateTime? lastBackupTime;
  final BackupInfo? remoteBackupInfo;

  const BackupState({
    this.status = BackupStatus.initial,
    this.email,
    this.message,
    this.lastBackupTime,
    this.remoteBackupInfo,
  });

  BackupState copyWith({
    BackupStatus? status,
    String? email,
    String? message,
    DateTime? lastBackupTime,
    BackupInfo? remoteBackupInfo,
    bool clearEmail = false,
    bool clearMessage = false,
    bool clearRemoteInfo = false,
  }) {
    return BackupState(
      status: status ?? this.status,
      email: clearEmail ? null : (email ?? this.email),
      message: clearMessage ? null : (message ?? this.message),
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      remoteBackupInfo: clearRemoteInfo
          ? null
          : (remoteBackupInfo ?? this.remoteBackupInfo),
    );
  }

  @override
  List<Object?> get props => [
    status,
    email,
    message,
    lastBackupTime,
    remoteBackupInfo,
  ];
}
