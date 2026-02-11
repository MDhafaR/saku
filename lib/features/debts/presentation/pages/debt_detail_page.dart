import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../cubit/debt_cubit.dart';

class DebtDetailPage extends StatefulWidget {
  final Debt debt;
  final String personName;

  const DebtDetailPage({
    super.key,
    required this.debt,
    required this.personName,
  });

  @override
  State<DebtDetailPage> createState() => _DebtDetailPageState();
}

class _DebtDetailPageState extends State<DebtDetailPage> {
  final DebtCubit _cubit = locator<DebtCubit>();
  List<DebtPayment> _payments = [];
  bool _isLoading = true;
  Debt? _debt;

  @override
  void initState() {
    super.initState();
    _debt = widget.debt;
    _loadData();
  }

  Future<void> _loadData() async {
    final debt = await _cubit.getDebt(widget.debt.id);
    final payments = await _cubit.getPayments(widget.debt.id);

    if (mounted) {
      if (debt == null) {
        // Debt might have been deleted
        Navigator.pop(context);
        return;
      }
      setState(() {
        _debt = debt;
        _payments = payments;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data?'),
        content: const Text(
          'Data yang dihapus tidak dapat dikembalikan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.semanticRed),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _cubit.deleteDebt(widget.debt.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleMarkAsPaid(double remaining) async {
    final wallets = await _cubit.getWallets();
    if (wallets.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Belum ada wallet')));
      }
      return;
    }

    Wallet? selectedWallet = wallets.first;

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Konfirmasi Pelunasan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Catat pelunasan sebesar Rp ${_formatPrice(remaining)}?'),
                SizedBox(height: 16.h),
                DropdownButtonFormField<Wallet>(
                  value: selectedWallet,
                  decoration: const InputDecoration(
                    labelText: 'Sumber Dana',
                    border: OutlineInputBorder(),
                  ),
                  items: wallets.map((w) {
                    return DropdownMenuItem(value: w, child: Text(w.name));
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedWallet = val);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Bayar'),
              ),
            ],
          );
        },
      ),
    );

    if (confirm == true && selectedWallet != null) {
      await _cubit.addPayment(
        debtId: widget.debt.id,
        walletId: selectedWallet!.id,
        amount: remaining,
        paymentDate: DateTime.now(),
        note: 'Pelunasan Otomatis',
      );
      _loadData();
    }
  }

  Future<void> _handleUndoPayment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pelunasan?'),
        content: const Text(
          'Pembayaran terakhir akan dihapus dan status akan kembali ke sebelumnya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.semanticRed),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _cubit.deleteLastPayment(widget.debt.id);
      _loadData();
    }
  }

  Future<void> _showPaymentDialog() async {
    final wallets = await _cubit.getWallets();
    if (wallets.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Belum ada wallet')));
      }
      return;
    }

    if (!mounted) return;

    Wallet selectedWallet = wallets.first;
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            20.h,
            20.w,
            MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Catat Pembayaran',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<Wallet>(
                value: selectedWallet,
                decoration: const InputDecoration(
                  labelText: 'Wallet / Akun',
                  border: OutlineInputBorder(),
                ),
                items: wallets.map((w) {
                  return DropdownMenuItem(value: w, child: Text(w.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedWallet = val);
                  }
                },
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) return;

                  await _cubit.addPayment(
                    debtId: widget.debt.id,
                    walletId: selectedWallet.id,
                    amount: amount,
                    paymentDate: DateTime.now(),
                    note: noteController.text,
                  );

                  if (context.mounted) Navigator.pop(context);
                  _loadData(); // Refresh history
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final debt = _debt ?? widget.debt;
    final remaining = debt.totalAmount - debt.paidAmount;
    final percentPaid = debt.totalAmount > 0
        ? (debt.paidAmount / debt.totalAmount).clamp(0.0, 1.0)
        : 0.0;

    // Status text logic
    String statusText = 'Pending';
    Color statusColor = AppTheme.primaryBlue;
    Color statusBg = const Color(0xFFEFF6FF);

    if (debt.status == 'paid') {
      statusText = 'Lunas';
      statusColor = AppTheme.semanticGreen;
      statusBg = const Color(0xFFECFDF5);
    } else if (debt.dueDate != null) {
      final now = DateTime.now();
      final diff = debt.dueDate!.difference(now).inDays;
      if (diff < 0) {
        statusText = 'Terlambat ${diff.abs()} Hari';
        statusColor = AppTheme.semanticRed;
        statusBg = const Color(0xFFFFF0F0);
      } else if (diff <= 7) {
        statusText =
            'Jatuh Tempo ${diff == 0 ? "Hari Ini" : "$diff Hari Lagi"}';
        statusColor = const Color(0xFFF59E0B);
        statusBg = const Color(0xFFFFFBEB);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          debt.type == 'debt' ? 'Detail Utang' : 'Detail Piutang',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Profile Header Section
                SakuCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getAvatarBackgroundColor(
                                widget.personName,
                              ).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(widget.personName),
                                style: TextStyle(
                                  color: _getAvatarBackgroundColor(
                                    widget.personName,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.personName,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sisa Tagihan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${_formatPrice(remaining)}',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${_formatPrice(debt.totalAmount)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Progress Card
                SakuCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status Pelunasan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          InkWell(
                            onTap: percentPaid >= 1.0
                                ? _handleUndoPayment
                                : () => _handleMarkAsPaid(remaining),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: percentPaid >= 1.0
                                    ? const Color(0xFFFFFBEB)
                                    : AppTheme.semanticGreen.withValues(
                                        alpha: 0.1,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: percentPaid >= 1.0
                                    ? Border.all(color: Colors.orange)
                                    : Border.all(color: AppTheme.semanticGreen),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    percentPaid >= 1.0
                                        ? Icons.undo
                                        : Icons.check_circle,
                                    size: 14,
                                    color: percentPaid >= 1.0
                                        ? Colors.orange
                                        : AppTheme.semanticGreen,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    percentPaid >= 1.0
                                        ? 'Batalkan'
                                        : 'Tandai Lunas',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: percentPaid >= 1.0
                                          ? Colors.orange
                                          : AppTheme.semanticGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percentPaid,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.semanticGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(percentPaid * 100).toInt()}% Terbayar',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.semanticGreen,
                            ),
                          ),
                          Text(
                            'Sisa ${(100 - (percentPaid * 100)).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Call Button
                    _buildActionButton(
                      icon: Icons.call,
                      color: AppTheme.semanticGreen,
                      label: 'Hubungi',
                      bgColor: const Color(0xFFECFDF5),
                      onTap: () {}, // TODO: Implement call
                    ),

                    // Delete Button
                    _buildActionButton(
                      icon: Icons.delete,
                      color: AppTheme.semanticRed,
                      label: 'Hapus',
                      bgColor: const Color(0xFFFFF0F0),
                      onTap: _handleDelete,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // History Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Riwayat Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_payments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Belum ada pembayaran',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                else
                  ..._payments.map(
                    (payment) => _buildHistoryItem(
                      title: payment.note ?? 'Pembayaran',
                      date: intl.DateFormat(
                        'dd MMM yyyy',
                      ).format(payment.paymentDate),
                      amount: '+Rp ${_formatPrice(payment.amount)}',
                      isSuccess: true,
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Button (Only show if not fully paid)
          if (debt.status != 'paid')
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFFAFAFA),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _showPaymentDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Catat Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String date,
    required String amount,
    bool isSuccess = false,
  }) {
    return SakuCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSuccess
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.payments_outlined,
              color: isSuccess
                  ? AppTheme.semanticGreen
                  : const Color(0xFF6B7280),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.semanticGreen,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return CurrencyFormatter.format(price.toStringAsFixed(0));
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getAvatarBackgroundColor(String name) {
    final colors = [
      const Color(0xFF6366F1), // Purple
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFFEC4899), // Pink
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}
