import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/injection.dart';
import '../cubit/backup_cubit.dart';
import '../cubit/backup_state.dart';

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<BackupCubit>()..checkSignInStatus(),
      child: const _BackupView(),
    );
  }
}

class _BackupView extends StatelessWidget {
  const _BackupView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Cloud Backup',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<BackupCubit, BackupState>(
        listener: (context, state) {
          if (state.status == BackupStatus.success) {
            // Restore berhasil — perlu restart app
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                title: const Text('Restore Berhasil ✅'),
                content: const Text(
                  'Data berhasil dipulihkan. Aplikasi perlu ditutup dan dibuka ulang agar perubahan aktif.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => exit(0),
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                    child: const Text(
                      'Tutup Aplikasi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          } else if (state.message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: state.status == BackupStatus.error
                      ? Colors.red
                      : null,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.status == BackupStatus.loading ||
              state.status == BackupStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BackupStatus.signedOut) {
            return _buildSignedOutView(context);
          }

          return _buildSignedInView(context, state);
        },
      ),
    );
  }

  Widget _buildSignedOutView(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 64.sp,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Belum Terhubung',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Hubungkan akun Google untuk backup data keuanganmu ke cloud secara aman.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.read<BackupCubit>().signIn(),
                icon: Icon(Icons.login, color: Colors.white, size: 20.sp),
                label: Text(
                  'Hubungkan Google Drive',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignedInView(BuildContext context, BackupState state) {
    final isProcessing =
        state.status == BackupStatus.backingUp ||
        state.status == BackupStatus.restoring;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Account status card
          _buildAccountCard(state),

          SizedBox(height: 24.h),

          // Sync button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isProcessing
                  ? null
                  : () => context.read<BackupCubit>().createBackup(),
              icon: isProcessing
                  ? SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.white,
                      size: 24.sp,
                    ),
              label: Text(
                isProcessing
                    ? (state.status == BackupStatus.restoring
                          ? 'Memulihkan...'
                          : 'Menyinkronkan...')
                    : 'Backup Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.05),
                disabledBackgroundColor: const Color(0xFF6B7280),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Restore button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isProcessing
                  ? null
                  : () => _showRestoreConfirmation(context),
              icon: Icon(
                Icons.cloud_download_outlined,
                size: 24.sp,
                color: isProcessing
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF111111),
              ),
              label: Text(
                'Restore dari Cloud',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: isProcessing
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF111111),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                side: BorderSide(
                  color: isProcessing
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFF111111),
                ),
              ),
            ),
          ),

          SizedBox(height: 32.h),

          // Backup info section
          if (state.remoteBackupInfo != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'INFO BACKUP',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2.w,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            _buildInfoCard(state),
            SizedBox(height: 24.h),
          ],

          // Disconnect
          SizedBox(height: 16.h),
          TextButton(
            onPressed: isProcessing
                ? null
                : () => _showDisconnectConfirmation(context),
            child: Text(
              'Putuskan Akun',
              style: TextStyle(
                color: isProcessing ? Colors.grey : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          Text(
            'Data lokal tidak akan terhapus',
            style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BackupState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_done_outlined,
                  size: 48.sp,
                  color: Colors.white,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 12.sp, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            state.email ?? '',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Terakhir backup: ',
                style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              ),
              Text(
                _formatLastBackup(
                  state.remoteBackupInfo?.modifiedTime?.toLocal() ??
                      state.lastBackupTime,
                ),
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BackupState state) {
    final info = state.remoteBackupInfo;
    if (info == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Tanggal Backup',
            value: info.modifiedTime != null
                ? DateFormat(
                    'dd MMM yyyy, HH:mm',
                  ).format(info.modifiedTime!.toLocal())
                : '-',
          ),
          Divider(height: 1.h, color: Colors.grey[100]),
          _buildInfoRow(
            icon: Icons.storage,
            label: 'Ukuran File',
            value: info.sizeBytes != null
                ? _formatFileSize(info.sizeBytes!)
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: const Color(0xFF6B7280), size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  String _formatLastBackup(DateTime? time) {
    if (time == null) return 'Belum pernah';

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';

    return DateFormat('dd MMM yyyy').format(time);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showRestoreConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore Data?'),
        content: const Text(
          'Data lokal akan diganti dengan data dari backup cloud. '
          'Aplikasi perlu di-restart setelah restore. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BackupCubit>().restoreBackup();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Restore'),
          ),
        ],
      ),
    );
  }

  void _showDisconnectConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Putuskan Akun?'),
        content: const Text(
          'Akun Google Drive akan diputuskan. '
          'Data lokal tidak akan terhapus. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BackupCubit>().signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Putuskan'),
          ),
        ],
      ),
    );
  }
}
