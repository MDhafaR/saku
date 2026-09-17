import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:saku/core/models/financial_target_model.dart';
import 'package:saku/core/services/spending_planner_service.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });
  group('FinancialTarget Model Tests', () {
    test('getNextOccurrence for monthly repeat target in the future of current month', () {
      final target = FinancialTarget(
        id: 't1',
        title: 'Gaji Kantor',
        type: FinancialTargetType.repeat,
        dayOfMonth: 25,
        isEnabled: true,
        createdAt: DateTime(2026, 9, 1),
      );

      final now = DateTime(2026, 9, 16);
      final nextOccur = target.getNextOccurrence(now);

      expect(nextOccur, equals(DateTime(2026, 9, 25)));
    });

    test('getNextOccurrence for monthly repeat target that already passed in current month', () {
      final target = FinancialTarget(
        id: 't1',
        title: 'Gaji Kantor',
        type: FinancialTargetType.repeat,
        dayOfMonth: 10,
        isEnabled: true,
        createdAt: DateTime(2026, 9, 1),
      );

      final now = DateTime(2026, 9, 16);
      final nextOccur = target.getNextOccurrence(now);

      expect(nextOccur, equals(DateTime(2026, 10, 10)));
    });

    test('getNextOccurrence for once target in the future', () {
      final target = FinancialTarget(
        id: 't2',
        title: 'Project Freelance',
        type: FinancialTargetType.once,
        specificDate: DateTime(2026, 10, 5),
        isEnabled: true,
        createdAt: DateTime(2026, 9, 1),
      );

      final now = DateTime(2026, 9, 16);
      final nextOccur = target.getNextOccurrence(now);

      expect(nextOccur, equals(DateTime(2026, 10, 5)));
    });

    test('getNextOccurrence for once target that already expired', () {
      final target = FinancialTarget(
        id: 't3',
        title: 'Project Lama',
        type: FinancialTargetType.once,
        specificDate: DateTime(2026, 9, 10),
        isEnabled: true,
        createdAt: DateTime(2026, 9, 1),
      );

      final now = DateTime(2026, 9, 16);
      final nextOccur = target.getNextOccurrence(now);

      expect(nextOccur, isNull);
    });
  });

  group('SpendingPlannerService Runway Calculation Tests', () {
    test('calculateRunway calculates daily allowance correctly', () {
      final targets = [
        FinancialTarget(
          id: 't1',
          title: 'Gaji Akhir Bulan',
          type: FinancialTargetType.repeat,
          dayOfMonth: 26,
          isEnabled: true,
          createdAt: DateTime(2026, 9, 1),
        ),
      ];

      // Now is 16 Sept -> 26 Sept is 10 days away
      final now = DateTime(2026, 9, 16);
      final totalBalance = 1000000.0;

      final result = SpendingPlannerService.calculateRunway(
        targets,
        totalBalance,
        currentDate: now,
      );

      expect(result.status, equals(RunwayStatus.safe));
      expect(result.daysRemaining, equals(10));
      expect(result.dailyAllowance, equals(100000.0));
      expect(result.headlineMessage, contains('100.000'));
    });

    test('calculateRunway handles day-of target (Hari-H)', () {
      final targets = [
        FinancialTarget(
          id: 't1',
          title: 'Gaji Kantor',
          type: FinancialTargetType.repeat,
          dayOfMonth: 16,
          isEnabled: true,
          createdAt: DateTime(2026, 9, 1),
        ),
      ];

      final now = DateTime(2026, 9, 16);
      final totalBalance = 250000.0;

      final result = SpendingPlannerService.calculateRunway(
        targets,
        totalBalance,
        currentDate: now,
      );

      expect(result.status, equals(RunwayStatus.reachedToday));
      expect(result.daysRemaining, equals(0));
      expect(result.headlineMessage, contains('Hari ini adalah hari Gaji Kantor!'));
    });

    test('calculateRunway prioritizes the nearest active target among multiple', () {
      final targets = [
        FinancialTarget(
          id: 't_repeat',
          title: 'Gaji Bulanan',
          type: FinancialTargetType.repeat,
          dayOfMonth: 30, // 14 days away from 16 Sept
          isEnabled: true,
          createdAt: DateTime(2026, 9, 1),
        ),
        FinancialTarget(
          id: 't_once',
          title: 'Proyekan Kilat',
          type: FinancialTargetType.once,
          specificDate: DateTime(2026, 9, 21), // 5 days away from 16 Sept
          isEnabled: true,
          createdAt: DateTime(2026, 9, 1),
        ),
      ];

      final now = DateTime(2026, 9, 16);
      final totalBalance = 500000.0;

      final result = SpendingPlannerService.calculateRunway(
        targets,
        totalBalance,
        currentDate: now,
      );

      expect(result.nextTarget?.id, equals('t_once'));
      expect(result.daysRemaining, equals(5));
      expect(result.dailyAllowance, equals(100000.0));
    });
  });
}
