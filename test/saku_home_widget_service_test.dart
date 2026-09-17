import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:saku/core/models/financial_target_model.dart';
import 'package:saku/core/services/spending_planner_service.dart';
import 'package:saku/core/utils/currency_formatter.dart';
import 'package:saku/data/local/database/app_database.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Saku Home Widget Data Formatting Tests', () {
    test('Wallets data serialization matches expected AppWidget schema', () {
      final wallets = [
        Wallet(
          id: 1,
          name: 'BNI',
          type: 'bank',
          initialBalance: 100000,
          currentBalance: 243274,
          icon: 'bank',
          iconColor: 0xFF10B981,
          sortOrder: 0,
          isMain: true,
          isHidden: false,
          isNumberMasked: false,
          isArchived: false,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
        Wallet(
          id: 2,
          name: 'Jago',
          type: 'bank',
          initialBalance: 0,
          currentBalance: 50000,
          icon: 'bank',
          iconColor: 0xFFF59E0B,
          sortOrder: 1,
          isMain: false,
          isHidden: false,
          isNumberMasked: false,
          isArchived: false,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
        Wallet(
          id: 3,
          name: 'Hidden Wallet',
          type: 'cash',
          initialBalance: 0,
          currentBalance: 999999,
          icon: 'wallet',
          iconColor: 0xFF6B7280,
          sortOrder: 2,
          isMain: false,
          isHidden: true,
          isNumberMasked: false,
          isArchived: false,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
      ];

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

      expect(formattedTotal, equals('Rp 293.274'));
      expect(walletCount, equals('2 Wallet'));
      expect(walletsData.length, equals(2));
      expect(walletsData[0]['name'], equals('BNI'));
      expect(walletsData[0]['balance'], equals('Rp 243.274'));
      expect(walletsData[1]['name'], equals('Jago'));
      expect(walletsData[1]['balance'], equals('Rp 50.000'));

      final jsonStr = jsonEncode(walletsData);
      expect(jsonStr, contains('BNI'));
      expect(jsonStr, contains('Rp 243.274'));
    });

    test('Runway data calculations for AppWidget payload', () {
      final targets = [
        FinancialTarget(
          id: 't1',
          title: 'Akhir Bulan / Gajian',
          type: FinancialTargetType.repeat,
          dayOfMonth: 27,
          isEnabled: true,
          createdAt: DateTime(2026, 9, 1),
        ),
      ];

      final totalBalance = 377301.0;
      final fixedNow = DateTime(2026, 9, 16);
      final calc = SpendingPlannerService.calculateRunway(targets, totalBalance, currentDate: fixedNow);

      final formattedDaily = CurrencyFormatter.format(calc.dailyAllowance.toStringAsFixed(0));
      final formattedTotal = CurrencyFormatter.format(totalBalance.toStringAsFixed(0));

      expect(calc.daysRemaining, equals(11));
      expect(formattedDaily, equals('34.300'));
      expect(formattedTotal, equals('377.301'));
      expect(calc.nextTarget?.title, equals('Akhir Bulan / Gajian'));
      expect(calc.adviceMessage, contains('Keluarkan maksimal Rp 34.300 per hari'));
    });
  });
}
