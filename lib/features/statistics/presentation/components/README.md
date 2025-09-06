# Statistics Components

Folder ini berisi komponen-komponen yang digunakan untuk membangun halaman statistics.

## Struktur Komponen

### 1. PeriodSelector
Komponen untuk memilih periode waktu (Daily, Monthly, Yearly, Custom).
- **File**: `period_selector.dart`
- **Props**: selectedPeriod, onPeriodChanged

### 2. StatisticsSummaryCard
Komponen kartu ringkasan dengan persentase perubahan.
- **File**: `statistics_summary_card.dart`
- **Props**: title, amount, percentage, icon, iconColor, backgroundColor, percentageColor

### 3. LineChartWidget
Komponen grafik garis untuk menampilkan Income vs Expense.
- **File**: `line_chart_widget.dart`
- **Library**: fl_chart
- **Features**: Interactive line chart dengan data 6 bulan

### 4. DonutChartWidget
Komponen grafik donat untuk Category Breakdown.
- **File**: `donut_chart_widget.dart`
- **Library**: fl_chart
- **Features**: Pie chart dengan 5 kategori

### 5. TopCategoriesList
Komponen daftar kategori teratas dengan persentase.
- **File**: `top_categories_list.dart`
- **Data Class**: CategoryData
- **Features**: List dengan color indicator dan persentase

### 6. ChartPanel
Komponen panel wrapper untuk chart dengan header dan action.
- **File**: `chart_panel.dart`
- **Props**: title, child, actionText, onActionTap, headerActions

## Penggunaan

```dart
import '../components/components.dart' as components;

// Contoh penggunaan
components.StatisticsSummaryCard(
  title: 'Income',
  amount: '\$4,250',
  percentage: '+12.5%',
  icon: Icons.arrow_upward,
  iconColor: Colors.green[700]!,
  backgroundColor: Colors.green[600]!,
  percentageColor: Colors.green[400]!,
)
```

## Dependencies

- **fl_chart**: ^0.69.0 - Library untuk membuat chart
- **flutter/material**: UI components

## Catatan

- Semua komponen menggunakan dark theme
- Warna dan styling sudah disesuaikan dengan desain UI
- Chart menggunakan data static sesuai gambar
- Komponen dibuat reusable dan mudah untuk dikustomisasi
