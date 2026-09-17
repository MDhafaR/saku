import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../core/services/saku_home_widget_service.dart';
import '../../../../data/local/database/app_database.dart';
import '../../widgets/account_card.dart';
import '../../widgets/spending_planner_card.dart';
import 'add_edit_wallet_page.dart';
import 'wallet_detail_page.dart';

class WalletListPage extends StatefulWidget {
  const WalletListPage({super.key});

  @override
  State<WalletListPage> createState() => _WalletListPageState();
}

class _WalletListPageState extends State<WalletListPage> {
  late final Stream<List<Wallet>> _walletsStream;
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = locator<AppDatabase>();
    _walletsStream = _db.walletDao.watchAllWallets();
  }

  void _onReorder(List<Wallet> wallets, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = wallets.removeAt(oldIndex);
    wallets.insert(newIndex, item);

    // Update database sortOrder
    await _db.walletDao.updateWalletOrder(wallets);
    await SakuHomeWidgetService.updateWalletsWidget(wallets);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Wallets',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditWalletPage()),
          );
        },
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Wallet>>(
        stream: _walletsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                    SizedBox(height: 12.h),
                    Text(
                      'Perlu Hot Restart aplikasi setelah pembaruan database.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final wallets = List<Wallet>.from(snapshot.data ?? []);

          if (wallets.isEmpty) {
            return _buildEmptyState();
          }

          final totalBalance = wallets.fold<double>(
            0.0,
            (sum, w) => sum + (w.isHidden ? 0.0 : w.currentBalance),
          );

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h),
                child: SpendingPlannerCard(
                  totalBalance: totalBalance,
                  onTargetUpdated: () {
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 4.h,
                    bottom: 88.h,
                  ),
                  itemCount: wallets.length,
                  onReorder: (oldIndex, newIndex) =>
                      _onReorder(wallets, oldIndex, newIndex),
                  proxyDecorator: (child, index, animation) {
                    final double animValue = Curves.easeInOut.transform(
                      animation.value,
                    );
                    final double elevation = lerpDouble(0, 8, animValue)!;
                    return Material(
                      elevation: elevation,
                      borderRadius: BorderRadius.circular(12.r),
                      shadowColor: Colors.black.withValues(alpha: 0.35),
                      color: Colors.transparent,
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final wallet = wallets[index];
                    return Container(
                      key: ValueKey('wallet_${wallet.id}'),
                      margin: EdgeInsets.only(bottom: 6.h),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WalletDetailPage(wallet: wallet),
                            ),
                          );
                        },
                        child: Opacity(
                          opacity: wallet.isHidden ? 0.6 : 1.0,
                          child: AccountCard(
                            wallet: wallet,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 12.sp,
                                ),
                                SizedBox(width: 12.w),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 6.h,
                                    ),
                                    child: Icon(
                                      Icons.drag_handle_rounded,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.35,
                                      ),
                                      size: 22.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 72.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          SizedBox(height: 16.h),
          Text(
            'Belum ada wallet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Tambahkan wallet pertamamu dengan menekan tombol + di bawah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
