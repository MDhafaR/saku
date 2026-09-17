import 'package:equatable/equatable.dart';

/// Merepresentasikan satu intent transaksi yang diekstrak oleh AI dari input suara.
///
/// Satu kalimat suara bisa menghasilkan banyak [VoiceIntentModel] sekaligus
/// (multi-intent). Contoh: "beli nugget 20000, lalu transfer ke BNI 50000"
/// → dua objek [VoiceIntentModel].
class VoiceIntentModel extends Equatable {
  /// Fitur tujuan di app. Nilai: 'transaksi', 'transfer', 'hutang_piutang'
  final String feature;

  /// Tipe untuk fitur transaksi: 'income' atau 'expense'.
  /// Tipe untuk fitur hutang_piutang: 'hutang' atau 'piutang'.
  final String? type;

  /// Nominal dalam rupiah (sudah dikonversi dari teks, mis: "dua puluh ribu" → 20000)
  final double? amount;

  /// Kategori transaksi (mis: 'Makanan', 'Transportasi'). Null jika tidak terdeteksi.
  final String? category;

  /// Catatan/deskripsi singkat dari konteks kalimat
  final String? note;

  /// Nama wallet sumber (untuk transaksi biasa & hutang/piutang)
  final String? wallet;

  /// Nama wallet asal transfer (khusus fitur 'transfer')
  final String? fromWallet;

  /// Nama wallet tujuan transfer (khusus fitur 'transfer')
  final String? toWallet;

  /// Nama kontak untuk hutang/piutang
  final String? contactName;

  /// Tanggal transaksi yang diekstrak dari teks alami (misal: "kemarin", "14 September", "3 bulan lalu")
  final DateTime? date;

  const VoiceIntentModel({
    required this.feature,
    this.type,
    this.amount,
    this.category,
    this.note,
    this.wallet,
    this.fromWallet,
    this.toWallet,
    this.contactName,
    this.date,
  });

  factory VoiceIntentModel.fromJson(Map<String, dynamic> json) {
    return VoiceIntentModel(
      feature: json['feature'] as String? ?? 'transaksi',
      type: json['type'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      category: json['category'] as String?,
      note: json['note'] as String?,
      wallet: json['wallet'] as String?,
      fromWallet: json['from_wallet'] as String?,
      toWallet: json['to_wallet'] as String?,
      contactName: json['contact_name'] as String?,
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'feature': feature,
        'type': type,
        'amount': amount,
        'category': category,
        'note': note,
        'wallet': wallet,
        'from_wallet': fromWallet,
        'to_wallet': toWallet,
        'contact_name': contactName,
        'date': date?.toIso8601String(),
      };

  /// Label ringkas untuk ditampilkan di UI konfirmasi
  String get displayLabel {
    final nominal = amount != null
        ? 'Rp ${amount!.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]}.',
            )}'
        : '?';

    switch (feature) {
      case 'transfer':
        return 'Transfer $nominal dari ${fromWallet ?? '?'} ke ${toWallet ?? '?'}';
      case 'hutang_piutang':
        final label = type == 'hutang' ? 'Hutang' : 'Piutang';
        return '$label $nominal${contactName != null ? ' (${contactName!})' : ''}';
      case 'penyesuaian_saldo':
        return '⚖️ Ngepasin Saldo ${wallet ?? 'Dompet'} jadi $nominal';
      default:
        final label = type == 'income' ? '📈 Pemasukan' : '📉 Pengeluaran';
        return '$label $nominal${note != null ? ' — ${note!}' : ''}';
    }
  }

  @override
  List<Object?> get props => [
        feature,
        type,
        amount,
        category,
        note,
        wallet,
        fromWallet,
        toWallet,
        contactName,
        date,
      ];
}
