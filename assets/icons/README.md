# Assets - App Launcher Icons

Letakkan file icon di folder ini sesuai nama berikut:

1. `app_icon.png` (Icon Utama Standar / Legacy):
   - **Ukuran**: 1024 x 1024 px
   - **Format**: PNG (32-bit PNG dengan background solid/transparan)
   - **Fungsi**: Digunakan untuk icon aplikasi di iOS, Android versi lama, dan store listing.

2. `foreground.png` (Adaptive Icon Foreground - Android 8.0+):
   - **Ukuran**: 1024 x 1024 px (atau 512 x 512 px)
   - **Format**: PNG Transparan (hanya simbol logo di area tengah ~66%, safe zone radius 66%)
   - **Fungsi**: Lambang/logo yang berada di atas background adaptive icon.

3. `background.png` (Opsional jika ingin background berupa gambar):
   - **Ukuran**: 1024 x 1024 px
   - **Format**: PNG Solid tanpa transparansi
   - *(Jika tidak ada file background.png, warna hex `#1E293B` di `pubspec.yaml` yang akan digunakan)*.
