# Revisi Final Validasi Terakhir

Dokumen ini berisi rangkuman revisi kolokium, teks siap tempel, dan status validasi terakhir terhadap laporan tugas akhir `Tugas Akhir - Muhamad Taopik (1197050081).docx`.

## Urutan Pengerjaan

1. BAB I - perjelas batasan fitur bantuan.
2. BAB II - lengkapi penjelasan simbol dan visualisasi Haversine.
3. BAB III - ganti flowchart dan tambahkan flowchart algoritma Haversine.
4. BAB III - tambahkan rancangan database dalam bentuk ERD.
5. BAB III - perjelas rancangan fitur bantuan, pesan, dan notifikasi.
6. BAB IV - tambahkan contoh perhitungan manual Haversine.
7. BAB IV - perjelas satuan jarak dan perbedaan Haversine dengan Mapbox Directions API.
8. BAB V - tambahkan batasan dan saran pengembangan terkait banyak jemaah memilih petugas yang sama.

## 0. Abstrak - Penjelasan Koordinat

**Cari di abstrak Indonesia kalimat yang membahas koordinat latitude dan longitude.**

**Gunakan kalimat ini:**

Koordinat latitude dan longitude diperoleh dari perangkat jemaah dan petugas, kemudian jarak antara keduanya dihitung menggunakan Haversine Formula untuk menentukan dan mengurutkan petugas haji terdekat.

**Cari di abstract bahasa Inggris kalimat yang membahas coordinates.**

**Gunakan kalimat ini:**

The latitude and longitude coordinates are obtained from the devices of both the pilgrim and the officer. The distance between them is then calculated using the Haversine Formula to determine and rank the nearest Hajj officers.

**Catatan:**

Pada bagian ini jangan menggunakan `user's device` atau `pilgrim's device` saja, karena koordinat yang dihitung berasal dari dua pihak, yaitu jemaah dan petugas.

## 0.1 Konsistensi Istilah Pengguna, Jemaah, dan Petugas

Bagian ini dipakai untuk merapikan kata `pengguna` agar tidak ambigu. Jangan mengganti semua kata `pengguna` menjadi `jemaah`, karena pada beberapa bagian kata `pengguna` memang berarti semua aktor aplikasi, yaitu jemaah, petugas, dan administrator.

### Yang Perlu Diganti

**Abstrak Indonesia**

Ganti:

```text
Hasil penelitian menunjukkan bahwa aplikasi dapat menentukan petugas haji terdekat berdasarkan koordinat pengguna dan petugas
```

Menjadi:

```text
Hasil penelitian menunjukkan bahwa aplikasi dapat menentukan petugas haji terdekat berdasarkan koordinat jemaah dan petugas
```

**BAB I - Latar Belakang**

Ganti:

```text
Dalam penelitian ini, algoritma Haversine Formula digunakan untuk menentukan dan mengurutkan petugas haji terdekat berdasarkan koordinat geografis pengguna. Hasil perhitungan tersebut kemudian divisualisasikan dalam bentuk peta digital untuk memudahkan pengguna dalam mengetahui posisi petugas haji.
```

Menjadi:

```text
Dalam penelitian ini, algoritma Haversine Formula digunakan untuk menentukan dan mengurutkan petugas haji terdekat berdasarkan koordinat geografis jemaah dan petugas. Hasil perhitungan tersebut kemudian divisualisasikan dalam bentuk peta digital untuk memudahkan jemaah dalam mengetahui posisi petugas haji.
```

**BAB I - Kerangka Pemikiran**

Ganti:

```text
Untuk mengatasi permasalahan tersebut, dikembangkan aplikasi mobile yang memanfaatkan teknologi Global Positioning System (GPS) untuk memperoleh koordinat lokasi pengguna dalam bentuk latitude dan longitude.
```

Menjadi:

```text
Untuk mengatasi permasalahan tersebut, dikembangkan aplikasi mobile yang memanfaatkan teknologi Global Positioning System (GPS) untuk memperoleh koordinat lokasi jemaah dan petugas dalam bentuk latitude dan longitude.
```

Ganti:

```text
Selanjutnya, Mapbox API digunakan untuk menampilkan peta digital serta lokasi pengguna dan petugas haji dalam aplikasi. Setelah petugas haji terdekat ditemukan, Mapbox Directions API digunakan untuk menampilkan rute navigasi dari lokasi pengguna menuju lokasi petugas haji yang dipilih.
```

Menjadi:

```text
Selanjutnya, Mapbox API digunakan untuk menampilkan peta digital serta lokasi jemaah dan petugas haji dalam aplikasi. Setelah petugas haji terdekat ditemukan, Mapbox Directions API digunakan untuk menampilkan rute navigasi dari lokasi jemaah menuju lokasi petugas haji yang dipilih.
```

Ganti pada penjelasan Gambar 1.1:

```text
koordinat latitude dan longitude pengguna
```

Menjadi:

```text
koordinat latitude dan longitude jemaah dan petugas
```

Ganti:

```text
menampilkan peta dan lokasi pengguna
```

Menjadi:

```text
menampilkan peta dan lokasi jemaah serta petugas
```

**BAB II - Mapbox API**

Ganti:

```text
berdasarkan koordinat latitude dan longitude yang diperoleh dari perangkat pengguna
```

Menjadi:

```text
berdasarkan koordinat latitude dan longitude yang diperoleh dari perangkat jemaah dan petugas
```

**BAB III - Metode SDLC**

Ganti:

```text
untuk memperoleh koordinat lokasi pengguna serta menggunakan Mapbox API
```

Menjadi:

```text
untuk memperoleh koordinat lokasi jemaah dan petugas serta menggunakan Mapbox API
```

**BAB III - Analisis Teknologi**

Ganti:

```text
GPS digunakan untuk memperoleh koordinat lokasi pengguna berupa latitude dan longitude.
```

Menjadi:

```text
GPS digunakan untuk memperoleh koordinat lokasi jemaah dan petugas berupa latitude dan longitude.
```

Ganti:

```text
Firebase Realtime Database menyimpan data profil dan lokasi pengguna secara real-time.
```

Menjadi:

```text
Firebase Realtime Database menyimpan data profil dan lokasi jemaah serta petugas secara real-time.
```

**BAB III - Perancangan Halaman Beranda**

Ganti kalimat terakhir:

```text
Layar ini dipakai sebagai titik awal sebelum pengguna masuk ke proses pencarian petugas.
```

Menjadi:

```text
Layar ini dipakai sebagai titik awal sebelum jemaah masuk ke proses pencarian petugas.
```

**BAB III - Perancangan Halaman Pencarian Petugas**

Ganti seluruh paragraf:

```text
Proses utama dimulai dari layar ini. Pengguna melihat lokasi mereka saat ini dan tombol Cari Petugas. Saat tombol ditekan, sistem mengambil koordinat pengguna melalui GPS. Koordinat tersebut dipakai sebagai input untuk menghitung jarak ke petugas haji yang tersimpan pada database.
```

Menjadi:

```text
Proses utama dimulai dari layar ini. Jemaah melihat lokasi mereka saat ini dan tombol Cari Petugas. Saat tombol ditekan, sistem mengambil koordinat jemaah melalui GPS. Koordinat tersebut dipakai sebagai input untuk menghitung jarak ke petugas haji yang tersimpan pada database.
```

**BAB III - Perancangan Tampilan Peta Hasil Pencarian**

Ganti seluruh paragraf:

```text
Layar ini menampilkan posisi pengguna dan posisi petugas pada peta. Setelah sistem menghitung jarak, hasil pencarian ditampilkan pada peta agar pengguna dapat melihat letak petugas terhadap posisinya. Dari layar ini, pengguna dapat memilih petugas yang ingin dituju.
```

Menjadi:

```text
Layar ini menampilkan posisi jemaah dan posisi petugas pada peta. Setelah sistem menghitung jarak, hasil pencarian ditampilkan pada peta agar jemaah dapat melihat letak petugas terhadap posisinya. Dari layar ini, jemaah dapat memilih petugas yang ingin dituju.
```

**BAB III - Perancangan Tampilan Hasil Pencarian**

Ganti:

```text
berdasarkan jarak dari lokasi pengguna
```

Menjadi:

```text
berdasarkan jarak dari lokasi jemaah
```

Ganti:

```text
karena pengguna langsung mengetahui petugas mana yang paling dekat
```

Menjadi:

```text
karena jemaah langsung mengetahui petugas mana yang paling dekat
```

**BAB III - Perancangan Halaman Navigasi**

Ganti seluruh paragraf:

```text
Setelah petugas dipilih, pengguna masuk ke layar navigasi. Sistem menampilkan rute dari posisi pengguna menuju petugas, disertai jarak tempuh, waktu tempuh, dan petunjuk arah. Layar ini dipakai agar pengguna tidak berhenti pada hasil pencarian, tetapi bisa langsung bergerak menuju lokasi petugas.
```

Menjadi:

```text
Setelah petugas dipilih, jemaah masuk ke layar navigasi. Sistem menampilkan rute dari posisi jemaah menuju petugas, disertai jarak tempuh, waktu tempuh, dan petunjuk arah. Layar ini dipakai agar jemaah tidak berhenti pada hasil pencarian, tetapi bisa langsung bergerak menuju lokasi petugas.
```

**BAB III - Pengujian**

Ganti:

```text
menampilkan lokasi pengguna dan petugas pada peta
```

Menjadi:

```text
menampilkan lokasi jemaah dan petugas pada peta
```

**BAB IV - Proses Kerja Aplikasi**

Ganti seluruh paragraf:

```text
Proses kerja aplikasi dimulai ketika pengguna (jemaah) membuka aplikasi dan mengaktifkan fitur pencarian. Sistem akan mengambil koordinat lokasi pengguna, kemudian menghitung jarak ke setiap petugas menggunakan algoritma Haversine Formula. Hasil perhitungan tersebut digunakan untuk mengurutkan petugas berdasarkan jarak terdekat, kemudian ditampilkan kepada pengguna. Selanjutnya, pengguna dapat memilih petugas dan melihat rute navigasi melalui Mapbox Directions API.
```

Menjadi:

```text
Proses kerja aplikasi dimulai ketika jemaah membuka aplikasi dan mengaktifkan fitur pencarian. Sistem akan mengambil koordinat lokasi jemaah, kemudian menghitung jarak ke setiap petugas menggunakan algoritma Haversine Formula. Hasil perhitungan tersebut digunakan untuk mengurutkan petugas berdasarkan jarak terdekat, kemudian ditampilkan kepada jemaah. Selanjutnya, jemaah dapat memilih petugas dan melihat rute navigasi melalui Mapbox Directions API.
```

**BAB IV - Layanan Pemetaan**

Ganti:

```text
sistem menampilkan posisi pengguna dan petugas
```

Menjadi:

```text
sistem menampilkan posisi jemaah dan petugas
```

Ganti:

```text
sehingga pengguna dapat mengetahui jalur perjalanan menuju lokasi petugas
```

Menjadi:

```text
sehingga jemaah dapat mengetahui jalur perjalanan menuju lokasi petugas
```

**BAB IV - Alur Data dalam Sistem**

Ganti:

```text
hasil pencarian ditampilkan kepada pengguna dalam aplikasi
```

Menjadi:

```text
hasil pencarian ditampilkan kepada jemaah dalam aplikasi
```

Ganti poin-poin berikut:

```text
Pengguna melakukan login ke dalam aplikasi melalui Firebase Authentication.
Sistem mengambil lokasi pengguna menggunakan GPS pada perangkat mobile.
Koordinat lokasi pengguna diperbarui ke dalam Firebase Realtime Database.
Sistem menghitung jarak antara pengguna dan setiap petugas menggunakan algoritma Haversine Formula pada sisi frontend.
Data hasil pencarian ditampilkan kepada pengguna dalam bentuk daftar dan peta interaktif.
Jika pengguna memilih salah satu petugas, sistem menggunakan Mapbox Directions API untuk menampilkan rute navigasi menuju lokasi tujuan.
Dengan alur tersebut, sistem dapat menentukan dan menampilkan petugas haji terdekat berdasarkan lokasi pengguna.
```

Menjadi:

```text
Jemaah melakukan login ke dalam aplikasi melalui Firebase Authentication.
Sistem mengambil lokasi jemaah menggunakan GPS pada perangkat mobile.
Koordinat lokasi jemaah diperbarui ke dalam Firebase Realtime Database.
Sistem menghitung jarak antara jemaah dan setiap petugas menggunakan algoritma Haversine Formula pada sisi frontend.
Data hasil pencarian ditampilkan kepada jemaah dalam bentuk daftar dan peta interaktif.
Jika jemaah memilih salah satu petugas, sistem menggunakan Mapbox Directions API untuk menampilkan rute navigasi menuju lokasi tujuan.
Dengan alur tersebut, sistem dapat menentukan dan menampilkan petugas haji terdekat berdasarkan lokasi jemaah.
```

**BAB IV - Implementasi Algoritma Haversine Formula**

Ganti:

```text
jarak antara pengguna (jemaah haji) dan petugas haji
```

Menjadi:

```text
jarak antara jemaah haji dan petugas haji
```

Ganti:

```text
perangkat pengguna
```

Menjadi:

```text
perangkat jemaah
```

Ganti poin-poin berikut:

```text
Sistem mengambil koordinat lokasi pengguna menggunakan GPS.
Sistem menghitung jarak antara pengguna dan setiap petugas menggunakan algoritma Haversine Formula.
Sistem memilih sejumlah petugas dengan jarak terdekat untuk ditampilkan kepada pengguna.
```

Menjadi:

```text
Sistem mengambil koordinat lokasi jemaah menggunakan GPS.
Sistem menghitung jarak antara jemaah dan setiap petugas menggunakan algoritma Haversine Formula.
Sistem memilih sejumlah petugas dengan jarak terdekat untuk ditampilkan kepada jemaah.
```

Ganti:

```text
kondisi aktual pengguna di lapangan
```

Menjadi:

```text
kondisi aktual jemaah di lapangan
```

**BAB IV - Antarmuka Aplikasi**

Ganti:

```text
Antarmuka disusun agar pengguna dapat menjalankan pencarian lokasi, melihat hasil pada peta, dan membuka navigasi menuju petugas yang dipilih.
```

Menjadi:

```text
Antarmuka disusun agar jemaah dapat menjalankan pencarian lokasi, melihat hasil pada peta, dan membuka navigasi menuju petugas yang dipilih.
```

**BAB IV - Implementasi Halaman Beranda**

Ganti:

```text
sebelum pengguna menjalankan proses pencarian petugas
```

Menjadi:

```text
sebelum jemaah menjalankan proses pencarian petugas
```

**BAB IV - Implementasi Halaman Pencarian Petugas**

Ganti:

```text
aplikasi menampilkan lokasi pengguna
```

Menjadi:

```text
aplikasi menampilkan lokasi jemaah
```

**BAB IV - Implementasi Tampilan Peta**

Ganti seluruh paragraf:

```text
Peta dibangun dengan Mapbox. Pada layar ini, pengguna dapat melihat posisi mereka dan posisi petugas pada area yang sama. Hasil pencarian tidak hanya muncul dalam bentuk daftar. Letaknya juga ditampilkan pada peta agar pengguna dapat membaca posisi petugas terhadap lokasinya.
```

Menjadi:

```text
Peta dibangun dengan Mapbox. Pada layar ini, jemaah dapat melihat posisinya dan posisi petugas pada area yang sama. Hasil pencarian tidak hanya muncul dalam bentuk daftar. Letaknya juga ditampilkan pada peta agar jemaah dapat membaca posisi petugas terhadap lokasinya.
```

**BAB IV - Implementasi Tampilan Hasil Pencarian**

Ganti seluruh paragraf:

```text
Setelah data petugas dibaca dari basis data, sistem menghitung jarak antara pengguna dan setiap petugas dengan Haversine Formula. Hasil perhitungan itu lalu diurutkan dari yang paling dekat. Daftar itulah yang ditampilkan kepada pengguna. Bagian ini menjadi hasil utama penelitian karena menunjukkan bahwa sistem dapat menentukan petugas terdekat berdasarkan posisi pengguna.
```

Menjadi:

```text
Setelah data petugas dibaca dari basis data, sistem menghitung jarak antara jemaah dan setiap petugas dengan Haversine Formula. Hasil perhitungan itu lalu diurutkan dari yang paling dekat. Daftar itulah yang ditampilkan kepada jemaah. Bagian ini menjadi hasil utama penelitian karena menunjukkan bahwa sistem dapat menentukan petugas terdekat berdasarkan posisi jemaah.
```

**BAB IV - Implementasi Halaman Navigasi**

Ganti:

```text
Setelah pengguna memilih petugas
```

Menjadi:

```text
Setelah jemaah memilih petugas
```

Ganti:

```text
pengguna tidak hanya mengetahui siapa petugas terdekat
```

Menjadi:

```text
jemaah tidak hanya mengetahui siapa petugas terdekat
```

### Yang Tidak Perlu Diganti

Biarkan kata `pengguna` pada konteks berikut karena maknanya umum atau mencakup lebih dari satu role:

- `posisi pengguna secara real-time` pada penjelasan umum perangkat mobile dan GPS.
- `perancangan antarmuka pengguna`.
- `Location-Based Service ... lokasi pengguna` pada teori LBS.
- `GPS ... posisi pengguna` pada teori GPS.
- `Aplikasi mobile memungkinkan pengguna...` pada teori aplikasi mobile.
- `data pengguna` jika konteksnya data akun jemaah, petugas, dan administrator.
- `Analisis Pengguna (User Analysis)`.
- `tiga jenis pengguna utama`.
- `autentikasi pengguna`, `pengguna terdaftar`, dan `persetujuan pengguna` pada bagian keamanan.
- `kebutuhan pengguna` pada metode SDLC.
- `pengguna` pada tabel penelitian terdahulu, karena itu merujuk pada pengguna aplikasi pada penelitian lain.
- `Pengguna melakukan login` boleh tetap `pengguna` jika pembahasannya login umum untuk semua role. Namun jika paragrafnya khusus alur pencarian petugas, gunakan `jemaah`.

## 1. BAB I - Batasan Fitur Bantuan

**Cari di laporan:** `Batasan Masalah Penelitian`

**Letakkan setelah poin batasan tentang Mapbox Directions API atau setelah kalimat:** `Penelitian ini berfokus pada implementasi Haversine Formula untuk menentukan petugas haji terdekat, integrasi peta digital, dan penampilan rute navigasi pada aplikasi mobile.`

**Teks siap tempel:**

Fitur pesan bantuan dan notifikasi pada aplikasi digunakan sebagai fitur pendukung komunikasi antara jemaah dan petugas. Fitur tersebut dirancang untuk membantu jemaah menyampaikan kendala seperti tersesat, terpisah dari rombongan, membutuhkan arahan, atau membutuhkan bantuan awal. Namun, fitur ini tidak dimaksudkan sebagai pengganti prosedur resmi penanganan keadaan darurat dalam pelaksanaan ibadah haji.

Penelitian ini tetap berfokus pada implementasi Haversine Formula untuk menghitung jarak awal dan mengurutkan petugas haji terdekat berdasarkan koordinat latitude dan longitude. Fitur bantuan hanya digunakan sebagai pelengkap setelah jemaah memilih salah satu petugas dari hasil pencarian.

## 2. BAB II - Penjelasan Simbol Haversine

**Cari di laporan:** `Tabel 2. 2 Keterangan Simbol Haversine Formula`

**Letakkan setelah tabel simbol Haversine.**

**Teks siap tempel:**

Pada penelitian ini, titik pertama pada rumus Haversine adalah posisi jemaah, sedangkan titik kedua adalah posisi petugas haji. Nilai `lat1` dan `lon1` menunjukkan latitude dan longitude jemaah. Nilai `lat2` dan `lon2` menunjukkan latitude dan longitude petugas. Selisih latitude ditulis sebagai `dlat`, sedangkan selisih longitude ditulis sebagai `dlon`.

Nilai `a` merupakan nilai antara yang diperoleh dari kombinasi fungsi sinus dan cosinus. Nilai `a` dibatasi pada rentang 0 sampai 1 untuk menjaga stabilitas perhitungan, terutama ketika terdapat perbedaan pembulatan angka desimal pada koordinat. Setelah nilai `a` diperoleh, sistem menghitung nilai `c`, kemudian mengalikannya dengan radius bumi untuk memperoleh jarak dalam satuan kilometer.

**Tambahkan gambar pendukung jika diperlukan:**

`docs/kolokium/assets/haversine-ilustrasi-laporan.png`

Versi SVG yang bisa diedit:

`docs/kolokium/assets/haversine-ilustrasi-laporan.svg`

**Kalimat sebelum gambar:**

Ilustrasi Haversine Formula dapat dilihat pada Gambar 2.x. Ilustrasi tersebut menunjukkan bahwa perhitungan dilakukan dari dua titik koordinat, yaitu lokasi jemaah dan lokasi petugas, kemudian jarak dihitung berdasarkan selisih latitude dan longitude pada permukaan bumi.

## 3. BAB III - Flowchart Sistem

**Cari di laporan:** `Analisis Alur Sistem (Flow Analysis)`

**Letakkan setelah kalimat:** `Flowchart sistem pencarian petugas haji terdekat menggunakan algoritma Haversine Formula ditunjukkan pada Gambar 3.1.`

**Ganti gambar flowchart lama dengan file:**

`docs/kolokium/assets/flowchart-pencarian-revisi.png`

Versi SVG yang bisa diedit:

`docs/kolokium/assets/flowchart-pencarian-revisi.svg`

**Teks siap tempel setelah gambar:**

Gambar 3.1 menunjukkan alur sistem pencarian petugas haji terdekat. Proses dimulai ketika jemaah melakukan login ke aplikasi. Setelah login berhasil, sistem membaca role akun dan mengambil koordinat lokasi jemaah melalui GPS. Apabila izin lokasi atau koordinat belum tersedia, sistem menampilkan pesan bahwa lokasi belum dapat digunakan.

Jika lokasi jemaah valid, sistem memperbarui koordinat jemaah ke Firebase Realtime Database. Setelah itu, sistem membaca data petugas haji yang tersimpan pada database. Data petugas kemudian difilter berdasarkan role petugas haji dan ketersediaan koordinat lokasi.

Koordinat jemaah dan koordinat petugas digunakan sebagai input perhitungan Haversine Formula. Sistem menghitung jarak dari posisi jemaah ke setiap petugas, kemudian mengurutkan hasil dari jarak terkecil sampai terbesar. Hasil pengurutan tersebut ditampilkan dalam bentuk daftar petugas terdekat dan marker pada peta. Setelah jemaah memilih salah satu petugas, aplikasi dapat menampilkan rute melalui Mapbox Directions API atau membuka fitur bantuan sebagai media komunikasi pendukung.

## 4. BAB III - Flowchart Algoritma Haversine

**Letakkan setelah pembahasan flowchart sistem pada bagian `Analisis Alur Sistem (Flow Analysis)`.**

**Tambahkan gambar:**

`docs/kolokium/assets/flowchart-algoritma-haversine.png`

Versi SVG yang bisa diedit:

`docs/kolokium/assets/flowchart-algoritma-haversine.svg`

**Teks siap tempel sebelum gambar:**

Untuk memperjelas proses perhitungan jarak, alur perhitungan Haversine Formula dipisahkan ke dalam flowchart algoritma. Flowchart ini menjelaskan tahapan perhitungan mulai dari input koordinat jemaah dan petugas, konversi derajat ke radian, perhitungan selisih koordinat, perhitungan nilai `a`, perhitungan nilai `c`, hingga menghasilkan jarak dalam kilometer.

**Teks siap tempel setelah gambar:**

Pada flowchart algoritma Haversine, input yang digunakan adalah latitude dan longitude jemaah serta latitude dan longitude petugas. Seluruh koordinat dikonversi ke radian karena fungsi trigonometri pada rumus Haversine menggunakan satuan radian. Setelah itu, sistem menghitung selisih latitude dan longitude, menghitung nilai `a`, lalu menghitung nilai `c`. Nilai jarak diperoleh dari hasil perkalian antara radius bumi dan nilai `c`.

## 5. BAB III - Rancangan Database / ERD

**Cari di laporan:** `Firebase Realtime Database digunakan untuk menyimpan data pengguna dan lokasi.`

**Letakkan sebelum kalimat tersebut, atau buat subbagian baru setelah pembahasan arsitektur sistem dan sebelum `Perancangan Antarmuka Pengguna`.**

**Judul subbagian yang disarankan:**

`Perancangan Database`

**Tambahkan gambar ERD:**

`docs/kolokium/assets/rancangan-database-erd.png`

Versi SVG yang bisa diedit:

`docs/kolokium/assets/rancangan-database-erd.svg`

**Teks siap tempel sebelum gambar:**

Perancangan database digunakan untuk menggambarkan hubungan data yang dibutuhkan oleh aplikasi. Walaupun implementasi sistem menggunakan Firebase Realtime Database yang berbentuk struktur JSON, rancangan database tetap digambarkan dalam bentuk ERD untuk memperjelas entitas, atribut utama, dan relasi data yang digunakan pada sistem.

Entitas utama pada rancangan database terdiri dari `users`, `helpConversations`, `helpMessages`, `helpConversationSessions`, dan `helpNotificationRequests`. Entitas `users` menyimpan data akun jemaah dan petugas, termasuk role dan koordinat lokasi terakhir. Entitas `helpConversations` menyimpan data percakapan bantuan antara jemaah dan petugas. Entitas `helpMessages` menyimpan detail pesan yang dikirim dalam percakapan. Entitas `helpConversationSessions` digunakan untuk menandai sesi percakapan bantuan yang masih aktif. Entitas `helpNotificationRequests` digunakan untuk menyimpan permintaan notifikasi bantuan.

**Teks siap tempel setelah gambar:**

Relasi pada rancangan database menunjukkan bahwa satu data pada entitas `users` dapat berperan sebagai jemaah maupun petugas dalam banyak percakapan bantuan. Satu percakapan pada `helpConversations` dapat memiliki banyak pesan pada `helpMessages`. Selain itu, satu percakapan dapat memiliki satu sesi aktif pada `helpConversationSessions` dan dapat menghasilkan beberapa permintaan notifikasi pada `helpNotificationRequests`. Dengan rancangan ini, data akun, lokasi, percakapan bantuan, sesi aktif, dan notifikasi dapat saling terhubung melalui penggunaan ID seperti `userId`, `conversationId`, `pilgrimId`, dan `officerId`.

## 6. BAB III - Rancangan Fitur Bantuan, Pesan, dan Notifikasi

**Cari di laporan:** `Perancangan Fitur Pendukung Aplikasi`

**Letakkan setelah paragraf pembuka bagian fitur pendukung atau sebelum gambar rancangan halaman chat.**

**Teks siap tempel:**

Fitur bantuan dirancang sebagai fitur pendukung setelah jemaah memilih petugas dari hasil pencarian. Melalui fitur ini, jemaah dapat mengirim pesan bantuan kepada petugas apabila mengalami kendala selama pelaksanaan ibadah haji, seperti tersesat, terpisah dari rombongan, membutuhkan arahan, membutuhkan pertolongan medis, atau mengalami kendala logistik.

Pada sisi jemaah, sistem menyediakan pesan cepat agar jemaah dapat menyampaikan kondisi secara lebih mudah. Pesan cepat tersebut digunakan untuk mempercepat komunikasi awal tanpa harus mengetik pesan secara manual. Jemaah juga tetap dapat mengirim pesan tambahan melalui kolom pesan bantuan.

Pada sisi petugas, sistem menampilkan informasi bantuan yang berisi nama jemaah, kloter atau asal jika tersedia, pesan bantuan, riwayat percakapan, dan lokasi terakhir jemaah jika data lokasi tersedia. Informasi tersebut membantu petugas memahami konteks permintaan bantuan sebelum memberikan respons.

Notifikasi digunakan untuk memberi tanda adanya permintaan bantuan atau pesan baru. Notifikasi ini bersifat pendukung komunikasi dan tidak menggantikan prosedur resmi penanganan keadaan darurat. Dengan demikian, fitur bantuan tetap ditempatkan sebagai pelengkap dari fitur utama pencarian petugas terdekat.

## 7. BAB III - Penyesuaian Bahasa Aplikasi

**Cari di laporan:** `Perancangan Antarmuka Pengguna`

**Letakkan setelah paragraf pembuka perancangan antarmuka atau setelah penjelasan fitur pendukung.**

**Teks siap tempel:**

Antarmuka aplikasi disesuaikan menggunakan Bahasa Indonesia agar lebih mudah dipahami oleh jemaah. Penyesuaian bahasa dilakukan pada label tombol, menu, pesan bantuan, pesan kesalahan, notifikasi, dan informasi yang tampil pada layar aplikasi. Hal ini dilakukan karena konteks penggunaan aplikasi berkaitan dengan jemaah haji, sehingga bahasa yang digunakan perlu sederhana, langsung, dan sesuai dengan kebutuhan pengguna.

## 8. BAB IV - Contoh Perhitungan Manual Haversine

**Cari di laporan:** `Pengujian Perhitungan Jarak dengan Haversine Formula`

**Letakkan pada BAB IV, tepat di bagian pengujian Haversine, sebelum tabel hasil pengujian lengkap. Di Word, tabel hasil lengkap itu saat ini masih bernomor Tabel 4.1, tetapi setelah penambahan tabel manual sebaiknya digeser menjadi Tabel 4.4.**

**HAPUS INI dari laporan:**

```text
Untuk memperjelas proses perhitungan Haversine Formula, digunakan contoh perhitungan manual dengan satu titik jemaah dan dua titik petugas. Titik jemaah berada pada koordinat latitude 21,4225 dan longitude 39,8262. Petugas A berada pada latitude 21,4230 dan longitude 39,8258, sedangkan Petugas B berada pada latitude 21,4217 dan longitude 39,8285.
```

**GANTI DENGAN INI:**

Tempelkan seluruh teks pada bagian **Teks siap tempel** di bawah ini, mulai dari kalimat:

```text
Untuk memperjelas proses perhitungan Haversine Formula, digunakan contoh perhitungan manual dengan satu titik jemaah dan dua titik petugas.
```

Sampai kalimat:

```text
Contoh ini menunjukkan bahwa Haversine Formula digunakan sebagai dasar pengurutan awal kandidat petugas berdasarkan jarak koordinat.
```

**JANGAN HAPUS INI dari laporan, tapi ubah nomor tabelnya:**

Paragraf setelahnya tetap dipakai:

```text
Pengujian pada bagian ini dilakukan untuk melihat hasil perhitungan jarak antara titik jemaah dan titik petugas menggunakan algoritma Haversine Formula. Titik jemaah ditempatkan pada koordinat Jabal Al Kaabah, sedangkan titik petugas diambil dari data lokasi yang digunakan pada sistem. Hasil perhitungan jarak ditampilkan pada Tabel 4.4.
```

**Urutan akhirnya di Word:**

```text
1. Pengujian Perhitungan Jarak dengan Haversine Formula

[GANTI DENGAN INI: teks perhitungan manual Haversine]

[JANGAN HAPUS: paragraf pengantar tabel hasil lengkap, tetapi ubah rujukan menjadi Tabel 4.4]

Tabel 4.4 Perhitungan Jarak Jemaah ke Petugas Menggunakan Algoritma Haversine
```

**Catatan penting:** contoh manual di bawah ini memakai titik jemaah dan dua titik petugas yang sesuai dengan tabel hasil lengkap, yaitu Souq Al-Khalil dan Zamzam Well. Jadi jangan memakai lagi contoh koordinat lama `21,4225`, `21,4230`, dan `21,4217`, karena hasilnya tidak nyambung dengan data pengujian.

**Penomoran tabel yang disarankan pada bagian ini:**

| Nomor | Judul tabel |
|---|---|
| Tabel 4.1 | Data Koordinat Contoh Perhitungan Manual Haversine |
| Tabel 4.2 | Keterangan Simbol pada Perhitungan Manual Haversine |
| Tabel 4.3 | Ringkasan Hasil Perhitungan Manual Haversine |
| Tabel 4.4 | Perhitungan Jarak Jemaah ke Petugas Menggunakan Algoritma Haversine |
| Tabel 4.5 | Perbandingan Jarak Hasil Haversine dan Mapbox Directions API |

**Cek akhir setelah ditempel ke Word:**

1. Pada `Tabel 4.1 Data Koordinat Contoh Perhitungan Manual Haversine`, pastikan Petugas B adalah Zamzam Well dengan koordinat:

```text
Petugas B - Zamzam Well | 21,426062 | 39,825126 | Kandidat petugas kedua
```

Jangan memakai koordinat `21.423126` dan `39.825266` untuk Petugas B, karena itu adalah data Abraj Al Bait pada tabel pengujian lengkap.

2. Kalimat sebelum Tabel 4.1 sebaiknya:

```text
Data koordinat yang digunakan pada contoh perhitungan ditunjukkan pada Tabel 4.1.
```

3. Kalimat sebelum Tabel 4.2 sebaiknya:

```text
Keterangan simbol pada rumus Haversine ditunjukkan pada Tabel 4.2.
```

4. Paragraf sebelum tabel hasil lengkap harus merujuk ke Tabel 4.4, bukan Tabel 4.1:

```text
Hasil perhitungan jarak ditampilkan pada Tabel 4.4.
```

5. Tabel perbandingan Haversine dan Mapbox harus menjadi Tabel 4.5. Jika masih tertulis Tabel 4.2, ubah menjadi:

```text
Tabel 4.5 Perbandingan Jarak Hasil Haversine dan Mapbox Directions API
```

Paragraf setelah tabel tersebut juga harus merujuk ke Tabel 4.5.

**Teks siap tempel:**

Untuk memperjelas proses perhitungan Haversine Formula, digunakan contoh perhitungan manual dengan satu titik jemaah dan dua titik petugas. Contoh ini digunakan untuk menunjukkan bagaimana sistem menghitung jarak dari posisi jemaah ke masing-masing petugas, kemudian mengurutkan hasilnya berdasarkan jarak terkecil.

Data koordinat yang digunakan pada contoh perhitungan ditunjukkan pada Tabel 4.1.

**Tabel 4.1 Data Koordinat Contoh Perhitungan Manual Haversine**

| Titik | Latitude | Longitude | Keterangan |
|---|---:|---:|---|
| Jemaah | 21,424988 | 39,818937 | Titik awal pencarian |
| Petugas A - Souq Al-Khalil | 21,425382 | 39,824153 | Kandidat petugas pertama |
| Petugas B - Zamzam Well | 21,426062 | 39,825126 | Kandidat petugas kedua |

Rumus Haversine yang digunakan adalah:

```text
a = sin²(dlat/2) + cos(lat1) × cos(lat2) × sin²(dlon/2)
c = 2 × atan2(√a, √(1-a))
d = R × c
```

Bentuk `2 × atan2(√a, √(1-a))` digunakan sesuai implementasi pada kode aplikasi dan ekuivalen dengan `2 × arcsin(√a)` ketika nilai `a` berada pada rentang 0 sampai 1.

Keterangan simbol pada rumus Haversine ditunjukkan pada Tabel 4.2.

**Tabel 4.2 Keterangan Simbol pada Perhitungan Manual Haversine**

| Simbol | Keterangan |
|---|---|
| `lat1` | latitude jemaah |
| `lon1` | longitude jemaah |
| `lat2` | latitude petugas |
| `lon2` | longitude petugas |
| `dlat` | selisih latitude petugas dan jemaah |
| `dlon` | selisih longitude petugas dan jemaah |
| `a` | nilai antara pada rumus Haversine |
| `c` | sudut pusat antara dua titik |
| `R` | radius bumi, yaitu `6371,0088 km` |
| `d` | jarak hasil Haversine dalam kilometer |

Langkah pertama adalah mengubah koordinat dari derajat ke radian karena fungsi trigonometri pada Haversine menggunakan satuan radian. Konversi dilakukan dengan rumus:

```text
radian = derajat × π / 180
```

Hasil konversi koordinat jemaah adalah `lat1 = 0,3739365828` radian dan `lon1 = 0,6949715553` radian.

Perhitungan untuk Petugas A dilakukan dengan mengubah koordinat petugas ke radian terlebih dahulu. Dari koordinat Petugas A diperoleh `lat2 = 0,3739434594` radian dan `lon2 = 0,6950625917` radian. Selisih koordinatnya adalah:

```text
dlat = lat2 - lat1 = 0,0000068766 radian
dlon = lon2 - lon1 = 0,0000910364 radian
```

Setelah nilai selisih koordinat dimasukkan ke rumus Haversine, diperoleh nilai `a = 0,000000001807`. Nilai tersebut masih berada pada rentang 0 sampai 1, sehingga dapat digunakan untuk menghitung sudut pusat. Nilai sudut pusat yang diperoleh adalah `c = 0,000085023877` radian. Jarak Petugas A dihitung sebagai berikut:

```text
d = R × c
d = 6371,0088 × 0,000085023877
d = 0,541688 km
```

Dengan demikian, jarak antara jemaah dan Petugas A adalah `0,541688 km` atau sekitar `541,69 meter`. Nilai tersebut dibulatkan menjadi `0,542 km` pada tabel pengujian.

Perhitungan untuk Petugas B dilakukan dengan cara yang sama. Dari koordinat Petugas B diperoleh `lat2 = 0,3739553276` radian dan `lon2 = 0,6950795737` radian. Selisih koordinatnya adalah:

```text
dlat = lat2 - lat1 = 0,0000187448 radian
dlon = lon2 - lon1 = 0,0001080184 radian
```

Setelah nilai selisih koordinat dimasukkan ke rumus Haversine, diperoleh nilai `a = 0,000000002616`. Nilai sudut pusat yang diperoleh adalah `c = 0,000102285867` radian. Jarak Petugas B dihitung sebagai berikut:

```text
d = R × c
d = 6371,0088 × 0,000102285867
d = 0,651664 km
```

Dengan demikian, jarak antara jemaah dan Petugas B adalah `0,651664 km` atau sekitar `651,66 meter`. Nilai tersebut dibulatkan menjadi `0,652 km` pada tabel pengujian.

Ringkasan hasil perhitungan manual ditunjukkan pada Tabel 4.3.

**Tabel 4.3 Ringkasan Hasil Perhitungan Manual Haversine**

| Petugas | Nilai `a` | Nilai `c` | Jarak Haversine | Jarak dalam Meter | Urutan |
|---|---:|---:|---:|---:|---:|
| Petugas A - Souq Al-Khalil | 0,000000001807 | 0,000085023877 | 0,541688 km | 541,69 meter | 1 |
| Petugas B - Zamzam Well | 0,000000002616 | 0,000102285867 | 0,651664 km | 651,66 meter | 2 |

Berdasarkan hasil tersebut, Petugas A - Souq Al-Khalil memiliki jarak yang lebih dekat dibandingkan Petugas B - Zamzam Well. Oleh karena itu, sistem menempatkan Souq Al-Khalil pada urutan pertama dan Zamzam Well pada urutan kedua. Contoh ini menunjukkan bahwa Haversine Formula digunakan sebagai dasar pengurutan awal kandidat petugas berdasarkan jarak koordinat.

## 9. BAB IV - Satuan Jarak dan Perbedaan Haversine dengan Mapbox

**Cari di laporan:** `Jarak (Haversine) (km)`

**Letakkan setelah tabel pengujian Haversine atau setelah paragraf yang membahas hasil Tabel 4.4.**

**Teks siap tempel:**

Jarak hasil perhitungan Haversine pada penelitian ini ditampilkan dalam satuan kilometer. Satuan kilometer digunakan agar hasil pengujian konsisten dengan tabel perhitungan dan tampilan sistem. Untuk jarak yang sangat dekat, nilai kilometer dapat dipahami juga dalam satuan meter dengan cara mengalikan nilai kilometer dengan 1000.

Jarak Haversine merupakan estimasi jarak awal berdasarkan koordinat latitude dan longitude, bukan jarak tempuh berdasarkan jalur jalan. Oleh karena itu, hasil Haversine dapat berbeda dengan jarak rute dari Mapbox Directions API. Pada sistem ini, Haversine digunakan untuk mengurutkan kandidat petugas terdekat, sedangkan Mapbox Directions API digunakan setelah jemaah memilih petugas untuk menampilkan rute, durasi, dan instruksi navigasi.

## 10. BAB V - Banyak Jemaah Memilih Petugas yang Sama

**Cari di laporan:** `Saran`

**Ganti seluruh isi bagian `5.2 Saran` dengan teks gabungan di bawah ini.**

**Hapus isi lama pada bagian Saran, lalu tempel teks berikut:**

```text
Pengembangan berikutnya dapat diarahkan pada perluasan area pengujian, peningkatan akurasi data lokasi di lapangan, dan pengujian performa teknis yang lebih rinci pada perangkat Android dan iOS. Selain itu, pengujian pada kondisi yang lebih mendekati situasi operasional haji juga perlu dilakukan agar sistem dapat dievaluasi secara lebih menyeluruh.

Sistem juga dapat dikembangkan dengan mekanisme prioritas bantuan apabila terdapat lebih dari satu jemaah yang memilih petugas yang sama. Pada penelitian ini, sistem masih menampilkan petugas terdekat berdasarkan hasil perhitungan Haversine dan belum mengatur pembagian permintaan bantuan secara otomatis. Pengembangan berikutnya dapat mempertimbangkan tingkat urgensi kendala, jarak jemaah ke petugas, status kesediaan petugas, jumlah permintaan bantuan yang sedang ditangani, area tanggung jawab, dan informasi kloter. Dengan mekanisme tersebut, proses pemberian bantuan dapat diarahkan tidak hanya berdasarkan kedekatan jarak, tetapi juga berdasarkan kondisi jemaah dan beban petugas di lapangan.

Fitur bantuan, percakapan bantuan, dan notifikasi pada penelitian ini masih bersifat pendukung komunikasi antara jemaah dan petugas. Fitur tersebut belum mencakup sistem prioritas darurat, eskalasi otomatis, pembagian tugas petugas, maupun integrasi dengan prosedur resmi layanan haji. Oleh karena itu, penelitian selanjutnya dapat mengembangkan fitur bantuan yang lebih lengkap dengan mempertimbangkan tingkat urgensi, kategori kendala, dan koordinasi antarpetugas.

Dengan pengembangan tersebut, sistem diharapkan dapat diuji lebih luas dan dinilai lebih akurat pada kondisi yang mendekati situasi operasional haji.
```

## 11. BAB V - Batasan Fitur Bantuan

Point ini sudah digabungkan ke teks lengkap bagian `5.2 Saran` pada point 10. Tidak perlu ditempel terpisah agar isi Saran tidak berulang.

## File Gambar yang Dipakai

| Kebutuhan | File untuk laporan | File SVG editable |
|---|---|---|
| Flowchart sistem | `docs/kolokium/assets/flowchart-pencarian-revisi.png` | `docs/kolokium/assets/flowchart-pencarian-revisi.svg` |
| Flowchart algoritma Haversine | `docs/kolokium/assets/flowchart-algoritma-haversine.png` | `docs/kolokium/assets/flowchart-algoritma-haversine.svg` |
| Ilustrasi Haversine | `docs/kolokium/assets/haversine-ilustrasi-laporan.png` | `docs/kolokium/assets/haversine-ilustrasi-laporan.svg` |
| ERD rancangan database | `docs/kolokium/assets/rancangan-database-erd.png` | `docs/kolokium/assets/rancangan-database-erd.svg` |

## Yang Tidak Perlu Ditempel

Jangan tempel daftar catatan pembimbing ke isi laporan. Daftar tersebut cukup menjadi acuan revisi.

Jangan tempel tabel Firebase panjang jika sudah menggunakan ERD pada BAB III, kecuali pembimbing meminta detail field. ERD lebih cocok untuk rancangan database, sedangkan tabel field dapat disimpan sebagai lampiran atau bahan penjelasan.

Jangan menjelaskan fitur bantuan seolah-olah menjadi sistem resmi penanganan darurat. Gunakan posisi aman: fitur bantuan adalah fitur pendukung komunikasi.

Jangan menulis bahwa Haversine menghasilkan jarak rute jalan. Haversine menghasilkan jarak awal berdasarkan koordinat, sedangkan rute jalan berasal dari Mapbox Directions API.

## Checklist Akhir

- [x] BAB I sudah menjelaskan batasan fitur bantuan.
- [x] BAB II sudah menambahkan penjelasan simbol Haversine dan visualisasi.
- [x] BAB III sudah memakai flowchart sistem yang baru.
- [x] BAB III sudah menambahkan flowchart algoritma Haversine.
- [x] BAB III sudah menambahkan ERD rancangan database.
- [x] BAB III sudah menjelaskan rancangan bantuan, pesan, dan notifikasi secara detail.
- [x] BAB IV sudah menambahkan contoh perhitungan manual Haversine dari awal sampai akhir.
- [x] BAB IV sudah menjelaskan satuan jarak dan perbedaan Haversine dengan Mapbox.
- [x] BAB V sudah menambahkan saran prioritas bantuan jika banyak jemaah memilih petugas yang sama.
- [x] Konsistensi kata `pengguna` menjadi `jemaah` pada bagian yang membahas alur pencarian aplikasi sudah dirapikan.
- [x] Daftar Isi, Daftar Tabel, dan Daftar Gambar sudah di-update ulang di Word.

## Status Validasi Draft

Validasi dilakukan terhadap draft Word `Tugas Akhir - Muhamad Taopik (1197050081).docx`.

### Sudah Aman

- BAB I sudah memuat batasan fitur pesan bantuan dan notifikasi sebagai fitur pendukung komunikasi, serta sudah menegaskan bahwa fitur tersebut bukan pengganti prosedur resmi penanganan keadaan darurat.
- BAB I sudah memuat batasan pengujian perangkat, yaitu pengujian pada Android emulator, iOS simulator, dan iPhone fisik hanya untuk memastikan fungsi utama berjalan, bukan untuk pengukuran performa teknis rinci.
- BAB II sudah memuat penjelasan simbol Haversine, hubungan koordinat jemaah dan petugas, serta bentuk implementasi `atan2` yang ekuivalen dengan `arcsin`.
- BAB III sudah memuat flowchart sistem pencarian petugas haji.
- BAB III sudah memuat flowchart algoritma Haversine Formula.
- BAB III sudah memuat rancangan database dalam bentuk ERD.
- BAB III sudah memuat penyesuaian Bahasa Indonesia pada antarmuka aplikasi.
- BAB III sudah menjelaskan rancangan fitur bantuan, pesan cepat, informasi jemaah, kloter atau asal, lokasi terakhir jemaah, serta notifikasi bantuan sebagai fitur pendukung komunikasi.
- BAB IV sudah memuat contoh perhitungan manual Haversine dengan 1 titik jemaah dan 2 titik petugas.
- BAB IV sudah memuat perbandingan Haversine dengan Mapbox Directions API dan sudah menjelaskan bahwa Haversine digunakan untuk pencarian, sedangkan Mapbox Directions API digunakan untuk navigasi.
- BAB IV sudah menjelaskan satuan jarak dalam kilometer dan meter.
- BAB V sudah memuat saran pengembangan terkait banyak jemaah memilih petugas yang sama.
- Konsistensi istilah `pengguna`, `jemaah`, dan `petugas` sudah aman. Kata `jemaah` digunakan pada alur pencarian petugas, sedangkan kata `pengguna` tetap dipakai pada konteks umum, teori, login, antarmuka pengguna, data akun, keamanan, dan bagian yang mencakup lebih dari satu role.

### Masih Perlu Update

1. Pada BAB I, kalimat `Fitur pesan bantuan, dan notifikasi` sebaiknya diganti menjadi `Fitur pesan bantuan dan notifikasi`.
2. Pada BAB V, istilah `chat` sebaiknya diganti menjadi `percakapan bantuan` agar konsisten dengan penggunaan Bahasa Indonesia.
3. Cek visual BAB II di Word. Jika simbol rumus Haversine seperti `φ1`, `λ1`, `φ2`, dan `λ2` tampil normal, tidak perlu diubah. Jika terlihat kosong atau tidak terbaca, gunakan penjelasan `lat1`, `lon1`, `lat2`, dan `lon2`.
4. Daftar Isi, Daftar Tabel, dan Daftar Gambar sudah di-update ulang. `Gambar 2.1 Ilustrasi Haversine Formula pada Koordinat Jemaah dan Petugas` sudah muncul pada Daftar Gambar.

### Teks Tambahan yang Paling Perlu Ditempel

Bagian BAB III `Perancangan Fitur Pendukung Aplikasi` sudah memuat penjelasan detail. Teks di bawah ini dapat dipakai sebagai pembanding apabila ingin memastikan isi Word tetap sama.

Letakkan setelah paragraf:

```text
Aplikasi juga memuat fitur pendukung berupa pesan bantuan, akun, ubah password, dan notifikasi bantuan.
```

Teks siap tempel:

```text
Fitur bantuan dirancang sebagai fitur pendukung setelah jemaah memilih petugas dari hasil pencarian. Melalui fitur ini, jemaah dapat mengirim pesan bantuan kepada petugas apabila mengalami kendala selama pelaksanaan ibadah haji, seperti tersesat, terpisah dari rombongan, membutuhkan arahan, membutuhkan pertolongan medis, atau mengalami kendala logistik.

Pada sisi jemaah, sistem menyediakan pesan cepat agar jemaah dapat menyampaikan kondisi secara lebih mudah. Pesan cepat tersebut digunakan untuk mempercepat komunikasi awal tanpa harus mengetik pesan secara manual. Jemaah juga tetap dapat mengirim pesan tambahan melalui kolom pesan bantuan.

Pada sisi petugas, sistem menampilkan informasi bantuan yang berisi nama jemaah, kloter atau asal jika tersedia, pesan bantuan, riwayat percakapan, dan lokasi terakhir jemaah jika data lokasi tersedia. Informasi tersebut membantu petugas memahami konteks permintaan bantuan sebelum memberikan respons.

Notifikasi digunakan untuk memberi tanda adanya permintaan bantuan atau pesan baru. Notifikasi ini bersifat pendukung komunikasi dan tidak menggantikan prosedur resmi penanganan keadaan darurat. Dengan demikian, fitur bantuan tetap ditempatkan sebagai pelengkap dari fitur utama pencarian petugas terdekat.
```

### Prioritas Terakhir Sebelum Submit

1. Tambahkan teks detail fitur bantuan pada BAB III.
2. Rapikan kata `pengguna` menjadi `jemaah` pada bagian alur pencarian aplikasi.
3. Ganti `chat` menjadi `percakapan bantuan` pada BAB V.
4. Update Daftar Isi, Daftar Tabel, dan Daftar Gambar.
