import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/financial_target_model.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/services/spending_planner_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'financial_targets_bottom_sheet.dart';

class SpendingPlannerCard extends StatefulWidget {
  final double totalBalance;
  final VoidCallback? onTargetUpdated;

  const SpendingPlannerCard({
    super.key,
    required this.totalBalance,
    this.onTargetUpdated,
  });

  @override
  State<SpendingPlannerCard> createState() => _SpendingPlannerCardState();
}

class _SpendingPlannerCardState extends State<SpendingPlannerCard> {
  List<FinancialTarget> _targets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  Future<void> _loadTargets() async {
    final targets = await SpendingPlannerService.getTargets();
    if (mounted) {
      setState(() {
        _targets = targets;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    if (_isLoading) {
      return const SizedBox.shrink();
    }

    final calculation = SpendingPlannerService.calculateRunway(
      _targets,
      widget.totalBalance,
    );

    // Color theme based on calculation status
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (calculation.status) {
      case RunwayStatus.safe:
        statusColor = const Color(0xFF10B981); // Emerald Green
        statusBgColor = const Color(0xFF10B981).withValues(alpha: 0.12);
        statusIcon = Icons.savings_rounded;
        break;
      case RunwayStatus.moderate:
        statusColor = const Color(0xFF3B82F6); // Blue
        statusBgColor = const Color(0xFF3B82F6).withValues(alpha: 0.12);
        statusIcon = Icons.account_balance_wallet_rounded;
        break;
      case RunwayStatus.tight:
        statusColor = const Color(0xFFF59E0B); // Amber / Orange
        statusBgColor = const Color(0xFFF59E0B).withValues(alpha: 0.12);
        statusIcon = Icons.warning_amber_rounded;
        break;
      case RunwayStatus.reachedToday:
        statusColor = const Color(0xFF8B5CF6); // Purple
        statusBgColor = const Color(0xFF8B5CF6).withValues(alpha: 0.12);
        statusIcon = Icons.celebration_rounded;
        break;
      case RunwayStatus.noTarget:
        statusColor = cs.primary;
        statusBgColor = cs.primary.withValues(alpha: 0.1);
        statusIcon = Icons.calendar_month_rounded;
        break;
    }

    String countdownBadge;
    if (calculation.status == RunwayStatus.noTarget) {
      countdownBadge = l10n.setTargetDate;
    } else if (calculation.status == RunwayStatus.reachedToday) {
      countdownBadge = l10n.targetReachedToday;
    } else {
      countdownBadge = l10n.daysLeftCount(calculation.daysRemaining);
    }

    final formattedDaily = CurrencyFormatter.format(calculation.dailyAllowance.toStringAsFixed(0));
    final formattedTotal = CurrencyFormatter.format(widget.totalBalance.toStringAsFixed(0));

    return SakuCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title + Target Badge + Settings Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: statusBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(statusIcon, color: statusColor, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      calculation.nextTarget != null
                          ? calculation.nextTarget!.title
                          : l10n.dailySpendingAllocation,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      calculation.targetDate != null
                          ? 'Target: ${DateFormat('d MMMM yyyy', l10n.dateLocaleCode).format(calculation.targetDate!)}'
                          : l10n.noActiveTarget,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              InkWell(
                onTap: () => FinancialTargetsBottomSheet.show(
                  context,
                  initialTargets: _targets,
                  onTargetsChanged: () {
                    _loadTargets();
                    widget.onTargetUpdated?.call();
                  },
                ),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: isDark ? cs.surfaceContainerHighest : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        countdownBadge,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.tune_rounded, size: 13.sp, color: cs.onSurface.withValues(alpha: 0.6)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Main Metric Row
          if (calculation.status != RunwayStatus.noTarget && calculation.status != RunwayStatus.reachedToday) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Rp $formattedDaily',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  l10n.perDay,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const Spacer(),
                Text(
                  '${l10n.balancePrefix} Rp $formattedTotal',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ] else if (calculation.status == RunwayStatus.reachedToday) ...[
            Row(
              children: [
                Text(
                  l10n.targetIncomeDay,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${l10n.remainingBalanceLabel} Rp $formattedTotal',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 8.h),

          // Smart Advice Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: statusBgColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Icon(Icons.auto_awesome_rounded, size: 13.sp, color: statusColor),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    calculation.adviceMessage,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
