import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/financial_target_model.dart';
import '../utils/currency_formatter.dart';
import 'saku_home_widget_service.dart';

enum RunwayStatus {
  safe,        // Jatah harian sangat cukup/sehat
  moderate,    // Jatah harian wajar
  tight,       // Jatah harian ketat / perlu hemat
  reachedToday,// Hari ini adalah hari-H target pemasukan/gajian
  noTarget,    // Belum ada target aktif yang valid
}

class RunwayCalculationResult {
  final FinancialTarget? nextTarget;
  final DateTime? targetDate;
  final int daysRemaining;
  final double dailyAllowance;
  final double totalBalance;
  final String headlineMessage;
  final String adviceMessage;
  final RunwayStatus status;

  const RunwayCalculationResult({
    this.nextTarget,
    this.targetDate,
    required this.daysRemaining,
    required this.dailyAllowance,
    required this.totalBalance,
    required this.headlineMessage,
    required this.adviceMessage,
    required this.status,
  });
}

class SpendingPlannerService {
  static const String _storageKey = 'saku_financial_targets_v1';

  /// Mengambil semua daftar target finansial dari penyimpanan lokal
  static Future<List<FinancialTarget>> getTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_storageKey);

    if (rawJson == null || rawJson.trim().isEmpty) {
      // Inisialisasi default target pertama kali (misal: "Akhir Bulan / Gajian Rutin")
      final defaultTargets = [
        FinancialTarget(
          id: 'default_end_of_month',
          title: 'Akhir Bulan / Gajian',
          type: FinancialTargetType.repeat,
          dayOfMonth: 30,
          isEnabled: true,
          createdAt: DateTime.now(),
        ),
      ];
      await saveAllTargets(defaultTargets);
      return defaultTargets;
    }

    try {
      final List<dynamic> list = json.decode(rawJson) as List<dynamic>;
      return list.map((item) => FinancialTarget.fromMap(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Menyimpan seluruh list target ke SharedPreferences
  static Future<void> saveAllTargets(List<FinancialTarget> targets) async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = json.encode(targets.map((t) => t.toMap()).toList());
    await prefs.setString(_storageKey, rawJson);
    SakuHomeWidgetService.updateRunwayWidget(targets: targets);
  }

  /// Menambah atau memperbarui target tertentu
  static Future<void> saveTarget(FinancialTarget target) async {
    final current = await getTargets();
    final index = current.indexWhere((t) => t.id == target.id);
    if (index >= 0) {
      current[index] = target;
    } else {
      current.add(target);
    }
    await saveAllTargets(current);
  }

  /// Menghapus target berdasarkan ID
  static Future<void> deleteTarget(String id) async {
    final current = await getTargets();
    current.removeWhere((t) => t.id == id);
    await saveAllTargets(current);
  }

  /// Toggle status aktif/nonaktif target
  static Future<void> toggleTarget(String id, bool isEnabled) async {
    final current = await getTargets();
    final index = current.indexWhere((t) => t.id == id);
    if (index >= 0) {
      current[index] = current[index].copyWith(isEnabled: isEnabled);
      await saveAllTargets(current);
    }
  }

  /// Kalkulasi landasan pacu uang (Runway & Jatah Belanja Harian)
  static RunwayCalculationResult calculateRunway(
    List<FinancialTarget> targets,
    double totalBalance, {
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Cari target aktif terdekat berikutnya
    FinancialTarget? nearestTarget;
    DateTime? nearestDate;
    int? shortestDays;

    for (final target in targets) {
      if (!target.isEnabled) continue;
      final nextOccur = target.getNextOccurrence(today);
      if (nextOccur == null) continue;

      final diffDays = nextOccur.difference(today).inDays;
      if (diffDays >= 0) {
        if (shortestDays == null || diffDays < shortestDays) {
          shortestDays = diffDays;
          nearestDate = nextOccur;
          nearestTarget = target;
        }
      }
    }

    // Jika tidak ada target aktif
    if (nearestTarget == null || nearestDate == null || shortestDays == null) {
      return RunwayCalculationResult(
        nextTarget: null,
        targetDate: null,
        daysRemaining: 0,
        dailyAllowance: 0,
        totalBalance: totalBalance,
        headlineMessage: 'Belum ada target tanggal aktif',
        adviceMessage: 'Atur tanggal gajian atau proyekan Anda untuk menghitung jatah belanja harian.',
        status: RunwayStatus.noTarget,
      );
    }

    final formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(nearestDate);
    final targetTitle = nearestTarget.title.trim().isNotEmpty ? nearestTarget.title : 'Target Pemasukan';

    // Kasus 1: Hari ini adalah Hari-H Target (shortestDays == 0)
    if (shortestDays == 0) {
      return RunwayCalculationResult(
        nextTarget: nearestTarget,
        targetDate: nearestDate,
        daysRemaining: 0,
        dailyAllowance: totalBalance > 0 ? totalBalance : 0,
        totalBalance: totalBalance,
        headlineMessage: 'Hari ini adalah hari $targetTitle! 🎉',
        adviceMessage: 'Selamat menyambut pemasukan baru! Anda berhasil mengelola saldo hingga hari target.',
        status: RunwayStatus.reachedToday,
      );
    }

    // Kasus 2: Masih ada N hari menuju target
    // Sisa hari inklusif (termasuk hari ini hingga hari sebelum target tiba)
    final daysToDivide = shortestDays;
    final dailyAllowance = totalBalance > 0 ? (totalBalance / daysToDivide) : 0.0;
    final formattedDaily = CurrencyFormatter.format(dailyAllowance.toStringAsFixed(0));
    final formattedTotal = CurrencyFormatter.format(totalBalance.toStringAsFixed(0));

    RunwayStatus status;
    String advice;

    if (totalBalance <= 0) {
      status = RunwayStatus.tight;
      advice = 'Saldo telah habis. Hindari pengeluaran tidak mendesak hingga $targetTitle ($formattedDate).';
    } else if (dailyAllowance < 20000) {
      status = RunwayStatus.tight;
      advice = 'Jatah harian cukup ketat (Rp $formattedDaily/hari). Prioritaskan kebutuhan pokok hingga $formattedDate.';
    } else if (dailyAllowance < 75000) {
      status = RunwayStatus.moderate;
      advice = 'Keluarkan maksimal Rp $formattedDaily per hari agar saldo Rp $formattedTotal cukup sampai $formattedDate.';
    } else {
      status = RunwayStatus.safe;
      advice = 'Kondisi kas aman! Jatah pengeluaran harian Anda Rp $formattedDaily/hari menuju $targetTitle.';
    }

    return RunwayCalculationResult(
      nextTarget: nearestTarget,
      targetDate: nearestDate,
      daysRemaining: daysToDivide,
      dailyAllowance: dailyAllowance,
      totalBalance: totalBalance,
      headlineMessage: 'Rp $formattedDaily / hari',
      adviceMessage: advice,
      status: status,
    );
  }
}
