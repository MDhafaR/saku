import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../../data/local/database/app_database.dart';
import '../injection.dart';
import '../models/financial_target_model.dart';
import 'spending_planner_service.dart';
import '../utils/currency_formatter.dart';

class SakuHomeWidgetService {
  static const String walletsWidgetProvider = 'SakuWalletsWidgetProvider';
  static const String runwayWidgetProvider = 'SakuRunwayWidgetProvider';

  /// Updates both Wallets & Runway widgets with current database state.
  static Future<void> updateAllWidgets([AppDatabase? database]) async {
    try {
      final db = database ?? locator<AppDatabase>();
      final wallets = await db.walletDao.getAllWallets();
      final targets = await SpendingPlannerService.getTargets();

      await updateWalletsWidget(wallets);
      await updateRunwayWidget(wallets: wallets, targets: targets);
    } catch (e) {
      // Ignore or log error gracefully
    }
  }

  /// Updates the Wallets & Total Balance widget.
  static Future<void> updateWalletsWidget(List<Wallet> wallets) async {
    try {
      final visibleWallets = wallets.where((w) => !w.isHidden).toList();
      final totalBalance = visibleWallets.fold<double>(0.0, (sum, w) => sum + w.currentBalance);

      final formattedTotal = 'Rp ${CurrencyFormatter.format(totalBalance.toStringAsFixed(0))}';
      final walletCount = '${visibleWallets.length} Wallet';

      final walletsData = visibleWallets.map((w) {
        final formattedBalance = 'Rp ${CurrencyFormatter.format(w.currentBalance.toStringAsFixed(0))}';
        return {
          'id': w.id,
          'name': w.name,
          'balance': formattedBalance,
        };
      }).toList();

      await HomeWidget.saveWidgetData<String>('total_balance', formattedTotal);
      await HomeWidget.saveWidgetData<String>('wallet_count', walletCount);
      await HomeWidget.saveWidgetData<String>('wallets_json', jsonEncode(walletsData));

      await HomeWidget.updateWidget(
        name: walletsWidgetProvider,
        androidName: walletsWidgetProvider,
      );
    } catch (e) {
      // Handle gracefully
    }
  }

  /// Updates the Daily Spending Runway widget.
  static Future<void> updateRunwayWidget({
    List<Wallet>? wallets,
    List<FinancialTarget>? targets,
    AppDatabase? database,
  }) async {
    try {
      final db = database ?? locator<AppDatabase>();
      final allWallets = wallets ?? await db.walletDao.getAllWallets();
      final allTargets = targets ?? await SpendingPlannerService.getTargets();

      final visibleWallets = allWallets.where((w) => !w.isHidden).toList();
      final totalBalance = visibleWallets.fold<double>(0.0, (sum, w) => sum + w.currentBalance);

      final calc = SpendingPlannerService.calculateRunway(allTargets, totalBalance);

      final formattedDaily = CurrencyFormatter.format(calc.dailyAllowance.toStringAsFixed(0));
      final formattedTotal = CurrencyFormatter.format(totalBalance.toStringAsFixed(0));

      String countdownBadge;
      if (calc.status == RunwayStatus.noTarget) {
        countdownBadge = 'Atur Target';
      } else if (calc.status == RunwayStatus.reachedToday) {
        countdownBadge = 'Hari Ini! 🎉';
      } else {
        countdownBadge = '${calc.daysRemaining} hari lagi';
      }

      await HomeWidget.saveWidgetData<String>(
        'runway_target_title',
        calc.nextTarget != null ? calc.nextTarget!.title : 'Alokasi Belanja Harian',
      );
      await HomeWidget.saveWidgetData<String>('runway_countdown_badge', countdownBadge);
      await HomeWidget.saveWidgetData<String>('runway_daily_amount', 'Rp $formattedDaily');
      await HomeWidget.saveWidgetData<String>('runway_total_balance', 'Saldo: Rp $formattedTotal');
      await HomeWidget.saveWidgetData<String>('runway_advice_text', calc.adviceMessage);

      await HomeWidget.updateWidget(
        name: runwayWidgetProvider,
        androidName: runwayWidgetProvider,
      );
    } catch (e) {
      // Handle gracefully
    }
  }
}
