# Hajj App

Hajj App adalah aplikasi mobile berbasis Flutter untuk membantu jemaah dan petugas haji dalam proses pencarian lokasi, navigasi, serta komunikasi bantuan secara cepat. Aplikasi ini menggabungkan GPS, Firebase Realtime Database, dan Mapbox untuk menampilkan lokasi terdekat, rute berjalan, serta chat bantuan dua arah.

## 1. Deskripsi Aplikasi

### Tujuan aplikasi
- Membantu jemaah haji menemukan petugas haji terdekat saat berada di area operasional yang didukung sistem (utama: Makkah, termasuk zona pengujian UIN Sunan Gunung Djati Bandung).
- Menyediakan kanal bantuan yang lebih cepat melalui chat dan notifikasi.
- Menampilkan navigasi berbasis peta agar pengguna bisa bergerak menuju lokasi tujuan dengan lebih jelas.

### Masalah yang diselesaikan
- Jemaah sering kesulitan menemukan petugas saat kondisi ramai atau terpisah dari rombongan.
- Komunikasi darurat perlu terjadi cepat tanpa harus mencari petugas secara manual.
- Pengguna membutuhkan petunjuk lokasi dan arah yang mudah dipahami di perangkat mobile.

### Pengguna utama
- Jemaah haji.
- Petugas haji.

## 2. Fitur Utama

### Fitur yang tersedia
- Onboarding awal untuk memperkenalkan aplikasi.
- Autentikasi pengguna:
  - Login
  - Register
  - Forgot password
- Home berisi tampilan jam analog dan waktu dua zona, yaitu Makkah dan Indonesia.
- Menu Find My untuk:
  - mengambil lokasi pengguna saat ini,
  - menampilkan lokasi dalam bentuk peta,
  - mencari petugas terdekat,
  - memperbarui lokasi pengguna ke database.
- Halaman peta utama untuk:
  - menampilkan marker lokasi,
  - menampilkan daftar petugas terdekat,
  - membuka navigasi ke petugas,
  - mengirim permintaan bantuan.
- Halaman navigasi untuk:
  - menampilkan rute berjalan,
  - menampilkan instruksi arah langkah demi langkah,
  - menghitung jarak dan estimasi waktu tempuh.
- Fitur bantuan:
  - inbox bantuan,
  - chat bantuan,
  - quick template pesan,
  - notifikasi bantuan baru.
- Halaman settings/profil untuk:
  - melihat data akun,
  - mengubah profil,
  - mengubah password,
  - melihat help inbox,
  - logout.

### Alur penggunaan singkat
1. Pengguna membuka aplikasi dan login.
2. Aplikasi membaca role pengguna dari Firebase.
3. GPS aktif untuk mengambil lokasi terbaru.
4. Jika pengguna jemaah, aplikasi mencari petugas terdekat.
5. Pengguna dapat membuka peta, memilih petugas, lalu melihat navigasi.
6. Jika butuh bantuan, pengguna dapat mengirim chat ke petugas.
7. Petugas menerima inbox/notifikasi lalu membuka percakapan.

## 3. Teknologi yang Digunakan

### Framework
- Flutter
- Dart

### Database dan backend
- Firebase Authentication
- Firebase Realtime Database
- Firebase Storage
- Firebase App Check

### API dan layanan peta
- Mapbox Maps SDK
- Mapbox Directions API

### Library penting lainnya
- `geolocator` untuk akses GPS dan stream lokasi
- `geocoding` untuk mengubah koordinat menjadi alamat
- `flutter_local_notifications` untuk notifikasi lokal
- `http` untuk request ke Mapbox Directions API
- `intl` untuk format waktu
- `hijri` untuk kalender Hijriah
- `analog_clock` untuk jam analog
- `iconsax` untuk ikon UI
- `flutter_animate` untuk animasi tampilan
- `salomon_bottom_bar` untuk navigasi bawah
- `csv` untuk utilitas import data user dari file CSV
- `flutter_dotenv` untuk membaca token dari file `.env`

## 4. Cara Kerja Sistem

### Alur dari membuka aplikasi sampai hasil tampil
1. `main.dart` melakukan inisialisasi Firebase, App Check, dotenv, Mapbox token, dan layanan notifikasi lokal.
2. Aplikasi memeriksa status login melalui Firebase Auth.
3. Jika user sudah login, aplikasi memulai:
   - pelacakan lokasi,
   - polling notifikasi bantuan secara periodik (sekitar tiap 12 detik).
4. Jika user belum login, aplikasi menampilkan onboarding lalu halaman login.
5. Setelah login, user masuk ke halaman utama sesuai route aplikasi.

### Bagaimana GPS digunakan
- Aplikasi meminta izin lokasi melalui `geolocator`.
- Lokasi saat ini diambil dengan `getCurrentPosition()`.
- Pada mode tertentu, lokasi juga dipantau dengan `getPositionStream()` agar posisi bisa diperbarui terus.
- Lokasi terbaru pengguna disimpan kembali ke `users/{userId}` di Firebase Realtime Database.
- Koordinat ini dipakai untuk:
  - menghitung petugas terdekat,
  - membuat rute navigasi,
  - mengirim lokasi pengguna saat chat bantuan.

### Bagaimana data diambil dari database
- Data profil user dibaca dari node `users`.
- Data percakapan bantuan dibaca dari:
  - `helpConversations`
  - `helpConversationSessions`
  - `helpNotificationRequests`
- `UserService` mengambil dan melakukan cache pada profil user untuk mengurangi pembacaan berulang.
- `HelpService` mengelola:
  - pembuatan percakapan,
  - pengiriman pesan,
  - penandaan pesan telah dibaca,
  - penutupan percakapan,
  - inbox bantuan.

### Bagaimana pencarian petugas terdekat dilakukan
1. Aplikasi mengambil daftar user dari node `users`.
2. Data difilter berdasarkan role petugas haji.
3. User yang sedang login dikeluarkan dari hasil pencarian.
4. Hanya petugas yang berada di area operasional yang didukung (Makkah dan UIN Sunan Gunung Djati Bandung untuk pengujian) yang diproses.
5. Jarak dihitung dari posisi user ke setiap petugas menggunakan algoritma Haversine.
6. Hasil diurutkan dari jarak paling kecil ke paling besar.
7. Aplikasi menampilkan sejumlah petugas terdekat di daftar dan peta.

## 5. Implementasi Algoritma Haversine

### Digunakan di bagian mana
- `lib/screens/features/finding/haversine_algorithm.dart`
- `map_screen.dart`
- `navigation_screen.dart`

### Input
- Latitude pengguna saat ini
- Longitude pengguna saat ini
- Latitude petugas
- Longitude petugas

### Proses
- Koordinat derajat diubah ke radian.
- Selisih lintang dan bujur dihitung.
- Rumus Haversine digunakan untuk mendapatkan jarak garis lengkung di permukaan bumi.
- Hasil jarak dikonversi ke kilometer.

### Output
- Jarak antara user dan petugas dalam kilometer.

### Pengurutan hasil
- Semua petugas yang valid diberi nilai jarak.
- Data kemudian diurutkan dari jarak paling kecil.
- Sistem mengambil beberapa petugas terdekat untuk ditampilkan ke pengguna.

## 6. Integrasi Mapbox

### Digunakan untuk apa
- Menampilkan peta interaktif.
- Menampilkan lokasi pengguna.
- Menampilkan marker petugas dan tujuan.
- Menampilkan polyline/rute navigasi.
- Menampilkan arah langkah demi langkah pada layar navigasi.

### Apakah menggunakan Directions API
- Ya. Aplikasi tidak hanya memakai Mapbox untuk visualisasi.
- Pada proses navigasi, aplikasi memanggil Mapbox Directions API dengan profil berjalan (`walking`) untuk mendapatkan:
  - geometry rute,
  - distance,
  - duration,
  - steps/instruksi arah.

### Alur penggunaan Mapbox
1. Token Mapbox dibaca dari file `.env`.
2. Mapbox dipakai untuk inisialisasi peta dan style.
3. Peta menampilkan posisi user dengan location puck.
4. Saat user memilih petugas, aplikasi memanggil Directions API.
5. Hasil API diproses menjadi polyline dan instruksi navigasi.

## 7. Struktur Aplikasi

### Folder utama
- `lib/core`
  - konstanta, theme, utilitas umum, dan widget bersama.
- `lib/models`
  - model data seperti `UserModel`.
- `lib/services`
  - akses Firebase, chat, notifikasi lokal, dan data user.
- `lib/screens`
  - seluruh halaman aplikasi.
- `lib/widgets`
  - komponen UI reusable seperti bottom bar, top bar, onboarding page, dan radar.
- `assets`
  - aset gambar dan data CSV.

### File penting
- `lib/main.dart`
  - entry point aplikasi, inisialisasi Firebase, App Check, Mapbox, notifikasi, dan routing.
- `lib/services/user_service.dart`
  - membaca dan memperbarui profil user di Realtime Database.
- `lib/services/help_service.dart`
  - logika chat bantuan, inbox, session, dan notifikasi bantuan.
- `lib/screens/features/finding/map_screen.dart`
  - layar peta utama untuk pencarian petugas dan bantuan.
- `lib/screens/features/finding/navigation_screen.dart`
  - layar navigasi menuju petugas.
- `lib/screens/features/finding/haversine_algorithm.dart`
  - fungsi perhitungan jarak antar koordinat.
- `lib/screens/features/help/help_inbox.dart`
  - daftar percakapan bantuan.
- `lib/screens/features/help/help_chat.dart`
  - ruang percakapan bantuan.
- `lib/screens/features/menu/menu_shell_screen.dart`
  - shell menu dengan tab Home, Find My, dan Settings.
- `lib/screens/presentation/onboarding_screen.dart`
  - halaman onboarding awal.

## 8. Alur Data

- User login ke aplikasi.
- Firebase Auth memvalidasi identitas user.
- Profil user dibaca dari `users`.
- GPS mengambil koordinat user.
- Koordinat user disimpan ke database.
- Sistem menghitung petugas terdekat dengan Haversine.
- Hasil ditampilkan di peta dan daftar.
- User dapat membuka navigasi atau chat bantuan.
- Pesan masuk dan status percakapan disimpan di `helpConversations`.
- Notifikasi bantuan disimpan di `helpNotificationRequests`.

## 9. Catatan

- Aplikasi menggunakan data nyata dari Firebase Realtime Database, tetapi ada utilitas impor CSV untuk kebutuhan inisialisasi data saat pengembangan.
- File `importDataFromCSVToFirebase()` di `user_service.dart` bersifat utilitas dan tidak dijalankan otomatis.
- Aplikasi bergantung pada koneksi internet, GPS, dan konfigurasi token Mapbox.
- Jika izin lokasi ditolak, fitur pencarian petugas dan navigasi tidak dapat berjalan normal.
- Firebase App Check menggunakan mode debug saat pengembangan, sehingga token debug perlu didaftarkan di Firebase Console.
- Pada perangkat iOS, deployment target disetel ke `15.0`.

## 10. Cara Menjalankan Aplikasi

### Persiapan
Pastikan file `.env` tersedia di root proyek dan berisi minimal:

```env
MAPBOX_PUBLIC_KEY=your_mapbox_public_key
MAPBOX_SECRET_KEY=your_mapbox_secret_key
```

### Jalankan aplikasi
```bash
flutter pub get
flutter run
```

### Jalankan di Android emulator
```bash
flutter run -d emulator-5554
```

### Jalankan di iPhone simulator
```bash
flutter devices
flutter run -d <ios_simulator_id>
```

### Build Android APK
```bash
flutter build apk --release
```

### Build iOS
```bash
cd ios
pod install --repo-update
cd ..
flutter devices
flutter run -d <ios_simulator_id>
```

## 11. Arsitektur Sistem

Arsitektur aplikasi ini dapat dipahami sebagai beberapa lapisan yang saling terhubung.

### Lapisan presentasi
Lapisan ini terdiri dari seluruh halaman dan widget yang ditampilkan kepada pengguna, seperti login, home, pencarian petugas, navigasi, inbox bantuan, dan settings. Lapisan presentasi bertugas menerima input user, menampilkan data hasil pengolahan, dan mengarahkan user ke halaman berikutnya.

### Lapisan logika dan layanan
Lapisan ini berisi kelas service yang menjadi penghubung antara tampilan dan data, yaitu:
- `UserService` untuk membaca dan memperbarui data user.
- `HelpService` untuk mengelola percakapan bantuan, inbox, dan status pesan.
- `LocalNotificationService` untuk menampilkan notifikasi lokal.

Lapisan ini menangani proses inti seperti pemilihan role user, pembaruan lokasi, pembentukan percakapan, serta pengiriman pesan bantuan.

### Lapisan data
Lapisan data menggunakan Firebase Realtime Database, Firebase Authentication, dan Firebase Storage. Data user disimpan di node `users`, data chat di `helpConversations`, sesi percakapan di `helpConversationSessions`, dan antrian notifikasi di `helpNotificationRequests`.

### Lapisan layanan eksternal
Lapisan ini mencakup Mapbox dan layanan lokasi perangkat. Mapbox digunakan untuk menampilkan peta dan mengambil rute berjalan, sedangkan GPS perangkat digunakan untuk membaca posisi aktual user. Keduanya menjadi fondasi utama pada fitur pencarian petugas dan navigasi.

### Alur antar lapisan
Secara sederhana, alurnya adalah:
1. User membuka halaman aplikasi.
2. Halaman memanggil service yang sesuai.
3. Service membaca atau menulis data ke Firebase / Mapbox / GPS.
4. Hasil pengolahan dikembalikan ke tampilan.
5. User melihat hasilnya dalam bentuk daftar, peta, notifikasi, atau chat.

Arsitektur seperti ini memisahkan tampilan, logika, dan sumber data sehingga aplikasi lebih mudah dipahami untuk kebutuhan pengembangan maupun penulisan laporan.

## 12. Alur Sistem

Bagian ini menjelaskan flow aplikasi dari awal sampai user memperoleh hasil pencarian atau bantuan.

### Flow utama
1. User membuka aplikasi.
2. `main.dart` melakukan inisialisasi Firebase, App Check, dotenv, Mapbox, dan notifikasi lokal.
3. Aplikasi memeriksa status login user melalui Firebase Auth.
4. Jika belum login, user diarahkan ke onboarding lalu login.
5. Jika sudah login, user masuk ke halaman utama.
6. Sistem membaca role user dari Firebase Realtime Database.
7. Sistem meminta izin lokasi jika belum tersedia.
8. GPS mengambil koordinat aktual user.
9. Koordinat user disimpan kembali ke database agar data lokasi selalu mutakhir.
10. Jika user adalah jemaah, sistem mengambil daftar petugas dari node `users`.
11. Sistem menghitung jarak ke setiap petugas dengan algoritma Haversine.
12. Hasil diurutkan dari yang paling dekat.
13. Aplikasi menampilkan daftar petugas terdekat beserta peta.
14. User dapat memilih petugas untuk membuka navigasi atau chat bantuan.
15. Jika user mengirim pesan bantuan, pesan disimpan ke `helpConversations` dan notifikasi masuk dicatat ke `helpNotificationRequests`.
16. Petugas menerima inbox atau notifikasi, lalu membuka percakapan untuk menindaklanjuti permintaan.

### Flow saat user memilih petugas
1. User melihat daftar petugas terdekat.
2. User mengetuk salah satu petugas.
3. Aplikasi membuka detail petugas atau navigasi.
4. Jika user menekan tombol `Go`, sistem memanggil Mapbox Directions API.
5. Hasil rute divisualisasikan di peta dan ditampilkan sebagai instruksi langkah demi langkah.
6. Jika user menekan `Help`, sistem membuka chat bantuan untuk mengirim pesan ke petugas tersebut.

### Flow saat petugas menerima bantuan
1. Petugas login ke aplikasi.
2. Sistem membaca inbox bantuan milik petugas.
3. Jika ada pesan baru, sistem menampilkan inbox dan notifikasi lokal.
4. Petugas membuka percakapan.
5. Petugas dapat membalas pesan, melihat lokasi, atau membuka navigasi menuju pengguna.

Flow di atas menunjukkan bahwa aplikasi bukan hanya menampilkan peta, tetapi juga membentuk alur layanan bantuan dari pencarian lokasi sampai komunikasi tindakan.

## 13. Deskripsi Tiap Halaman Aplikasi

### Onboarding
Halaman onboarding berfungsi sebagai pengenalan awal aplikasi. Di sini user melihat penjelasan singkat tentang fungsi utama aplikasi sebelum masuk ke login. Halaman ini membantu memberikan konteks bahwa aplikasi dipakai untuk bantuan dan pencarian petugas.

### Login
Halaman login digunakan untuk autentikasi user ke Firebase Authentication. Setelah berhasil login, aplikasi membaca profil dan role user dari database. Role ini menentukan apakah user diperlakukan sebagai jemaah atau petugas, sehingga alur fitur yang ditampilkan dapat berbeda.

### Register
Halaman register digunakan untuk membuat akun baru. Data yang dimasukkan user akan diproses agar akun dapat digunakan untuk login. Setelah registrasi, user masuk ke alur aplikasi yang sama seperti pengguna lain.

### Forgot Password
Halaman ini digunakan untuk reset kata sandi. Fungsinya penting agar user tetap dapat mengakses akun tanpa harus membuat akun baru ketika lupa password.

### Home
Halaman Home menampilkan jam analog, tanggal Hijriah, dan waktu untuk Makkah serta Indonesia. Walaupun terlihat sederhana, halaman ini menjadi halaman informatif utama setelah login dan berfungsi sebagai pintu masuk menuju menu lain melalui shell menu.

### Find My
Halaman Find My adalah pusat fitur pencarian lokasi. Halaman ini mengambil lokasi GPS user, memperbarui koordinat ke database, lalu menampilkan peta dan tombol untuk mencari petugas. Role user juga dibaca di sini untuk menentukan label tombol, misalnya `Find Officers` atau `Find Pilgrims`.

### Pencarian Petugas / Hasil Search
Bagian pencarian petugas menampilkan daftar petugas yang sudah diurutkan berdasarkan jarak terdekat. Hasil ini berasal dari perhitungan Haversine dan filter area operasional yang dikonfigurasi sistem. Halaman ini merupakan hasil langsung dari proses logika sistem, bukan hanya hasil visual.

### Map Screen
Halaman peta utama digunakan untuk menampilkan lokasi user, marker petugas, dan informasi ringkas petugas terdekat. Dari halaman ini user dapat:
- membuka navigasi,
- mengirim bantuan,
- melihat petugas dalam tampilan peta,
- memusatkan peta ke lokasi user.

Halaman ini berperan sebagai jembatan antara pencarian petugas dan tindakan lanjutan.

### Navigation Screen
Halaman navigasi menampilkan rute menuju petugas terpilih. Di dalamnya terdapat polyline rute, lokasi tujuan, instruksi belok, estimasi jarak, dan estimasi waktu tempuh. Halaman ini mengubah hasil Mapbox Directions API menjadi panduan yang mudah dipahami user.

### Help Inbox
Halaman help inbox menampilkan daftar percakapan bantuan yang masuk atau keluar. Halaman ini penting untuk petugas karena menjadi pusat pemantauan permintaan bantuan dari jemaah. Status pesan belum dibaca juga ditampilkan di sini.

### Help Chat
Halaman chat bantuan dipakai untuk komunikasi dua arah antara jemaah dan petugas. User dapat mengirim pesan teks, memakai quick template, melihat status percakapan, dan pada kasus tertentu membuka navigasi dari dalam percakapan. Halaman ini menjadi inti dari fitur layanan bantuan.

### Settings
Halaman settings menampilkan identitas user, role, dan menu pengaturan akun. Dari halaman ini user dapat melihat help inbox, mengganti password, mengubah profil, membaca versi aplikasi, dan logout.

### Edit Profile dan Change Password
Kedua halaman ini merupakan halaman pendukung untuk pengelolaan akun. Edit profile dipakai untuk memperbarui data identitas dan foto, sedangkan change password digunakan untuk menjaga akses akun tetap aman.

### Kaitan antarhalaman
Semua halaman di atas saling berhubungan melalui routing aplikasi:
- onboarding mengarah ke login,
- login mengarah ke home,
- home mengarah ke Find My atau settings,
- Find My mengarah ke map dan navigasi,
- navigasi dan map dapat mengarah ke help chat,
- help inbox menjadi daftar percakapan bantuan,
- settings mengarah ke edit profile, change password, dan inbox.

Dengan urutan ini, aplikasi membentuk alur yang jelas dari identitas user, pencarian petugas, sampai tindak lanjut bantuan.
