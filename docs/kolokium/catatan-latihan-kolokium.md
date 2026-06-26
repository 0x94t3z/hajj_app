# Catatan Latihan Presentasi Kolokium Hajj App

Catatan ini dipakai untuk latihan menjelaskan slide tanpa membaca isi presentasi. Slide utama tetap berisi poin singkat, sedangkan penjelasan detail ada di file ini.

## Kapan Demo Dilakukan

Demo utama dilakukan pada **Slide 14 - Validasi Alur Aplikasi**.

Sebelum slide 14, cukup jelaskan konsep dan tunjukkan screenshot pada slide. Jangan langsung membuka aplikasi terlalu awal, supaya alur presentasi tetap rapi.

Jika dosen meminta bukti fitur sebelum slide 14, gunakan mini-demo singkat:

- Slide 11: tunjukkan tampilan login, home, dan find my dari screenshot, tidak perlu buka app.
- Slide 12: jika ditanya alur pencarian, boleh buka app sebentar sampai halaman Find My, lalu kembali ke slide.
- Slide 13: jika ditanya fitur bantuan, cukup jelaskan screenshot Help Inbox dan Chat.
- Slide 14: baru lakukan demo utama dari awal sampai akhir.

## Rundown Waktu

- Slide 1-3: pembukaan, latar belakang, dan rumusan masalah.
- Slide 4-5: tujuan, manfaat, dan batasan masalah penelitian.
- Slide 6-10: teknologi, metode, alur sistem, Haversine, dan Mapbox.
- Slide 11-13: tampilan aplikasi dan fitur utama.
- Slide 14: validasi alur aplikasi dan demo utama.
- Slide 15-17: rencana pengujian, penutup, dan kontak.

Target durasi aman: 8 sampai 12 menit. Jika waktu sempit, percepat slide 6-10 dan fokus pada slide 14.

## Slide 01 - Seminar Kolokium Tugas Akhir

**Tujuan slide:** membuka presentasi dan memperkenalkan topik.

**Yang dijelaskan:**

- Ucapkan salam.
- Ucapkan terima kasih karena dosen/audiens sudah menyempatkan hadir.
- Perkenalkan nama, NIM, jurusan, dan kampus.
- Sebutkan judul penelitian.
- Jelaskan singkat bahwa topik membahas aplikasi mobile untuk mencari petugas haji terdekat menggunakan Haversine Formula.

**Contoh kalimat:**

Assalamu'alaikum warahmatullahi wabarakatuh. Terima kasih kepada Bapak/Ibu dosen dan hadirin yang telah menyempatkan waktu untuk hadir pada kolokium ini. Perkenalkan, saya Muhamad Taopik, NIM 1197050081, dari Teknik Informatika UIN Sunan Gunung Djati Bandung. Pada kolokium ini saya akan mempresentasikan tugas akhir dengan judul pencarian lokasi terdekat petugas haji menggunakan Haversine Formula berbasis mobile.

**Demo:** tidak ada demo.

**Transisi:** lanjut ke latar belakang masalah.

## Slide 02 - Latar Belakang

**Tujuan slide:** menjelaskan kenapa topik ini perlu dibuat.

**Yang dijelaskan:**

- Ibadah haji berlangsung di area yang padat dan dinamis.
- Jemaah bisa kesulitan menemukan petugas ketika berada di lokasi yang tidak familiar.
- Pencarian manual dapat memakan waktu.
- Perangkat mobile dapat membantu membaca lokasi, menghitung jarak, dan menampilkan peta.

**Jangan dibaca:** jangan membaca semua poin satu per satu. Jelaskan sebagai cerita masalah.

**Contoh kalimat:**

Permasalahan yang saya angkat berawal dari kondisi ibadah haji yang padat dan luas. Dalam kondisi seperti itu, jemaah dapat kesulitan mengetahui posisi petugas terdekat. Karena perangkat mobile dapat membaca koordinat GPS, data lokasi tersebut dapat dimanfaatkan untuk membantu pencarian petugas secara lebih terarah.

**Demo:** tidak ada demo. Cukup arahkan perhatian ke screenshot kecil.

**Transisi:** dari masalah tersebut, masuk ke rumusan masalah penelitian.

## Slide 03 - Rumusan Masalah

**Tujuan slide:** menunjukkan fokus penelitian.

**Yang dijelaskan:**

- Fokus pertama: implementasi Haversine untuk perhitungan dan pengurutan jarak.
- Fokus kedua: aplikasi mobile untuk menampilkan lokasi petugas terdekat.
- Fokus ketiga: navigasi dan bantuan setelah petugas dipilih.

**Contoh kalimat:**

Dari latar belakang tersebut, penelitian ini difokuskan pada tiga hal. Pertama, bagaimana Haversine digunakan untuk menghitung dan mengurutkan jarak petugas. Kedua, bagaimana hasil tersebut ditampilkan pada aplikasi mobile. Ketiga, bagaimana pengguna dapat melanjutkan ke navigasi atau fitur bantuan.

**Demo:** tidak ada demo.

**Catatan untuk tanya jawab:**

Jika ditanya apakah sistem menggantikan petugas resmi, jawab: sistem ini hanya alat bantu informasi lokasi, bukan pengganti prosedur resmi.

**Transisi:** setelah masalah, jelaskan tujuan dan manfaat.

## Slide 04 - Tujuan dan Manfaat

**Tujuan slide:** menjelaskan target penelitian.

**Yang dijelaskan:**

- Tujuan penelitian: menghitung dan mengurutkan jarak petugas terdekat.
- Tujuan aplikasi: menampilkan peta, daftar petugas, rute, dan bantuan.
- Manfaat: menjadi referensi location-based service pada konteks haji.
- Alur output: koordinat jemaah, data petugas, ranking Haversine, marker pada peta, daftar petugas terdekat, rute/bantuan.

**Contoh kalimat:**

Tujuan utama penelitian ini adalah mengimplementasikan Haversine Formula untuk menghitung jarak awal antara jemaah dan petugas. Hasil perhitungan tersebut digunakan untuk mengurutkan kandidat petugas terdekat, kemudian divisualisasikan pada aplikasi mobile.

**Demo:** tidak ada demo.

**Transisi:** sebelum masuk teknis, jelaskan batasan penelitian agar pembahasan tetap terarah.

## Slide 05 - Batasan Masalah Penelitian

**Tujuan slide:** membuat klaim penelitian tetap proporsional.

**Yang dijelaskan:**

- Platform: Flutter mobile.
- Data: Firebase Realtime Database.
- Area: Makkah dan zona uji UIN Bandung.
- Haversine: estimasi jarak awal.
- Navigasi: Mapbox setelah tujuan dipilih.
- Prasyarat: internet, GPS, Firebase, Mapbox.

**Contoh kalimat:**

Pada penelitian ini, ruang lingkup saya batasi pada fungsi pencarian lokasi, pengurutan jarak, peta, rute, dan bantuan. Haversine digunakan untuk estimasi jarak awal, sedangkan rute jalan tetap menggunakan Mapbox setelah pengguna memilih tujuan.

**Demo:** tidak ada demo.

**Catatan penting:**

Tekankan bagian bawah slide: aplikasi adalah alat bantu informasi, bukan pengganti prosedur resmi. Ini penting supaya dosen melihat klaim penelitian tetap aman.

**Transisi:** setelah batasan, masuk ke teknologi yang digunakan.

## Slide 06 - Teknologi dan Komponen Sistem

**Tujuan slide:** menjelaskan komponen teknologi tanpa terlalu teknis.

**Yang dijelaskan:**

- Flutter dan Dart untuk aplikasi mobile.
- GPS/Geolocator untuk lokasi.
- Firebase untuk auth dan database.
- Haversine untuk ranking awal.
- Mapbox untuk peta dan rute.
- Node data utama: users dan help conversation.

**Contoh kalimat:**

Komponen sistem dibagi menjadi beberapa bagian. Aplikasi mobile dibuat dengan Flutter. Data pengguna dan lokasi disimpan di Firebase. GPS digunakan untuk mengambil koordinat, Haversine untuk menghitung jarak awal, dan Mapbox untuk menampilkan peta serta rute.

**Demo:** tidak ada demo.

**Transisi:** setelah teknologi, jelaskan metode atau tahapan penelitian.

## Slide 07 - Metodologi Penelitian

**Tujuan slide:** menunjukkan tahapan kerja penelitian.

**Yang dijelaskan:**

- Metode penelitian menggunakan System Development Life Cycle (SDLC).
- Planning: menentukan masalah dan ruang lingkup.
- Analysis: menganalisis data, role, alur, dan batasan.
- Design: merancang flow, arsitektur, UI, dan database.
- Development: implementasi Flutter, Firebase, Haversine, Mapbox.
- Testing: memeriksa jarak, urutan, peta, navigasi, bantuan.
- Implementation: menyiapkan perangkat atau simulator.

**Contoh kalimat:**

Pada penelitian ini saya menggunakan System Development Life Cycle atau SDLC. Tahapannya saya susun dari planning sampai implementation. Pada tahap analysis, saya melihat kebutuhan data dan role pengguna. Pada tahap development, sistem mulai diimplementasikan menggunakan Flutter, Firebase, Haversine, dan Mapbox.

**Demo:** tidak ada demo.

**Transisi:** setelah metode, jelaskan alur sistem pencarian.

## Slide 08 - Alur Sistem Pencarian

**Tujuan slide:** menjelaskan proses inti aplikasi.

**Yang dijelaskan:**

- Login membaca akun dan role.
- Lokasi mengambil koordinat GPS.
- Data petugas difilter.
- Haversine menghitung dan mengurutkan.
- Aksi menampilkan peta, rute, dan bantuan.

**Contoh kalimat:**

Alur sistem dimulai ketika pengguna login. Setelah itu aplikasi membaca role pengguna dan mengambil koordinat GPS. Data petugas dibaca dari Firebase, kemudian difilter. Haversine digunakan untuk menghitung jarak awal dan mengurutkan petugas. Setelah hasil tampil, pengguna dapat membuka rute atau mengirim bantuan.

**Demo:** tidak ada demo live. Ini masih penjelasan konsep.

**Transisi:** setelah alur, jelaskan bagian algoritma Haversine.

## Slide 09 - Implementasi Haversine Formula

**Tujuan slide:** menjelaskan peran rumus tanpa terlalu matematis.

**Yang dijelaskan:**

- Input: latitude dan longitude pengguna serta petugas.
- Proses: koordinat derajat dikonversi ke radian.
- Hitung selisih latitude dan longitude.
- Hitung nilai `a` dari komponen Haversine.
- Hitung jarak `d` dengan radius bumi 6371.0088 km.
- Output: jarak dalam kilometer.
- Output digunakan untuk ranking awal.

**Contoh kalimat:**

Haversine Formula digunakan untuk menghitung jarak antarkoordinat di permukaan bumi. Inputnya adalah latitude dan longitude dari pengguna dan petugas. Karena fungsi trigonometri bekerja dalam radian, koordinat yang awalnya dalam derajat dikonversi dulu ke radian. Setelah itu sistem menghitung selisih latitude dan longitude, menghitung nilai `a`, lalu menghitung jarak `d` menggunakan radius bumi 6371.0088 kilometer. Outputnya berupa jarak dalam kilometer, lalu jarak tersebut digunakan untuk mengurutkan petugas dari yang terdekat.

**Cara menjelaskan perhitungan detail:**

1. Ambil koordinat pengguna sebagai titik pertama: `lat1` dan `lon1`.
2. Ambil koordinat petugas sebagai titik kedua: `lat2` dan `lon2`.
3. Ubah latitude dan longitude dari derajat ke radian dengan `derajat × π / 180`.
4. Hitung selisih koordinat: `Δlat = lat2 - lat1` dan `Δlon = lon2 - lon1`.
5. Hitung nilai `a`:
   `a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)`.
6. Untuk menjaga stabilitas angka desimal, nilai `a` dibatasi pada rentang 0 sampai 1.
7. Hitung jarak:
   `d = 2r × asin(√a)`, dengan `r = 6371.0088 km`.
8. Ulangi perhitungan untuk setiap petugas, lalu urutkan dari nilai `d` terkecil.

**Kalimat aman jika ditanya akurasi:**

Haversine memberikan estimasi jarak antarkoordinat pada permukaan bumi. Jadi hasilnya dipakai untuk ranking awal petugas terdekat, bukan untuk menggantikan jarak tempuh jalan. Untuk rute jalan, aplikasi menggunakan Mapbox setelah petugas dipilih.

**Validasi sederhana:**

Jika dua koordinat sama, hasil jaraknya 0 km. Jika koordinat berbeda, nilai jarak bertambah sesuai selisih titik. Pada kode aplikasi, bentuk `atan2` digunakan setelah `a` di-clamp, dan hasilnya ekuivalen dengan bentuk `asin(√a)` yang ditampilkan pada slide.

**Demo:** tidak ada demo.

**Catatan tanya jawab:**

Jika ditanya kenapa tidak langsung pakai Mapbox untuk semua, jawab: Haversine dipakai untuk perhitungan awal yang ringan, sedangkan Mapbox dipakai setelah tujuan dipilih untuk rute jalan.

**Transisi:** setelah Haversine, jelaskan integrasi Mapbox.

## Slide 10 - Integrasi Mapbox

**Tujuan slide:** membedakan fungsi Haversine dan Mapbox.

**Yang dijelaskan:**

- Mapbox Maps SDK menampilkan peta dan marker.
- Directions API menampilkan rute, jarak, durasi, dan instruksi arah.
- Jarak Haversine dan Mapbox bisa berbeda.

**Contoh kalimat:**

Mapbox digunakan pada bagian visualisasi peta dan navigasi. Setelah pengguna memilih petugas, aplikasi meminta rute dari Mapbox Directions API. Jadi Haversine digunakan untuk mengurutkan kandidat awal, sedangkan Mapbox digunakan untuk rute berdasarkan jaringan jalan.

**Demo:** tidak ada demo live. Tunjukkan screenshot peta dan navigasi pada slide.

**Transisi:** setelah penjelasan teknis, masuk ke tampilan aplikasi.

## Slide 11 - Implementasi Antarmuka Aplikasi

**Tujuan slide:** menunjukkan tampilan akhir aplikasi.

**Yang dijelaskan:**

- Login: autentikasi pengguna.
- Home: informasi waktu.
- Find My: lokasi pengguna.
- Pencarian: proses menemukan petugas.

**Contoh kalimat:**

Pada slide ini saya tampilkan beberapa antarmuka utama aplikasi. Login digunakan untuk autentikasi, Home menampilkan informasi waktu, Find My mengambil lokasi pengguna, dan halaman pencarian digunakan saat aplikasi mencari petugas terdekat.

**Demo:** belum demo utama. Cukup tunjuk screenshot.

**Jika dosen meminta demo di sini:**

Jawab singkat: nanti saya tunjukkan alur lengkapnya pada slide demo, agar urutannya lebih jelas.

**Transisi:** setelah tampilan utama, jelaskan fitur pencarian dan navigasi.

## Slide 12 - Fitur Pencarian dan Navigasi

**Tujuan slide:** menjelaskan fitur utama aplikasi sebelum demo.

**Yang dijelaskan:**

- Daftar: hasil petugas terdekat.
- Map: marker dan detail petugas.
- Rute: navigasi setelah petugas dipilih.
- Haversine untuk ranking, Mapbox untuk rute.

**Contoh kalimat:**

Fitur utama aplikasi berada pada pencarian dan navigasi. Daftar petugas diurutkan berdasarkan jarak awal dari Haversine. Setelah pengguna memilih petugas, aplikasi menampilkan marker pada peta dan dapat membuka rute menggunakan Mapbox.

**Demo:** belum demo utama. Ini preview fitur.

**Transisi:** setelah pencarian dan navigasi, jelaskan fitur bantuan.

## Slide 13 - Fitur Bantuan dan Peran Pengguna

**Tujuan slide:** menjelaskan tindak lanjut setelah pencarian.

**Yang dijelaskan:**

- Role membedakan jemaah dan petugas.
- Help Inbox menampilkan permintaan bantuan.
- Chat digunakan untuk komunikasi.
- Notifikasi membantu petugas mengetahui permintaan baru.

**Contoh kalimat:**

Selain pencarian lokasi, aplikasi juga menyediakan fitur bantuan. Permintaan bantuan dapat masuk ke Help Inbox, kemudian percakapan dapat dilanjutkan melalui chat. Fitur ini digunakan sebagai tindak lanjut ketika jemaah membutuhkan bantuan dari petugas.

**Demo:** belum demo utama, kecuali dosen meminta.

**Catatan penting:**

Jangan klaim notifikasi selalu real-time sempurna. Jelaskan bahwa fitur bergantung pada koneksi dan layanan Firebase.

**Transisi:** setelah semua fitur dijelaskan, masuk ke demo aplikasi.

## Slide 14 - Validasi Alur Aplikasi

**Tujuan slide:** menjelaskan validasi alur aplikasi, lalu melakukan demo utama sebagai pembuktian fungsi.

**Demo dilakukan di slide ini.**

**Sebelum mulai demo, ucapkan:**

Selanjutnya saya akan mendemonstrasikan alur utama aplikasi, mulai dari login, pencarian petugas, navigasi, sampai fitur bantuan.

**Urutan demo utama:**

1. Login sebagai Jemaah Haji.
2. Tampilkan Home.
3. Masuk ke Find My dan aktifkan izin lokasi.
4. Tekan Find Officers.
5. Jelaskan bahwa daftar petugas terdekat diurutkan menggunakan Haversine.
6. Pilih salah satu petugas.
7. Buka peta atau rute Mapbox.
8. Kirim permintaan bantuan atau buka chat.
9. Tampilkan Help Inbox atau jelaskan notifikasi.
10. Tutup dengan batasan sistem.

**Kalimat saat menjelaskan Haversine di demo:**

Pada bagian ini, aplikasi membaca koordinat pengguna dan data petugas, lalu menghitung jarak awal menggunakan Haversine Formula. Hasilnya digunakan untuk mengurutkan petugas dari yang paling dekat.

**Kalimat saat menjelaskan Mapbox di demo:**

Setelah petugas dipilih, aplikasi menggunakan Mapbox Directions API untuk menampilkan rute berjalan. Karena mengikuti jaringan jalan, jarak rute bisa berbeda dari jarak Haversine.

**Jika demo live bermasalah:**

- GPS bermasalah: jelaskan bahwa fitur membutuhkan izin lokasi, lalu gunakan screenshot.
- Firebase bermasalah: jelaskan bahwa data petugas dibaca dari Firebase.
- Mapbox bermasalah: jelaskan perbedaan Haversine dan Mapbox memakai screenshot.
- Chat bermasalah: jelaskan struktur Help Inbox dan chat dari screenshot.

**Transisi setelah demo:**

Setelah demo, saya lanjutkan ke rencana pengujian dan indikator keberhasilan sistem.

## Slide 15 - Rencana Pengujian dan Indikator

**Tujuan slide:** menjelaskan cara mengevaluasi sistem.

**Yang dijelaskan:**

- Uji fungsi: auth, lokasi, Firebase, peta, navigasi, bantuan.
- Uji algoritma: data koordinat uji dan urutan jarak.
- Uji integrasi: jarak antartitik dan jarak rute.
- Indikator: urutan petugas, marker/rute, pesan bantuan.

**Contoh kalimat:**

Untuk pengujian, saya membaginya menjadi tiga bagian. Uji fungsi memeriksa fitur utama aplikasi. Uji algoritma memeriksa hasil Haversine dan urutan jarak. Uji integrasi membandingkan jarak Haversine dengan jarak rute dari Mapbox.

**Demo:** tidak ada demo baru. Jika demo tadi berhasil, cukup kaitkan dengan indikator ini.

**Transisi:** setelah rencana pengujian, masuk ke penutup.

## Slide 16 - Penutup Kolokium

**Tujuan slide:** menutup presentasi dengan simpulan sementara.

**Yang dijelaskan:**

- Aplikasi dirancang sebagai alat bantu informasi lokasi.
- Haversine digunakan untuk jarak awal dan pengurutan.
- Mapbox digunakan untuk rute.
- Pengembangan lanjutan: data lapangan, validasi, performa jaringan.

**Contoh kalimat:**

Sebagai penutup, sistem ini dirancang sebagai alat bantu informasi lokasi petugas haji. Haversine digunakan untuk perhitungan jarak awal dan pengurutan, sedangkan Mapbox digunakan untuk rute setelah tujuan dipilih. Pengembangan berikutnya dapat mencakup validasi data lapangan dan pengujian performa pada kondisi jaringan yang bervariasi.

**Demo:** tidak ada demo.

**Transisi:** tutup dengan terima kasih dan kontak.

## Slide 17 - Kontak

**Tujuan slide:** menutup presentasi dan membuka sesi pertanyaan.

**Yang dijelaskan:**

- Ucapkan terima kasih.
- Sebutkan siap menerima pertanyaan, masukan, dan arahan.
- Tidak perlu membaca email kecuali diminta.

**Contoh kalimat:**

Demikian presentasi kolokium tugas akhir saya. Terima kasih atas perhatian Bapak/Ibu dosen. Saya siap menerima pertanyaan, masukan, dan arahan untuk penyempurnaan penelitian ini.

**Demo:** tidak ada demo.

## Catatan Jawaban Cepat Untuk Tanya Jawab

**Kenapa memakai Haversine?**

Haversine digunakan karena dapat menghitung jarak awal antarkoordinat latitude dan longitude secara sederhana dan ringan untuk pengurutan kandidat terdekat.

**Kenapa tetap memakai Mapbox?**

Mapbox digunakan untuk peta dan rute jalan. Haversine hanya menghitung jarak awal antartitik, sedangkan Mapbox mengikuti jaringan jalan. Jika ditanya kenapa tidak Google Maps, jawab bahwa Google Maps juga bisa digunakan, tetapi penelitian ini mempertimbangkan keterbatasan biaya dan akses layanan sebagai tugas akhir mahasiswa. Fokus penelitian tetap pada Haversine untuk pengurutan petugas terdekat, sedangkan Mapbox dipakai sebagai layanan peta dan rute yang cukup untuk prototipe.

**Kenapa jarak Haversine dan Mapbox berbeda?**

Karena Haversine menghitung jarak antartitik, sedangkan Mapbox menghitung rute berdasarkan jalan yang tersedia.

**Apakah aplikasi ini untuk kondisi darurat resmi?**

Tidak. Aplikasi diposisikan sebagai alat bantu informasi lokasi dan komunikasi, bukan pengganti prosedur resmi layanan darurat.

**Apa batasan sistem?**

Sistem membutuhkan internet, izin lokasi, data lokasi petugas yang valid, Firebase, dan Mapbox.

**Kapan demo dilakukan?**

Demo utama dilakukan pada slide 14, setelah fitur dan alur sistem dijelaskan.
