import 'package:hugeicons/hugeicons.dart';

class CategoryIconItem {
  final String key;
  final String label;
  final List<String> keywords;
  final List<List<dynamic>> icon;

  const CategoryIconItem({
    required this.key,
    required this.label,
    required this.keywords,
    required this.icon,
  });
}

class CategoryIconGroup {
  final String id;
  final String title;
  final List<List<dynamic>> groupIcon;
  final List<CategoryIconItem> items;

  const CategoryIconGroup({
    required this.id,
    required this.title,
    required this.groupIcon,
    required this.items,
  });
}

class CategoryIconCatalog {
  static final List<CategoryIconGroup> groups = [
    // 1. Makanan & Minuman
    CategoryIconGroup(
      id: 'food',
      title: 'Makanan & Minuman',
      groupIcon: HugeIcons.strokeRoundedRestaurant01,
      items: [
        CategoryIconItem(
          key: 'restaurant',
          label: 'Restoran',
          keywords: ['makan', 'restoran', 'restaurant', 'food', 'dine'],
          icon: HugeIcons.strokeRoundedRestaurant01,
        ),
        CategoryIconItem(
          key: 'huge_coffee',
          label: 'Kopi & Kafe',
          keywords: ['kopi', 'coffee', 'cafe', 'kafe', 'latte', 'espresso', 'teh', 'tea'],
          icon: HugeIcons.strokeRoundedCoffee01,
        ),
        CategoryIconItem(
          key: 'huge_fastfood',
          label: 'Makanan Cepat Saji',
          keywords: ['burger', 'fastfood', 'snack', 'kentang', 'junkfood'],
          icon: HugeIcons.strokeRoundedHamburger01,
        ),
        CategoryIconItem(
          key: 'huge_pizza',
          label: 'Pizza & Roti',
          keywords: ['pizza', 'roti', 'bakery', 'bread'],
          icon: HugeIcons.strokeRoundedPizza01,
        ),
        CategoryIconItem(
          key: 'huge_icecream',
          label: 'Es Krim & Dessert',
          keywords: ['es', 'ice cream', 'dessert', 'manis', 'sweet'],
          icon: HugeIcons.strokeRoundedIceCream01,
        ),
        CategoryIconItem(
          key: 'huge_drinks',
          label: 'Minuman / Boba',
          keywords: ['minuman', 'drink', 'juice', 'jus', 'boba', 'soda'],
          icon: HugeIcons.strokeRoundedDrink,
        ),
        CategoryIconItem(
          key: 'huge_fruits',
          label: 'Buah & Sayur',
          keywords: ['buah', 'fruit', 'sayur', 'vegetable', 'apel', 'apple', 'pasar'],
          icon: HugeIcons.strokeRoundedApple,
        ),
        CategoryIconItem(
          key: 'huge_cake',
          label: 'Kue & Ulang Tahun',
          keywords: ['kue', 'cake', 'tart', 'ulang tahun', 'birthday', 'snack'],
          icon: HugeIcons.strokeRoundedBirthdayCake,
        ),
        CategoryIconItem(
          key: 'huge_fish_food',
          label: 'Seafood & Ikan',
          keywords: ['ikan', 'fish', 'seafood', 'udang', 'sushi'],
          icon: HugeIcons.strokeRoundedFishFood,
        ),
        CategoryIconItem(
          key: 'huge_bar',
          label: 'Bar & Hiburan Malam',
          keywords: ['bar', 'wine', 'beer', 'alkohol', 'cocktail'],
          icon: HugeIcons.strokeRoundedSoftDrink01,
        ),
      ],
    ),

    // 2. Belanja & Keperluan
    CategoryIconGroup(
      id: 'shopping',
      title: 'Belanja & Retail',
      groupIcon: HugeIcons.strokeRoundedShoppingBag01,
      items: [
        CategoryIconItem(
          key: 'shopping_cart',
          label: 'Keranjang Belanja',
          keywords: ['belanja', 'shopping', 'cart', 'troli', 'supermarket', 'mart'],
          icon: HugeIcons.strokeRoundedShoppingCart01,
        ),
        CategoryIconItem(
          key: 'huge_shopping_bag',
          label: 'Tas Belanja',
          keywords: ['shopping bag', 'mall', 'belanja', 'olshop', 'store'],
          icon: HugeIcons.strokeRoundedShoppingBag01,
        ),
        CategoryIconItem(
          key: 'huge_store',
          label: 'Toko / Warung',
          keywords: ['toko', 'warung', 'store', 'shop', 'kios'],
          icon: HugeIcons.strokeRoundedStore01,
        ),
        CategoryIconItem(
          key: 'huge_clothes',
          label: 'Pakaian & Baju',
          keywords: ['baju', 'clothes', 'pakaian', 'fashion', 'tshirt', 'kaos', 'outfit'],
          icon: HugeIcons.strokeRoundedTShirt,
        ),
        CategoryIconItem(
          key: 'huge_shoes',
          label: 'Sepatu & Sandal',
          keywords: ['sepatu', 'shoes', 'sneakers', 'sandal', 'footwear'],
          icon: HugeIcons.strokeRoundedRunningShoes,
        ),
        CategoryIconItem(
          key: 'huge_discount',
          label: 'Diskon & Promo',
          keywords: ['diskon', 'discount', 'promo', 'sale', 'voucher', 'kupon'],
          icon: HugeIcons.strokeRoundedDiscountTag01,
        ),
        CategoryIconItem(
          key: 'huge_delivery',
          label: 'Paket & Pengiriman',
          keywords: ['paket', 'package', 'delivery', 'kurir', 'ongkir', 'shipping'],
          icon: HugeIcons.strokeRoundedDeliveryBox01,
        ),
        CategoryIconItem(
          key: 'huge_gadget',
          label: 'Elektronik & Gadget',
          keywords: ['gadget', 'hp', 'smartphone', 'elektronik', 'laptop', 'device'],
          icon: HugeIcons.strokeRoundedSmartPhone01,
        ),
        CategoryIconItem(
          key: 'huge_cosmetics',
          label: 'Skincare & Kosmetik',
          keywords: ['kosmetik', 'makeup', 'skincare', 'beauty', 'parfum', 'serum'],
          icon: HugeIcons.strokeRoundedSparkles,
        ),
      ],
    ),

    // 3. Transportasi & Perjalanan
    CategoryIconGroup(
      id: 'transport',
      title: 'Transportasi',
      groupIcon: HugeIcons.strokeRoundedCar01,
      items: [
        CategoryIconItem(
          key: 'directions_car',
          label: 'Mobil',
          keywords: ['mobil', 'car', 'kendaraan', 'drive', 'rental'],
          icon: HugeIcons.strokeRoundedCar01,
        ),
        CategoryIconItem(
          key: 'huge_motorcycle',
          label: 'Motor',
          keywords: ['motor', 'motorcycle', 'ojol', 'gojek', 'grab', 'ride'],
          icon: HugeIcons.strokeRoundedMotorbike01,
        ),
        CategoryIconItem(
          key: 'huge_fuel',
          label: 'Bensin & BBM',
          keywords: ['bensin', 'bbm', 'fuel', 'pertamax', 'pertalite', 'spbu', 'gas'],
          icon: HugeIcons.strokeRoundedFuelStation,
        ),
        CategoryIconItem(
          key: 'huge_bus',
          label: 'Bus & Angkot',
          keywords: ['bus', 'bis', 'angkot', 'transjakarta', 'public transport'],
          icon: HugeIcons.strokeRoundedBus01,
        ),
        CategoryIconItem(
          key: 'huge_train',
          label: 'Kereta & MRT/KRL',
          keywords: ['kereta', 'train', 'mrt', 'krl', 'lrt', 'railway'],
          icon: HugeIcons.strokeRoundedTrain01,
        ),
        CategoryIconItem(
          key: 'flight',
          label: 'Pesawat & Liburan',
          keywords: ['pesawat', 'flight', 'airplane', 'airport', 'bandara', 'travel'],
          icon: HugeIcons.strokeRoundedAirplane01,
        ),
        CategoryIconItem(
          key: 'huge_parking',
          label: 'Parkir & Tol',
          keywords: ['parkir', 'parking', 'tol', 'karcis', 'etoll'],
          icon: HugeIcons.strokeRoundedCarParking01,
        ),
        CategoryIconItem(
          key: 'huge_taxi',
          label: 'Taksi',
          keywords: ['taksi', 'taxi', 'cab', 'gocar', 'grabcar'],
          icon: HugeIcons.strokeRoundedTaxi,
        ),
      ],
    ),

    // 4. Tagihan & Rumah Tangga
    CategoryIconGroup(
      id: 'bills',
      title: 'Tagihan & Rumah',
      groupIcon: HugeIcons.strokeRoundedHome01,
      items: [
        CategoryIconItem(
          key: 'home',
          label: 'Rumah & Kost',
          keywords: ['rumah', 'home', 'kost', 'kosan', 'kontrakan', 'apartemen', 'rent'],
          icon: HugeIcons.strokeRoundedHome01,
        ),
        CategoryIconItem(
          key: 'huge_electricity',
          label: 'Listrik & Token PLN',
          keywords: ['listrik', 'electricity', 'pln', 'token', 'power', 'lampu'],
          icon: HugeIcons.strokeRoundedFlash,
        ),
        CategoryIconItem(
          key: 'huge_water',
          label: 'Air & PDAM',
          keywords: ['air', 'water', 'pdam', 'galon', 'aqua'],
          icon: HugeIcons.strokeRoundedDroplet,
        ),
        CategoryIconItem(
          key: 'huge_wifi',
          label: 'Internet & WiFi',
          keywords: ['wifi', 'internet', 'indihome', 'biznet', 'provider', 'kuota'],
          icon: HugeIcons.strokeRoundedWifi01,
        ),
        CategoryIconItem(
          key: 'huge_phone_bill',
          label: 'Pulsa & Paket Data',
          keywords: ['pulsa', 'kuota', 'paket data', 'telkomsel', 'indosat', 'xl', 'sim'],
          icon: HugeIcons.strokeRoundedSmartPhone01,
        ),
        CategoryIconItem(
          key: 'receipt',
          label: 'Tagihan Umum',
          keywords: ['tagihan', 'bill', 'receipt', 'struk', 'invoice', 'iuran'],
          icon: HugeIcons.strokeRoundedReceiptText,
        ),
        CategoryIconItem(
          key: 'huge_repair',
          label: 'Perbaikan & Servis',
          keywords: ['servis', 'service', 'repair', 'bengkel', 'renovasi', 'alat'],
          icon: HugeIcons.strokeRoundedWrench01,
        ),
        CategoryIconItem(
          key: 'huge_cleaning',
          label: 'Kebersihan & Laundry',
          keywords: ['laundry', 'cuci', 'kebersihan', 'cleaning', 'deterjen'],
          icon: HugeIcons.strokeRoundedClean,
        ),
      ],
    ),

    // 5. Hiburan & Gaya Hidup
    CategoryIconGroup(
      id: 'entertainment',
      title: 'Hiburan & Hobi',
      groupIcon: HugeIcons.strokeRoundedGameController01,
      items: [
        CategoryIconItem(
          key: 'movie',
          label: 'Bioskop & Film',
          keywords: ['bioskop', 'movie', 'film', 'cinema', 'netflix', 'streaming'],
          icon: HugeIcons.strokeRoundedFilm01,
        ),
        CategoryIconItem(
          key: 'sports_esports',
          label: 'Game & Topup',
          keywords: ['game', 'gaming', 'esports', 'topup', 'steam', 'playstation'],
          icon: HugeIcons.strokeRoundedGameController01,
        ),
        CategoryIconItem(
          key: 'huge_music',
          label: 'Musik & Spotify',
          keywords: ['musik', 'music', 'spotify', 'konser', 'headphone', 'lagu'],
          icon: HugeIcons.strokeRoundedHeadphones,
        ),
        CategoryIconItem(
          key: 'fitness_center',
          label: 'Gym & Olahraga',
          keywords: ['gym', 'fitness', 'olahraga', 'sport', 'workout', 'futsal', 'badminton'],
          icon: HugeIcons.strokeRoundedDumbbell01,
        ),
        CategoryIconItem(
          key: 'huge_camera',
          label: 'Foto & Kamera',
          keywords: ['foto', 'kamera', 'camera', 'photo', 'video', 'content'],
          icon: HugeIcons.strokeRoundedCamera01,
        ),
        CategoryIconItem(
          key: 'huge_books',
          label: 'Buku & Komik',
          keywords: ['buku', 'book', 'novel', 'komik', 'manga', 'reading'],
          icon: HugeIcons.strokeRoundedBook01,
        ),
        CategoryIconItem(
          key: 'card_giftcard',
          label: 'Hadiah & Kado',
          keywords: ['hadiah', 'gift', 'kado', 'giveaway', 'donasi', 'charity'],
          icon: HugeIcons.strokeRoundedGift,
        ),
        CategoryIconItem(
          key: 'huge_vacation',
          label: 'Liburan & Pantai',
          keywords: ['liburan', 'vacation', 'pantai', 'hotel', 'wisata', 'holiday'],
          icon: HugeIcons.strokeRoundedSun01,
        ),
      ],
    ),

    // 6. Kesehatan & Medis
    CategoryIconGroup(
      id: 'health',
      title: 'Kesehatan',
      groupIcon: HugeIcons.strokeRoundedHospital01,
      items: [
        CategoryIconItem(
          key: 'medical_services',
          label: 'Rumah Sakit & Dokter',
          keywords: ['dokter', 'doctor', 'hospital', 'klinik', 'puskesmas', 'periksa'],
          icon: HugeIcons.strokeRoundedHospital01,
        ),
        CategoryIconItem(
          key: 'huge_medicine',
          label: 'Obat & Farmasi',
          keywords: ['obat', 'medicine', 'pill', 'apotek', 'vitamin', 'suplemen'],
          icon: HugeIcons.strokeRoundedMedicineBottle01,
        ),
        CategoryIconItem(
          key: 'huge_heart_health',
          label: 'Kesehatan & Asuransi',
          keywords: ['kesehatan', 'health', 'asuransi', 'bpjs', 'medical', 'care'],
          icon: HugeIcons.strokeRoundedFavourite,
        ),
        CategoryIconItem(
          key: 'huge_shield',
          label: 'Perlindungan & Asuransi',
          keywords: ['asuransi', 'shield', 'proteksi', 'insurance', 'keamanan'],
          icon: HugeIcons.strokeRoundedShield01,
        ),
      ],
    ),

    // 7. Pendidikan & Karier
    CategoryIconGroup(
      id: 'education',
      title: 'Pendidikan & Karier',
      groupIcon: HugeIcons.strokeRoundedMortarboard01,
      items: [
        CategoryIconItem(
          key: 'school',
          label: 'Sekolah & Kuliah',
          keywords: ['sekolah', 'school', 'kuliah', 'universitas', 'spp', 'pendidikan'],
          icon: HugeIcons.strokeRoundedMortarboard01,
        ),
        CategoryIconItem(
          key: 'work',
          label: 'Pekerjaan & Kantor',
          keywords: ['kerja', 'work', 'kantor', 'office', 'job', 'karir'],
          icon: HugeIcons.strokeRoundedBriefcase01,
        ),
        CategoryIconItem(
          key: 'business',
          label: 'Bisnis & Usaha',
          keywords: ['bisnis', 'business', 'usaha', 'modal', 'toko', 'omzet'],
          icon: HugeIcons.strokeRoundedBuilding01,
        ),
        CategoryIconItem(
          key: 'huge_certificate',
          label: 'Kursus & Sertifikasi',
          keywords: ['kursus', 'course', 'sertifikat', 'bootcamp', 'training', 'les'],
          icon: HugeIcons.strokeRoundedCertificate01,
        ),
      ],
    ),

    // 8. Finansial & Dompet
    CategoryIconGroup(
      id: 'finance',
      title: 'Dompet & Finansial',
      groupIcon: HugeIcons.strokeRoundedWallet01,
      items: [
        CategoryIconItem(
          key: 'wallet',
          label: 'Dompet Utama',
          keywords: ['dompet', 'wallet', 'uang', 'saku', 'kas', 'utama', 'cash'],
          icon: HugeIcons.strokeRoundedWallet01,
        ),
        CategoryIconItem(
          key: 'bank',
          label: 'Bank & Rekening',
          keywords: ['bank', 'bca', 'bri', 'bni', 'mandiri', 'jago', 'rekening', 'atm'],
          icon: HugeIcons.strokeRoundedBank,
        ),
        CategoryIconItem(
          key: 'credit_card',
          label: 'Kartu Kredit / Debit',
          keywords: ['kartu kredit', 'credit card', 'debit', 'visa', 'mastercard', 'atm'],
          icon: HugeIcons.strokeRoundedCreditCard,
        ),
        CategoryIconItem(
          key: 'cash',
          label: 'Uang Tunai / Cash',
          keywords: ['tunai', 'cash', 'uang', 'money', 'lembaran', 'rupiah'],
          icon: HugeIcons.strokeRoundedMoney01,
        ),
        CategoryIconItem(
          key: 'savings',
          label: 'Tabungan & Celengan',
          keywords: ['tabungan', 'saving', 'celengan', 'simpanan', 'dana darurat'],
          icon: HugeIcons.strokeRoundedPiggyBank,
        ),
        CategoryIconItem(
          key: 'money',
          label: 'Gaji & Uang',
          keywords: ['gaji', 'salary', 'uang', 'money', 'income', 'pendapatan'],
          icon: HugeIcons.strokeRoundedMoney02,
        ),
        CategoryIconItem(
          key: 'investment',
          label: 'Investasi & Saham',
          keywords: ['investasi', 'investment', 'saham', 'reksadana', 'crypto', 'profit', 'cuan'],
          icon: HugeIcons.strokeRoundedTradeUp,
        ),
        CategoryIconItem(
          key: 'mobile',
          label: 'E-Wallet / Dompet Digital',
          keywords: ['ewallet', 'gopay', 'ovo', 'dana', 'shopeepay', 'linkaja', 'mobile', 'hp', 'digital'],
          icon: HugeIcons.strokeRoundedSmartPhone01,
        ),
        CategoryIconItem(
          key: 'coins',
          label: 'Koin & Receh',
          keywords: ['koin', 'coins', 'receh', 'tabungan', 'uang'],
          icon: HugeIcons.strokeRoundedCoins01,
        ),
        CategoryIconItem(
          key: 'store',
          label: 'Kas Toko / Usaha',
          keywords: ['toko', 'warung', 'store', 'usaha', 'omzet', 'bisnis'],
          icon: HugeIcons.strokeRoundedStore01,
        ),
        CategoryIconItem(
          key: 'payments',
          label: 'Pembayaran / Kasir',
          keywords: ['bayar', 'payment', 'kasir', 'transaksi', 'struk'],
          icon: HugeIcons.strokeRoundedMoney01,
        ),
        CategoryIconItem(
          key: 'huge_award',
          label: 'Bonus & Hadiah',
          keywords: ['bonus', 'thr', 'reward', 'award', 'komisi', 'cashback'],
          icon: HugeIcons.strokeRoundedAward01,
        ),
        CategoryIconItem(
          key: 'swap_horiz',
          label: 'Transfer Antar Dompet',
          keywords: ['transfer', 'pindah', 'mutasi', 'swap', 'kirim', 'antar dompet', 'exchange'],
          icon: HugeIcons.strokeRoundedTransaction,
        ),
      ],
    ),

    // 9. Keluarga, Hewan & Lainnya
    CategoryIconGroup(
      id: 'misc',
      title: 'Keluarga & Lainnya',
      groupIcon: HugeIcons.strokeRoundedUserGroup,
      items: [
        CategoryIconItem(
          key: 'pets',
          label: 'Hewan Peliharaan',
          keywords: ['hewan', 'pet', 'kucing', 'anjing', 'cat', 'dog', 'pakan', 'vet'],
          icon: HugeIcons.strokeRoundedFavourite,
        ),
        CategoryIconItem(
          key: 'child_care',
          label: 'Bayi & Anak',
          keywords: ['bayi', 'baby', 'anak', 'child', 'susu', 'pampers', 'mainan'],
          icon: HugeIcons.strokeRoundedUserGroup,
        ),
        CategoryIconItem(
          key: 'huge_family',
          label: 'Keluarga & Pasangan',
          keywords: ['keluarga', 'family', 'orang tua', 'pasangan', 'transfer keluarga'],
          icon: HugeIcons.strokeRoundedUserGroup,
        ),
        CategoryIconItem(
          key: 'category',
          label: 'Kategori Umum',
          keywords: ['kategori', 'category', 'lainnya', 'general', 'misc'],
          icon: HugeIcons.strokeRoundedGrid,
        ),
      ],
    ),
  ];

  /// Find a specific icon item by key
  static CategoryIconItem? findByKey(String key) {
    for (final group in groups) {
      for (final item in group.items) {
        if (item.key == key) return item;
      }
    }
    return null;
  }

  /// Get HugeIcon data for a given key, with fallback to default category icon
  static List<List<dynamic>> getIconData(String key) {
    final item = findByKey(key);
    if (item != null) return item.icon;

    // Legacy and key alias fallback mapping
    switch (key) {
      // Wallet & Financial Aliases
      case 'wallet':
      case 'account_balance_wallet':
      case 'account_balance_wallet_outlined':
      case 'huge_wallet':
        return HugeIcons.strokeRoundedWallet01;
      case 'bank':
      case 'account_balance':
      case 'huge_bank':
        return HugeIcons.strokeRoundedBank;
      case 'credit_card':
      case 'credit_card_outlined':
      case 'huge_credit_card':
        return HugeIcons.strokeRoundedCreditCard;
      case 'cash':
      case 'money':
      case 'payments':
      case 'payment':
      case 'monetization_on':
      case 'attach_money':
      case 'huge_money':
        return HugeIcons.strokeRoundedMoney01;
      case 'savings':
      case 'savings_outlined':
      case 'huge_piggy_bank':
        return HugeIcons.strokeRoundedPiggyBank;
      case 'investment':
      case 'trending_up':
      case 'show_chart':
      case 'huge_investment':
        return HugeIcons.strokeRoundedTradeUp;
      case 'mobile':
      case 'phone_android':
      case 'smartphone':
      case 'huge_mobile':
        return HugeIcons.strokeRoundedSmartPhone01;
      case 'store':
      case 'storefront':
      case 'huge_store':
        return HugeIcons.strokeRoundedStore01;
      case 'coins':
      case 'huge_coins':
        return HugeIcons.strokeRoundedCoins01;

      // Category Aliases
      case 'restaurant':
        return HugeIcons.strokeRoundedRestaurant01;
      case 'local_cafe':
      case 'coffee':
        return HugeIcons.strokeRoundedCoffee01;
      case 'local_bar':
      case 'bar':
      case 'drinks':
        return HugeIcons.strokeRoundedDrink;
      case 'fastfood':
      case 'burger':
        return HugeIcons.strokeRoundedHamburger01;
      case 'directions_car':
      case 'drive_eta':
      case 'commute':
        return HugeIcons.strokeRoundedCar01;
      case 'shopping_cart':
      case 'shopping_bag':
        return HugeIcons.strokeRoundedShoppingCart01;
      case 'receipt':
      case 'receipt_long':
      case 'bill':
        return HugeIcons.strokeRoundedReceiptText;
      case 'movie':
      case 'theaters':
        return HugeIcons.strokeRoundedFilm01;
      case 'medical_services':
      case 'local_hospital':
      case 'health_and_safety':
        return HugeIcons.strokeRoundedHospital01;
      case 'school':
      case 'menu_book':
        return HugeIcons.strokeRoundedMortarboard01;
      case 'flight':
      case 'flight_takeoff':
        return HugeIcons.strokeRoundedAirplane01;
      case 'business':
      case 'domain':
        return HugeIcons.strokeRoundedBuilding01;
      case 'card_giftcard':
      case 'redeem':
        return HugeIcons.strokeRoundedGift;
      case 'home':
      case 'house':
        return HugeIcons.strokeRoundedHome01;
      case 'fitness_center':
      case 'sports':
        return HugeIcons.strokeRoundedDumbbell01;
      case 'work':
      case 'business_center':
        return HugeIcons.strokeRoundedBriefcase01;
      case 'sports_esports':
      case 'gamepad':
        return HugeIcons.strokeRoundedGameController01;
      case 'child_care':
      case 'baby':
      case 'pets':
        return HugeIcons.strokeRoundedUserGroup;
      case 'favorite':
      case 'favorite_border':
        return HugeIcons.strokeRoundedFavourite;
      case 'swap_horiz':
      case 'swap_horizontal':
      case 'transfer':
      case 'transaction':
      case 'exchange':
        return HugeIcons.strokeRoundedTransaction;
      default:
        return HugeIcons.strokeRoundedGrid;
    }
  }

  /// Search catalog by query
  static List<CategoryIconItem> search(String query) {
    if (query.trim().isEmpty) {
      return groups.expand((g) => g.items).toList();
    }
    final q = query.toLowerCase().trim();
    final results = <CategoryIconItem>[];
    final seen = <String>{};

    for (final group in groups) {
      for (final item in group.items) {
        if (seen.contains(item.key)) continue;

        if (item.label.toLowerCase().contains(q) ||
            item.key.toLowerCase().contains(q) ||
            item.keywords.any((k) => k.contains(q) || q.contains(k))) {
          results.add(item);
          seen.add(item.key);
        }
      }
    }
    return results;
  }
}
