import 'dart:convert';

/// Tipe target pemasukan
enum FinancialTargetType {
  repeat, // Berulang setiap bulan pada tanggal tertentu
  once,   // Satu kali pada tanggal spesifik
}

/// Model untuk target pemasukan / gajian finansial
class FinancialTarget {
  final String id;
  final String title;
  final FinancialTargetType type;
  final int? dayOfMonth; // 1-31 (untuk tipe repeat)
  final DateTime? specificDate; // (untuk tipe once)
  final bool isEnabled;
  final DateTime createdAt;

  const FinancialTarget({
    required this.id,
    required this.title,
    required this.type,
    this.dayOfMonth,
    this.specificDate,
    this.isEnabled = true,
    required this.createdAt,
  });

  bool get isRepeat => type == FinancialTargetType.repeat;

  /// Menghitung tanggal kejadian terdekat berikutnya dari tanggal referensi [fromDate]
  DateTime? getNextOccurrence(DateTime fromDate) {
    if (!isEnabled) return null;

    final refDate = DateTime(fromDate.year, fromDate.month, fromDate.day);

    if (type == FinancialTargetType.once) {
      if (specificDate == null) return null;
      final target = DateTime(
        specificDate!.year,
        specificDate!.month,
        specificDate!.day,
      );
      // Jika target satu kali sudah lewat sebelum hari ini, return null
      if (target.isBefore(refDate)) return null;
      return target;
    } else {
      // Repeat bulanan
      final targetDay = dayOfMonth ?? 1;

      // Cek bulan ini
      final daysInThisMonth = _getDaysInMonth(refDate.year, refDate.month);
      final clampedDayThisMonth = targetDay.clamp(1, daysInThisMonth);
      final thisMonthTarget = DateTime(refDate.year, refDate.month, clampedDayThisMonth);

      if (!thisMonthTarget.isBefore(refDate)) {
        return thisMonthTarget;
      }

      // Jika tanggal target bulan ini sudah lewat, jadwalkan untuk bulan depan
      int nextMonth = refDate.month + 1;
      int nextYear = refDate.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }

      final daysInNextMonth = _getDaysInMonth(nextYear, nextMonth);
      final clampedDayNextMonth = targetDay.clamp(1, daysInNextMonth);
      return DateTime(nextYear, nextMonth, clampedDayNextMonth);
    }
  }

  static int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  FinancialTarget copyWith({
    String? id,
    String? title,
    FinancialTargetType? type,
    int? dayOfMonth,
    DateTime? specificDate,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return FinancialTarget(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      specificDate: specificDate ?? this.specificDate,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'dayOfMonth': dayOfMonth,
      'specificDate': specificDate?.toIso8601String(),
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FinancialTarget.fromMap(Map<String, dynamic> map) {
    return FinancialTarget(
      id: map['id'] as String,
      title: map['title'] as String,
      type: map['type'] == 'once' ? FinancialTargetType.once : FinancialTargetType.repeat,
      dayOfMonth: map['dayOfMonth'] as int?,
      specificDate: map['specificDate'] != null ? DateTime.tryParse(map['specificDate'] as String) : null,
      isEnabled: map['isEnabled'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FinancialTarget.fromJson(String source) =>
      FinancialTarget.fromMap(json.decode(source) as Map<String, dynamic>);
}
