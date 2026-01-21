import 'package:flutter/material.dart';
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
        title: const Text(
          'My Wallets',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
