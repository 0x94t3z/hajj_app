# Catatan Final Kolokium Tugas Akhir

Judul: Pencarian Lokasi Terdekat Petugas Haji pada Ibadah Haji Menggunakan Algoritma Haversine Formula Berbasis Mobile  
Nama: Muhamad Taopik  
NIM: 1197050081  
Program Studi: Teknik Informatika, UIN Sunan Gunung Djati Bandung

## Cara Memakai Catatan Ini

Catatan ini bukan naskah untuk dibaca kata per kata. Gunakan sebagai pegangan latihan agar penjelasan terdengar natural, formal, dan sesuai dengan penulisan tugas akhir.

Pegangan utama saat presentasi:

- Slide cukup dijadikan penanda poin.
- Penjelasan lisan mengikuti catatan ini.
- Jangan terlalu panjang di slide awal.
- Demo utama dilakukan pada slide 14.
- Jika dosen memotong atau bertanya, jawab dengan batasan penelitian yang aman.

Dasar isi catatan:

- BAB I: latar belakang, rumusan masalah, tujuan, manfaat, batasan, kerangka pemikiran.
- BAB II: kajian literatur, Haversine Formula, GPS, Location-Based Service, Mapbox.
- BAB III: metodologi, analisis sistem, desain, arsitektur, UI, pengembangan, pengujian.
- BAB IV: implementasi aplikasi, Haversine, Mapbox, fitur UI, pengujian, hasil perbandingan.
- BAB V: simpulan dan saran.
- Project aplikasi: Flutter, Firebase, GPS/Geolocator, Mapbox, dan Haversine.

## Alur Besar Presentasi

Pembukaan:
Perkenalkan identitas, judul, dan fokus penelitian.

Masalah:
Jemaah haji berada di area padat dan dapat kesulitan menemukan petugas saat membutuhkan bantuan.

Solusi:
Aplikasi mobile membaca lokasi pengguna, mengambil data lokasi petugas, menghitung jarak awal dengan Haversine Formula, lalu menampilkan petugas terdekat pada peta.

Teknis:
Flutter sebagai mobile app, Firebase untuk autentikasi dan database, GPS untuk koordinat, Haversine untuk ranking jarak, Mapbox untuk peta dan rute.

Demo:
Tunjukkan alur login, home, Find My, Find Officers, hasil petugas terdekat, dan rute Mapbox.

Penutup:
Sampaikan bahwa sistem berhasil menjalankan fungsi utama, tetapi tetap memiliki batasan pada validitas data, koneksi internet, GPS, Firebase, dan Mapbox.

## Kapan Harus Demo

Demo utama dilakukan saat membahas **Slide 14 - Validasi Alur Aplikasi**.

Sebelum slide 14, jangan membuka aplikasi terlalu banyak. Gunakan screenshot pada slide untuk menjelaskan antarmuka. Ini membuat alur presentasi lebih rapi dan dosen tidak merasa presentasi meloncat dari konsep ke demo terlalu cepat.

Mini-demo opsional:

- Slide 11: boleh tunjukkan tampilan login/home dari screenshot saja.
- Slide 12: jika ditanya, boleh buka Find My sebentar.
- Slide 13: jika ditanya, jelaskan singkat sebagai fitur pendukung, bukan fokus rumusan masalah.
- Slide 14: demo lengkap, tetapi slide tetap ditulis sebagai validasi fungsi utama.

Jika waktu presentasi hanya 8-10 menit:

- Slide 1-5: 2 menit.
- Slide 6-10: 3 menit.
- Slide 11-13: 2 menit.
- Slide 14: 3 menit.
- Slide 15-17: 1-2 menit.

## Slide 01 - Seminar Kolokium Tugas Akhir

Tujuan:
Membuka presentasi dan memperkenalkan identitas penelitian.

Sumber skripsi:
Halaman judul dan abstrak.

Poin lisan:

- Ucapkan salam.
- Ucapkan terima kasih kepada dosen dan hadirin yang sudah menyempatkan hadir.
- Perkenalkan nama, NIM, jurusan, dan kampus.
- Sebutkan judul lengkap tugas akhir.
- Sampaikan bahwa fokus penelitian adalah pencarian petugas haji terdekat menggunakan aplikasi mobile.
- Sebutkan komponen inti secara singkat: Flutter, Firebase, GPS, Mapbox, dan Haversine.

Contoh narasi:

Assalamu'alaikum warahmatullahi wabarakatuh. Terima kasih kepada Bapak/Ibu dosen dan hadirin yang telah menyempatkan waktu untuk hadir pada kolokium ini. Perkenalkan, saya Muhamad Taopik, NIM 1197050081, dari Program Studi Teknik Informatika UIN Sunan Gunung Djati Bandung. Pada kolokium ini saya akan mempresentasikan tugas akhir berjudul "Pencarian Lokasi Terdekat Petugas Haji pada Ibadah Haji Menggunakan Algoritma Haversine Formula Berbasis Mobile". Secara umum, penelitian ini membahas aplikasi mobile yang membantu jemaah mengetahui petugas haji terdekat berdasarkan lokasi pengguna.

Jangan:

- Jangan langsung menjelaskan rumus.
- Jangan langsung membuka aplikasi.
- Jangan menyebut sistem sebagai solusi darurat resmi.

Demo:
Tidak ada demo.

Transisi:
Setelah memperkenalkan judul, saya akan masuk ke latar belakang kenapa topik ini diangkat.

## Slide 02 - Latar Belakang

Tujuan:
Menjelaskan masalah utama dan alasan penelitian ini penting.

Sumber skripsi:
BAB I bagian Latar Belakang Penelitian.

Poin lisan:

- Ibadah haji melibatkan jumlah jemaah besar dalam area terbatas.
- Situasi lapangan dapat padat, dinamis, dan tidak familiar bagi sebagian jemaah.
- Jemaah dapat kesulitan menemukan petugas ketika membutuhkan bantuan.
- Pencarian manual dapat memakan waktu, terutama dalam kondisi ramai.
- Perangkat mobile memiliki GPS yang dapat dimanfaatkan untuk membaca koordinat.
- Koordinat tersebut dapat dipakai untuk menghitung jarak dan menentukan kandidat petugas terdekat.

Contoh narasi:

Latar belakang penelitian ini berangkat dari kondisi ibadah haji yang melibatkan banyak jemaah dalam area yang relatif terbatas, khususnya di Makkah dan sekitarnya. Dalam kondisi padat, jemaah dapat mengalami kesulitan ketika harus menemukan petugas haji terdekat. Pencarian secara manual masih mungkin dilakukan, tetapi dalam situasi ramai prosesnya bisa memakan waktu. Karena itu, perangkat mobile yang sudah memiliki GPS dapat dimanfaatkan untuk membaca posisi pengguna, lalu posisi tersebut digunakan sebagai dasar pencarian petugas terdekat.

Jawaban aman:
Penelitian ini tidak mengambil posisi sebagai pengganti mekanisme resmi, tetapi sebagai alat bantu informasi lokasi.

Demo:
Tidak ada demo.

Transisi:
Dari latar belakang tersebut, rumusan masalah penelitian saya fokuskan pada implementasi perhitungan jarak dan penampilan lokasi petugas dalam aplikasi mobile.

## Slide 03 - Rumusan Masalah

Tujuan:
Menunjukkan fokus penelitian agar pembahasan tidak melebar.

Sumber skripsi:
BAB I bagian Perumusan Masalah Penelitian.

Poin lisan:

- Pada skripsi, rumusan masalah utama adalah implementasi Haversine Formula untuk menghitung dan mengurutkan petugas haji terdekat berdasarkan latitude dan longitude.
- Slide memecah fokus tersebut menjadi aspek perhitungan, tampilan lokasi petugas, serta visualisasi peta/rute agar alur presentasi mudah dipahami.
- Fitur bantuan/chat tidak dijadikan fokus rumusan masalah.

Contoh narasi:

Berdasarkan latar belakang tadi, fokus penelitian saya adalah bagaimana Haversine Formula diimplementasikan untuk menghitung dan mengurutkan petugas haji terdekat berdasarkan koordinat latitude dan longitude. Pada slide, fokus tersebut saya uraikan menjadi proses perhitungan, penampilan lokasi petugas pada aplikasi mobile, serta visualisasi peta dan rute setelah petugas dipilih. Jadi pembahasan tetap diarahkan pada pencarian petugas terdekat, bukan pada fitur komunikasi.

Jika dosen bertanya kenapa slide memuat beberapa poin:
Jawab: poin pada slide adalah pemecahan alur teknis agar mudah dijelaskan. Rumusan utama pada skripsi tetap implementasi Haversine Formula untuk menghitung dan mengurutkan petugas haji terdekat.

Demo:
Tidak ada demo.

Transisi:
Setelah rumusan masalah, saya jelaskan tujuan dan manfaat penelitian.

## Slide 04 - Tujuan dan Manfaat

Tujuan:
Menjelaskan output yang ingin dicapai dari penelitian.

Sumber skripsi:
BAB I bagian Tujuan dan Manfaat Penelitian.

Poin lisan:

- Tujuan penelitian: mengimplementasikan Haversine Formula untuk menghitung dan mengurutkan petugas terdekat.
- Tujuan aplikasi: membangun aplikasi mobile yang dapat menampilkan lokasi petugas dengan Mapbox.
- Manfaat praktis: membantu jemaah mengetahui lokasi petugas terdekat.
- Manfaat akademik: menjadi referensi pengembangan Location-Based Service yang menggunakan Haversine dan Mapbox.
- Output sistem: koordinat jemaah, data lokasi petugas, ranking Haversine, tampilan peta, daftar petugas terdekat, dan rute.

Contoh narasi:

Tujuan utama penelitian ini adalah mengimplementasikan Haversine Formula untuk menghitung jarak awal antara jemaah dan petugas, kemudian mengurutkan petugas berdasarkan jarak terdekat. Selain itu, aplikasi mobile dikembangkan agar hasil perhitungan tersebut dapat ditampilkan sebagai marker pada peta dan sebagai daftar petugas terdekat yang sudah diurutkan. Dari sisi manfaat, sistem ini diharapkan membantu jemaah mengetahui lokasi petugas terdekat dan menjadi referensi untuk pengembangan aplikasi berbasis lokasi.

Catatan penting:
Gunakan kata "membantu", bukan "menjamin", "menyelamatkan", atau "menggantikan layanan resmi".

Demo:
Tidak ada demo.

Transisi:
Supaya klaim penelitian tetap proporsional, saya jelaskan batasan masalah penelitian.

## Slide 05 - Batasan Masalah Penelitian

Tujuan:
Menjaga klaim penelitian tetap aman dan sesuai skripsi.

Sumber skripsi:
BAB I bagian Batasan Masalah Penelitian.

Poin lisan:

- Aplikasi dikembangkan menggunakan Flutter untuk platform mobile.
- Perhitungan jarak memakai Haversine Formula berdasarkan latitude dan longitude.
- Data lokasi pengujian menggunakan data dummy kawasan Makkah dan zona uji UIN Sunan Gunung Djati Bandung.
- Data disimpan menggunakan Firebase Realtime Database.
- Peta ditampilkan menggunakan Mapbox API.
- Sistem menampilkan maksimal 10 petugas haji terdekat.
- Rute navigasi memakai Mapbox Directions API setelah petugas dipilih.
- Pengujian difokuskan pada fungsi utama, bukan performa teknis rinci seperti memori, frame rate, atau waktu render.

Contoh narasi:

Pada penelitian ini, ruang lingkup saya batasi agar pembahasan tetap terarah. Aplikasi dikembangkan menggunakan Flutter, data disimpan pada Firebase Realtime Database, dan peta ditampilkan menggunakan Mapbox. Perhitungan jarak dilakukan menggunakan Haversine Formula berdasarkan latitude dan longitude. Sistem menampilkan maksimal 10 petugas terdekat. Untuk rute navigasi, aplikasi menggunakan Mapbox Directions API setelah pengguna memilih petugas.

Jawaban paling aman:
Sistem ini merupakan alat bantu informasi lokasi, bukan pengganti prosedur resmi layanan darurat.

Jika dosen bertanya soal akurasi:
Haversine menghitung estimasi jarak awal berdasarkan koordinat. Jarak tersebut bukan jarak tempuh jalan. Untuk rute jalan, sistem menggunakan Mapbox Directions API.

Demo:
Tidak ada demo.

Transisi:
Setelah batasan, saya masuk ke komponen teknologi yang digunakan dalam aplikasi.

## Slide 06 - Teknologi dan Komponen Sistem

Tujuan:
Menjelaskan komponen aplikasi dan hubungan antarteknologi.

Sumber skripsi:
BAB III bagian Analisis Teknologi, BAB IV bagian Arsitektur Sistem, dan README project.

Poin lisan:

- Flutter dan Dart: membangun antarmuka dan logic aplikasi mobile.
- GPS/Geolocator: membaca koordinat pengguna.
- Firebase Authentication: autentikasi pengguna.
- Firebase Realtime Database: menyimpan profil, role, dan koordinat lokasi.
- Haversine Formula: menghitung jarak awal dan ranking petugas.
- Mapbox API: menampilkan peta.
- Mapbox Directions API: menampilkan rute berjalan, jarak rute, durasi, dan instruksi arah.
- Detail node Firebase seperti users, helpConversations, helpConversationSessions, dan helpNotificationRequests cukup disimpan sebagai bahan tanya jawab jika dosen menanyakan struktur data.

Contoh narasi:

Komponen sistem dibagi menjadi beberapa bagian. Aplikasi mobile dikembangkan menggunakan Flutter dan Dart. Untuk autentikasi dan data pengguna, sistem memakai Firebase Authentication dan Firebase Realtime Database. Lokasi pengguna diperoleh dari GPS melalui Geolocator. Setelah koordinat pengguna dan petugas tersedia, Haversine Formula menghitung jarak awal untuk menentukan urutan petugas terdekat. Mapbox digunakan untuk peta, sedangkan Mapbox Directions API digunakan ketika pengguna membuka rute menuju petugas yang dipilih.

Bagian yang perlu ditegaskan:
Perhitungan Haversine dilakukan pada sisi aplikasi atau frontend. Firebase menyimpan data, tetapi bukan tempat utama menghitung ranking.

Jika dosen bertanya soal backend Python:
Backend Python digunakan sebagai komponen administratif untuk pengolahan data secara batch, seperti pembersihan data, impor data, pembuatan akun, dan pembaruan data ke Firebase. Backend tersebut bukan REST API utama aplikasi.

Demo:
Tidak ada demo.

Transisi:
Setelah komponen teknologi, saya jelaskan tahapan metodologi penelitian.

## Slide 07 - Metodologi Penelitian

Tujuan:
Menunjukkan proses penelitian dari perencanaan sampai implementasi.

Sumber skripsi:
BAB III Metodologi Penelitian, khususnya metode System Development Life Cycle (SDLC).

Poin lisan:

- Metode penelitian yang digunakan adalah System Development Life Cycle (SDLC).
- Planning: menentukan masalah, kebutuhan, dan ruang lingkup.
- Analysis: menganalisis role pengguna, kebutuhan data, alur sistem, teknologi, dan keamanan.
- Design: merancang arsitektur, flow, database, dan antarmuka.
- Development: membangun aplikasi dengan Flutter, Firebase, Haversine, dan Mapbox.
- Testing: menguji fungsi utama, perhitungan jarak, peta, dan navigasi.
- Implementation: menjalankan aplikasi pada emulator, simulator, dan perangkat fisik.

Contoh narasi:

Metodologi penelitian yang saya gunakan adalah System Development Life Cycle atau SDLC. Tahapannya dimulai dari planning sampai implementation. Pada tahap planning, saya menentukan masalah dan ruang lingkup penelitian. Pada tahap analysis, saya menganalisis kebutuhan pengguna, role, alur sistem, teknologi, serta aspek keamanan. Tahap design digunakan untuk merancang arsitektur dan antarmuka. Setelah itu aplikasi dikembangkan menggunakan Flutter, Firebase, Haversine, dan Mapbox. Terakhir, sistem diuji untuk memastikan fungsi utama berjalan.

Catatan valid:
Sebut "pengujian fungsi utama", karena skripsi memang tidak memfokuskan pengujian performa teknis rinci.

Demo:
Tidak ada demo.

Transisi:
Berikutnya saya jelaskan alur sistem pencarian dari login sampai hasil petugas ditampilkan.

## Slide 08 - Alur Sistem Pencarian

Tujuan:
Menjelaskan proses inti aplikasi secara runtut.

Sumber skripsi:
BAB III bagian Analisis Alur Sistem, Arsitektur Sistem, dan BAB IV bagian Alur Data dalam Sistem.

Poin lisan:

- Pengguna login.
- Sistem membaca akun dan role pengguna.
- Aplikasi mengambil koordinat pengguna melalui GPS.
- Koordinat pengguna diperbarui ke Firebase.
- Aplikasi mengambil data lokasi petugas dari Firebase.
- Sistem memfilter data sesuai role dan area.
- Haversine menghitung jarak dari pengguna ke tiap petugas.
- Hasil diurutkan dari jarak terkecil.
- Maksimal 10 petugas terdekat ditampilkan.
- Jika petugas dipilih, Mapbox Directions API menampilkan rute.

Contoh narasi:

Alur pencarian dimulai ketika pengguna login. Setelah login, sistem membaca role pengguna, kemudian aplikasi mengambil koordinat lokasi melalui GPS. Koordinat ini diperbarui ke Firebase dan digunakan sebagai titik awal pencarian. Aplikasi mengambil data petugas dari Firebase, kemudian menghitung jarak dari posisi pengguna ke setiap petugas menggunakan Haversine Formula. Hasilnya diurutkan dari jarak terkecil dan ditampilkan sebagai daftar petugas terdekat serta marker pada peta.

Kalimat pembeda yang penting:
Haversine digunakan untuk urutan awal, sedangkan Mapbox digunakan untuk visualisasi peta dan rute setelah petugas dipilih.

Demo:
Tidak ada demo live. Ini masih penjelasan konsep.

Transisi:
Setelah alur sistem, saya jelaskan algoritma Haversine yang menjadi inti perhitungan jarak.

## Slide 09 - Implementasi Haversine Formula

Tujuan:
Menjelaskan rumus dan perannya tanpa terlalu matematis.

Sumber skripsi:
BAB II Landasan Teori Haversine Formula, BAB III Flowchart, BAB IV Implementasi Algoritma Haversine.

Poin lisan:

- Haversine Formula menghitung jarak antara dua titik koordinat di permukaan bumi.
- Input: latitude dan longitude pengguna serta petugas.
- Koordinat dari GPS berbentuk derajat, lalu dikonversi ke radian karena fungsi `sin`, `cos`, dan `asin` bekerja dalam radian.
- Sistem menghitung selisih latitude dan longitude: `Δlat` dan `Δlon`.
- Sistem menghitung nilai `a` sebagai inti rumus Haversine.
- Radius bumi yang digunakan dalam kode adalah 6371.0088 km.
- Output berupa jarak dalam kilometer.
- Jarak dipakai untuk mengurutkan petugas dari yang paling dekat.
- Dalam kode, nilai `a` di-clamp ke rentang 0 sampai 1 agar perhitungan tetap stabil sebelum akar dan sudut pusat dihitung.

Contoh narasi:

Haversine Formula digunakan untuk menghitung jarak antara dua titik koordinat pada permukaan bumi. Inputnya adalah latitude dan longitude pengguna serta latitude dan longitude petugas. Koordinat dari GPS masih berbentuk derajat, sehingga sistem mengubahnya terlebih dahulu ke radian. Setelah itu sistem menghitung selisih latitude dan longitude, menghitung nilai `a`, lalu menghitung jarak menggunakan radius bumi 6371.0088 kilometer. Outputnya berupa jarak dalam kilometer, kemudian sistem mengurutkan petugas dari jarak paling kecil.

Cara menjelaskan perhitungan secara detail:

1. Titik pertama adalah posisi pengguna, yaitu `lat1` dan `lon1`.
2. Titik kedua adalah posisi petugas, yaitu `lat2` dan `lon2`.
3. Latitude dan longitude dikonversi dari derajat ke radian dengan rumus `derajat × π / 180`.
4. Sistem menghitung `Δlat = lat2 - lat1` dan `Δlon = lon2 - lon1`.
5. Sistem menghitung nilai inti Haversine:
   `a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)`.
6. Nilai `a` kemudian dijaga pada rentang 0 sampai 1. Tujuannya untuk menghindari error akibat pembulatan angka desimal komputer.
7. Jarak dihitung dengan:
   `d = 2r × asin(√a)`, dengan `r = 6371.0088 km`.
8. Perhitungan ini dilakukan ke setiap petugas yang datanya valid.
9. Hasil jarak dibandingkan, lalu daftar petugas diurutkan dari nilai paling kecil.

Catatan validasi rumus:
Rumus di slide sudah sesuai dengan rumus Haversine. Di kode aplikasi, bentuk akhirnya memakai `atan2(√a, √(1-a))` setelah nilai `a` di-clamp. Bentuk tersebut ekuivalen dengan `asin(√a)` untuk nilai `a` pada rentang 0 sampai 1, sehingga aman dijelaskan sebagai Haversine Formula.

Validasi sederhana yang bisa disebut jika ditanya:
Jika titik pengguna dan titik petugas sama, hasil jaraknya 0 km. Jika terdapat selisih koordinat, nilai jarak bertambah sesuai perbedaan posisi. Contoh pembanding umum, selisih 1 derajat longitude di ekuator menghasilkan jarak sekitar 111.195 km dengan radius bumi 6371.0088 km. Ini menunjukkan rumus dan implementasi berada pada skala yang benar.

Versi sederhana jika dosen non-teknis:
Intinya, Haversine menghitung jarak awal antarkoordinat. Dari hasil jarak itu, sistem mengetahui kandidat petugas yang paling dekat.

Jika dosen bertanya kenapa tidak pakai Mapbox untuk ranking semua petugas:
Haversine lebih sesuai untuk tahap awal karena ringan untuk menghitung satu titik pengguna ke banyak titik petugas. Mapbox digunakan setelah tujuan dipilih, karena rute jalan membutuhkan data jaringan jalan dan Directions API.

Demo:
Tidak ada demo.

Transisi:
Setelah jarak awal dihitung dengan Haversine, sistem membutuhkan peta dan rute. Bagian itu menggunakan Mapbox.

## Slide 10 - Integrasi Mapbox

Tujuan:
Menjelaskan peran Mapbox dan batasannya.

Sumber skripsi:
BAB I batasan, BAB III teknologi, BAB IV implementasi Mapbox dan perbandingan Haversine dengan Mapbox Directions API.

Poin lisan:

- Mapbox API digunakan untuk visualisasi peta.
- Peta menampilkan lokasi pengguna dan petugas.
- Mapbox Directions API digunakan untuk rute setelah petugas dipilih.
- Directions API menghasilkan rute berjalan, jarak rute, durasi, dan instruksi arah.
- Jarak Haversine dan jarak Mapbox dapat berbeda.
- Perbedaannya wajar karena Haversine menghitung jarak antarkoordinat, sedangkan Mapbox menghitung rute berdasarkan jaringan jalan.

Contoh narasi:

Mapbox pada sistem ini digunakan untuk dua kebutuhan. Pertama, menampilkan peta dan posisi pengguna maupun petugas. Kedua, melalui Mapbox Directions API, sistem menampilkan rute berjalan setelah pengguna memilih petugas. Jadi Haversine dan Mapbox memiliki fungsi berbeda. Haversine menghasilkan urutan awal petugas terdekat, sedangkan Mapbox menghasilkan rute navigasi.

Data valid dari skripsi:
Pada pengujian, contoh Souq Al-Khalil memiliki jarak Haversine 0.542 km, sedangkan jarak Mapbox Directions API 0.925 km. Selisih ini wajar karena Mapbox mengikuti rute jalan.

Jika dosen bertanya kenapa jarak Mapbox lebih besar:
Karena jarak rute mengikuti jalur yang tersedia, tidak selalu berupa garis langsung dari titik pengguna ke titik petugas.

Demo:
Tidak ada demo live.

Transisi:
Setelah menjelaskan bagian teknis, saya tampilkan implementasi antarmuka aplikasi.

## Slide 11 - Implementasi Antarmuka Aplikasi

Tujuan:
Menunjukkan tampilan aplikasi secara umum sebelum demo.

Sumber skripsi:
BAB III perancangan UI dan BAB IV implementasi halaman Login, Home, dan Find Officers.

Poin lisan:

- Login digunakan untuk autentikasi melalui Firebase Authentication.
- Setelah login, aplikasi membaca data pengguna dan role dari Firebase.
- Home menjadi titik masuk setelah login.
- Find My menjadi pusat pencarian lokasi.
- Tombol Find Officers digunakan oleh jemaah untuk mencari petugas terdekat.
- UI yang ditampilkan pada slide merupakan tampilan final aplikasi.

Contoh narasi:

Pada bagian antarmuka, halaman login digunakan untuk autentikasi pengguna. Setelah login berhasil, aplikasi membaca profil dan role pengguna. Halaman home menjadi titik awal sebelum pengguna masuk ke fitur pencarian. Fitur Find My digunakan untuk membaca lokasi pengguna dan memulai pencarian petugas melalui tombol Find Officers.

Jika dosen bertanya role:
Role membedakan tampilan dan hak akses pengguna. Pada fokus penelitian ini, role digunakan agar pencarian diarahkan ke target pengguna yang sesuai.

Demo:
Belum demo utama. Tunjukkan screenshot saja.

Transisi:
Setelah tampilan dasar, saya jelaskan fitur pencarian dan navigasi.

## Slide 12 - Fitur Pencarian dan Navigasi

Tujuan:
Menjelaskan hasil utama sistem dari sisi pengguna.

Sumber skripsi:
BAB IV implementasi tampilan hasil pencarian, peta hasil pencarian, dan halaman navigasi.

Poin lisan:

- Pengguna menekan Find Officers.
- Sistem mengambil koordinat pengguna.
- Sistem membaca data petugas dari Firebase.
- Haversine menghitung jarak ke tiap petugas.
- Daftar petugas diurutkan berdasarkan jarak terdekat.
- Hasil ditampilkan sebagai daftar petugas terdekat dan marker pada peta.
- Setelah petugas dipilih, Mapbox Directions API menampilkan rute.
- Navigasi menampilkan estimasi jarak, waktu tempuh, dan instruksi arah.

Contoh narasi:

Fitur pencarian adalah bagian utama dari penelitian ini. Ketika pengguna menekan Find Officers, aplikasi mengambil koordinat pengguna dan membaca data petugas dari Firebase. Setelah itu, Haversine menghitung jarak ke masing-masing petugas dan hasilnya diurutkan dari yang paling dekat. Pengguna dapat melihat daftar petugas terdekat, marker petugas pada peta, lalu memilih petugas untuk membuka rute navigasi.

Data valid dari skripsi:
Pada pengujian BAB IV, sistem mampu mengurutkan 10 petugas terdekat. Contoh hasil terdekat adalah Souq Al-Khalil dengan jarak Haversine 0.542 km dari titik uji.

Demo:
Belum demo lengkap. Jika dosen meminta, boleh buka app sampai Find My, lalu kembali ke slide.

Transisi:
Setelah pencarian dan navigasi, saya jelaskan singkat fitur pendukung pengguna agar tidak menggeser fokus penelitian.

## Slide 13 - Fitur Pendukung dan Peran Pengguna

Tujuan:
Menjelaskan fitur pendukung secara singkat tanpa menjadikannya fokus utama penelitian.

Sumber skripsi:
BAB III dan BAB IV bagian perancangan serta implementasi fitur pendukung aplikasi.

Poin lisan:

- Role pengguna menentukan tampilan dan target pencarian.
- Fitur pendukung seperti Help Inbox dan Chat tersedia pada aplikasi.
- Bagian ini cukup dijelaskan sebagai pelengkap penggunaan aplikasi.
- Fokus utama penelitian tetap pencarian petugas terdekat, perhitungan Haversine, peta, dan rute.

Contoh narasi:

Pada slide ini, saya hanya menunjukkan bahwa aplikasi memiliki fitur pendukung berdasarkan role pengguna. Namun bagian ini tidak saya jadikan pembahasan utama, karena rumusan masalah penelitian berfokus pada implementasi Haversine Formula untuk menghitung dan mengurutkan petugas haji terdekat. Jadi penjelasan slide ini cukup singkat, lalu saya kembali ke alur validasi pencarian dan rute.

Jawaban aman:
Fitur pendukung ini bukan bagian utama evaluasi penelitian dan bukan prosedur resmi penanganan darurat.

Demo:
Belum demo utama. Screenshot cukup.

Transisi:
Setelah menjelaskan fitur, saya masuk ke validasi alur aplikasi.

## Slide 14 - Validasi Alur Aplikasi

Tujuan:
Menjelaskan validasi alur fungsi utama aplikasi, lalu menggunakannya sebagai momen demo.

Sumber skripsi:
BAB IV implementasi sistem, BAB IV pengujian fungsi utama, dan aplikasi Hajj App.

Sebelum demo:

- Pastikan internet aktif.
- Pastikan Firebase dapat diakses.
- Pastikan Mapbox token valid.
- Pastikan izin lokasi aktif.
- Siapkan akun jemaah.
- Jika memakai simulator, atur lokasi agar sesuai area pengujian.

Urutan demo:

1. Buka aplikasi.
2. Login sebagai Jemaah Haji.
3. Buka halaman Home.
4. Masuk ke Find My.
5. Sampaikan bahwa aplikasi membaca koordinat GPS pengguna.
6. Gunakan tombol Find Officers.
7. Tunjukkan daftar petugas terdekat dan marker pada peta.
8. Sampaikan bahwa urutan berasal dari Haversine Formula.
9. Pilih salah satu petugas.
10. Buka rute/navigasi.
11. Sampaikan bahwa rute berasal dari Mapbox Directions API.
12. Tutup demo dengan batasan sistem.

Narasi saat demo:

Pada demo ini, saya menunjukkan alur utama aplikasi. Setelah pengguna login sebagai jemaah, aplikasi membaca lokasi pengguna melalui GPS. Ketika tombol Find Officers ditekan, sistem mengambil data petugas dari Firebase, lalu menghitung jarak awal menggunakan Haversine Formula. Hasilnya digunakan untuk mengurutkan petugas terdekat. Setelah petugas dipilih, aplikasi menggunakan Mapbox Directions API untuk menampilkan rute berjalan menuju petugas tersebut.

Saat daftar petugas muncul:

Bagian ini adalah hasil utama dari implementasi Haversine, karena sistem sudah menghitung jarak antara pengguna dan setiap petugas, kemudian menampilkan kandidat dengan jarak paling dekat.

Saat rute muncul:

Pada bagian ini, jarak yang tampil dapat berbeda dari jarak Haversine. Hal itu karena Haversine menghitung jarak awal antarkoordinat, sedangkan Mapbox menghitung rute berdasarkan jalur yang tersedia.

Jika GPS bermasalah:

Fitur ini membutuhkan izin lokasi. Jika saat demo lokasi tidak terbaca, saya menggunakan dokumentasi tampilan pendukung, tetapi alur sistem tetap sama: lokasi pengguna menjadi input untuk perhitungan Haversine.

Jika Firebase bermasalah:

Data petugas diambil dari Firebase Realtime Database. Jika koneksi atau rules Firebase bermasalah saat demo, saya jelaskan menggunakan slide alur sistem dan dokumentasi final UI.

Jika Mapbox bermasalah:

Mapbox digunakan untuk peta dan rute. Jika peta tidak tampil, saya tetap dapat menjelaskan bahwa Haversine sudah berperan pada ranking, sedangkan Mapbox hanya pada visualisasi dan rute.

Demo:
Demo utama dilakukan di slide ini.

Transisi:
Setelah demo, saya jelaskan rencana pengujian dan indikator keberhasilan sistem.

## Slide 15 - Rencana Pengujian dan Indikator

Tujuan:
Menjelaskan bagaimana sistem dievaluasi.

Sumber skripsi:
BAB IV bagian Pengujian dan Evaluasi Sistem.

Poin lisan:

- Pengujian dilakukan pada Android emulator, iOS simulator, dan iPhone fisik.
- Pengujian difokuskan pada fungsi utama.
- Fungsi yang diuji: login, lokasi, Firebase, peta, dan navigasi.
- Algoritma diuji dengan data koordinat jemaah dan petugas.
- Hasil Haversine dibandingkan dengan Mapbox Directions API.
- Indikator: urutan petugas sesuai jarak, marker dan rute tampil, serta dokumentasi final UI tersedia sebagai pendukung evaluasi.

Contoh narasi:

Pengujian pada penelitian ini difokuskan pada fungsi utama sistem. Aplikasi diuji pada Android emulator, iOS simulator, dan iPhone fisik. Bagian yang diuji meliputi login, pembacaan lokasi, pengambilan data dari Firebase, perhitungan Haversine, tampilan peta, dan navigasi. Untuk algoritma, hasil Haversine dibandingkan dengan hasil Mapbox Directions API agar terlihat perbedaan antara jarak antarkoordinat dan jarak rute.

Data valid dari skripsi:

- Titik uji jemaah ditempatkan pada koordinat Jabal Al Kaabah.
- Sistem menghasilkan 10 petugas terdekat.
- Souq Al-Khalil menjadi contoh petugas terdekat dengan jarak Haversine 0.542 km.
- Jarak Mapbox untuk titik yang sama adalah 0.925 km.
- Aplikasi dapat dijalankan pada Android dan iOS untuk mendukung fungsi utama.

Jika dosen bertanya performa:
Pengukuran performa teknis rinci seperti memori, frame rate, dan waktu render belum menjadi fokus utama penelitian. Fokus penelitian adalah keberhasilan fungsi pencarian, pengurutan, peta, dan navigasi.

Demo:
Tidak ada demo baru. Gunakan hasil demo slide 14 sebagai pembuktian.

Transisi:
Setelah pengujian, saya masuk ke penutup kolokium.

## Slide 16 - Penutup Kolokium

Tujuan:
Menyampaikan simpulan sementara dan arah pengembangan.

Sumber skripsi:
BAB V Simpulan dan Saran.

Poin lisan:

- Aplikasi dibangun sebagai alat bantu informasi lokasi petugas haji.
- Haversine digunakan untuk menghitung jarak awal dan mengurutkan petugas.
- Mapbox digunakan untuk menampilkan peta dan rute setelah petugas dipilih.
- Firebase digunakan untuk autentikasi, data pengguna, dan lokasi.
- Aplikasi dapat menjalankan fungsi utama pada platform mobile yang diuji.
- Pengembangan lanjutan: perluasan area pengujian, peningkatan akurasi data lokasi, pengujian performa teknis, dan pengujian pada kondisi yang lebih mendekati operasional haji.

Contoh narasi:

Sebagai penutup, aplikasi yang dibangun berfungsi sebagai alat bantu informasi lokasi petugas haji. Haversine Formula digunakan untuk menghitung jarak awal dan mengurutkan petugas terdekat, sedangkan Mapbox digunakan untuk peta dan rute setelah petugas dipilih. Berdasarkan pengujian, aplikasi dapat menjalankan fungsi utama seperti login, pencarian petugas, tampilan peta, dan navigasi pada platform mobile yang diuji.

Jawaban aman:
Untuk pengembangan berikutnya, sistem masih perlu diuji lebih luas dengan data lokasi lapangan yang lebih valid dan kondisi yang lebih mendekati operasional haji.

Demo:
Tidak ada demo.

Transisi:
Terakhir, saya tampilkan kontak dan siap menerima pertanyaan.

## Slide 17 - Kontak

Tujuan:
Menutup presentasi dan membuka sesi tanya jawab.

Sumber skripsi:
Identitas penulis dan informasi presentasi.

Poin lisan:

- Ucapkan terima kasih.
- Sebutkan bahwa penelitian terbuka untuk masukan.
- Undang dosen untuk memberikan pertanyaan atau arahan.

Contoh narasi:

Demikian presentasi kolokium tugas akhir saya. Terima kasih atas perhatian Bapak/Ibu dosen. Saya siap menerima pertanyaan, masukan, dan arahan untuk penyempurnaan penelitian ini.

Demo:
Tidak ada demo.

## Jawaban Cepat untuk Tanya Jawab

### Apa kontribusi utama penelitian ini?

Kontribusi utama penelitian ini adalah implementasi Haversine Formula pada aplikasi mobile untuk menentukan dan mengurutkan petugas haji terdekat berdasarkan koordinat pengguna dan petugas. Hasil perhitungan kemudian divisualisasikan melalui peta dan dapat dilanjutkan ke navigasi menggunakan Mapbox Directions API.

### Kenapa memilih Haversine Formula?

Karena Haversine sesuai untuk menghitung jarak antara dua titik koordinat geografis berdasarkan latitude dan longitude. Dalam sistem ini, Haversine digunakan untuk menghitung jarak awal dari satu jemaah ke banyak petugas secara ringan dan efisien.

### Kenapa tidak memakai Mapbox untuk semua perhitungan?

Haversine digunakan untuk ranking awal karena menghitung jarak antarkoordinat. Mapbox Directions API digunakan setelah pengguna memilih petugas, karena pada tahap itu sistem membutuhkan rute berdasarkan jaringan jalan. Jadi keduanya memiliki peran berbeda.

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

Data utama yang digunakan adalah data pengguna, role, profil, dan koordinat lokasi. Jika ditanya fitur pendukung, data percakapan dapat dijelaskan sebagai data tambahan aplikasi, bukan data utama dalam rumusan penelitian.

### Apakah data lokasi bersifat sensitif?

Ya. Karena itu sistem menggunakan autentikasi pengguna, permission lokasi, dan kontrol akses Firebase. Aplikasi tidak dapat membaca lokasi sebelum pengguna memberikan izin lokasi.

### Kenapa memakai Flutter?

Flutter digunakan karena mendukung pengembangan aplikasi mobile lintas platform dengan satu basis kode, sehingga aplikasi dapat dikembangkan untuk Android dan iOS.

### Kenapa memakai Firebase Realtime Database?

Firebase Realtime Database digunakan karena dapat menyimpan dan memperbarui data pengguna serta lokasi secara langsung. Hal ini sesuai dengan kebutuhan aplikasi berbasis lokasi yang perlu membaca data terbaru.

### Kenapa memakai Mapbox?

Mapbox dipakai karena pada penelitian ini saya membutuhkan dua hal: peta digital di dalam aplikasi mobile dan rute navigasi setelah petugas dipilih. Mapbox mendukung integrasi dengan Flutter melalui SDK/API, dapat menampilkan marker lokasi pengguna dan petugas, serta menyediakan Mapbox Directions API untuk mengambil rute berjalan, jarak rute, durasi, dan instruksi arah. Jadi Mapbox tidak dipakai untuk menggantikan Haversine, tetapi untuk visualisasi peta dan navigasi.

Jika dibandingkan dengan Google Maps atau layanan peta lain, layanan tersebut sebenarnya juga dapat digunakan untuk aplikasi berbasis lokasi. Namun, pada penelitian ini saya mempertimbangkan batasan sebagai mahasiswa, terutama terkait biaya, akses layanan, dan kebutuhan implementasi prototipe tugas akhir. Karena kebutuhan utama sistem adalah menampilkan peta, marker, dan rute setelah petugas dipilih, Mapbox sudah mencukupi untuk mendukung fungsi tersebut.

Jawaban yang lebih aman jika ditanya langsung “kenapa tidak Google Maps?”:

Google Maps memiliki ekosistem yang matang dan sangat banyak digunakan, tetapi dalam penelitian ini pemilihan teknologi juga mempertimbangkan keterbatasan biaya dan akses layanan untuk pengembangan tugas akhir. Karena fokus penelitian bukan membandingkan akurasi layanan peta, melainkan implementasi Haversine Formula untuk menentukan urutan petugas terdekat, saya menggunakan Mapbox sebagai layanan peta dan rute yang sesuai dengan kebutuhan prototipe sistem.

### Apa bedanya fitur utama dan fitur pendukung?

Fitur utama adalah pencarian petugas terdekat, perhitungan Haversine, peta, dan navigasi. Fitur pendukung seperti chat, Help Inbox, profil, ubah password, dan notifikasi tidak dijadikan fokus utama penelitian.

### Bagaimana proses pencarian petugas?

Pengguna login, aplikasi membaca role, mengambil lokasi GPS, membaca data petugas dari Firebase, menghitung jarak dengan Haversine, mengurutkan hasil, menampilkan maksimal 10 petugas terdekat, lalu pengguna dapat memilih petugas untuk melihat rute.

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

Secara ringkas, penelitian ini membangun aplikasi mobile untuk membantu pencarian petugas haji terdekat. Sistem mengambil koordinat pengguna melalui GPS, membaca data petugas dari Firebase, menghitung jarak awal menggunakan Haversine Formula, lalu mengurutkan petugas terdekat. Setelah petugas dipilih, Mapbox Directions API digunakan untuk menampilkan rute. Sistem ini tetap diposisikan sebagai alat bantu informasi lokasi, dengan pengembangan lanjutan pada validasi data lapangan, perluasan area pengujian, dan pengujian performa teknis yang lebih rinci.
