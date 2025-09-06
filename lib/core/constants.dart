/// Base URL of the backend API.  Update this when deploying the Express server.
const String baseUrl = 'http://localhost:3000';

/// Predefined transaction categories.  Users can extend this list in the app.
const List<String> kCategories = [
  'Makanan',
  'Transportasi',
  'Kesehatan',
  'Belanja',
  'Tagihan',
  'Gaji',
  'Lainnya',
];

/// Transaction types.  Use these to classify a transaction as income or expense.
const String kTypeIncome = 'income';
const String kTypeExpense = 'expense';

/// UI Constants
const int kDecimalPlaces = 2;
const double kMinAmount = 0.01;
const String kDefaultDescription = '(Tanpa deskripsi)';
