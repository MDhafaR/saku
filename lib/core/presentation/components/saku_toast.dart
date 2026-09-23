import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SakuToastType { success, error, info, warning }

/// Premium notification toast / dynamic pill adhering to Saku's design system.
/// Floats elegantly at the top of the screen (below the status bar / SafeArea),
/// scoped to the active route so it does not bleed or duplicate across screen navigation.
class SakuToast {
  static OverlayEntry? _currentEntry;

  /// Explicitly dismiss any currently visible toast immediately.
  static void dismiss() {
    _dismissCurrent();
  }

  static void _dismissCurrent() {
    try {
      _currentEntry?.remove();
    } catch (_) {}
    _currentEntry = null;
  }

  static void show(
    BuildContext context, {
    required String message,
    SakuToastType type = SakuToastType.success,
    Duration duration = const Duration(milliseconds: 3000),
    Widget? action,
    double topMargin = 8.0,
    double? bottomMargin, // Kept for API backwards compatibility
  }) {
    _dismissCurrent();

    // Use local overlay (rootOverlay: false) so toast stays strictly inside the
    // current route and does NOT bleed into or duplicate over newly pushed pages.
    final overlay = Overlay.maybeOf(context, rootOverlay: false) ??
        Overlay.maybeOf(context, rootOverlay: true);

    if (overlay == null) {
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      if (scaffoldMessenger != null) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            duration: duration,
            behavior: SnackBarBehavior.floating,
            content: Text(message),
          ),
        );
      }
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _SakuToastWidget(
        key: UniqueKey(),
        message: message,
        type: type,
        duration: duration,
        action: action,
        topMargin: topMargin,
        onDismiss: () {
          if (_currentEntry == entry) {
            try {
              entry.remove();
            } catch (_) {}
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 3000),
    double topMargin = 8.0,
    double? bottomMargin,
  }) {
    show(
      context,
      message: message,
      type: SakuToastType.success,
      duration: duration,
      topMargin: topMargin,
      bottomMargin: bottomMargin,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 3000),
    double topMargin = 8.0,
    double? bottomMargin,
  }) {
    show(
      context,
      message: message,
      type: SakuToastType.error,
      duration: duration,
      topMargin: topMargin,
      bottomMargin: bottomMargin,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 3000),
    double topMargin = 8.0,
    double? bottomMargin,
  }) {
    show(
      context,
      message: message,
      type: SakuToastType.info,
      duration: duration,
      topMargin: topMargin,
      bottomMargin: bottomMargin,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 3000),
    double topMargin = 8.0,
    double? bottomMargin,
  }) {
    show(
      context,
      message: message,
      type: SakuToastType.warning,
      duration: duration,
      topMargin: topMargin,
      bottomMargin: bottomMargin,
    );
  }
}

class _SakuToastWidget extends StatefulWidget {
  final String message;
  final SakuToastType type;
  final Duration duration;
  final Widget? action;
  final double topMargin;
  final VoidCallback onDismiss;

  const _SakuToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    this.action,
    required this.topMargin,
    required this.onDismiss,
  });

  @override
  State<_SakuToastWidget> createState() => _SakuToastWidgetState();
}

class _SakuToastWidgetState extends State<_SakuToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();

    _autoDismissTimer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _autoDismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color iconColor;
    Color iconBgColor;
    IconData iconData;

    switch (widget.type) {
      case SakuToastType.success:
        iconColor = const Color(0xFF10B981);
        iconBgColor = const Color(0xFF10B981).withValues(alpha: 0.18);
        iconData = Icons.check_circle_rounded;
        break;
      case SakuToastType.error:
        iconColor = const Color(0xFFEF4444);
        iconBgColor = const Color(0xFFEF4444).withValues(alpha: 0.18);
        iconData = Icons.error_outline_rounded;
        break;
      case SakuToastType.warning:
        iconColor = const Color(0xFFF59E0B);
        iconBgColor = const Color(0xFFF59E0B).withValues(alpha: 0.18);
        iconData = Icons.warning_amber_rounded;
        break;
      case SakuToastType.info:
        iconColor = const Color(0xFF3B82F6);
        iconBgColor = const Color(0xFF3B82F6).withValues(alpha: 0.18);
        iconData = Icons.info_outline_rounded;
        break;
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, widget.topMargin.h, 16.w, 0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -2) {
                _dismiss();
              }
            },
            onTap: _dismiss,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            iconData,
                            color: iconColor,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (widget.action != null) ...[
                          SizedBox(width: 8.w),
                          widget.action!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
