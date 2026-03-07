import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/google_drive_service.dart';
import '../../data/local/database/app_database.dart';

class BackupResult {
  final bool success;
  final String message;
  final DateTime? timestamp;

  BackupResult({required this.success, required this.message, this.timestamp});
}

class BackupService {
  final GoogleDriveService _driveService;
  final AppDatabase _database;
  final SharedPreferences _prefs;

  static const _lastBackupKey = 'last_backup_timestamp';

  BackupService(this._driveService, this._database, this._prefs);

  DateTime? get lastBackupTime {
    final millis = _prefs.getInt(_lastBackupKey);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<BackupResult> createBackup() async {
    try {
      if (!_driveService.isSignedIn) {
        return BackupResult(success: false, message: 'Belum login ke Google');
      }

      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'saku.sqlite');
      final dbFile = File(dbPath);

      if (!dbFile.existsSync()) {
        return BackupResult(
          success: false,
          message: 'Database tidak ditemukan',
        );
      }

      // Create a copy to avoid issues with active DB connections
      final tempDir = await getTemporaryDirectory();
      final tempPath = p.join(tempDir.path, 'saku_backup_temp.sqlite');
      final tempFile = dbFile.copySync(tempPath);

      try {
        await _driveService.uploadBackup(tempFile);

        final now = DateTime.now();
        await _prefs.setInt(_lastBackupKey, now.millisecondsSinceEpoch);

        return BackupResult(
          success: true,
          message: 'Backup berhasil',
          timestamp: now,
        );
      } finally {
        if (tempFile.existsSync()) {
          tempFile.deleteSync();
        }
      }
    } catch (e) {
      return BackupResult(success: false, message: 'Gagal backup: $e');
    }
  }

  Future<BackupResult> restoreBackup() async {
    try {
      if (!_driveService.isSignedIn) {
        return BackupResult(success: false, message: 'Belum login ke Google');
      }

      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'saku.sqlite');

      final tempDir = await getTemporaryDirectory();
      final tempPath = p.join(tempDir.path, 'saku_restore_temp.sqlite');

      final downloaded = await _driveService.downloadBackup(tempPath);
      if (downloaded == null) {
        return BackupResult(
          success: false,
          message: 'Tidak ada backup di Google Drive',
        );
      }

      // Close current database, replace file, then the app needs restart
      await _database.close();

      final dbFile = File(dbPath);
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }
      downloaded.copySync(dbPath);

      if (downloaded.existsSync()) {
        downloaded.deleteSync();
      }

      return BackupResult(
        success: true,
        message: 'Restore berhasil. Aplikasi perlu di-restart.',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return BackupResult(success: false, message: 'Gagal restore: $e');
    }
  }

  Future<BackupInfo?> getRemoteBackupInfo() async {
    try {
      return await _driveService.getLatestBackupInfo();
    } catch (_) {
      return null;
    }
  }
}
