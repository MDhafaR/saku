import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../settings/presentation/pages/add_edit_wallet_page.dart';

class WalletSelectionPage extends StatefulWidget {
  const WalletSelectionPage({super.key});

  @override
  State<WalletSelectionPage> createState() => _WalletSelectionPageState();
}

class _WalletSelectionPageState extends State<WalletSelectionPage> {
  List<Wallet> _wallets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final db = locator<AppDatabase>();
    final wallets = await db.walletDao.getAllWallets();
    setState(() {
      _wallets = wallets;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.selectWalletTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20.h),

          // Wallet List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _wallets.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 0,
                    ),
                    itemCount: _wallets.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final wallet = _wallets[index];
                      final color = Color(wallet.iconColor);

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context, {
                            'id': wallet.id,
                            'name': wallet.name,
                            'type': wallet.type,
                            'balance': wallet.currentBalance,
                            'iconName': wallet.icon,
                            'color': color,
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                alignment: Alignment.center,
                                child: CategoryIcon(
                                  iconName: wallet.icon,
                                  color: color,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              // Name & Balance
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wallet.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF111111),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Rp ${CurrencyFormatter.format(wallet.currentBalance.toStringAsFixed(0))}',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                size: 22.sp,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditWalletPage()),
          );
          _loadWallets();
        },
        backgroundColor: const Color(0xFF111111),
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.noWalletsYet,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.tapPlusToAddWallet,
            style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}
