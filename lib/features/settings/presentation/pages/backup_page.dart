import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../cubit/backup_cubit.dart';
import '../cubit/backup_state.dart';

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: locator<BackupCubit>()..checkSignInStatus(),
      child: const _BackupView(),
    );
  }
}

class _BackupView extends StatelessWidget {
  const _BackupView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.cloudBackupTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
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
                title: Text(l10n.restoreSuccessTitle),
                content: Text(
                  l10n.restoreSuccessDesc,
                ),
                actions: [
                  TextButton(
                    onPressed: () => exit(0),
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                    child: Text(
                      l10n.closeAppButton,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surfaceContainerLow
                    : const Color(0xFFF3F4F6),
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
              l10n.notConnectedTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.notConnectedDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
                  l10n.connectGoogleButton,
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
    final l10n = context.l10n;
    final isProcessing =
        state.status == BackupStatus.backingUp ||
        state.status == BackupStatus.restoring;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Account status card
          _buildAccountCard(context, state),

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
                          ? l10n.restoringData
                          : l10n.syncingData)
                    : l10n.backupNowButton,
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
                l10n.restoreDataButton,
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
                l10n.infoBackupHeader,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2.w,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            _buildInfoCard(context, state),
            SizedBox(height: 24.h),
          ],

          // Disconnect
          SizedBox(height: 16.h),
          TextButton(
            onPressed: isProcessing
                ? null
                : () => _showDisconnectConfirmation(context),
            child: Text(
              l10n.disconnectAccount,
              style: TextStyle(
                color: isProcessing ? Colors.grey : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          Text(
            l10n.localDataSafeNote,
            style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, BackupState state) {
    final l10n = context.l10n;
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
                '${l10n.lastBackupLabel}: ',
                style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              ),
              Text(
                _formatLastBackup(
                  context,
                  state.remoteBackupInfo?.modifiedTime?.toLocal() ??
                      state.lastBackupTime,
                ),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, BackupState state) {
    final l10n = context.l10n;
    final info = state.remoteBackupInfo;
    if (info == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
            context: context,
            icon: Icons.calendar_today,
            label: l10n.backupDateLabel,
            value: info.modifiedTime != null
                ? DateFormat(
                    'dd MMM yyyy, HH:mm',
                    l10n.dateLocaleCode,
                  ).format(info.modifiedTime!.toLocal())
                : '-',
          ),
          Divider(height: 1.h, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
          _buildInfoRow(
            context: context,
            icon: Icons.storage,
            label: l10n.fileSizeLabel,
            value: info.sizeBytes != null
                ? _formatFileSize(info.sizeBytes!)
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerLow
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  String _formatLastBackup(BuildContext context, DateTime? time) {
    final l10n = context.l10n;
    if (time == null) return l10n.neverBackedUp;

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgoCount(diff.inDays);

    return DateFormat('dd MMM yyyy', l10n.dateLocaleCode).format(time);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showRestoreConfirmation(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.restoreDataTitle),
        content: Text(l10n.restoreDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BackupCubit>().restoreBackup();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.yesRestore),
          ),
        ],
      ),
    );
  }

  void _showDisconnectConfirmation(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.disconnectAccountTitle),
        content: Text(l10n.disconnectAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BackupCubit>().signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.yesDisconnect),
          ),
        ],
      ),
    );
  }
}
