import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class BackupInfo {
  final String fileId;
  final String fileName;
  final DateTime? modifiedTime;
  final int? sizeBytes;

  BackupInfo({
    required this.fileId,
    required this.fileName,
    this.modifiedTime,
    this.sizeBytes,
  });
}

class GoogleDriveService {
  static const _backupFileName = 'saku_backup.sqlite';
  static const _backupMimeType = 'application/x-sqlite3';
  static const _driveScope = drive.DriveApi.driveAppdataScope;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [_driveScope]);

  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      _currentUser = account;
      return account;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    _currentUser = null;
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    final account = await _googleSignIn.signInSilently();
    _currentUser = account;
    return account;
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    if (_currentUser == null) return null;

    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) return null;

    return drive.DriveApi(httpClient);
  }

  Future<void> uploadBackup(File dbFile) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) throw Exception('Tidak terautentikasi');

    final existing = await _findBackupFile(driveApi);

    final media = drive.Media(dbFile.openRead(), dbFile.lengthSync());

    if (existing != null) {
      await driveApi.files.update(
        drive.File()..name = _backupFileName,
        existing.fileId,
        uploadMedia: media,
      );
    } else {
      final driveFile = drive.File()
        ..name = _backupFileName
        ..parents = ['appDataFolder']
        ..mimeType = _backupMimeType;

      await driveApi.files.create(driveFile, uploadMedia: media);
    }
  }

  Future<File?> downloadBackup(String targetPath) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) throw Exception('Tidak terautentikasi');

    final existing = await _findBackupFile(driveApi);
    if (existing == null) return null;

    final response = await driveApi.files.get(
      existing.fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );

    if (response is! drive.Media) return null;

    final file = File(targetPath);
    final sink = file.openWrite();
    await response.stream.pipe(sink);
    await sink.close();

    return file;
  }

  Future<BackupInfo?> getLatestBackupInfo() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return null;

    return _findBackupFile(driveApi);
  }

  Future<BackupInfo?> _findBackupFile(drive.DriveApi driveApi) async {
    final fileList = await driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName'",
      $fields: 'files(id, name, modifiedTime, size)',
      orderBy: 'modifiedTime desc',
      pageSize: 1,
    );

    final files = fileList.files;
    if (files == null || files.isEmpty) return null;

    final file = files.first;
    return BackupInfo(
      fileId: file.id!,
      fileName: file.name ?? _backupFileName,
      modifiedTime: file.modifiedTime,
      sizeBytes: file.size != null ? int.tryParse(file.size!) : null,
    );
  }
}
