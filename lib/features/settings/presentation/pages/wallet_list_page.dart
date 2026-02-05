import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../domain/entities/account.dart';
import '../../widgets/account_card.dart';
import 'wallet_detail_page.dart';

class WalletListPage extends StatelessWidget {
  final List<Account> accounts;
  final Function(Account) onAccountUpdate;

  const WalletListPage({
    super.key,
    required this.accounts,
    required this.onAccountUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'My Wallets',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: accounts
              .map(
                (account) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WalletDetailPage(
                          account: account,
                          onUpdate: onAccountUpdate,
                        ),
                      ),
                    );
                  },
                  child: Opacity(
                    opacity: account.isHidden ? 0.6 : 1.0,
                    child: AccountCard(account: account),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
