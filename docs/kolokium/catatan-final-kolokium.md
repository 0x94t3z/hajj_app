# Catatan Final Kolokium Tugas Akhir

Judul: Pencarian Lokasi Terdekat Petugas Haji pada Ibadah Haji Menggunakan Algoritma Haversine Formula Berbasis Mobile  
Nama: Muhamad Taopik  
NIM: 1197050081  
Program Studi: Teknik Informatika, UIN Sunan Gunung Djati Bandung

## Cara Memakai Catatan Ini

Catatan ini bukan naskah untuk dibaca kata per kata. Gunakan sebagai pegangan latihan agar penjelasan terdengar natural, formal, dan sesuai dengan penulisan tugas akhir.

Pegangan utama saat presentasi:

- Materi presentasi cukup dijadikan penanda poin.
- Penjelasan lisan mengikuti catatan ini.
- Jangan terlalu panjang di bagian awal.
- Demo utama dilakukan pada bagian 14.
- Jika dosen memotong atau bertanya, jawab dengan batasan penelitian yang aman.

Dasar isi catatan:

- BAB I: latar belakang, rumusan masalah, tujuan, manfaat, batasan, kerangka pemikiran.
- BAB II: kajian literatur, Haversine Formula, GPS, Location-Based Service, Mapbox.
- BAB III: metodologi, analisis sistem, desain, arsitektur, UI, pengembangan, pengujian.
- BAB IV: implementasi aplikasi, Haversine, Mapbox, fitur UI, pengujian, hasil perbandingan.
- BAB V: simpulan dan saran.
- Project aplikasi: Flutter, Firebase, GPS/Geolocator, Mapbox, dan Haversine.


## Penanda Saat Presentasi

Gunakan penanda ini saat latihan:

- **BACA / UCAPKAN:** bagian yang boleh kamu ucapkan saat presentasi. Tidak harus sama persis, tetapi inti kalimatnya perlu keluar.
- **JELASKAN DENGAN KATA SENDIRI:** poin yang cukup dijadikan pegangan. Jangan dibaca satu per satu.
- **JANGAN DIBACA:** pengingat agar tidak membuka pembahasan yang tidak perlu.
- **TANYA JAWAB:** simpan untuk menjawab pertanyaan dosen, bukan untuk dijelaskan di awal.
- **DEMO:** arahan aksi saat presentasi, bukan kalimat untuk dibaca.

Prioritas saat presentasi: gunakan **Contoh narasi** sebagai bahan utama untuk diucapkan, pakai **Poin lisan** sebagai checklist, dan simpan bagian **TANYA JAWAB** untuk menjawab pertanyaan dosen.

## Alur Besar Presentasi

**JELASKAN DENGAN KATA SENDIRI - Pembukaan:**
Perkenalkan identitas, judul, dan fokus penelitian.

**JELASKAN DENGAN KATA SENDIRI - Masalah:**
Saat melaksanakan ibadah haji, jemaah dapat mengalami kendala seperti sakit, tersesat, terpisah dari rombongan, atau membutuhkan arahan. Dalam kondisi area yang padat dan tidak familiar, informasi petugas terdekat menjadi penting.

**JELASKAN DENGAN KATA SENDIRI - Solusi:**
Aplikasi mobile membaca lokasi jemaah, mengambil data lokasi petugas, menghitung jarak awal dengan Haversine Formula, lalu menampilkan petugas terdekat pada peta.

**JELASKAN DENGAN KATA SENDIRI - Teknis:**
Flutter sebagai mobile app, Firebase untuk autentikasi dan database, GPS untuk koordinat, Haversine untuk ranking jarak, Mapbox untuk peta dan rute.

**DEMO:**
Tunjukkan alur login, home, Find My, Find Officers, hasil petugas terdekat, dan rute Mapbox.

**JELASKAN DENGAN KATA SENDIRI - Penutup:**
Sampaikan bahwa sistem berhasil menjalankan fungsi utama, tetapi tetap memiliki batasan pada validitas data, koneksi internet, GPS, Firebase, dan Mapbox.

## Kapan Harus Demo

Demo utama dilakukan saat membahas **Bagian 14 - Validasi Alur Aplikasi**.

Sebelum bagian 14, jangan membuka aplikasi terlalu banyak. Gunakan screenshot pada bagian untuk menjelaskan antarmuka. Ini membuat alur presentasi lebih rapi dan dosen tidak merasa presentasi meloncat dari konsep ke demo terlalu cepat.

**DEMO - Mini-demo opsional:**

- Bagian 11: boleh tunjukkan tampilan login/home dari screenshot saja.
- Bagian 12: jika ditanya, boleh buka Find My sebentar.
- Bagian 13: jika ditanya, jelaskan singkat sebagai fitur pendukung, bukan fokus rumusan masalah.
- Bagian 14: demo lengkap, tetapi materi tetap ditulis sebagai validasi fungsi utama.

**JELASKAN DENGAN KATA SENDIRI - Jika waktu presentasi hanya 8-10 menit:**

- Bagian 1-5: 2 menit.
- Bagian 6-10: 3 menit.
- Bagian 11-13: 2 menit.
- Bagian 14: 3 menit.
- Bagian 15-17: 1-2 menit.

## Bagian 01 - Seminar Kolokium Tugas Akhir

**JANGAN DIBACA - Tujuan bagian:**
Membuka presentasi dan memperkenalkan identitas penelitian.

**JANGAN DIBACA - Sumber skripsi:**
Halaman judul dan abstrak.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Ucapkan salam.
- Ucapkan terima kasih kepada dosen dan hadirin yang sudah menyempatkan hadir.
- Perkenalkan nama, NIM, jurusan, dan kampus.
- Sebutkan judul lengkap tugas akhir.
- Sampaikan bahwa fokus penelitian adalah pencarian petugas haji terdekat menggunakan aplikasi mobile.
- Sebutkan komponen inti secara singkat: Flutter, Firebase, GPS, Mapbox, dan Haversine.

**BACA / UCAPKAN - Contoh narasi:**

Assalamu'alaikum warahmatullahi wabarakatuh. Terima kasih kepada Bapak/Ibu dosen dan hadirin yang telah menyempatkan waktu untuk hadir pada kolokium ini. Perkenalkan, saya Muhamad Taopik, NIM 1197050081, dari Program Studi Teknik Informatika UIN Sunan Gunung Djati Bandung. Pada kolokium ini saya akan mempresentasikan tugas akhir berjudul "Pencarian Lokasi Terdekat Petugas Haji pada Ibadah Haji Menggunakan Algoritma Haversine Formula Berbasis Mobile". Secara umum, penelitian ini membahas aplikasi mobile yang membantu jemaah mengetahui petugas haji terdekat berdasarkan lokasi jemaah.

**JANGAN DIBACA:**

- Jangan langsung menjelaskan rumus.
- Jangan langsung membuka aplikasi.
- Jangan menyebut sistem sebagai solusi darurat resmi.

**DEMO:**
Tidak ada demo.

**BACA / UCAPKAN - Transisi:**
Setelah memperkenalkan judul, saya akan masuk ke latar belakang kenapa topik ini diangkat.

## Bagian 02 - Latar Belakang

**JANGAN DIBACA - Tujuan bagian:**
Menjelaskan masalah utama dan alasan penelitian ini penting.

**JANGAN DIBACA - Sumber skripsi:**
BAB I bagian Latar Belakang Penelitian.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Ibadah haji melibatkan jumlah jemaah besar dalam area terbatas.
- Situasi lapangan dapat padat, dinamis, dan tidak familiar bagi sebagian jemaah.
- Jemaah dapat mengalami kendala saat ibadah, misalnya sakit, tersesat, terpisah dari rombongan, atau membutuhkan arahan.
- Dalam kondisi tersebut, jemaah dapat kesulitan menemukan petugas terdekat.
- Pencarian manual dapat memakan waktu, terutama dalam kondisi ramai.
- Perangkat mobile memiliki GPS yang dapat dimanfaatkan untuk membaca koordinat.
- Koordinat tersebut dapat dipakai untuk menghitung jarak dan menentukan kandidat petugas terdekat.

**BACA / UCAPKAN - Contoh narasi:**

Latar belakang penelitian ini berangkat dari kondisi ibadah haji yang melibatkan banyak jemaah dalam area yang relatif terbatas, khususnya di Makkah dan sekitarnya. Saat melaksanakan ibadah, jemaah dapat mengalami kendala seperti sakit, tersesat, terpisah dari rombongan, atau membutuhkan arahan petugas. Dalam kondisi area yang padat dan tidak selalu familiar, jemaah membutuhkan informasi petugas terdekat agar proses pencarian bantuan atau arahan menjadi lebih terarah. Pencarian secara manual masih mungkin dilakukan, tetapi dalam situasi ramai prosesnya bisa memakan waktu. Karena itu, perangkat mobile yang sudah memiliki GPS dapat dimanfaatkan untuk membaca posisi jemaah, lalu posisi tersebut digunakan sebagai dasar pencarian petugas terdekat.

**TANYA JAWAB - Jawaban aman:**
Penelitian ini tidak mengambil posisi sebagai pengganti mekanisme resmi, tetapi sebagai alat bantu informasi lokasi.

**DEMO:**
Tidak ada demo.

**BACA / UCAPKAN - Transisi:**
Dari latar belakang tersebut, rumusan masalah penelitian saya fokuskan pada implementasi perhitungan jarak dan penampilan lokasi petugas dalam aplikasi mobile.

## Bagian 03 - Rumusan Masalah

**JANGAN DIBACA - Tujuan bagian:**
Menunjukkan fokus penelitian agar pembahasan tidak melebar.

**JANGAN DIBACA - Sumber skripsi:**
BAB I bagian Perumusan Masalah Penelitian.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Rumusan pertama: implementasi Haversine Formula untuk menghitung dan mengurutkan petugas haji terdekat berdasarkan koordinat latitude dan longitude pada aplikasi mobile.
- Rumusan kedua: membangun aplikasi mobile yang dapat menentukan dan menampilkan lokasi petugas haji terdekat menggunakan Mapbox API.
- Fitur bantuan/chat tidak termasuk dalam rumusan masalah penelitian.

**BACA / UCAPKAN - Contoh narasi:**

Berdasarkan latar belakang tadi, rumusan masalah penelitian ini ada dua. Pertama, bagaimana mengimplementasikan algoritma Haversine Formula untuk menghitung dan mengurutkan petugas haji terdekat berdasarkan koordinat latitude dan longitude pada aplikasi mobile. Kedua, bagaimana membangun aplikasi mobile yang dapat menentukan dan menampilkan lokasi petugas haji terdekat menggunakan Mapbox API. Jadi pembahasan rumusan masalah tetap diarahkan pada pencarian petugas terdekat, perhitungan Haversine, dan penampilan lokasi melalui aplikasi mobile.

**DEMO:**
Tidak ada demo.

**BACA / UCAPKAN - Transisi:**
Setelah rumusan masalah, saya jelaskan tujuan dan manfaat penelitian.

## Bagian 04 - Tujuan dan Manfaat

**JANGAN DIBACA - Tujuan bagian:**
Menjelaskan output yang ingin dicapai dari penelitian.

**JANGAN DIBACA - Sumber skripsi:**
BAB I bagian Tujuan dan Manfaat Penelitian.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Tujuan penelitian: mengimplementasikan Haversine Formula untuk menghitung dan mengurutkan petugas terdekat.
- Tujuan aplikasi: membangun aplikasi mobile yang dapat menampilkan lokasi petugas dengan Mapbox.
- Manfaat praktis: membantu jemaah mengetahui lokasi petugas terdekat.
- Manfaat akademik: menjadi referensi pengembangan Location-Based Service yang menggunakan Haversine dan Mapbox.
- Output sistem: koordinat jemaah, data lokasi petugas, ranking Haversine, tampilan peta, daftar petugas terdekat, dan rute.

**BACA / UCAPKAN - Contoh narasi:**

Tujuan utama penelitian ini adalah mengimplementasikan Haversine Formula untuk menghitung jarak awal antara jemaah dan petugas, kemudian mengurutkan petugas berdasarkan jarak terdekat. Selain itu, aplikasi mobile dikembangkan agar hasil perhitungan tersebut dapat ditampilkan sebagai marker pada peta dan sebagai daftar petugas terdekat yang sudah diurutkan. Dari sisi manfaat, sistem ini diharapkan membantu jemaah mengetahui lokasi petugas terdekat dan menjadi referensi untuk pengembangan aplikasi berbasis lokasi.

**JANGAN DIBACA - Catatan penting:**
Gunakan kata "membantu", bukan "menjamin", "menyelamatkan", atau "menggantikan layanan resmi".

**DEMO:**
Tidak ada demo.

**BACA / UCAPKAN - Transisi:**
Supaya klaim penelitian tetap proporsional, saya jelaskan batasan masalah penelitian.

## Bagian 05 - Batasan Masalah Penelitian

**JANGAN DIBACA - Tujuan bagian:**
Menjaga klaim penelitian tetap aman dan sesuai skripsi.

**JANGAN DIBACA - Sumber skripsi:**
BAB I bagian Batasan Masalah Penelitian.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Aplikasi dikembangkan menggunakan Flutter untuk platform mobile.
- Perhitungan jarak memakai Haversine Formula berdasarkan latitude dan longitude.
- Data lokasi pengujian menggunakan data dummy kawasan Makkah dan zona uji UIN Sunan Gunung Djati Bandung.
- Data disimpan menggunakan Firebase Realtime Database.
- Peta ditampilkan menggunakan Mapbox API.
- Sistem menampilkan maksimal 10 petugas haji terdekat.
- Rute navigasi memakai Mapbox Directions API setelah petugas dipilih.
- Pengujian difokuskan pada fungsi utama, bukan performa teknis rinci seperti memori, frame rate, atau waktu render.

**BACA / UCAPKAN - Contoh narasi:**

Pada penelitian ini, ruang lingkup saya batasi agar pembahasan tetap terarah. Aplikasi dikembangkan menggunakan Flutter, data disimpan pada Firebase Realtime Database, dan peta ditampilkan menggunakan Mapbox. Perhitungan jarak dilakukan menggunakan Haversine Formula berdasarkan latitude dan longitude. Sistem menampilkan maksimal 10 petugas terdekat. Untuk rute navigasi, aplikasi menggunakan Mapbox Directions API setelah jemaah memilih petugas.

**TANYA JAWAB - Jawaban paling aman:**
Sistem ini merupakan alat bantu informasi lokasi, bukan pengganti prosedur resmi layanan darurat.

**TANYA JAWAB - Jika dosen bertanya soal akurasi:**
Haversine menghitung estimasi jarak awal berdasarkan koordinat. Jarak tersebut bukan jarak tempuh jalan. Untuk rute jalan, sistem menggunakan Mapbox Directions API.

**DEMO:**
Tidak ada demo.

**BACA / UCAPKAN - Transisi:**
Setelah batasan, saya masuk ke komponen teknologi yang digunakan dalam aplikasi.

## Bagian 06 - Teknologi dan Komponen Sistem

**JANGAN DIBACA - Tujuan bagian:**
Menjelaskan komponen aplikasi dan hubungan antarteknologi.

**JANGAN DIBACA - Sumber skripsi:**
BAB III bagian Analisis Teknologi, BAB IV bagian Arsitektur Sistem, dan README project.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Flutter dan Dart: membangun antarmuka dan logic aplikasi mobile.
- GPS/Geolocator: membaca koordinat jemaah.
- Firebase Authentication: autentikasi akun.
- Firebase Realtime Database: menyimpan profil, role, dan koordinat lokasi.
- Haversine Formula: menghitung jarak awal dan ranking petugas.
- Mapbox API: menampilkan peta.
- Mapbox Directions API: menampilkan rute berjalan, jarak rute, durasi, dan instruksi arah.
- Detail node Firebase seperti users, helpConversations, helpConversationSessions, dan helpNotificationRequests cukup disimpan sebagai bahan tanya jawab jika dosen menanyakan struktur data.

**BACA / UCAPKAN - Contoh narasi:**

Komponen sistem dibagi menjadi beberapa bagian. Aplikasi mobile dikembangkan menggunakan Flutter dan Dart. Untuk autentikasi dan data akun, sistem memakai Firebase Authentication dan Firebase Realtime Database. Lokasi jemaah diperoleh dari GPS melalui Geolocator. Setelah koordinat jemaah dan petugas tersedia, Haversine Formula menghitung jarak awal untuk menentukan urutan petugas terdekat. Mapbox digunakan untuk peta, sedangkan Mapbox Directions API digunakan ketika jemaah membuka rute menuju petugas yang dipilih.

**BACA / UCAPKAN - Bagian yang perlu ditegaskan:**
Perhitungan Haversine dilakukan pada sisi aplikasi atau frontend. Firebase menyimpan data, tetapi bukan tempat utama menghitung ranking.

**TANYA JAWAB - Jika dosen bertanya soal backend Python:**
Backend Python digunakan sebagai komponen administratif untuk pengolahan data secara batch, seperti pembersihan data, impor data, pembuatan akun, dan pembaruan data ke Firebase. Backend tersebut bukan REST API utama aplikasi.

**DEMO:**
Tidak ada demo.

**BACA / UCAPKAN - Transisi:**
Setelah komponen teknologi, saya jelaskan tahapan metodologi penelitian.

## Bagian 07 - Metodologi Penelitian

**JANGAN DIBACA - Tujuan bagian:**
Menunjukkan proses penelitian dari perencanaan sampai implementasi.

**JANGAN DIBACA - Sumber skripsi:**
BAB III Metodologi Penelitian, khususnya metode System Development Life Cycle (SDLC).

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Metode penelitian yang digunakan adalah System Development Life Cycle (SDLC).
- Planning: menentukan masalah, kebutuhan, dan ruang lingkup.
- Analysis: menganalisis role akun, kebutuhan data, alur sistem, teknologi, dan keamanan.
- Design: merancang arsitektur, flow, database, dan antarmuka.
- Development: membangun aplikasi dengan Flutter, Firebase, Haversine, dan Mapbox.
- Testing: menguji fungsi utama, perhitungan jarak, peta, dan navigasi.
- Implementation: menjalankan aplikasi pada emulator, simulator, dan perangkat fisik.

**BACA / UCAPKAN - Contoh narasi:**

Metodologi penelitian yang saya gunakan adalah System Development Life Cycle atau SDLC. Tahapannya dimulai dari planning sampai implementation. Pada tahap planning, saya menentukan masalah dan ruang lingkup penelitian. Pada tahap analysis, saya menganalisis kebutuhan sistem, role akun, alur sistem, teknologi, serta aspek keamanan. Tahap design digunakan untuk merancang arsitektur dan antarmuka. Setelah itu aplikasi dikembangkan menggunakan Flutter, Firebase, Haversine, dan Mapbox. Terakhir, sistem diuji untuk memastikan fungsi utama berjalan.

**JANGAN DIBACA - Catatan valid:**
Sebut "pengujian fungsi utama", karena skripsi memang tidak memfokuskan pengujian performa teknis rinci.

**DEMO:**
Tidak ada demo.

**BACA / UCAPKAN - Transisi:**
Berikutnya saya jelaskan alur sistem pencarian dari login sampai hasil petugas ditampilkan.

## Bagian 08 - Alur Sistem Pencarian

**JANGAN DIBACA - Tujuan bagian:**
Menjelaskan proses inti aplikasi secara runtut.

**JANGAN DIBACA - Sumber skripsi:**
BAB III bagian Analisis Alur Sistem, Arsitektur Sistem, dan BAB IV bagian Alur Data dalam Sistem.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Jemaah login.
- Sistem membaca akun dan role jemaah.
- Aplikasi mengambil koordinat jemaah melalui GPS.
- Koordinat jemaah diperbarui ke Firebase.
- Aplikasi mengambil data lokasi petugas dari Firebase.
- Sistem memfilter data sesuai role dan area.
- Haversine menghitung jarak dari jemaah ke tiap petugas.
- Hasil diurutkan dari jarak terkecil.
- Maksimal 10 petugas terdekat ditampilkan.
- Jika petugas dipilih, Mapbox Directions API menampilkan rute.

**BACA / UCAPKAN - Contoh narasi:**

Alur pencarian dimulai ketika jemaah login. Setelah login, sistem membaca role jemaah, kemudian aplikasi mengambil koordinat lokasi melalui GPS. Koordinat ini diperbarui ke Firebase dan digunakan sebagai titik awal pencarian. Aplikasi mengambil data petugas dari Firebase, kemudian menghitung jarak dari posisi jemaah ke setiap petugas menggunakan Haversine Formula. Hasilnya diurutkan dari jarak terkecil dan ditampilkan sebagai daftar petugas terdekat serta marker pada peta.

Kalimat pembeda yang penting:
Haversine digunakan untuk urutan awal, sedangkan Mapbox digunakan untuk visualisasi peta dan rute setelah petugas dipilih.

**DEMO:**
Tidak ada demo live. Ini masih penjelasan konsep.

**BACA / UCAPKAN - Transisi:**
Setelah alur sistem, saya jelaskan algoritma Haversine yang menjadi inti perhitungan jarak.

## Bagian 09 - Implementasi Haversine Formula

**JANGAN DIBACA - Tujuan bagian:**
Menjelaskan rumus dan perannya tanpa terlalu matematis.

**JANGAN DIBACA - Sumber skripsi:**
BAB II Landasan Teori Haversine Formula, BAB III Flowchart, BAB IV Implementasi Algoritma Haversine.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Haversine Formula menghitung jarak antara dua titik koordinat di permukaan bumi.
- Input: latitude dan longitude jemaah serta petugas.
- Koordinat dari GPS berbentuk derajat, lalu dikonversi ke radian karena fungsi `sin`, `cos`, dan `asin` bekerja dalam radian.
- Sistem menghitung selisih latitude dan longitude: `Δlat` dan `Δlon`.
- Sistem menghitung nilai `a` sebagai inti rumus Haversine.
- Radius bumi yang digunakan dalam kode adalah 6371.0088 km.
- Output berupa jarak dalam kilometer.
- Jarak dipakai untuk mengurutkan petugas dari yang paling dekat.
- Dalam kode, nilai `a` dibatasi untuk stabilitas perhitungan sebelum akar dan sudut pusat dihitung.

**BACA / UCAPKAN - Contoh narasi:**

Haversine Formula digunakan untuk menghitung jarak antara dua titik koordinat pada permukaan bumi. Inputnya adalah latitude dan longitude jemaah serta latitude dan longitude petugas. Koordinat dari GPS masih berbentuk derajat, sehingga sistem mengubahnya terlebih dahulu ke radian. Setelah itu sistem menghitung selisih latitude dan longitude, menghitung nilai `a`, lalu menghitung jarak menggunakan radius bumi 6371.0088 kilometer. Outputnya berupa jarak dalam kilometer, kemudian sistem mengurutkan petugas dari jarak paling kecil.

**BACA / UCAPKAN - Cara menyebut simbol rumus:**

- `a`: dibaca "nilai a", yaitu nilai antara untuk menghitung jarak Haversine.
- `d`: dibaca "distance" atau "jarak akhir", yaitu hasil jarak dalam kilometer.
- `r`: dibaca "radius bumi", pada sistem ini nilainya 6371.0088 kilometer.
- `lat1`: dibaca "latitude satu", yaitu latitude titik jemaah.
- `lon1`: dibaca "longitude satu", yaitu longitude titik jemaah.
- `lat2`: dibaca "latitude dua", yaitu latitude titik petugas.
- `lon2`: dibaca "longitude dua", yaitu longitude titik petugas.
- `Δlat`: dibaca "delta latitude", yaitu selisih latitude antara petugas dan jemaah.
- `Δlon`: dibaca "delta longitude", yaitu selisih longitude antara petugas dan jemaah.
- `sin`: dibaca "sinus".
- `cos`: dibaca "kosinus".
- `asin`: dibaca "arc sinus" atau "inverse sinus".
- `√a`: dibaca "akar dari a".
- `sin²`: dibaca "sinus kuadrat".
- `×`: dibaca "dikali".

**BACA / UCAPKAN - Cara membaca rumus:**

Untuk rumus pertama, saya baca: nilai `a` sama dengan sinus kuadrat dari delta latitude dibagi dua, ditambah kosinus latitude satu dikali kosinus latitude dua, dikali sinus kuadrat dari delta longitude dibagi dua.

Untuk rumus kedua, jarak `d` sama dengan dua dikali radius bumi, dikali arc sinus dari akar nilai `a`. Hasil `d` inilah yang digunakan sebagai jarak awal untuk mengurutkan petugas.

**JELASKAN DENGAN KATA SENDIRI - Cara menjelaskan perhitungan secara detail:**

1. Titik pertama adalah posisi jemaah, yaitu `lat1` dan `lon1`.
2. Titik kedua adalah posisi petugas, yaitu `lat2` dan `lon2`.
3. Latitude dan longitude dikonversi dari derajat ke radian dengan rumus `derajat × π / 180`.
4. Sistem menghitung `Δlat = lat2 - lat1` dan `Δlon = lon2 - lon1`.
5. Sistem menghitung nilai inti Haversine:
   `a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)`.
6. Nilai `a` dibatasi untuk stabilitas perhitungan. Secara teknis, nilai ini dijaga pada rentang valid 0 sampai 1 agar tidak terjadi error akibat pembulatan angka desimal komputer.
7. Jarak dihitung dengan:
   `d = 2r × asin(√a)`, dengan `r = 6371.0088 km`.
8. Perhitungan ini dilakukan ke setiap petugas yang datanya valid.
9. Hasil jarak dibandingkan, lalu daftar petugas diurutkan dari nilai paling kecil.

**TANYA JAWAB - Catatan validasi rumus:**
Rumus yang ditampilkan sudah sesuai dengan rumus Haversine. Di kode aplikasi, bentuk akhirnya memakai `atan2(√a, √(1-a))` setelah nilai `a` dibatasi pada rentang valid 0 sampai 1. Bentuk tersebut ekuivalen dengan `asin(√a)` untuk nilai `a` pada rentang tersebut, sehingga aman dijelaskan sebagai Haversine Formula.

**TANYA JAWAB - Validasi sederhana jika ditanya:**
Jika titik jemaah dan titik petugas sama, hasil jaraknya 0 km. Jika terdapat selisih koordinat, nilai jarak bertambah sesuai perbedaan posisi. Contoh pembanding umum, selisih 1 derajat longitude di ekuator menghasilkan jarak sekitar 111.195 km dengan radius bumi 6371.0088 km. Ini menunjukkan rumus dan implementasi berada pada skala yang benar.

**TANYA JAWAB - Versi sederhana jika dosen non-teknis:**
Intinya, Haversine menghitung jarak awal antarkoordinat. Dari hasil jarak itu, sistem mengetahui kandidat petugas yang paling dekat.

**TANYA JAWAB - Jika dosen bertanya kenapa tidak pakai Mapbox untuk ranking semua petugas:**
Haversine lebih sesuai untuk tahap awal karena ringan untuk menghitung satu titik jemaah ke banyak titik petugas. Mapbox digunakan setelah tujuan dipilih, karena rute jalan membutuhkan data jaringan jalan dan Directions API.

**DEMO:**
Tidak ada demo.

**BACA / UCAPKAN - Transisi:**
Setelah jarak awal dihitung dengan Haversine, sistem membutuhkan peta dan rute. Bagian itu menggunakan Mapbox.

## Bagian 10 - Integrasi Mapbox

**JANGAN DIBACA - Tujuan bagian:**
Menjelaskan peran Mapbox dan batasannya.

**JANGAN DIBACA - Sumber skripsi:**
BAB I batasan, BAB III teknologi, BAB IV implementasi Mapbox dan perbandingan Haversine dengan Mapbox Directions API.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Mapbox API digunakan untuk visualisasi peta.
- Peta menampilkan lokasi jemaah dan petugas.
- Mapbox Directions API digunakan untuk rute setelah petugas dipilih.
- Directions API menghasilkan rute berjalan, jarak rute, durasi, dan instruksi arah.
- Jarak Haversine dan jarak Mapbox dapat berbeda.
- Perbedaannya wajar karena Haversine menghitung jarak antarkoordinat, sedangkan Mapbox menghitung rute berdasarkan jaringan jalan.

**BACA / UCAPKAN - Contoh narasi:**

Mapbox pada sistem ini digunakan untuk dua kebutuhan. Pertama, menampilkan peta dan posisi jemaah maupun petugas. Kedua, melalui Mapbox Directions API, sistem menampilkan rute berjalan setelah jemaah memilih petugas. Jadi Haversine dan Mapbox memiliki fungsi berbeda. Haversine menghasilkan urutan awal petugas terdekat, sedangkan Mapbox menghasilkan rute navigasi.

**TANYA JAWAB - Data valid dari skripsi:**
Pada pengujian, contoh Souq Al-Khalil memiliki jarak Haversine 0.542 km, sedangkan jarak Mapbox Directions API 0.925 km. Selisih ini wajar karena Mapbox mengikuti rute jalan.

**TANYA JAWAB - Jika dosen bertanya kenapa jarak Mapbox lebih besar:**
Karena jarak rute mengikuti jalur yang tersedia, tidak selalu berupa garis langsung dari titik jemaah ke titik petugas.

**DEMO:**
Tidak ada demo live.

**BACA / UCAPKAN - Transisi:**
Setelah menjelaskan bagian teknis, saya tampilkan implementasi antarmuka aplikasi.

## Bagian 11 - Implementasi Antarmuka Aplikasi

**JANGAN DIBACA - Tujuan bagian:**
Menunjukkan tampilan aplikasi secara umum sebelum demo.

**JANGAN DIBACA - Sumber skripsi:**
BAB III perancangan UI dan BAB IV implementasi halaman Login, Home, dan Find Officers.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Login digunakan untuk autentikasi melalui Firebase Authentication.
- Setelah login, aplikasi membaca data akun dan role dari Firebase.
- Home menjadi titik masuk setelah login.
- Find My menjadi pusat pencarian lokasi.
- Tombol Find Officers digunakan oleh jemaah untuk mencari petugas terdekat.
- UI yang ditampilkan pada bagian merupakan tampilan final aplikasi.

**BACA / UCAPKAN - Contoh narasi:**

Pada bagian antarmuka, halaman login digunakan untuk autentikasi akun. Setelah login berhasil, aplikasi membaca profil dan role jemaah. Halaman home menjadi titik awal sebelum jemaah masuk ke fitur pencarian. Fitur Find My digunakan untuk membaca lokasi jemaah dan memulai pencarian petugas melalui tombol Find Officers.

**TANYA JAWAB - Jika dosen bertanya role:**
Role membedakan tampilan dan hak akses akun. Pada fokus penelitian ini, role digunakan agar pencarian diarahkan ke target pencarian yang sesuai.

**DEMO:**
Belum demo utama. Tunjukkan screenshot saja.

**BACA / UCAPKAN - Transisi:**
Setelah tampilan dasar, saya jelaskan fitur pencarian dan navigasi.

## Bagian 12 - Fitur Pencarian dan Navigasi

**JANGAN DIBACA - Tujuan bagian:**
Menjelaskan hasil utama sistem dari sisi jemaah.

**JANGAN DIBACA - Sumber skripsi:**
BAB IV implementasi tampilan hasil pencarian, peta hasil pencarian, dan halaman navigasi.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Jemaah menekan Find Officers.
- Sistem mengambil koordinat jemaah.
- Sistem membaca data petugas dari Firebase.
- Haversine menghitung jarak ke tiap petugas.
- Daftar petugas diurutkan berdasarkan jarak terdekat.
- Hasil ditampilkan sebagai daftar petugas terdekat dan marker pada peta.
- Setelah petugas dipilih, Mapbox Directions API menampilkan rute.
- Navigasi menampilkan estimasi jarak, waktu tempuh, dan instruksi arah.

**BACA / UCAPKAN - Contoh narasi:**

Fitur pencarian adalah bagian utama dari penelitian ini. Ketika jemaah menekan Find Officers, aplikasi mengambil koordinat jemaah dan membaca data petugas dari Firebase. Setelah itu, Haversine menghitung jarak ke masing-masing petugas dan hasilnya diurutkan dari yang paling dekat. Jemaah dapat melihat daftar petugas terdekat, marker petugas pada peta, lalu memilih petugas untuk membuka rute navigasi.

**TANYA JAWAB - Data valid dari skripsi:**
Pada pengujian BAB IV, sistem mampu mengurutkan 10 petugas terdekat. Contoh hasil terdekat adalah Souq Al-Khalil dengan jarak Haversine 0.542 km dari titik uji.

**DEMO:**
Belum demo lengkap. Jika dosen meminta, boleh buka app sampai Find My, lalu kembali ke presentasi.

**BACA / UCAPKAN - Transisi:**
Setelah pencarian dan navigasi, saya jelaskan singkat fitur pendukung jemaah agar tidak menggeser fokus penelitian.

## Bagian 13 - Fitur Pendukung dan Peran Akun

**JANGAN DIBACA - Tujuan bagian:**
Menjelaskan fitur pendukung secara singkat tanpa menjadikannya fokus utama penelitian.

**JANGAN DIBACA - Sumber skripsi:**
BAB III dan BAB IV bagian perancangan serta implementasi fitur pendukung aplikasi.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Role akun menentukan tampilan dan target pencarian.
- Fitur pendukung seperti Help Inbox dan Chat tersedia pada aplikasi.
- Bagian ini cukup dijelaskan sebagai pelengkap penggunaan aplikasi.
- Fokus utama penelitian tetap pencarian petugas terdekat, perhitungan Haversine, peta, dan rute.

**BACA / UCAPKAN - Contoh narasi:**

Pada bagian ini, saya hanya menunjukkan bahwa aplikasi memiliki fitur pendukung berdasarkan role akun. Namun bagian ini tidak saya jadikan pembahasan utama, karena rumusan masalah penelitian berfokus pada implementasi Haversine Formula untuk menghitung dan mengurutkan petugas haji terdekat. Jadi penjelasan bagian ini cukup singkat, lalu saya kembali ke alur validasi pencarian dan rute.

**TANYA JAWAB - Jawaban aman:**
Fitur pendukung ini bukan bagian utama evaluasi penelitian dan bukan prosedur resmi penanganan darurat.

**DEMO:**
Belum demo utama. Screenshot cukup.

**BACA / UCAPKAN - Transisi:**
Setelah menjelaskan fitur, saya masuk ke validasi alur aplikasi.

## Bagian 14 - Validasi Alur Aplikasi

**JANGAN DIBACA - Tujuan bagian:**
Menjelaskan validasi alur fungsi utama aplikasi, lalu menggunakannya sebagai momen demo.

**JANGAN DIBACA - Sumber skripsi:**
BAB IV implementasi sistem, BAB IV pengujian fungsi utama, dan aplikasi Hajj App.

**DEMO - Sebelum demo:**

- Pastikan internet aktif.
- Pastikan Firebase dapat diakses.
- Pastikan Mapbox token valid.
- Pastikan izin lokasi aktif.
- Siapkan akun jemaah.
- Jika memakai simulator, atur lokasi agar sesuai area pengujian.

**DEMO - Urutan demo:**

1. Buka aplikasi.
2. Login sebagai Jemaah Haji.
3. Buka halaman Home.
4. Masuk ke Find My.
5. Sampaikan bahwa aplikasi membaca koordinat GPS jemaah.
6. Gunakan tombol Find Officers.
7. Tunjukkan daftar petugas terdekat dan marker pada peta.
8. Sampaikan bahwa urutan berasal dari Haversine Formula.
9. Pilih salah satu petugas.
10. Buka rute/navigasi.
11. Sampaikan bahwa rute berasal dari Mapbox Directions API.
12. Tutup demo dengan batasan sistem.

**BACA / UCAPKAN - Narasi saat demo:**

Pada demo ini, saya menunjukkan alur utama aplikasi. Setelah login sebagai jemaah, aplikasi membaca lokasi jemaah melalui GPS. Ketika tombol Find Officers ditekan, sistem mengambil data petugas dari Firebase, lalu menghitung jarak awal menggunakan Haversine Formula. Hasilnya digunakan untuk mengurutkan petugas terdekat. Setelah petugas dipilih, aplikasi menggunakan Mapbox Directions API untuk menampilkan rute berjalan menuju petugas tersebut.

**BACA / UCAPKAN - Saat daftar petugas muncul:**

Bagian ini adalah hasil utama dari implementasi Haversine, karena sistem sudah menghitung jarak antara jemaah dan setiap petugas, kemudian menampilkan kandidat dengan jarak paling dekat.

**BACA / UCAPKAN - Saat rute muncul:**

Pada bagian ini, jarak yang tampil dapat berbeda dari jarak Haversine. Hal itu karena Haversine menghitung jarak awal antarkoordinat, sedangkan Mapbox menghitung rute berdasarkan jalur yang tersedia.

**TANYA JAWAB - Jika GPS bermasalah:**

Fitur ini membutuhkan izin lokasi. Jika saat demo lokasi tidak terbaca, saya menggunakan dokumentasi tampilan pendukung, tetapi alur sistem tetap sama: lokasi jemaah menjadi input untuk perhitungan Haversine.

**TANYA JAWAB - Jika Firebase bermasalah:**

Data petugas diambil dari Firebase Realtime Database. Jika koneksi atau rules Firebase bermasalah saat demo, saya jelaskan menggunakan bagian alur sistem dan dokumentasi final UI.

**TANYA JAWAB - Jika Mapbox bermasalah:**

Mapbox digunakan untuk peta dan rute. Jika peta tidak tampil, saya tetap dapat menjelaskan bahwa Haversine sudah berperan pada ranking, sedangkan Mapbox hanya pada visualisasi dan rute.

**DEMO:**
Demo utama dilakukan pada bagian ini.

**BACA / UCAPKAN - Transisi:**
Setelah demo, saya jelaskan rencana pengujian dan indikator keberhasilan sistem.

## Bagian 15 - Rencana Pengujian dan Indikator

**JANGAN DIBACA - Tujuan bagian:**
Menjelaskan bagaimana sistem dievaluasi.

**JANGAN DIBACA - Sumber skripsi:**
BAB IV bagian Pengujian dan Evaluasi Sistem.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Pengujian dilakukan pada Android emulator, iOS simulator, dan iPhone fisik.
- Pengujian difokuskan pada fungsi utama.
- Fungsi yang diuji: login, lokasi, Firebase, peta, dan navigasi.
- Algoritma diuji dengan data koordinat jemaah dan petugas.
- Hasil Haversine dibandingkan dengan Mapbox Directions API.
- Indikator: urutan petugas sesuai jarak, marker dan rute tampil, serta dokumentasi final UI tersedia sebagai pendukung evaluasi.

**BACA / UCAPKAN - Contoh narasi:**

Pengujian pada penelitian ini difokuskan pada fungsi utama sistem. Aplikasi diuji pada Android emulator, iOS simulator, dan iPhone fisik. Bagian yang diuji meliputi login, pembacaan lokasi, pengambilan data dari Firebase, perhitungan Haversine, tampilan peta, dan navigasi. Untuk algoritma, hasil Haversine dibandingkan dengan hasil Mapbox Directions API agar terlihat perbedaan antara jarak antarkoordinat dan jarak rute.

**TANYA JAWAB - Data valid dari skripsi:**

- Titik uji jemaah ditempatkan pada koordinat Jabal Al Kaabah.
- Sistem menghasilkan 10 petugas terdekat.
- Souq Al-Khalil menjadi contoh petugas terdekat dengan jarak Haversine 0.542 km.
- Jarak Mapbox untuk titik yang sama adalah 0.925 km.
- Aplikasi dapat dijalankan pada Android dan iOS untuk mendukung fungsi utama.

**TANYA JAWAB - Jika dosen bertanya performa:**
Pengukuran performa teknis rinci seperti memori, frame rate, dan waktu render belum menjadi fokus utama penelitian. Fokus penelitian adalah keberhasilan fungsi pencarian, pengurutan, peta, dan navigasi.

**DEMO:**
Tidak ada demo baru. Gunakan hasil demo bagian 14 sebagai pembuktian.

**BACA / UCAPKAN - Transisi:**
Setelah pengujian, saya masuk ke penutup kolokium.

## Bagian 16 - Penutup Kolokium

**JANGAN DIBACA - Tujuan bagian:**
Menyampaikan simpulan sementara dan arah pengembangan.

**JANGAN DIBACA - Sumber skripsi:**
BAB V Simpulan dan Saran.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Aplikasi dibangun sebagai alat bantu informasi lokasi petugas haji.
- Haversine digunakan untuk menghitung jarak awal dan mengurutkan petugas.
- Mapbox digunakan untuk menampilkan peta dan rute setelah petugas dipilih.
- Firebase digunakan untuk autentikasi, data akun, dan lokasi.
- Aplikasi dapat menjalankan fungsi utama pada platform mobile yang diuji.
- Pengembangan lanjutan: perluasan area pengujian, peningkatan akurasi data lokasi, pengujian performa teknis, dan pengujian pada kondisi yang lebih mendekati operasional haji.

**BACA / UCAPKAN - Contoh narasi:**

Sebagai penutup, aplikasi yang dibangun berfungsi sebagai alat bantu informasi lokasi petugas haji. Haversine Formula digunakan untuk menghitung jarak awal dan mengurutkan petugas terdekat, sedangkan Mapbox digunakan untuk peta dan rute setelah petugas dipilih. Berdasarkan pengujian, aplikasi dapat menjalankan fungsi utama seperti login, pencarian petugas, tampilan peta, dan navigasi pada platform mobile yang diuji.

**TANYA JAWAB - Jawaban aman:**
Untuk pengembangan berikutnya, sistem masih perlu diuji lebih luas dengan data lokasi lapangan yang lebih valid dan kondisi yang lebih mendekati operasional haji.

**DEMO:**
Tidak ada demo.

**BACA / UCAPKAN - Transisi:**
Terakhir, saya tampilkan kontak dan siap menerima pertanyaan.

## Bagian 17 - Kontak

**JANGAN DIBACA - Tujuan bagian:**
Menutup presentasi dan membuka sesi tanya jawab.

**JANGAN DIBACA - Sumber skripsi:**
Identitas penulis dan informasi presentasi.

**JELASKAN DENGAN KATA SENDIRI - Poin lisan:**

- Ucapkan terima kasih.
- Sebutkan bahwa penelitian terbuka untuk masukan.
- Undang dosen untuk memberikan pertanyaan atau arahan.

**BACA / UCAPKAN - Contoh narasi:**

Demikian presentasi kolokium tugas akhir saya. Terima kasih atas perhatian Bapak/Ibu dosen. Saya siap menerima pertanyaan, masukan, dan arahan untuk penyempurnaan penelitian ini.

**DEMO:**
Tidak ada demo.

## TANYA JAWAB - Jawaban Cepat

Bagian ini tidak perlu dibaca saat presentasi. Gunakan hanya jika dosen bertanya.

### Apa kontribusi utama penelitian ini?

Kontribusi utama penelitian ini adalah implementasi Haversine Formula pada aplikasi mobile untuk menentukan dan mengurutkan petugas haji terdekat berdasarkan koordinat jemaah dan petugas. Hasil perhitungan kemudian divisualisasikan melalui peta dan dapat dilanjutkan ke navigasi menggunakan Mapbox Directions API.

### Kenapa memilih Haversine Formula?

Karena Haversine sesuai untuk menghitung jarak antara dua titik koordinat geografis berdasarkan latitude dan longitude. Dalam sistem ini, Haversine digunakan untuk menghitung jarak awal dari satu jemaah ke banyak petugas secara ringan dan efisien.

### Kenapa tidak memakai Mapbox untuk semua perhitungan?

Haversine digunakan untuk ranking awal karena menghitung jarak antarkoordinat. Mapbox Directions API digunakan setelah jemaah memilih petugas, karena pada tahap itu sistem membutuhkan rute berdasarkan jaringan jalan. Jadi keduanya memiliki peran berbeda.

### Apakah jarak Haversine sama dengan jarak Mapbox?

Tidak selalu sama. Haversine menghitung jarak antarkoordinat, sedangkan Mapbox menghitung jarak rute berdasarkan jalur yang tersedia. Karena itu jarak Mapbox biasanya bisa lebih panjang.

### Contoh hasil pengujian yang bisa disebutkan?

Pada pengujian dengan titik jemaah di Jabal Al Kaabah, sistem menghasilkan Souq Al-Khalil sebagai salah satu titik terdekat dengan jarak Haversine 0.542 km. Untuk titik yang sama, jarak dari Mapbox Directions API adalah 0.925 km karena mengikuti rute jalan.

### Apakah aplikasi ini bisa dipakai langsung di haji sebenarnya?

Untuk penelitian ini, aplikasi masih diposisikan sebagai alat bantu dan diuji pada data pengujian. Agar siap digunakan pada kondisi operasional sebenarnya, masih diperlukan validasi data lapangan, pengujian area yang lebih luas, stabilitas jaringan, dan penyesuaian dengan prosedur resmi.

### Apakah sistem ini menggantikan petugas atau layanan darurat?

Tidak. Sistem ini hanya alat bantu informasi lokasi. Prosedur resmi layanan haji atau keadaan darurat tetap harus mengikuti aturan dan mekanisme yang berlaku.

### Apa batasan utama penelitian?

Batasannya meliputi kebutuhan internet, izin lokasi, GPS yang aktif, validitas data petugas, ketersediaan Firebase dan Mapbox, serta area pengujian yang dibatasi pada Makkah dan zona uji UIN Bandung.

### Apa data yang disimpan di Firebase?

Data utama yang digunakan adalah data akun, role, profil, dan koordinat lokasi jemaah/petugas. Jika ditanya fitur pendukung, data percakapan dapat dijelaskan sebagai data tambahan aplikasi, bukan data utama dalam rumusan penelitian.

### Apakah data lokasi bersifat sensitif?

Ya. Karena itu sistem menggunakan autentikasi akun, permission lokasi, dan kontrol akses Firebase. Aplikasi tidak dapat membaca lokasi sebelum jemaah memberikan izin lokasi.

### Kenapa memakai Flutter?

Flutter digunakan karena mendukung pengembangan aplikasi mobile lintas platform dengan satu basis kode, sehingga aplikasi dapat dikembangkan untuk Android dan iOS.

### Kenapa memakai Firebase Realtime Database?

Firebase Realtime Database digunakan karena dapat menyimpan dan memperbarui data akun serta lokasi secara langsung. Hal ini sesuai dengan kebutuhan aplikasi berbasis lokasi yang perlu membaca data terbaru.

### Kenapa memakai Mapbox?

Mapbox dipakai karena pada penelitian ini saya membutuhkan dua hal: peta digital di dalam aplikasi mobile dan rute navigasi setelah petugas dipilih. Mapbox mendukung integrasi dengan Flutter melalui SDK/API, dapat menampilkan marker lokasi jemaah dan petugas, serta menyediakan Mapbox Directions API untuk mengambil rute berjalan, jarak rute, durasi, dan instruksi arah. Jadi Mapbox tidak dipakai untuk menggantikan Haversine, tetapi untuk visualisasi peta dan navigasi.

Jika dibandingkan dengan Google Maps atau layanan peta lain, layanan tersebut sebenarnya juga dapat digunakan untuk aplikasi berbasis lokasi. Namun, pada penelitian ini saya mempertimbangkan batasan sebagai mahasiswa, terutama terkait biaya, akses layanan, dan kebutuhan implementasi prototipe tugas akhir. Karena kebutuhan utama sistem adalah menampilkan peta, marker, dan rute setelah petugas dipilih, Mapbox sudah mencukupi untuk mendukung fungsi tersebut.

Jawaban yang lebih aman jika ditanya langsung “kenapa tidak Google Maps?”:

Google Maps memiliki ekosistem yang matang dan sangat banyak digunakan, tetapi dalam penelitian ini pemilihan teknologi juga mempertimbangkan keterbatasan biaya dan akses layanan untuk pengembangan tugas akhir. Karena fokus penelitian bukan membandingkan akurasi layanan peta, melainkan implementasi Haversine Formula untuk menentukan urutan petugas terdekat, saya menggunakan Mapbox sebagai layanan peta dan rute yang sesuai dengan kebutuhan prototipe sistem.

### Apa bedanya fitur utama dan fitur pendukung?

Fitur utama adalah pencarian petugas terdekat, perhitungan Haversine, peta, dan navigasi. Fitur pendukung seperti chat, Help Inbox, profil, ubah password, dan notifikasi tidak dijadikan fokus utama penelitian.

### Bagaimana proses pencarian petugas?

Jemaah login, aplikasi membaca role, mengambil lokasi GPS, membaca data petugas dari Firebase, menghitung jarak dengan Haversine, mengurutkan hasil, menampilkan maksimal 10 petugas terdekat, lalu jemaah dapat memilih petugas untuk melihat rute.

### Apa hasil dari BAB V?

Simpulannya, aplikasi dapat menentukan petugas haji terdekat berdasarkan lokasi jemaah menggunakan Haversine Formula, menampilkan hasil pada peta, dan menyediakan rute navigasi menuju petugas yang dipilih melalui Mapbox Directions API. Saran pengembangan diarahkan pada perluasan area pengujian, peningkatan akurasi data lokasi, dan pengujian performa teknis yang lebih rinci.

## Kalimat Aman yang Bisa Diulang

- Sistem ini adalah alat bantu informasi lokasi.
- Haversine digunakan untuk estimasi jarak awal dan pengurutan.
- Mapbox digunakan untuk peta dan rute setelah tujuan dipilih.
- Jarak Haversine dan jarak rute dapat berbeda.
- Hasil sistem bergantung pada kualitas GPS, internet, validitas data, Firebase, dan Mapbox.
- Pengujian performa teknis rinci belum menjadi fokus utama penelitian.
- Untuk penggunaan operasional, sistem masih membutuhkan pengujian lapangan lebih luas.

## Kalimat yang Sebaiknya Dihindari

- Sistem ini menyelesaikan semua masalah jemaah haji.
- Sistem ini pasti akurat di semua kondisi.
- Sistem ini menggantikan petugas haji.
- Sistem ini menggantikan prosedur darurat.
- Jarak Haversine adalah jarak jalan.
- Aplikasi ini sudah siap dipakai secara resmi.

## Versi Singkat Penutup Jika Waktu Hampir Habis

Secara ringkas, penelitian ini membangun aplikasi mobile untuk membantu pencarian petugas haji terdekat. Sistem mengambil koordinat jemaah melalui GPS, membaca data petugas dari Firebase, menghitung jarak awal menggunakan Haversine Formula, lalu mengurutkan petugas terdekat. Setelah petugas dipilih, Mapbox Directions API digunakan untuk menampilkan rute. Sistem ini tetap diposisikan sebagai alat bantu informasi lokasi, dengan pengembangan lanjutan pada validasi data lapangan, perluasan area pengujian, dan pengujian performa teknis yang lebih rinci.
