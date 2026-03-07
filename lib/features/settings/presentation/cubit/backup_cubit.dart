import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/backup_service.dart';
import '../../../../core/services/google_drive_service.dart';
import 'backup_state.dart';

class BackupCubit extends Cubit<BackupState> {
  final BackupService _backupService;
  final GoogleDriveService _driveService;

  BackupCubit(this._backupService, this._driveService)
    : super(const BackupState());

  Future<void> checkSignInStatus() async {
    emit(state.copyWith(status: BackupStatus.loading));

    try {
      final user = await _driveService.signInSilently();
      if (user != null) {
        final remoteInfo = await _backupService.getRemoteBackupInfo();
        emit(
          state.copyWith(
            status: BackupStatus.signedIn,
            email: user.email,
            lastBackupTime: _backupService.lastBackupTime,
            remoteBackupInfo: remoteInfo,
          ),
        );
      } else {
        emit(state.copyWith(status: BackupStatus.signedOut));
      }
    } catch (_) {
      emit(state.copyWith(status: BackupStatus.signedOut));
    }
  }

  Future<void> signIn() async {
    emit(state.copyWith(status: BackupStatus.loading));

    try {
      final user = await _driveService.signIn();
      if (user != null) {
        final remoteInfo = await _backupService.getRemoteBackupInfo();
        emit(
          state.copyWith(
            status: BackupStatus.signedIn,
            email: user.email,
            remoteBackupInfo: remoteInfo,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: BackupStatus.signedOut,
            message: 'Login dibatalkan',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: BackupStatus.error, message: 'Gagal login: $e'),
      );
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: BackupStatus.loading));

    try {
      await _driveService.signOut();
      emit(
        state.copyWith(
          status: BackupStatus.signedOut,
          clearEmail: true,
          clearRemoteInfo: true,
          message: 'Akun berhasil diputuskan',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BackupStatus.error,
          message: 'Gagal memutuskan akun: $e',
        ),
      );
    }
  }

  Future<void> createBackup() async {
    emit(state.copyWith(status: BackupStatus.backingUp, clearMessage: true));

    final result = await _backupService.createBackup();

    if (result.success) {
      final remoteInfo = await _backupService.getRemoteBackupInfo();
      emit(
        state.copyWith(
          status: BackupStatus.signedIn,
          message: result.message,
          lastBackupTime: result.timestamp,
          remoteBackupInfo: remoteInfo,
        ),
      );
    } else {
      emit(
        state.copyWith(status: BackupStatus.signedIn, message: result.message),
      );
    }
  }

  Future<void> restoreBackup() async {
    emit(state.copyWith(status: BackupStatus.restoring, clearMessage: true));

    final result = await _backupService.restoreBackup();

    emit(
      state.copyWith(
        status: result.success ? BackupStatus.success : BackupStatus.signedIn,
        message: result.message,
      ),
    );
  }
}
