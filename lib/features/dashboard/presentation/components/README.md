# Dashboard Components

Folder ini berisi komponen-komponen yang digunakan untuk membangun halaman dashboard.

## Struktur Komponen

### 1. SummaryCard
Komponen untuk menampilkan ringkasan keuangan (Income, Expense, Total).
- **File**: `summary_card.dart`
- **Props**: title, amount, icon, iconColor, backgroundColor, textColor

### 2. SearchBar
Komponen search bar dengan filter.
- **File**: `search_bar.dart`
- **Props**: hintText, onFilterTap, onChanged

### 3. MonthNavigation
Komponen navigasi bulan dengan tombol previous/next.
- **File**: `month_navigation.dart`
- **Props**: currentMonth, onPreviousMonth, onNextMonth

### 4. TransactionItem
Komponen item transaksi individual.
- **File**: `transaction_item.dart`
- **Props**: category, paymentMethod, amount, icon, iconColor, backgroundColor, isIncome

### 5. TransactionSection
Komponen section yang mengelompokkan transaksi berdasarkan hari.
- **File**: `transaction_section.dart`
- **Props**: sectionTitle, transactions
- **Data Class**: TransactionData

## Penggunaan

```dart
import '../components/components.dart' as components;

// Contoh penggunaan
components.SummaryCard(
  title: 'Income',
  amount: '\$4,250',
  icon: Icons.arrow_upward,
  iconColor: Colors.green[700]!,
  backgroundColor: Colors.green[100]!,
)
```

## Catatan

- Semua komponen menggunakan design system yang konsisten
- Warna dan spacing sudah disesuaikan dengan desain UI
- Komponen dibuat reusable dan mudah untuk dikustomisasi
