import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/injection.dart';
import '../../../../core/models/voice_intent_model.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../settings/presentation/pages/add_edit_wallet_page.dart';

/// Formatter untuk memformat angka dengan pemisah ribuan titik (contoh: 25.000, 50.000.000)
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanText.isEmpty) {
      return const TextEditingValue();
    }

    final number = int.tryParse(cleanText);
    if (number == null) return oldValue;

    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class EditableIntentItem {
  String feature; // 'transaksi', 'transfer', 'hutang_piutang'
  String type; // 'expense', 'income', 'hutang', 'piutang'
  double amount;
  String note;
  DateTime date;
  String? category;
  int? categoryId;
  String? wallet; // Detected wallet name from parser (source wallet)
  String? toWallet; // Detected destination wallet name from parser
  int? walletId;
  int? toWalletId;
  String? contactName;
  late TextEditingController noteController;
  late TextEditingController amountController;
  late TextEditingController contactController;

  EditableIntentItem({
    required this.feature,
    required this.type,
    required this.amount,
    required this.note,
    required this.date,
    this.category,
    this.categoryId,
    this.wallet,
    this.toWallet,
    this.walletId,
    this.toWalletId,
    this.contactName,
  }) {
    noteController = TextEditingController(text: note);
    final formatter = NumberFormat('#,###', 'id_ID');
    amountController = TextEditingController(
      text: amount > 0 ? formatter.format(amount.toInt()) : '',
    );
    contactController = TextEditingController(text: contactName ?? '');
  }

  void dispose() {
    noteController.dispose();
    amountController.dispose();
    contactController.dispose();
  }

  factory EditableIntentItem.fromModel(VoiceIntentModel model) {
    return EditableIntentItem(
      feature: model.feature,
      type: model.type ?? (model.feature == 'hutang_piutang' ? 'hutang' : (model.feature == 'penyesuaian_saldo' ? 'adjustment' : 'expense')),
      amount: model.amount ?? 0,
      note: model.note ?? '',
      date: model.date ?? DateTime.now(),
      category: model.category,
      wallet: model.feature == 'transfer' ? model.fromWallet : (model.wallet ?? model.fromWallet),
      toWallet: model.toWallet,
      contactName: model.contactName,
    );
  }
}

class SmartImportReviewPage extends StatefulWidget {
  final List<VoiceIntentModel> initialIntents;
  final String sourceName;

  const SmartImportReviewPage({
    super.key,
    required this.initialIntents,
    this.sourceName = 'Mind Space',
  });

  @override
  State<SmartImportReviewPage> createState() => _SmartImportReviewPageState();
}

class _SmartImportReviewPageState extends State<SmartImportReviewPage> {
  final AppDatabase _db = locator<AppDatabase>();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List<EditableIntentItem> _items = [];
  List<Wallet> _wallets = [];
  List<Category> _categories = [];
  bool _isLoadingData = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _items = widget.initialIntents.map((m) => EditableIntentItem.fromModel(m)).toList();
    _loadMetadata();
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMetadata() async {
    try {
      var wallets = await _db.walletDao.getAllWallets();
      var categories = await _db.categoryDao.getAllCategories();

      // Jika belum ada dompet di database, buat dompet utama otomatis
      if (wallets.isEmpty) {
        await _db.seedDefaultWallet();
        wallets = await _db.walletDao.getAllWallets();
      }

      // Jika belum ada kategori di database, seed kategori default
      if (categories.isEmpty) {
        await _db.seedDefaultCategories();
        categories = await _db.categoryDao.getAllCategories();
      }

      // Intelligently resolve wallet matching against existing wallets
      final defaultWallet = wallets.isNotEmpty
          ? (wallets.where((w) => w.isMain).firstOrNull ?? wallets.first)
          : null;

      for (final item in _items) {
        // 1. Source wallet
        if (item.wallet != null && item.wallet!.trim().isNotEmpty) {
          final matchedId = _findMatchingWalletId(item.wallet!, wallets);
          item.walletId = matchedId ?? defaultWallet?.id;
        } else {
          item.walletId ??= defaultWallet?.id;
        }

        // 2. Destination wallet for transfer
        if (item.feature == 'transfer') {
          if (item.toWallet != null && item.toWallet!.trim().isNotEmpty) {
            final matchedToId = _findMatchingWalletId(item.toWallet!, wallets);
            item.toWalletId = matchedToId;
          }
          if (item.toWalletId == null || (item.toWalletId == item.walletId && wallets.length > 1)) {
            if (wallets.length > 1) {
              item.toWalletId = wallets.where((w) => w.id != item.walletId).firstOrNull?.id ?? wallets.first.id;
            } else {
              item.toWalletId = item.walletId;
            }
          }
        }

        // Set category with intelligent bilingual & synonym matching
        item.categoryId = _findMatchingCategoryId(item.category, item.type, categories);

        // Fallback category if not matched
        if (item.categoryId == null && categories.isNotEmpty) {
          final fallback = categories.where((c) => c.type == item.type).firstOrNull ?? categories.first;
          item.categoryId = fallback.id;
          item.category = fallback.name;
        }
      }

      setState(() {
        _wallets = wallets;
        _categories = categories;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  int? _findMatchingWalletId(String rawWallet, List<Wallet> wallets) {
    final raw = rawWallet.toLowerCase().trim();
    if (raw.isEmpty) return null;

    // 1. Exact case-insensitive match
    for (final w in wallets) {
      if (w.name.toLowerCase().trim() == raw) return w.id;
    }

    // 2. Alias / substring / brand match
    for (final w in wallets) {
      final wLower = w.name.toLowerCase().trim();
      if (wLower == raw) return w.id;
      if (wLower.contains(raw) || raw.contains(wLower)) return w.id;
      if ((raw == 'gopay' || raw == 'gojek') && (wLower.contains('gopay') || wLower.contains('gojek'))) return w.id;
      if ((raw == 'spay' || raw == 'shopeepay') && (wLower.contains('shopee') || wLower.contains('spay'))) return w.id;
      if (raw == 'dana' && wLower.contains('dana')) return w.id;
      if (raw == 'ovo' && wLower.contains('ovo')) return w.id;
      if (raw == 'bca' && wLower.contains('bca')) return w.id;
      if (raw == 'bni' && wLower.contains('bni')) return w.id;
      if (raw == 'bri' && wLower.contains('bri')) return w.id;
      if (raw == 'mandiri' && wLower.contains('mandiri')) return w.id;
      if (raw == 'jago' && wLower.contains('jago')) return w.id;
      if ((raw == 'tunai' || raw == 'cash' || raw == 'dompet' || raw == 'kantong') &&
          (wLower.contains('dompet') || wLower.contains('tunai') || wLower.contains('cash') || w.type == 'cash')) {
        return w.id;
      }
    }

    return null;
  }

  int? _findMatchingCategoryId(String? rawCategory, String type, List<Category> categories) {
    if (rawCategory == null || rawCategory.isEmpty) return null;
    final raw = rawCategory.toLowerCase();

    // Pastikan pencarian kategori hanya mencari kategori dengan tipe yang sesuai (expense vs income)
    final typedCategories = categories.where((c) => c.type == type).toList();
    final pool = typedCategories.isNotEmpty ? typedCategories : categories;

    // 1. Direct match
    for (final c in pool) {
      if (c.name.toLowerCase() == raw) return c.id;
    }

    // 2. Synonyms map
    final synMap = <String, List<String>>{
      'transportasi': ['transport', 'transportation', 'bensin', 'kendaraan'],
      'transportation': ['transportasi', 'transport', 'bensin', 'kendaraan'],
      'makanan & minuman': ['food & drinks', 'food', 'drinks', 'makanan', 'minuman', 'kuliner'],
      'food & drinks': ['makanan & minuman', 'food', 'drinks', 'makanan', 'minuman', 'kuliner'],
      'tagihan & utilitas': ['bills & utilities', 'bills', 'utilities', 'listrik', 'air', 'pulsa'],
      'bills & utilities': ['tagihan & utilitas', 'tagihan', 'utilitas', 'listrik', 'air', 'pulsa'],
      'belanja': ['shopping', 'supermarket', 'mart'],
      'shopping': ['belanja', 'supermarket', 'mart'],
      'hiburan': ['entertainment', 'nonton', 'game'],
      'entertainment': ['hiburan', 'nonton', 'game'],
      'kesehatan': ['health', 'medical', 'obat', 'dokter'],
      'health': ['kesehatan', 'medical', 'obat', 'dokter'],
      'pendidikan': ['education', 'school', 'kuliah', 'kursus'],
      'education': ['pendidikan', 'school', 'kuliah', 'kursus'],
      'travel': ['perjalanan', 'wisata'],
      'gaji': ['salary', 'upah', 'honor', 'pendapatan', 'penghasilan'],
      'salary': ['gaji', 'upah', 'honor', 'pendapatan', 'penghasilan'],
      'bonus': ['bonus', 'thr', 'reward', 'gift', 'hadiah', 'angpao', 'cashback'],
      'gift': ['hadiah', 'bonus', 'angpao', 'kiriman', 'dikirim'],
      'hadiah': ['gift', 'bonus', 'angpao', 'kiriman', 'dikirim'],
      'business': ['bisnis', 'jualan', 'penjualan', 'dagang', 'usaha', 'freelance', 'komisi', 'proyek'],
      'penjualan': ['business', 'bisnis', 'jual', 'jualan', 'dagang', 'usaha', 'omset'],
      'investasi': ['investment', 'saham', 'crypto', 'dividen', 'reksadana'],
      'investment': ['investasi', 'saham', 'crypto', 'dividen', 'reksadana'],
    };

    for (final c in pool) {
      final cLower = c.name.toLowerCase();
      if (synMap[raw]?.contains(cLower) == true) return c.id;
      if (synMap[cLower]?.contains(raw) == true) return c.id;
      if (cLower.contains(raw) || raw.contains(cLower)) return c.id;
    }

    return null;
  }

  double get _totalAmount {
    return _items.fold(0, (sum, item) => sum + item.amount);
  }

  Future<void> _saveAllTransactions() async {
    if (_items.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Pastikan dompet dan kategori siap
      if (_wallets.isEmpty) {
        await _db.seedDefaultWallet();
        _wallets = await _db.walletDao.getAllWallets();
      }
      if (_categories.isEmpty) {
        await _db.seedDefaultCategories();
        _categories = await _db.categoryDao.getAllCategories();
      }

      final fallbackWalletId = _wallets.isNotEmpty ? _wallets.first.id : 1;
      final fallbackCategoryId = _categories.isNotEmpty ? _categories.first.id : 1;

      for (final item in _items) {
        if (item.amount <= 0) continue;

        if (item.feature == 'transaksi') {
          await _db.transactionDao.createTransaction(
            TransactionsCompanion(
              walletId: drift.Value(item.walletId ?? fallbackWalletId),
              categoryId: drift.Value(item.categoryId ?? fallbackCategoryId),
              amount: drift.Value(item.amount),
              type: drift.Value(item.type),
              description: drift.Value(item.noteController.text.trim()),
              note: drift.Value(item.noteController.text.trim()),
              transactionDate: drift.Value(item.date),
            ),
          );
        } else if (item.feature == 'transfer') {
          final fromId = item.walletId ?? fallbackWalletId;
          final toId = item.toWalletId ?? (_wallets.length > 1 ? _wallets[1].id : fallbackWalletId);
          if (fromId != toId) {
            await _db.transferDao.createTransfer(
              TransfersCompanion(
                fromWalletId: drift.Value(fromId),
                toWalletId: drift.Value(toId),
                amount: drift.Value(item.amount),
                fee: const drift.Value(0),
                description: drift.Value(item.noteController.text.trim()),
                transferDate: drift.Value(item.date),
              ),
            );
          }
        } else if (item.feature == 'hutang_piutang') {
          // Resolve person
          final contact = item.contactController.text.trim().isNotEmpty
              ? item.contactController.text.trim()
              : 'Seseorang';
          final persons = await _db.debtDao.getAllPersons();
          var person = persons.where((p) => p.name.toLowerCase() == contact.toLowerCase()).firstOrNull;

          int personId;
          if (person != null) {
            personId = person.id;
          } else {
            personId = await _db.debtDao.createPerson(
              PersonsCompanion(
                name: drift.Value(contact),
                createdAt: drift.Value(item.date),
              ),
            );
          }

          await _db.debtDao.createDebt(
            DebtsCompanion(
              personId: drift.Value(personId),
              walletId: drift.Value(item.walletId ?? fallbackWalletId),
              type: drift.Value(item.type == 'hutang' ? 'debt' : 'loan'),
              totalAmount: drift.Value(item.amount),
              paidAmount: const drift.Value(0),
              status: const drift.Value('pending'),
              description: drift.Value(item.noteController.text.trim()),
              createdAt: drift.Value(item.date),
            ),
          );
        } else if (item.feature == 'penyesuaian_saldo') {
          final walletId = item.walletId ?? fallbackWalletId;
          final targetWallet = _wallets.where((w) => w.id == walletId).firstOrNull;
          final currentBal = targetWallet?.currentBalance ?? 0.0;
          final targetBal = item.amount;
          final diff = targetBal - currentBal;

          if (diff != 0) {
            final isIncome = diff > 0;
            final absDiff = diff.abs();
            final adjType = isIncome ? 'income' : 'expense';
            final category = await _db.categoryDao.getOrCreateAdjustmentCategory(adjType);

            final noteText = item.noteController.text.trim();
            final descriptionText = noteText.isNotEmpty
                ? noteText
                : (isIncome ? 'Penyesuaian Masuk' : 'Penyesuaian Keluar');

            final walletName = targetWallet?.name ?? 'Dompet';
            final detailedNote = 'Penyesuaian saldo $walletName dari Rp ${_currencyFormat.format(currentBal).replaceAll('Rp ', '')} ke Rp ${_currencyFormat.format(targetBal).replaceAll('Rp ', '')}${noteText.isNotEmpty ? ' ($noteText)' : ''}';

            await _db.transactionDao.createTransaction(
              TransactionsCompanion(
                walletId: drift.Value(walletId),
                categoryId: drift.Value(category.id),
                amount: drift.Value(absDiff),
                type: drift.Value(adjType),
                description: drift.Value(descriptionText),
                note: drift.Value(detailedNote),
                transactionDate: drift.Value(item.date),
              ),
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_items.length} transaksi berhasil disimpan ke Saku!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan transaksi: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Impor dari ${widget.sourceName}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'AI Smart',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: [
                    // Banner keterangan
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: colorScheme.primary, size: 20.r),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Ditemukan ${_items.length} item transaksi. Silakan periksa rincian di bawah sebelum disimpan.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List items
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        itemCount: _items.length,
                        separatorBuilder: (context, index) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          return _buildTransactionCard(context, index);
                        },
                      ),
                    ),

                    // Bottom bar
                    _buildBottomBar(context),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64.r, color: Colors.grey),
          SizedBox(height: 12.h),
          Text(
            'Tidak ada transaksi yang terdeteksi',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Pastikan konten yang dibagikan memiliki nominal atau rincian transaksi.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, int index) {
    final item = _items[index];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color badgeColor;
    String typeLabel;
    IconData typeIcon;

    if (item.feature == 'transfer') {
      badgeColor = Colors.blue.shade600;
      typeLabel = 'Transfer Dompet';
      typeIcon = Icons.swap_horiz_rounded;
    } else if (item.feature == 'penyesuaian_saldo') {
      badgeColor = const Color(0xFF0D9488);
      typeLabel = 'Ngepasin Saldo (Penyesuaian)';
      typeIcon = Icons.tune_rounded;
    } else if (item.feature == 'hutang_piutang') {
      if (item.type == 'hutang') {
        badgeColor = Colors.orange.shade700;
        typeLabel = 'Hutang (Saya Pinjam)';
        typeIcon = Icons.arrow_upward_rounded;
      } else {
        badgeColor = Colors.purple.shade600;
        typeLabel = 'Piutang (Meminjamkan)';
        typeIcon = Icons.arrow_downward_rounded;
      }
    } else {
      if (item.type == 'income') {
        badgeColor = Colors.green.shade600;
        typeLabel = 'Pemasukan';
        typeIcon = Icons.trending_up_rounded;
      } else {
        badgeColor = Colors.red.shade600;
        typeLabel = 'Pengeluaran';
        typeIcon = Icons.trending_down_rounded;
      }
    }

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Header Card: Badge Tipe & Tombol Hapus ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(typeIcon, color: badgeColor, size: 16.r),
                      SizedBox(width: 6.w),
                      Text(
                        typeLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus Item',
                  icon: Icon(Icons.delete_outline_rounded, color: Colors.grey.shade500, size: 22.r),
                  onPressed: () {
                    setState(() {
                      final removed = _items.removeAt(index);
                      removed.dispose();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // ── 2. Catatan / Deskripsi (Full Width) ───────────────────────────
            TextFormField(
              controller: item.noteController,
              decoration: InputDecoration(
                labelText: item.feature == 'penyesuaian_saldo' ? 'Catatan Penyesuaian' : 'Catatan Transaksi',
                hintText: item.feature == 'penyesuaian_saldo' ? 'Contoh: Penyesuaian saldo riil BNI' : 'Contoh: Bensin, Mi ayam',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
              onChanged: (val) {
                item.note = val;
              },
            ),
            SizedBox(height: 12.h),

            // ── 3. Nominal (Full Width) ───────────────────────────────────────
            TextFormField(
              controller: item.amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: item.feature == 'penyesuaian_saldo' ? 'Target Saldo Riil' : 'Nominal Transaksi',
                hintText: '0',
                prefixIcon: Icon(item.feature == 'penyesuaian_saldo' ? Icons.account_balance_wallet_outlined : Icons.payments_outlined),
                prefixText: 'Rp ',
                prefixStyle: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
              onChanged: (val) {
                final cleanVal = val.replaceAll('.', '').replaceAll(',', '');
                item.amount = double.tryParse(cleanVal) ?? 0;
                setState(() {});
              },
            ),
            SizedBox(height: 12.h),

            // ── 4. Tanggal Transaksi (Full Width Interactive Selector) ────────
            _buildDateSelectorField(item),
            SizedBox(height: 12.h),

            // ── 5. Dropdowns Kategori & Dompet ────────────────────────────────
            if (item.feature == 'transaksi') ...[
              // Kategori Selector (Full Width with Icon)
              _buildCategorySelectorField(item),
              SizedBox(height: 12.h),

              // Dompet Sumber Selector (Full Width with Icon & Saldo)
              _buildWalletSelectorField(
                label: 'Dompet Sumber',
                selectedId: item.walletId,
                onSelected: (val) {
                  setState(() {
                    item.walletId = val;
                  });
                },
              ),
            ] else if (item.feature == 'penyesuaian_saldo') ...[
              // Dompet yang Disesuaikan Selector
              _buildWalletSelectorField(
                label: 'Dompet yang Disesuaikan',
                selectedId: item.walletId,
                accentColor: const Color(0xFF0D9488),
                onSelected: (val) {
                  setState(() {
                    item.walletId = val;
                  });
                },
              ),
              SizedBox(height: 12.h),

              // Preview Perbandingan Saldo & Selisih Live
              _buildAdjustmentBalanceCard(item),
            ] else if (item.feature == 'transfer') ...[
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    // Dari Dompet (Sumber)
                    _buildWalletSelectorField(
                      label: 'Sumber Dana (Dari)',
                      selectedId: item.walletId,
                      accentColor: colorScheme.primary,
                      onSelected: (val) {
                        setState(() {
                          item.walletId = val;
                        });
                      },
                    ),
                    SizedBox(height: 10.h),

                    // Swap Button
                    Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            final temp = item.walletId;
                            item.walletId = item.toWalletId;
                            item.toWalletId = temp;
                          });
                        },
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.swap_vert_rounded, color: colorScheme.primary, size: 20.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Ke Dompet (Penerima)
                    _buildWalletSelectorField(
                      label: 'Penerima Transfer (Ke)',
                      selectedId: item.toWalletId,
                      accentColor: Colors.green.shade700,
                      onSelected: (val) {
                        setState(() {
                          item.toWalletId = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ] else if (item.feature == 'hutang_piutang') ...[
              // Nama Kontak
              TextFormField(
                controller: item.contactController,
                decoration: InputDecoration(
                  labelText: 'Nama Kontak / Pihak',
                  hintText: 'Contoh: Budi, Andi',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                onChanged: (val) {
                  item.contactName = val;
                },
              ),
              SizedBox(height: 12.h),

              // Dompet Terkait
              _buildWalletSelectorField(
                label: 'Dompet Sumber / Terkait',
                selectedId: item.walletId,
                onSelected: (val) {
                  setState(() {
                    item.walletId = val;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildAdjustmentBalanceCard(EditableIntentItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final targetWallet = _wallets.where((w) => w.id == item.walletId).firstOrNull;
    final currentBal = targetWallet?.currentBalance ?? 0.0;
    final targetBal = item.amount;
    final diff = targetBal - currentBal;

    final isIncome = diff > 0;
    final isExact = diff == 0;

    final Color deltaColor = isExact
        ? Colors.grey.shade600
        : (isIncome ? Colors.green.shade700 : Colors.red.shade700);

    final String deltaText = isExact
        ? 'Saldo sudah sesuai (Rp 0)'
        : (isIncome
            ? '+ ${_currencyFormat.format(diff)} (Pendapatan Penyesuaian)'
            : '- ${_currencyFormat.format(-diff)} (Pengeluaran Penyesuaian)');

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: const Color(0xFF0D9488), size: 18.r),
              SizedBox(width: 8.w),
              Text(
                'Perhitungan Otomatis Saku',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF0D9488),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo di Aplikasi:',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              Text(
                _currencyFormat.format(currentBal),
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Saldo Riil:',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              Text(
                _currencyFormat.format(targetBal),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D9488),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Akan dicatat sebagai:',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Flexible(
                child: Text(
                  deltaText,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: deltaColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectorField(EditableIntentItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(item.date);
    final relativeBadge = _formatRelativeDate(item.date);

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: item.date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          locale: const Locale('id', 'ID'),
        );
        if (picked != null) {
          setState(() {
            item.date = DateTime(
              picked.year,
              picked.month,
              picked.day,
              item.date.hour,
              item.date.minute,
              item.date.second,
            );
          });
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.calendar_today_rounded,
                color: colorScheme.primary,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Transaksi',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          formattedDate,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (relativeBadge.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            relativeBadge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_calendar_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return 'Hari Ini';
    if (diffDays == -1) return 'Kemarin';
    if (diffDays == -2) return 'Kemarin Lusa';
    if (diffDays == 1) return 'Besok';
    if (diffDays == 2) return 'Lusa';
    if (diffDays < -2 && diffDays >= -7) return '${diffDays.abs()} hari lalu';
    if (diffDays > 2 && diffDays <= 7) return '$diffDays hari lagi';
    if (diffDays < -7 && diffDays >= -31) return '${(diffDays.abs() / 7).round()} minggu lalu';
    if (diffDays < -31 && diffDays >= -365) return '${(diffDays.abs() / 30).round()} bulan lalu';
    if (diffDays < -365) return '${(diffDays.abs() / 365).round()} tahun lalu';
    return '';
  }

  Widget _buildCategorySelectorField(EditableIntentItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCategory = _categories.where((c) => c.id == item.categoryId).firstOrNull;
    final catColor = selectedCategory != null ? Color(selectedCategory.iconColor) : colorScheme.primary;

    return InkWell(
      onTap: () => _showCategoryPicker(item),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: CategoryIcon(
                iconName: selectedCategory?.icon ?? 'category',
                color: catColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori Transaksi',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    selectedCategory?.name ?? 'Pilih Kategori',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSelectorField({
    required String label,
    required int? selectedId,
    required ValueChanged<int> onSelected,
    Color? accentColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedWallet = _wallets.where((w) => w.id == selectedId).firstOrNull;
    final wColor = selectedWallet != null ? Color(selectedWallet.iconColor) : (accentColor ?? colorScheme.primary);

    return InkWell(
      onTap: () => _showWalletPicker(
        title: label,
        selectedId: selectedId,
        onSelected: onSelected,
      ),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: wColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: CategoryIcon(
                iconName: selectedWallet?.icon ?? 'bank',
                color: wColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accentColor ?? colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: accentColor != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          selectedWallet?.name ?? 'Pilih Dompet',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (selectedWallet != null) ...[
                        SizedBox(width: 6.w),
                        Text(
                          '(${_currencyFormat.format(selectedWallet.currentBalance)})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(EditableIntentItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final relevantCategories = _categories.where((c) => c.type == item.type).toList();
    final categoriesToShow = relevantCategories.isNotEmpty ? relevantCategories : _categories;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 12.h),

              // Title Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.type == 'income' ? 'Pilih Kategori Pemasukan' : 'Pilih Kategori Pengeluaran',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Category List
              Flexible(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  itemCount: categoriesToShow.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (ctx, idx) {
                    final cat = categoriesToShow[idx];
                    final catColor = Color(cat.iconColor);
                    final isSelected = item.categoryId == cat.id;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            item.categoryId = cat.id;
                            item.category = cat.name;
                          });
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withValues(alpha: 0.08)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.15),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                alignment: Alignment.center,
                                child: CategoryIcon(
                                  iconName: cat.icon,
                                  color: catColor,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Text(
                                  cat.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: colorScheme.primary,
                                  size: 22.r,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWalletPicker({
    required String title,
    required int? selectedId,
    required ValueChanged<int> onSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 12.h),

              // Title Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Wallet List
              Flexible(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  itemCount: _wallets.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (ctx, idx) {
                    final wallet = _wallets[idx];
                    final walletColor = Color(wallet.iconColor);
                    final isSelected = selectedId == wallet.id;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onSelected(wallet.id);
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withValues(alpha: 0.08)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.15),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: walletColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                alignment: Alignment.center,
                                child: CategoryIcon(
                                  iconName: wallet.icon,
                                  color: walletColor,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wallet.name,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Saldo: ${_currencyFormat.format(wallet.currentBalance)}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: colorScheme.primary,
                                  size: 22.r,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Tambah Dompet Baru button (Explicit User Action)
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 4.h, bottom: 12.h),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final created = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const AddEditWalletPage()),
                      );
                      if (created == true) {
                        final updated = await _db.walletDao.getAllWallets();
                        setState(() {
                          _wallets = updated;
                          if (updated.isNotEmpty) {
                            onSelected(updated.last.id);
                          }
                        });
                      }
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Buat Rekening Baru'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.15))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Akumulasi',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _currencyFormat.format(_totalAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveAllTransactions,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              icon: _isSaving
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                _isSaving ? 'Menyimpan...' : 'Simpan Transaksi',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
