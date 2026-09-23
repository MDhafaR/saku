import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Kamus dan Pengelola Lokalisasi Aplikasi Saku (Bahasa Indonesia & English).
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('id'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isIndonesian => locale.languageCode == 'id';
  String get dateLocaleCode => isIndonesian ? 'id' : 'en';

  // ── 1. Navigasi Bawah & Header Utama ──────────────────────────────────────
  String get navHome => isIndonesian ? 'Beranda' : 'Home';
  String get navTransactions => isIndonesian ? 'Transaksi' : 'Transactions';
  String get navDebts => isIndonesian ? 'Hutang' : 'Debts';
  String get navStatistics => isIndonesian ? 'Statistik' : 'Statistics';
  String get navSettings => isIndonesian ? 'Pengaturan' : 'Settings';

  // ── 2. Beranda / Dashboard ───────────────────────────────────────────────
  String get totalBalance => isIndonesian ? 'Total Saldo' : 'Total Balance';
  String get totalIncome => isIndonesian ? 'Pemasukan' : 'Income';
  String get totalExpense => isIndonesian ? 'Pengeluaran' : 'Expense';
  String get myWallets => isIndonesian ? 'Dompet Saya' : 'My Wallets';
  String get manageWallets => isIndonesian ? 'Kelola' : 'Manage';
  String get recentTransactions => isIndonesian ? 'Transaksi Terakhir' : 'Recent Transactions';
  String get seeAll => isIndonesian ? 'Lihat Semua' : 'See All';
  String get noTransactionsYet => isIndonesian ? 'Belum ada transaksi' : 'No transactions yet';
  String get noTransactionsSubtitle => isIndonesian
      ? 'Catat pengeluaran dan pemasukan Anda sekarang'
      : 'Start tracking your income and expenses now';
  String get today => isIndonesian ? 'Hari Ini' : 'Today';
  String get yesterday => isIndonesian ? 'Kemarin' : 'Yesterday';
  String get daysAgo => isIndonesian ? 'hari lalu' : 'days ago';
  String get netCashflow => isIndonesian ? 'Arus Kas Bersih' : 'Net Cash Flow';
  String selectedCount(int count) => isIndonesian ? '$count dipilih' : '$count selected';
  String get selectedTotal => isIndonesian ? 'Total Terpilih' : 'Selected Total';
  String get clearSelection => isIndonesian ? 'Batal' : 'Clear';

  // ── 3. Aksi Cepat / FAB ──────────────────────────────────────────────────
  String get quickRecordExpense => isIndonesian ? 'Catat Pengeluaran' : 'Add Expense';
  String get quickRecordIncome => isIndonesian ? 'Catat Pemasukan' : 'Add Income';
  String get quickTransfer => isIndonesian ? 'Pindah Buku' : 'Transfer';
  String get quickAdjustBalance => isIndonesian ? 'Ngepasin Saldo' : 'Adjust Balance';
  String get quickDebtLoan => isIndonesian ? 'Hutang / Piutang' : 'Debt / Loan';
  String get minWalletWarningTitle => isIndonesian ? 'Dompet Tidak Cukup' : 'Not Enough Wallets';
  String get minWalletTransferWarning => isIndonesian
      ? 'Anda membutuhkan minimal 2 dompet untuk melakukan transfer.'
      : 'You need at least 2 wallets to perform a transfer.';
  String get minWalletAdjustWarning => isIndonesian
      ? 'Anda membutuhkan minimal 1 dompet untuk melakukan penyesuaian saldo.'
      : 'You need at least 1 wallet to perform balance adjustment.';

  // ── 4. Form Transaksi (AddTransactionPage) ───────────────────────────────
  String get addTransactionTitle => isIndonesian ? 'Catat Transaksi' : 'Add Transaction';
  String get editTransactionTitle => isIndonesian ? 'Ubah Transaksi' : 'Edit Transaction';
  String get typeExpense => isIndonesian ? 'Pengeluaran' : 'Expense';
  String get typeIncome => isIndonesian ? 'Pemasukan' : 'Income';
  String get enterAmount => isIndonesian ? 'Masukkan Jumlah' : 'Enter Amount';
  String get amountLabel => isIndonesian ? 'Jumlah Nominal' : 'Amount';
  String get noteLabel => isIndonesian ? 'Catatan' : 'Note';
  String get noteOptionalHint => isIndonesian ? 'Tulis catatan (opsional)...' : 'Write a note (optional)...';
  String get categoryLabel => isIndonesian ? 'Kategori' : 'Category';
  String get selectCategory => isIndonesian ? 'Pilih Kategori' : 'Select Category';
  String get walletLabel => isIndonesian ? 'Dompet' : 'Wallet';
  String get selectWallet => isIndonesian ? 'Pilih Dompet' : 'Select Wallet';
  String get dateLabel => isIndonesian ? 'Tanggal' : 'Date';
  String get timeLabel => isIndonesian ? 'Waktu' : 'Time';
  String get saveButton => isIndonesian ? 'Simpan' : 'Save';
  String get saveChangesButton => isIndonesian ? 'Simpan Perubahan' : 'Save Changes';
  String get deleteTransactionConfirm => isIndonesian
      ? 'Apakah Anda yakin ingin menghapus transaksi ini?'
      : 'Are you sure you want to delete this transaction?';
  String get deleteTransferConfirm => isIndonesian
      ? 'Apakah Anda yakin ingin menghapus transfer ini?'
      : 'Are you sure you want to delete this transfer?';
  String get fillRequiredFields => isIndonesian
      ? 'Mohon lengkapi nominal dan kategori'
      : 'Please complete the amount and category';
  String get categoryRequired => isIndonesian ? 'Kategori wajib dipilih' : 'Category is required';
  String get walletRequired => isIndonesian ? 'Dompet wajib dipilih' : 'Wallet is required';
  String get amountRequired => isIndonesian ? 'Nominal transaksi wajib diisi' : 'Amount is required';
  String get requiredBadge => isIndonesian ? 'Wajib' : 'Required';

  // ── 5. Form Pindah Buku / Transfer (TransferPage) ─────────────────────────
  String get transferTitle => isIndonesian ? 'Pindah Buku' : 'Transfer';
  String get sourceWalletLabel => isIndonesian ? 'Sumber Dana (Dari)' : 'Source Wallet (From)';
  String get destinationWalletLabel => isIndonesian ? 'Penerima Transfer (Ke)' : 'Destination Wallet (To)';
  String get fromAccount => isIndonesian ? 'Dari Rekening' : 'From Account';
  String get toAccount => isIndonesian ? 'Ke Rekening' : 'To Account';
  String get totalAssets => isIndonesian ? 'Total Aset' : 'Total Assets';
  String get transferAmountLabel => isIndonesian ? 'Nominal Transfer' : 'Transfer Amount';
  String get adminFeeLabel => isIndonesian ? 'Biaya Admin' : 'Admin Fee';
  String get freeAdminFee => isIndonesian ? 'Gratis' : 'Free';
  String get customAdminFee => isIndonesian ? 'Kustom' : 'Custom';
  String get writeTransferNoteHint => isIndonesian
      ? 'Tulis catatan transfer, keperluan, atau keterangan di sini...'
      : 'Write transfer note, purpose, or remarks here...';
  String get transferNowButton => isIndonesian ? 'Transfer Sekarang' : 'Transfer Now';
  String get sameWalletError => isIndonesian
      ? 'Dompet asal dan tujuan tidak boleh sama'
      : 'Source and destination wallets cannot be the same';
  String get minTransferAmountError => isIndonesian
      ? 'Nominal transfer harus lebih dari 0'
      : 'Transfer amount must be greater than 0';

  // ── 6. Form Ngepasin Saldo (AdjustBalancePage) ────────────────────────────
  String get adjustBalanceTitle => isIndonesian ? 'Ngepasin Saldo' : 'Adjust Balance';
  String get adjustBalanceHeaderDesc => isIndonesian
      ? 'Sesuaikan saldo di aplikasi agar sama persis dengan uang fisik atau saldo rekening sebenarnya.'
      : 'Reconcile app balance to match your actual physical cash or bank balance.';
  String get selectAccountToAdjust => isIndonesian ? 'Pilih Rekening' : 'Select Account';
  String get realBalanceLabel => isIndonesian ? 'Saldo Riil Seharusnya' : 'Actual Real Balance';
  String get realBalancePhysical => isIndonesian ? 'Saldo Riil Sebenarnya' : 'Actual Real Balance';
  String get appBalanceLabel => isIndonesian ? 'Saldo di Aplikasi' : 'App Balance';
  String get recordedBalance => isIndonesian ? 'Saldo Tercatat di Saku' : 'Recorded Balance in Saku';
  String get differenceLabel => isIndonesian ? 'Selisih' : 'Difference';
  String get adjustmentIncome => isIndonesian ? 'Pendapatan Penyesuaian' : 'Adjustment Income';
  String get adjustmentExpense => isIndonesian ? 'Pengeluaran Penyesuaian' : 'Adjustment Expense';
  String get balanceAlreadyExact => isIndonesian ? 'Saldo sudah pas' : 'Balance is already exact';
  String get balanceExactDesc => isIndonesian
      ? 'Saldo fisik sudah sama dengan saldo aplikasi. Tidak ada mutasi baru yang perlu dicatat.'
      : 'Physical balance matches app balance. No new transaction needed.';
  String get defaultAdjustmentNote => isIndonesian
      ? 'Penyesuaian saldo riil'
      : 'Real balance adjustment';
  String get saveAdjustmentButton => isIndonesian ? 'Simpan Penyesuaian' : 'Save Adjustment';
  String get adjustmentSuccess => isIndonesian
      ? 'Saldo berhasil disesuaikan'
      : 'Balance adjusted successfully';
  String get noAdjustmentNeeded => isIndonesian
      ? 'Saldo sudah pas, tidak ada penyesuaian yang perlu disimpan'
      : 'Balance is already exact, no adjustment needed';
  String balanceAdjustedSuccess(String walletName, String amount) => isIndonesian
      ? 'Saldo $walletName berhasil disesuaikan ($amount)'
      : '$walletName balance adjusted successfully ($amount)';
  String get changeWallet => isIndonesian ? 'Ganti Rekening' : 'Change Wallet';
  String get actualBalance => isIndonesian ? 'Saldo Riil Sebenarnya' : 'Actual Real Balance';
  String get physicalBankMoney => isIndonesian ? 'Uang Fisik / Bank' : 'Physical Cash / Bank';
  String get adjustIncome => isIndonesian ? 'Pendapatan Penyesuaian' : 'Adjustment Income';
  String adjustIncomeDesc(String amount) => isIndonesian
      ? 'Saldo riil lebih besar $amount dari aplikasi. Akan dicatat sebagai pemasukan penyesuaian.'
      : 'Actual balance is $amount higher than app. Will be recorded as adjustment income.';
  String get adjustExpense => isIndonesian ? 'Pengeluaran Penyesuaian' : 'Adjustment Expense';
  String adjustExpenseDesc(String amount) => isIndonesian
      ? 'Saldo riil lebih kecil $amount dari aplikasi. Akan dicatat sebagai pengeluaran penyesuaian.'
      : 'Actual balance is $amount lower than app. Will be recorded as adjustment expense.';
  String get balanceMatched => isIndonesian ? 'Saldo Sudah Pas' : 'Balance Matches';
  String get balanceMatchedDesc => isIndonesian
      ? 'Saldo fisik sama persis dengan saldo aplikasi. Tidak ada mutasi baru.'
      : 'Physical balance matches app balance. No new transaction needed.';
  String get noteOptional => isIndonesian ? 'Catatan (Opsional)' : 'Note (Optional)';
  String get saveAdjustment => isIndonesian ? 'Simpan Penyesuaian' : 'Save Adjustment';

  // ── 7. Hutang & Piutang (Debts & Loans) ───────────────────────────────────
  String get debtsAndLoansTitle => isIndonesian ? 'Hutang & Piutang' : 'Debts & Loans';
  String get tabIDebt => isIndonesian ? 'Saya Hutang' : 'I Owe (Debt)';
  String get tabILoan => isIndonesian ? 'Pinjamkan' : 'Lent (Loan)';
  String get iOwe => isIndonesian ? 'Saya Hutang' : 'I Owe (Debt)';
  String get iLend => isIndonesian ? 'Pinjamkan' : 'I Lend (Loan)';
  String get completeDataError => isIndonesian
      ? 'Mohon lengkapi nominal dan nama kontak'
      : 'Please complete the amount and contact name';
  String get nominalAmount => isIndonesian ? 'Jumlah Nominal' : 'Amount';
  String get transactionDateLabel => isIndonesian ? 'Tanggal Transaksi' : 'Transaction Date';
  String get contactLabel => isIndonesian ? 'Kontak / Pihak' : 'Contact / Person';
  String get enterContactNameHint => isIndonesian ? 'Masukkan nama kontak' : 'Enter contact name';
  String get noDueDate => isIndonesian ? 'Tidak Ada' : 'None';
  String get writeNoteHint => isIndonesian ? 'Tulis catatan...' : 'Write a note...';
  String get accountWalletLabel => isIndonesian ? 'Rekening / Dompet' : 'Account / Wallet';
  String get totalDebtRemaining => isIndonesian ? 'Total Sisa Hutang' : 'Total Debt Remaining';
  String get totalLoanRemaining => isIndonesian ? 'Total Sisa Piutang' : 'Total Loan Remaining';
  String get addDebtTitle => isIndonesian ? 'Catat Hutang' : 'Add Debt';
  String get addLoanTitle => isIndonesian ? 'Catat Pinjaman' : 'Add Loan';
  String get personNameLabel => isIndonesian ? 'Nama Kontak / Pihak' : 'Contact / Person Name';
  String get personNameHint => isIndonesian ? 'Contoh: Budi, Andi' : 'e.g. Budi, Andi';
  String get loanDateLabel => isIndonesian ? 'Tanggal Pinjam' : 'Loan Date';
  String get dueDateLabel => isIndonesian ? 'Jatuh Tempo' : 'Due Date';
  String get dueDateOptional => isIndonesian ? 'Jatuh Tempo (Opsional)' : 'Due Date (Optional)';
  String get unlimited => isIndonesian ? 'Tidak Ada' : 'None';
  String get statusPending => isIndonesian ? 'Belum Lunas' : 'Unpaid';
  String get statusPaid => isIndonesian ? 'Lunas' : 'Paid';
  String get markAsPaid => isIndonesian ? 'Tandai Lunas' : 'Mark as Paid';
  String get recordPayment => isIndonesian ? 'Bayar Cicilan' : 'Record Payment';
  String get noDebtsYet => isIndonesian ? 'Belum ada catatan hutang' : 'No debt records yet';
  String get noLoansYet => isIndonesian ? 'Belum ada catatan piutang' : 'No loan records yet';
  String get saveLoanButton => isIndonesian ? 'Simpan Catatan' : 'Save Record';

  // ── 8. Statistik & Analisis ──────────────────────────────────────────────
  String get statisticsTitle => isIndonesian ? 'Statistik Keuangan' : 'Financial Statistics';
  String get periodAll => isIndonesian ? 'Semua' : 'All';
  String get periodDaily => isIndonesian ? 'Harian' : 'Daily';
  String get periodWeekly => isIndonesian ? 'Mingguan' : 'Weekly';
  String get periodMonthly => isIndonesian ? 'Bulanan' : 'Monthly';
  String get periodYearly => isIndonesian ? 'Tahunan' : 'Yearly';
  String get periodCustom => isIndonesian ? 'Kustom' : 'Custom';
  String get allTimeHistory => isIndonesian ? 'Semua Waktu' : 'All Time';
  String get allTimeHistoryDesc => isIndonesian ? 'Semua riwayat mutasi keuangan' : 'All financial mutation history';
  String get selectDateRangeTitle => isIndonesian ? 'Pilih Rentang Tanggal' : 'Select Date Range';
  String get customDateRange => isIndonesian ? 'Rentang Waktu' : 'Date Range';

  String get incomeVsExpense => isIndonesian ? 'Income vs Expense' : 'Income vs Expense';
  String get categoryBreakdown => isIndonesian ? 'Category Breakdown' : 'Category Breakdown';
  String get viewDetails => isIndonesian ? 'Lihat Rincian' : 'View Details';
  String get topCategories => isIndonesian ? 'Top Categories' : 'Top Categories';
  String get netCashFlow => isIndonesian ? 'Arus Kas Bersih' : 'Net Cash Flow';
  String get cashFlowTrend => isIndonesian ? 'Tren Arus Kas' : 'Cash Flow Trend';
  String get cashFlowTitle => isIndonesian ? 'Arus Kas' : 'Cash Flow';
  String get chartLine => isIndonesian ? 'Garis' : 'Line';
  String get chartBar => isIndonesian ? 'Batang' : 'Bar';
  String get categoryDistribution => isIndonesian ? 'Distribusi Kategori' : 'Category Distribution';
  String get spendingByCategory => isIndonesian ? 'Pengeluaran per Kategori' : 'Spending by Category';
  String get incomeByCategory => isIndonesian ? 'Pemasukan per Kategori' : 'Income by Category';
  String get topExpenses => isIndonesian ? 'Pengeluaran Terbesar' : 'Top Expenses';
  String get seeCategoryDetails => isIndonesian ? 'Lihat Rincian' : 'View Details';
  String get noChartData => isIndonesian ? 'Belum ada data pada periode ini' : 'No data in this period';
  String get noCategoriesRecorded => isIndonesian ? 'Belum ada kategori tercatat' : 'No categories recorded';
  String get noDataAvailable => isIndonesian ? 'Belum ada data' : 'No data available';
  String get noComparisonData => isIndonesian ? 'Tidak ada data komparasi' : 'No comparison data';

  // Rincian Kategori (CategoryDetailPage & CategoryDetailCard)
  String get categoryDetailTitle => isIndonesian ? 'Rincian Kategori' : 'Category Details';
  String get categoryDetailsTitle => isIndonesian ? 'Rincian Kategori' : 'Category Details';
  String get expenseComparison => isIndonesian ? 'Komparasi Pengeluaran' : 'Expense Comparison';
  String get top3LargestTransactions => isIndonesian ? 'Top 3 Transaksi Terbesar' : 'Top 3 Largest Transactions';
  String get topTransactions => isIndonesian ? 'Transaksi Terbesar' : 'Largest Transactions';
  String get dailyAverage => isIndonesian ? 'Rata-rata Harian' : 'Daily Average';
  String get categoryTotal => isIndonesian ? 'Total Kategori' : 'Category Total';
  String get transactionCountSuffix => isIndonesian ? 'Transaksi' : 'Transactions';
  String transactionCount(int count) => isIndonesian ? '$count Transaksi' : '$count Transactions';
  String transactionsCount(int count) => isIndonesian ? '$count Transaksi' : '$count Transactions';
  String percentageSaved(String pct) => isIndonesian ? 'Lebih hemat $pct' : 'Saved $pct';
  String percentageIncreased(String pct) => isIndonesian ? 'Lebih boros $pct' : 'Increased $pct';
  String get shareOfTotalExpense => isIndonesian ? 'dari total pengeluaran' : 'of total expenses';

  // Riwayat Mutasi Kategori (CategoryTransactionsPage)
  String get categoryHistoryTitle => isIndonesian ? 'Riwayat Transaksi' : 'Transaction History';
  String get averagePerTransaction => isIndonesian ? 'Rata-rata Transaksi' : 'Average Transaction';
  String get highestSingleTransaction => isIndonesian ? 'Transaksi Terbesar' : 'Largest Transaction';
  String get sortOptionTitle => isIndonesian ? 'Urutkan Berdasarkan' : 'Sort By';
  String get sortTransactionHistory => isIndonesian ? 'Urutkan Riwayat Transaksi' : 'Sort Transaction History';
  String get sortCategorySubtitle => isIndonesian
      ? 'Pilih prioritas tampilan data riwayat kategori ini'
      : 'Select display priority for this category history';
  String get sortDescriptionSubtitle => isIndonesian
      ? 'Pilih prioritas tampilan data riwayat transaksi ini'
      : 'Select display priority for this transaction history';
  String get sortNewest => isIndonesian ? 'Terbaru' : 'Newest';
  String get sortOldest => isIndonesian ? 'Terlama' : 'Oldest';
  String get sortHighestAmount => isIndonesian ? 'Terbesar' : 'Highest';
  String get sortLowestAmount => isIndonesian ? 'Terkecil' : 'Lowest';
  String get sortNewestToOldest => isIndonesian ? 'Tanggal terbaru ke terlama' : 'Newest to oldest date';
  String get sortOldestToNewest => isIndonesian ? 'Tanggal terlama ke terbaru' : 'Oldest to newest date';
  String get sortHighestExpense => isIndonesian ? 'Nominal pengeluaran tertinggi' : 'Highest expense amount';
  String get sortLowestExpense => isIndonesian ? 'Nominal pengeluaran terendah' : 'Lowest expense amount';
  String get selectModeMulti => isIndonesian ? 'Mode Pilih Banyak' : 'Multi-Select Mode';

  // Investigasi Deskripsi & Penggabungan Kata Kunci (DescriptionTransactionsPage & SearchAndMergeModal)
  String get expenseItemDetailsTitle => isIndonesian ? 'Rincian Pos Belanja' : 'Expense Item Details';
  String get searchAndMergeTitle => isIndonesian ? 'Cari & Gabungkan Transaksi' : 'Search & Merge Transactions';
  String get searchAndMergeModalSubtitle => isIndonesian
      ? 'Pilih satu atau lebih transaksi untuk disatukan datanya'
      : 'Select one or more transactions to merge data';
  String get searchTransactionPlaceholder => isIndonesian
      ? 'Cari nama transaksi (misal: sat, padang)...'
      : 'Search transaction name (e.g. food, market)...';
  String get activeKeywordsLabel => isIndonesian ? 'Kata Kunci Penggabungan:' : 'Merge Keywords:';
  String get activeKeywordsTagLabel => isIndonesian ? 'Kata Kunci Aktif:' : 'Active Keywords:';
  String get addKeywordButton => isIndonesian ? 'Tambah Kata Kunci' : 'Add Keyword';
  String get mergeKeywordsButton => isIndonesian ? 'Cari & Gabungkan' : 'Search & Merge';
  String get selectAll => isIndonesian ? 'Pilih Semua' : 'Select All';
  String get deselectAll => isIndonesian ? 'Batal Pilih' : 'Deselect All';
  String get deselectAllLong => isIndonesian ? 'Batal Pilih Semua' : 'Deselect All';
  String get searchTransactionHint => isIndonesian ? 'Cari transaksi lain...' : 'Search other transactions...';
  String get noMatchingTransactions => isIndonesian ? 'Tidak ada transaksi yang cocok' : 'No matching transactions';
  String get includedInThisItem => isIndonesian ? 'Termasuk dalam pos ini' : 'Included in this item';
  String get excludedTransactions => isIndonesian ? 'Transaksi Dikeluarkan' : 'Excluded Transactions';
  String get excludeItemAction => isIndonesian ? 'Keluarkan dari pos' : 'Exclude from item';
  String get excludeSingleTooltip => isIndonesian ? 'Keluarkan transaksi ini' : 'Exclude this transaction';
  String get restoreItemAction => isIndonesian ? 'Masukkan kembali' : 'Include back';
  String get restoreAll => isIndonesian ? 'Pulihkan Semua' : 'Restore All';
  String get mergeSelectedItems => isIndonesian ? 'Gabungkan Pilihan' : 'Merge Selected';
  String get selectTransactionsToMerge => isIndonesian
      ? 'Pilih Transaksi untuk Digabungkan'
      : 'Select Transactions to Merge';
  String get selectedCountSuffix => isIndonesian ? 'dipilih' : 'selected';
  String selectedItemsCount(int count) => isIndonesian ? '$count Dipilih' : '$count Selected';
  String transactionsFound(int count) => isIndonesian ? '$count Transaksi Ditemukan' : '$count Transactions Found';
  String transactionsSelected(int count) => isIndonesian ? '$count Transaksi Dipilih' : '$count Transactions Selected';
  String noTransactionNamed(String query) => isIndonesian ? 'Tidak ada transaksi bernama "$query"' : 'No transaction named "$query"';
  String useKeywordAsSearch(String query) => isIndonesian ? 'Gunakan "$query" sebagai kata kunci' : 'Use "$query" as keyword';
  String useWordPrefix(String query) => isIndonesian ? 'Gunakan kata: "$query"' : 'Use word: "$query"';
  String get matchAllTransactionsWithWord => isIndonesian
      ? 'Cocokkan semua transaksi yang memuat kata ini'
      : 'Match all transactions containing this word';
  String mergeSelectedCount(int count) => isIndonesian ? 'Gabungkan ($count) Kata / Data' : 'Merge ($count) Words / Data';
  String excludeSelectedDataButton(int count) => isIndonesian ? 'Keluarkan ($count) Data' : 'Exclude ($count) Items';
  String excludeSingleItem(String name) => isIndonesian
      ? '1 transaksi ($name) dikeluarkan dari perhitungan'
      : '1 transaction ($name) excluded from calculation';
  String excludeItemsCount(int count) => isIndonesian
      ? '$count transaksi dikeluarkan dari perhitungan'
      : '$count transactions excluded from calculation';
  String get portionOfCategory => isIndonesian ? 'Porsi dari Kategori' : 'Share of Category';
  String get transactionFrequency => isIndonesian ? 'Frekuensi Transaksi' : 'Transaction Frequency';
  String get totalThisItem => isIndonesian ? 'Total Pos Ini' : 'Total This Item';
  String get totalAccumulatedExpense => isIndonesian ? 'Total Pengeluaran Terakumulasi' : 'Total Accumulated Expense';
  String get averagePerTxLabel => isIndonesian ? 'Rata-rata per transaksi:' : 'Average per transaction:';
  String get suggestedRelatedWords => isIndonesian ? 'Saran Kata Terkait untuk Digabungkan:' : 'Suggested Related Words to Merge:';
  String get suggestedRelatedWordsDesc => isIndonesian
      ? 'Ditemukan kata lain pada transaksi terpilih yang juga muncul di transaksi lain:'
      : 'Other words found in selected transactions that also appear elsewhere:';
  String get openFullTransactionDetails => isIndonesian
      ? 'Buka Rincian Transaksi Lengkap'
      : 'Open Full Transaction Details';
  String get similarItemsRecommendation => isIndonesian ? 'Rekomendasi Kata Kunci Serupa' : 'Similar Keyword Recommendations';
  String get keywordMergedSuccess => isIndonesian ? 'Kata kunci berhasil digabungkan' : 'Keywords merged successfully';

  // Info Modals Edukatif Finansial & Chart Widget
  String get educationalGuide => isIndonesian ? 'Panduan Edukasi' : 'Educational Guide';
  String get actionableInsights => isIndonesian ? 'Rekomendasi Aksi Finansial' : 'Actionable Financial Insights';
  String get comparativeAnalysis => isIndonesian ? 'Analisis Komparatif' : 'Comparative Analysis';
  String get trendInterpretation => isIndonesian ? 'Interpretasi Tren' : 'Trend Interpretation';
  String get paretoLawTitle => isIndonesian ? 'Prinsip Pareto (80/20)' : 'Pareto Principle (80/20)';
  String get understandMetricsTitle => isIndonesian ? 'Memahami Metrik Ini' : 'Understanding This Metric';
  String get howToReadChart => isIndonesian ? 'Cara Membaca Grafik' : 'How to Read This Chart';
  String get realAnalysisPrefix => isIndonesian ? 'Analisis Riil' : 'Real Analysis';
  String get expenseComposition => isIndonesian ? 'Komposisi Pengeluaran' : 'Expense Composition';
  String get spendingRank => isIndonesian ? 'Peringkat Pos Belanja' : 'Spending Category Ranking';
  String get peakIncome => isIndonesian ? 'Puncak Pemasukan' : 'Peak Income';
  String get peakExpense => isIndonesian ? 'Puncak Pengeluaran' : 'Peak Expense';
  String get lineAndBarModeTitle => isIndonesian ? 'Mode Grafik Garis & Batang' : 'Line & Bar Chart Mode';
  String get smartTipTitle => isIndonesian ? 'Tips Cerdas' : 'Smart Financial Tip';
  String get understood => isIndonesian ? 'Mengerti' : 'Got It';
  String get viewDetailsBtn => isIndonesian ? 'Lihat Rincian' : 'View Details';
  String get viewAll => isIndonesian ? 'Lihat Semua' : 'View All';
  String get customRangeDateShort => isIndonesian ? 'Rentang Waktu' : 'Date Range';
  String get timesUnit => isIndonesian ? 'Kali' : 'Times';
  String get highest => isIndonesian ? 'Tertinggi' : 'Highest';
  String get lowest => isIndonesian ? 'Terendah' : 'Lowest';
  String get select => isIndonesian ? 'Pilih' : 'Select';
  String get selectYear => isIndonesian ? 'Pilih Tahun' : 'Select Year';
  String get noTransactionsFound => isIndonesian ? 'Tidak ada transaksi ditemukan' : 'No transactions found';

  // ── 9. Pengaturan (Settings) ─────────────────────────────────────────────
  String get settingsTitle => isIndonesian ? 'Pengaturan' : 'Settings';
  String get settingCategories => isIndonesian ? 'Kategori' : 'Categories';
  String get settingCategoriesSub => isIndonesian ? 'Kelola kategori kustom' : 'Manage custom categories';
  String get settingSecurity => isIndonesian ? 'Keamanan' : 'Security';
  String get settingSecuritySub => isIndonesian ? 'Pengaturan PIN & biometrik' : 'PIN & biometric settings';
  String get settingImport => isIndonesian ? 'Impor Data' : 'Import Data';
  String get settingImportSub => isIndonesian ? 'Impor dari CSV/Excel' : 'Import from CSV/Excel';
  String get settingReminder => isIndonesian ? 'Pengingat' : 'Reminder';
  String get settingReminderSub => isIndonesian ? 'Atur pengingat harian' : 'Set daily reminders';
  String get settingExport => isIndonesian ? 'Ekspor Data' : 'Export Data';
  String get settingExportSub => isIndonesian ? 'Ekspor ke Excel/Spreadsheet' : 'Excel/Spreadsheet export';
  String get settingBackup => isIndonesian ? 'Cadangkan & Sinkronisasi' : 'Backup & Sync';
  String get settingBackupSub => isIndonesian ? 'Hubungkan ke Google Drive' : 'Connect to Google Drive';
  String get settingLanguage => isIndonesian ? 'Bahasa' : 'Language';
  String get settingLanguageName => isIndonesian ? 'Bahasa Indonesia' : 'English';
  String get settingTheme => isIndonesian ? 'Tema' : 'Theme';
  String get settingThemeSub => isIndonesian ? 'Mode Terang/Gelap' : 'Light/Dark mode';
  String get settingShare => isIndonesian ? 'Bagikan Aplikasi' : 'Share App';
  String get settingShareSub => isIndonesian ? 'Beri tahu teman tentang Saku' : 'Tell your friends about Saku';
  String get settingAbout => isIndonesian ? 'Tentang Aplikasi' : 'About App';
  String get selectLanguageTitle => isIndonesian ? 'Pilih Bahasa' : 'Select Language';

  // Keamanan & PIN
  String get securitySettingsTitle => isIndonesian ? 'Pengaturan Keamanan' : 'Security Settings';
  String get appAccessHeader => isIndonesian ? 'AKSES APLIKASI' : 'APP ACCESS';
  String get appLockTitle => isIndonesian ? 'Kunci Aplikasi' : 'App Lock';
  String get biometricIdTitle => isIndonesian ? 'ID Biometrik' : 'Biometric ID';
  String get biometricAuthReason => isIndonesian ? 'Verifikasi biometrik untuk mengaktifkan' : 'Verify biometrics to enable';
  String get biometricLoginReason => isIndonesian ? 'Gunakan biometrik untuk masuk' : 'Use biometrics to log in';
  String get biometricNotSupported => isIndonesian
      ? 'Perangkat tidak mendukung biometrik atau tidak ada sidik jari yang terdaftar.'
      : 'Device does not support biometrics or no fingerprints enrolled.';
  String get setPin => isIndonesian ? 'Set PIN' : 'Set PIN';
  String get changePin => isIndonesian ? 'Ganti PIN' : 'Change PIN';
  String get deletePin => isIndonesian ? 'Hapus PIN' : 'Delete PIN';
  String get deletePinConfirmTitle => isIndonesian ? 'Hapus PIN?' : 'Delete PIN?';
  String get deletePinConfirmDesc => isIndonesian
      ? 'Apakah Anda yakin ingin menghapus PIN? Kunci aplikasi akan tetap aktif jika Biometrik aktif.'
      : 'Are you sure you want to delete your PIN? App lock will remain active if Biometrics is enabled.';
  String get autoLockTime => isIndonesian ? 'Waktu Kunci Otomatis' : 'Auto-Lock Time';
  String get immediately => isIndonesian ? 'Segera' : 'Immediately';
  String get visualPrivacyHeader => isIndonesian ? 'PRIVASI VISUAL' : 'VISUAL PRIVACY';
  String get secureScreenTitle => isIndonesian ? 'Layar Aman' : 'Secure Screen';
  String get secureScreenSub => isIndonesian
      ? 'Cegah screenshot & sembunyikan preview aplikasi.'
      : 'Prevent screenshots & hide app preview.';
  String get balanceSensorTitle => isIndonesian ? 'Sensor Saldo' : 'Balance Sensor';
  String get balanceSensorSub => isIndonesian
      ? 'Samarkan saldo di dashboard utama.'
      : 'Mask balance on main dashboard.';
  String get securityVersionFooter => isIndonesian
      ? 'Versi Keamanan 2.4.0 • Terlindungi Enkripsi AES-256'
      : 'Security Version 2.4.0 • Protected by AES-256 Encryption';
  String get createNewPin => isIndonesian ? 'Buat PIN baru Anda' : 'Create your new PIN';
  String get useBiometricId => isIndonesian ? 'Gunakan ID Biometrik' : 'Use Biometric ID';
  String get enterYourPin => isIndonesian ? 'Masukkan PIN Anda' : 'Enter your PIN';
  String get enterOldPin => isIndonesian ? 'Masukkan PIN Lama' : 'Enter Old PIN';
  String get confirmYourPin => isIndonesian ? 'Konfirmasi PIN Anda' : 'Confirm your PIN';
  String get pinMismatch => isIndonesian ? 'PIN tidak cocok, coba lagi' : 'PINs do not match, try again';
  String get pinWrong => isIndonesian ? 'PIN salah, silakan coba lagi' : 'Wrong PIN, please try again';
  String get pinNotSetUseBiometric => isIndonesian ? 'PIN belum diatur, gunakan ID Biometrik.' : 'PIN not set, use Biometric ID.';

  // Pengingat Harian
  String get dailyReminderTitle => isIndonesian ? 'Pengingat Harian' : 'Daily Reminder';
  String get enableReminder => isIndonesian ? 'Aktifkan Pengingat' : 'Enable Reminder';
  String get enableReminderSub => isIndonesian ? 'Terima notifikasi untuk membangun kebiasaan' : 'Receive notifications to build healthy financial habits';
  String get frequencyScheduleHeader => isIndonesian ? 'JADWAL FREKUENSI' : 'FREQUENCY SCHEDULE';
  String get addReminderTime => isIndonesian ? 'Tambah Waktu Pengingat' : 'Add Reminder Time';
  String get messageContentHeader => isIndonesian ? 'KONTEN PESAN' : 'MESSAGE CONTENT';
  String get randomQuoteOption => isIndonesian ? 'Kutipan Acak (Default)' : 'Random Quotes (Default)';
  String get customMessageOption => isIndonesian ? 'Pesan Kustom' : 'Custom Message';
  String get customMessageHint => isIndonesian ? 'Tulis pesan penyemangatmu...' : 'Write your motivational message...';
  String get customMessageNote => isIndonesian ? 'Pesan ini akan dikirim sesuai jadwal di atas.' : 'This message will be sent according to the schedule above.';
  String get saveSettingsButton => isIndonesian ? 'Simpan Pengaturan' : 'Save Settings';
  String get reminderSettingsSaved => isIndonesian ? 'Pengaturan pengingat berhasil disimpan' : 'Reminder settings saved successfully';

  // Ekspor Data
  String get exportDataTitle => isIndonesian ? 'Ekspor Data' : 'Export Data';
  String get exportFormatHeader => isIndonesian ? 'FORMAT EKSPOR' : 'EXPORT FORMAT';
  String get dateRangeHeader => isIndonesian ? 'PERIODE WAKTU' : 'TIME PERIOD';
  String get thisMonth => isIndonesian ? 'Bulan Ini' : 'This Month';
  String get lastMonth => isIndonesian ? 'Bulan Lalu' : 'Last Month';
  String get thisYear => isIndonesian ? 'Tahun Ini' : 'This Year';
  String get allTime => isIndonesian ? 'Semua' : 'All Time';
  String get includeReceiptsLabel => isIndonesian ? 'Sertakan Bukti / Kuitansi' : 'Include Receipts';
  String get passwordProtectionLabel => isIndonesian ? 'Proteksi Password (PDF)' : 'Password Protection (PDF)';
  String get enterPasswordHint => isIndonesian ? 'Masukkan password' : 'Enter password';
  String get passwordProtectionTitle => isIndonesian ? 'Proteksi Password' : 'Password Protection';
  String get exportNowButton => isIndonesian ? 'Ekspor Sekarang' : 'Export Now';
  String get fileSavedSuccess => isIndonesian ? 'File tersimpan:' : 'File saved:';
  String get exportFailed => isIndonesian ? 'Gagal export:' : 'Export failed:';

  // Cloud Backup
  String get cloudBackupTitle => isIndonesian ? 'Cloud Backup' : 'Cloud Backup';
  String get restoreSuccessTitle => isIndonesian ? 'Restore Berhasil ✅' : 'Restore Successful ✅';
  String get restoreSuccessDesc => isIndonesian
      ? 'Data berhasil dipulihkan. Aplikasi perlu ditutup dan dibuka ulang agar perubahan aktif.'
      : 'Data restored successfully. Please restart the app to apply changes.';
  String get closeAppButton => isIndonesian ? 'Tutup Aplikasi' : 'Close App';
  String get notConnectedTitle => isIndonesian ? 'Belum Terhubung' : 'Not Connected';
  String get notConnectedDesc => isIndonesian
      ? 'Hubungkan akun Google untuk backup data keuanganmu ke cloud secara aman.'
      : 'Connect your Google account to back up financial data securely to the cloud.';
  String get connectGoogleButton => isIndonesian ? 'Hubungkan Akun Google' : 'Connect Google Account';
  String get connectedAccount => isIndonesian ? 'Akun Terhubung' : 'Connected Account';
  String get lastBackupLabel => isIndonesian ? 'Backup Terakhir' : 'Last Backup';
  String get backupNowButton => isIndonesian ? 'Cadangkan Sekarang' : 'Back Up Now';
  String get restoreDataButton => isIndonesian ? 'Pulihkan Data' : 'Restore Data';
  String get disconnectAccount => isIndonesian ? 'Putuskan Akun' : 'Disconnect Account';
  String get backupSuccessMsg => isIndonesian ? 'Cadangan berhasil diperbarui' : 'Backup updated successfully';
  String get connectedStatus => isIndonesian ? 'Terhubung' : 'Connected';

  // Tentang Aplikasi
  String get aboutAppTitle => isIndonesian ? 'Tentang Aplikasi' : 'About App';
  String get appTagline => isIndonesian ? 'Teman terpercaya pengelolaan keuangan pribadimu.' : 'Your personal finance companion.';
  String get privacyPolicy => isIndonesian ? 'Kebijakan Privasi' : 'Privacy Policy';
  String get termsOfService => isIndonesian ? 'Ketentuan Layanan' : 'Terms of Service';
  String get openSourceLicenses => isIndonesian ? 'Lisensi Open Source' : 'Open Source Licenses';
  String get checkForUpdates => isIndonesian ? 'Periksa Pembaruan' : 'Check for Updates';
  String get appUpToDate => isIndonesian ? 'Aplikasi Anda sudah versi terbaru!' : 'Your app is up to date!';
  String get madeWithLove => isIndonesian ? 'Dibuat dengan ❤️ oleh Tim Saku' : 'Made with ❤️ by Saku Team';

  // Detail Rekening (WalletDetailPage)
  String get accountDetailTitle => isIndonesian ? 'Detail Rekening' : 'Account Details';
  String get currentBalanceLabel => isIndonesian ? 'Saldo Saat Ini' : 'Current Balance';
  String get quickActions => isIndonesian ? 'Aksi Cepat' : 'Quick Actions';
  String get transferAction => isIndonesian ? 'Pindah Buku' : 'Transfer';
  String get adjustAction => isIndonesian ? 'Ngepasin' : 'Reconcile';
  String get historyAction => isIndonesian ? 'Riwayat' : 'History';
  String get incomeSummary => isIndonesian ? 'Total Pemasukan' : 'Total Income';
  String get expenseSummary => isIndonesian ? 'Total Pengeluaran' : 'Total Expense';
  String get noTransactionsInWallet => isIndonesian ? 'Belum ada transaksi di rekening ini' : 'No transactions in this account yet';
  String get hideWalletOption => isIndonesian ? 'Sembunyikan Dompet' : 'Hide Wallet';
  String get unhideWalletOption => isIndonesian ? 'Tampilkan Dompet' : 'Unhide Wallet';
  String get editWalletOption => isIndonesian ? 'Edit Dompet' : 'Edit Wallet';

  // Spending Planner & Target Finansial
  String get dailySpendingAllocation => isIndonesian ? 'Alokasi Belanja Harian' : 'Daily Spending Allowance';
  String get setTargetDate => isIndonesian ? 'Atur Tanggal Target' : 'Set Target Date';
  String get targetReachedToday => isIndonesian ? 'Hari Ini Target Tiba! 🎉' : 'Target Day Reached Today! 🎉';
  String get targetIncomeDay => isIndonesian ? 'Hari Pemasukan Tiba!' : 'Income Day Has Arrived!';
  String get noActiveTarget => isIndonesian ? 'Belum ada target aktif' : 'No active target';
  String get remainingBalanceLabel => isIndonesian ? 'Sisa Saldo:' : 'Remaining Balance:';
  String get balancePrefix => isIndonesian ? 'Saldo:' : 'Balance:';
  String get perDay => isIndonesian ? '/ hari' : '/ day';
  String get financialTargetsTitle => isIndonesian ? 'Jadwal Target Pemasukan' : 'Income Target Schedule';
  String get financialTargetsSubtitle => isIndonesian
      ? 'Atur gajian & proyekan untuk hitungan jatah harian'
      : 'Set payday & projects for daily allowance calculation';
  String get addNewTarget => isIndonesian ? 'Tambah Target Pemasukan' : 'Add Income Target';
  String get editTargetTitle => isIndonesian ? 'Edit Target Pemasukan' : 'Edit Income Target';
  String get targetScheduleSub => isIndonesian
      ? 'Tentukan tanggal gajian atau penerimaan dana'
      : 'Set payday or fund receipt date';
  String get targetNameLabel => isIndonesian ? 'Nama Target / Sumber Pemasukan' : 'Target Name / Income Source';
  String get targetNameHint => isIndonesian ? 'Contoh: Gaji Kantor, Project Freelance' : 'e.g. Office Salary, Freelance Project';
  String get selectCycleType => isIndonesian ? 'Pilih Tipe Siklus' : 'Select Cycle Type';
  String get monthlyRoutine => isIndonesian ? 'Rutin Bulanan' : 'Monthly Routine';
  String get monthlyRoutineDesc => isIndonesian ? 'Gaji pokok, uang saku' : 'Base salary, allowance';
  String get oneTimeTarget => isIndonesian ? 'Sekali Saja' : 'One Time';
  String get oneTimeTargetDesc => isIndonesian ? 'Project lepas, bonus' : 'Freelance project, bonus';
  String get selectPayDate => isIndonesian ? 'Pilih Tanggal Penggajian / Masuk' : 'Select Payday / Incoming Date';
  String everyMonthDay(int day) => isIndonesian ? 'Setiap tanggal $day tiap bulan' : 'Every $day of the month';
  String get selectScheduledDate => isIndonesian ? 'Pilih Tanggal Target Terjadwal' : 'Select Scheduled Target Date';
  String get tapToChangeDate => isIndonesian ? 'Ketuk untuk mengubah tanggal' : 'Tap to change date';
  String get saveChanges => isIndonesian ? 'Simpan Perubahan' : 'Save Changes';
  String get deleteTargetTitle => isIndonesian ? 'Hapus Target?' : 'Delete Target?';
  String deleteTargetConfirm(String title) => isIndonesian
      ? 'Yakin ingin menghapus target "$title"?'
      : 'Are you sure you want to delete target "$title"?';
  String get noTargetsYet => isIndonesian
      ? 'Belum ada target pemasukan.\nTekan tombol + Tambah Target untuk mulai.'
      : 'No income targets yet.\nTap + Add Target button to start.';
  String routineScheduleDay(int day) => isIndonesian ? 'Rutin tgl $day' : 'Routine on day $day';
  String oneTimeScheduleDate(String date) => isIndonesian ? 'Sekali pada $date' : 'Once on $date';
  String get inactiveStatus => isIndonesian ? 'Nonaktif' : 'Inactive';
  String get passedStatus => isIndonesian ? 'Sudah lewat' : 'Passed';
  String get todayStatus => isIndonesian ? 'Hari ini!' : 'Today!';
  String daysLeftCount(int days) => isIndonesian ? '$days hari lagi' : '$days days left';
  String moreWalletsCount(int count) => isIndonesian ? '+ $count Lainnya' : '+ $count More';

  // Export Additional Details
  String get reportBuilderTitle => isIndonesian ? 'Pembuat Laporan' : 'Report Builder';
  String get selectFormatHeader => isIndonesian ? 'PILIH FORMAT' : 'SELECT FORMAT';
  String get timeRangeHeader => isIndonesian ? 'RENTANG WAKTU' : 'TIME RANGE';
  String get additionalOptionsHeader => isIndonesian ? 'OPSI TAMBAHAN' : 'ADDITIONAL OPTIONS';
  String get neatReportPdf => isIndonesian ? 'Laporan Rapi' : 'Neat Report';
  String get processedDataExcel => isIndonesian ? 'Data Olahan' : 'Spreadsheet Data';
  String get backupCsv => isIndonesian ? 'Backup Ringan' : 'Lightweight Backup';
  String get fromDateLabel => isIndonesian ? 'Dari Tanggal' : 'From Date';
  String get toDateLabel => isIndonesian ? 'Sampai Tanggal' : 'To Date';
  String get includeReceiptsSub => isIndonesian ? 'Ukuran file akan lebih besar' : 'File size will be larger';
  String get passwordProtectionSub => isIndonesian ? 'Khusus format PDF' : 'PDF format only';
  String get processingExport => isIndonesian ? 'Memproses...' : 'Processing...';
  String get exportAndShare => isIndonesian ? 'Ekspor & Bagikan' : 'Export & Share';

  // Backup Additional Details
  String get infoBackupHeader => isIndonesian ? 'INFO BACKUP' : 'BACKUP INFO';
  String get backupDateLabel => isIndonesian ? 'Tanggal Backup' : 'Backup Date';
  String get fileSizeLabel => isIndonesian ? 'Ukuran File' : 'File Size';
  String get neverBackedUp => isIndonesian ? 'Belum pernah' : 'Never';
  String get justNow => isIndonesian ? 'Baru saja' : 'Just now';
  String minutesAgo(int m) => isIndonesian ? '$m menit lalu' : '$m min ago';
  String hoursAgo(int h) => isIndonesian ? '$h jam lalu' : '$h hrs ago';
  String daysAgoCount(int d) => isIndonesian ? '$d hari lalu' : '$d days ago';
  String get restoringData => isIndonesian ? 'Memulihkan...' : 'Restoring...';
  String get syncingData => isIndonesian ? 'Menyinkronkan...' : 'Syncing...';
  String get restoreDataTitle => isIndonesian ? 'Restore Data?' : 'Restore Data?';
  String get restoreDataConfirm => isIndonesian
      ? 'Data lokal akan diganti dengan data dari backup cloud. Aplikasi perlu di-restart setelah restore. Lanjutkan?'
      : 'Local data will be replaced with cloud backup data. The app will restart after restore. Continue?';
  String get yesRestore => isIndonesian ? 'Ya, Restore' : 'Yes, Restore';
  String get disconnectAccountTitle => isIndonesian ? 'Putuskan Akun?' : 'Disconnect Account?';
  String get disconnectAccountConfirm => isIndonesian
      ? 'Akun Google Drive akan diputuskan. Data lokal tidak akan terhapus. Lanjutkan?'
      : 'Google Drive account will be disconnected. Local data will remain intact. Continue?';
  String get yesDisconnect => isIndonesian ? 'Ya, Putuskan' : 'Yes, Disconnect';
  String get localDataSafeNote => isIndonesian ? 'Data lokal tidak akan terhapus' : 'Local data will not be deleted';

  // About Additional Details
  String get copyrightTeam => isIndonesian ? '© 2026 Tim Saku.' : '© 2026 Saku Team.';
  String get madeWithPrefix => isIndonesian ? 'Dibuat dengan ' : 'Made with ';
  String get inIndonesia => isIndonesian ? ' di Indonesia.' : ' in Indonesia.';

  // Wallet Detail Additional Details
  String get mainBalanceLabel => isIndonesian ? 'Saldo Utama' : 'Main Balance';
  String get seeAllHistoryWithCount => isIndonesian ? 'Lihat Semua Riwayat' : 'View All History';
  String get noTransactionsWalletDesc => isIndonesian
      ? 'Transaksi untuk rekening ini akan muncul di sini'
      : 'Transactions for this wallet will appear here';

  // ── 10. Impor Cerdas Mind Space & Import Menu ───────────────────────────
  String get importReviewTitle => isIndonesian ? 'Impor dari Mind Space' : 'Import from Mind Space';
  String get importAiSmartBadge => isIndonesian ? 'AI Smart' : 'AI Smart';
  String get targetRealBalance => isIndonesian ? 'Target Saldo Riil' : 'Target Real Balance';
  String get transactionNoteHint => isIndonesian ? 'Contoh: Bensin, Mi ayam' : 'e.g. Fuel, Lunch';
  String get automaticCalculation => isIndonesian ? 'Perhitungan Otomatis Saku' : 'Saku Automatic Calculation';
  String get recordedAs => isIndonesian ? 'Akan dicatat sebagai:' : 'Will be recorded as:';
  String get saveAllTransactions => isIndonesian ? 'Simpan Transaksi' : 'Save Transactions';
  String get importDataTitle => isIndonesian ? 'Impor Data' : 'Import Data';
  String get transferFinancialDataTitle => isIndonesian ? 'Pindahkan Data Keuangan' : 'Transfer Financial Data';
  String get transferFinancialDataDesc => isIndonesian
      ? 'Pindahkan data keuanganmu dari aplikasi lain atau rekening koran bank dengan mudah.'
      : 'Easily transfer your financial data from other apps or bank statements.';
  String get importHistoryTitle => isIndonesian ? 'Riwayat Impor' : 'Import History';
  String get noImportHistoryYet => isIndonesian ? 'Belum ada riwayat impor.' : 'No import history yet.';
  String get selectFileFromStorage => isIndonesian ? 'Pilih File dari Penyimpanan' : 'Select File from Storage';
  String get selectingFile => isIndonesian ? 'Memilih file...' : 'Selecting file...';
  String get mapColumnsStep => isIndonesian ? 'Petakan Kolom' : 'Map Columns';
  String get mapCategoriesStep => isIndonesian ? 'Petakan Kategori' : 'Map Categories';
  String get mapWalletsStep => isIndonesian ? 'Petakan Wallet' : 'Map Wallets';
  String get confirmImportStep => isIndonesian ? 'Konfirmasi Impor' : 'Confirm Import';

  // ── 11. Manajemen Kategori & Dompet (Categories & Wallets) ───────────────
  String get categoryExpenseTitle => isIndonesian ? 'Kategori Pengeluaran' : 'Expense Categories';
  String get categoryIncomeTitle => isIndonesian ? 'Kategori Pemasukan' : 'Income Categories';
  String get selectWalletTitle => isIndonesian ? 'Pilih Wallet' : 'Select Wallet';
  String get manageCategories => isIndonesian ? 'Atur Kategori' : 'Manage Categories';
  String get noWalletsYet => isIndonesian ? 'Belum ada wallet' : 'No wallets yet';
  String get noWalletsSubtitle => isIndonesian
      ? 'Tambahkan wallet pertamamu dengan menekan tombol + di bawah'
      : 'Add your first wallet by tapping the + button below';
  String get tapPlusToAddWallet => isIndonesian
      ? 'Tap tombol + untuk menambah wallet'
      : 'Tap + button to add a wallet';
  String get addCategoryTitle => isIndonesian ? 'Tambah Kategori' : 'Add Category';
  String get editCategoryTitle => isIndonesian ? 'Edit Kategori' : 'Edit Category';
  String get categoryNameLabel => isIndonesian ? 'Nama Kategori' : 'Category Name';
  String get categoryNameHint => isIndonesian ? 'Contoh: Makanan, Transportasi' : 'e.g. Food, Transportation';
  String get iconLabel => isIndonesian ? 'Ikon' : 'Icon';
  String get fullCatalogLabel => isIndonesian ? 'Katalog Lengkap (4.000+)' : 'Full Catalog (4,000+)';
  String get colorLabel => isIndonesian ? 'Warna' : 'Color';
  String get deleteCategory => isIndonesian ? 'Hapus Kategori' : 'Delete Category';
  String get moveCategory => isIndonesian ? 'Pindahkan Kategori' : 'Move Category';
  String get transactionHistory => isIndonesian ? 'Riwayat Transaksi' : 'Transaction History';
  String get moveToLabel => isIndonesian ? 'Pindahkan ke:' : 'Move to:';
  String get moveButton => isIndonesian ? 'Pindahkan' : 'Move';
  String get noOtherCategoriesToMove => isIndonesian
      ? 'Tidak ada kategori lain untuk dipindahkan.'
      : 'No other categories to move to.';
  String get addWalletTitle => isIndonesian ? 'Tambah Wallet' : 'Add Wallet';
  String get editWalletTitle => isIndonesian ? 'Edit Wallet' : 'Edit Wallet';
  String get walletNameLabel => isIndonesian ? 'Nama Wallet' : 'Wallet Name';
  String get initialBalanceLabel => isIndonesian ? 'Saldo Awal' : 'Initial Balance';
  String get preferencesLabel => isIndonesian ? 'Preferensi' : 'Preferences';
  String get hideBalanceLabel => isIndonesian ? 'Sembunyikan Saldo' : 'Hide Balance';
  String get accountNumberLabel => isIndonesian
      ? 'Nomor Rekening / ID (Opsional)'
      : 'Account Number / ID (Optional)';
  String get maskAndLockNumber => isIndonesian ? 'Sensor & Kunci Nomor' : 'Mask & Lock Number';
  String get maskAndLockNumberDesc => isIndonesian
      ? 'Jika aktif, nomor akan disensor dan membutuhkan PIN/FaceID untuk menyalin.'
      : 'If enabled, the number will be masked and require PIN/FaceID to copy.';
  String get walletNameCannotBeEmpty => isIndonesian
      ? 'Nama wallet tidak boleh kosong'
      : 'Wallet name cannot be empty';
  String get noOtherWalletsToMove => isIndonesian
      ? 'Tidak ada wallet lain untuk dipindahkan.'
      : 'No other wallets to move to.';

  // ── 12. Dialog, Notifikasi, & Tombol Umum ─────────────────────────────────
  String get cancel => isIndonesian ? 'Batal' : 'Cancel';
  String get delete => isIndonesian ? 'Hapus' : 'Delete';
  String get confirm => isIndonesian ? 'Konfirmasi' : 'Confirm';
  String get success => isIndonesian ? 'Berhasil' : 'Success';
  String get failed => isIndonesian ? 'Gagal' : 'Failed';
  String get okUnderstand => isIndonesian ? 'Oke, Mengerti' : 'OK, Got It';
  String get featureUnderDevTitle => isIndonesian ? 'Fitur Dalam Pengembangan' : 'Feature Under Development';
  String get shareAppUnderDevDesc => isIndonesian
      ? 'Fitur Bagikan Aplikasi (Share App) saat ini masih dalam tahap pengembangan dan akan segera hadir pada pembaruan mendatang. Terima kasih telah menggunakan Saku!'
      : 'The Share App feature is currently under active development and will be available in an upcoming update. Thank you for using Saku!';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['id', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Helper extension pada BuildContext untuk akses cepat lokalisasi via `context.l10n`.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
