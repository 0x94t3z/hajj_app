# Demo Kolokium Hajj App

## Tujuan Demo

Menunjukkan alur utama aplikasi: login, pembacaan lokasi, pencarian petugas terdekat menggunakan Haversine Formula, visualisasi peta/rute dengan Mapbox, dan komunikasi bantuan melalui help chat.

## Persiapan Sebelum Presentasi

1. Pastikan koneksi internet aktif.
2. Pastikan file `.env` berisi token Mapbox yang valid.
3. Pastikan Firebase dapat diakses dan data user berisi role `Jemaah Haji` dan `Petugas Haji`.
4. Pastikan izin lokasi aktif pada emulator/simulator/perangkat fisik.
5. Siapkan akun demo jemaah dan akun demo petugas.
6. Siapkan screenshot cadangan dari folder `Docs/Pictures` atau `Docs/New Final UI` jika layanan GPS, Firebase, atau Mapbox bermasalah.

## Cara Menjalankan

```bash
flutter pub get
flutter run
```

Jika memakai iOS Simulator, atur lokasi simulasi agar berada di area pengujian. Jika memakai perangkat fisik, pastikan lokasi berada di area yang didukung sistem atau gunakan data/skenario uji yang sudah disiapkan.

## Alur Demo Utama

1. Buka aplikasi.
2. Login sebagai `Jemaah Haji`.
3. Tampilkan halaman Home.
4. Masuk ke menu `Find My`.
5. Jelaskan bahwa aplikasi mengambil koordinat pengguna melalui GPS dan menyimpan/membaca data lokasi dari Firebase.
6. Tekan `Find Officers`.
7. Tunjukkan daftar atau marker petugas terdekat.
8. Jelaskan bahwa urutan petugas dihitung menggunakan Haversine Formula berdasarkan latitude dan longitude.
9. Pilih salah satu petugas.
10. Tekan `Go` atau buka navigasi.
11. Jelaskan bahwa rute berjalan diambil dari Mapbox Directions API, sehingga jarak rute dapat berbeda dari jarak Haversine.
12. Tekan `Help` atau buka chat bantuan.
13. Kirim pesan singkat/template bantuan.
14. Tampilkan `Help Inbox` dari sisi petugas, atau jelaskan bahwa petugas menerima percakapan/notifikasi bantuan.
15. Tutup demo dengan menyebutkan batasan: sistem membutuhkan internet, izin lokasi, data petugas valid, Firebase, dan Mapbox.

## Narasi Singkat Saat Demo

Gunakan kalimat ini agar formal dan aman:

> Pada demo ini, saya menunjukkan alur aplikasi sebagai alat bantu pencarian petugas haji terdekat. Sistem membaca koordinat pengguna melalui GPS, mengambil data petugas dari Firebase, lalu menghitung jarak awal menggunakan Haversine Formula. Hasilnya digunakan untuk mengurutkan kandidat petugas terdekat. Setelah petugas dipilih, aplikasi menggunakan Mapbox Directions API untuk menampilkan rute berjalan.

## Kalimat Aman untuk Tanya Jawab

- Haversine digunakan untuk estimasi jarak awal antarkoordinat, bukan untuk menghitung jarak tempuh jalan.
- Jarak rute dari Mapbox dapat berbeda karena mengikuti jaringan jalan yang tersedia.
- Sistem ini merupakan alat bantu informasi lokasi dan komunikasi, bukan pengganti prosedur resmi layanan darurat haji.
- Akurasi hasil bergantung pada kualitas GPS, koneksi internet, validitas data petugas, dan ketersediaan layanan Firebase serta Mapbox.
- Pada penelitian ini, area yang didukung adalah Makkah dan zona pengujian UIN Sunan Gunung Djati Bandung sesuai konfigurasi sistem.

## Jika Demo Bermasalah

1. Jika GPS tidak muncul: jelaskan bahwa fitur membutuhkan izin lokasi dan gunakan screenshot `Find My`.
2. Jika Firebase gagal: jelaskan bahwa data petugas dibaca dari Realtime Database dan tampilkan slide alur sistem.
3. Jika Mapbox tidak memuat rute: jelaskan perbedaan fungsi Haversine dan Mapbox, lalu gunakan screenshot `map view` dan `navigasi`.
4. Jika chat tidak masuk: jelaskan struktur `helpConversations` dan `helpNotificationRequests`, lalu tampilkan screenshot `help requests`.

## Penutup Demo

> Dari demo ini dapat dilihat bahwa aplikasi menjalankan alur utama penelitian: membaca lokasi pengguna, menghitung jarak awal dengan Haversine, menampilkan kandidat petugas terdekat, membuka rute dengan Mapbox, dan menyediakan kanal bantuan melalui chat.
