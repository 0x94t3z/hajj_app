# Revisi Final Siap Tempel ke Laporan

Dokumen ini berisi teks revisi yang bisa langsung dimasukkan ke laporan tugas akhir. Setiap bagian diberi tanda lokasi penempatan agar revisi bisa dikerjakan berurutan.

## Urutan Pengerjaan

1. BAB I - perjelas batasan fitur bantuan.
2. BAB II - lengkapi penjelasan simbol dan visualisasi Haversine.
3. BAB III - ganti flowchart dan tambahkan flowchart algoritma Haversine.
4. BAB III - tambahkan rancangan database dalam bentuk ERD.
5. BAB III - perjelas rancangan fitur bantuan, pesan, dan notifikasi.
6. BAB IV - tambahkan contoh perhitungan manual Haversine.
7. BAB IV - perjelas satuan jarak dan perbedaan Haversine dengan Mapbox Directions API.
8. BAB V - tambahkan batasan dan saran pengembangan terkait banyak jemaah memilih petugas yang sama.

## 1. BAB I - Batasan Fitur Bantuan

**Cari di laporan:** `Batasan Masalah Penelitian`

**Letakkan setelah poin batasan tentang Mapbox Directions API atau setelah kalimat:** `Penelitian ini berfokus pada implementasi Haversine Formula untuk menentukan petugas haji terdekat, integrasi peta digital, dan penampilan rute navigasi pada aplikasi mobile.`

**Teks siap tempel:**

Fitur bantuan, chat, dan notifikasi pada aplikasi digunakan sebagai fitur pendukung komunikasi antara jemaah dan petugas. Fitur tersebut dirancang untuk membantu jemaah menyampaikan kendala seperti tersesat, terpisah dari rombongan, membutuhkan arahan, atau membutuhkan bantuan awal. Namun, fitur ini tidak dimaksudkan sebagai pengganti prosedur resmi penanganan keadaan darurat dalam pelaksanaan ibadah haji.

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

Pada sisi jemaah, sistem menyediakan pesan cepat agar jemaah dapat menyampaikan kondisi secara lebih mudah. Pesan cepat tersebut digunakan untuk mempercepat komunikasi awal tanpa harus mengetik pesan secara manual. Jemaah juga tetap dapat mengirim pesan tambahan melalui kolom chat.

Pada sisi petugas, sistem menampilkan informasi bantuan yang berisi nama jemaah, pesan bantuan, riwayat percakapan, dan lokasi terakhir jemaah jika data lokasi tersedia. Informasi tersebut membantu petugas memahami konteks permintaan bantuan sebelum memberikan respons.

Notifikasi digunakan untuk memberi tanda adanya permintaan bantuan atau pesan baru. Notifikasi ini bersifat pendukung komunikasi dan tidak menggantikan prosedur resmi penanganan keadaan darurat. Dengan demikian, fitur bantuan tetap ditempatkan sebagai pelengkap dari fitur utama pencarian petugas terdekat.

## 7. BAB III - Penyesuaian Bahasa Aplikasi

**Cari di laporan:** `Perancangan Antarmuka Pengguna`

**Letakkan setelah paragraf pembuka perancangan antarmuka atau setelah penjelasan fitur pendukung.**

**Teks siap tempel:**

Antarmuka aplikasi disesuaikan menggunakan Bahasa Indonesia agar lebih mudah dipahami oleh jemaah. Penyesuaian bahasa dilakukan pada label tombol, menu, pesan bantuan, pesan kesalahan, notifikasi, dan informasi yang tampil pada layar aplikasi. Hal ini dilakukan karena konteks penggunaan aplikasi berkaitan dengan jemaah haji, sehingga bahasa yang digunakan perlu sederhana, langsung, dan sesuai dengan kebutuhan pengguna.

## 8. BAB IV - Contoh Perhitungan Manual Haversine

**Cari di laporan:** `Pengujian Perhitungan Jarak dengan Haversine Formula`

**Letakkan sebelum Tabel 4.1 atau setelah paragraf pembuka pengujian Haversine.**

**Catatan penggantian:** pada file Word saat ini terdapat paragraf contoh koordinat lama yang diawali kalimat `Untuk memperjelas proses perhitungan Haversine Formula, digunakan contoh perhitungan manual...` dan masih memakai koordinat `21,4225`, `21,4230`, serta `21,4217`. Ganti paragraf tersebut dengan teks siap tempel di bawah ini agar contoh manual sesuai dengan hasil pada Tabel 4.1.

**Teks siap tempel:**

Untuk memperjelas proses perhitungan Haversine Formula, digunakan contoh perhitungan manual dengan satu titik jemaah dan dua titik petugas. Contoh ini digunakan untuk menunjukkan bagaimana sistem menghitung jarak dari posisi jemaah ke masing-masing petugas, kemudian mengurutkan hasilnya berdasarkan jarak terkecil.

Data koordinat yang digunakan pada contoh perhitungan ditunjukkan pada Tabel 4.x.

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

Keterangan:

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

Ringkasan hasil perhitungan manual ditunjukkan pada Tabel 4.x.

| Petugas | Nilai `a` | Nilai `c` | Jarak Haversine | Jarak dalam Meter | Urutan |
|---|---:|---:|---:|---:|---:|
| Petugas A - Souq Al-Khalil | 0,000000001807 | 0,000085023877 | 0,541688 km | 541,69 meter | 1 |
| Petugas B - Zamzam Well | 0,000000002616 | 0,000102285867 | 0,651664 km | 651,66 meter | 2 |

Berdasarkan hasil tersebut, Petugas A - Souq Al-Khalil memiliki jarak yang lebih dekat dibandingkan Petugas B - Zamzam Well. Oleh karena itu, sistem menempatkan Souq Al-Khalil pada urutan pertama dan Zamzam Well pada urutan kedua. Contoh ini menunjukkan bahwa Haversine Formula digunakan sebagai dasar pengurutan awal kandidat petugas berdasarkan jarak koordinat.

## 9. BAB IV - Satuan Jarak dan Perbedaan Haversine dengan Mapbox

**Cari di laporan:** `Jarak (Haversine) (km)`

**Letakkan setelah tabel pengujian Haversine atau setelah paragraf yang membahas hasil Tabel 4.1.**

**Teks siap tempel:**

Jarak hasil perhitungan Haversine pada penelitian ini ditampilkan dalam satuan kilometer. Satuan kilometer digunakan agar hasil pengujian konsisten dengan tabel perhitungan dan tampilan sistem. Untuk jarak yang sangat dekat, nilai kilometer dapat dipahami juga dalam satuan meter dengan cara mengalikan nilai kilometer dengan 1000.

Jarak Haversine merupakan estimasi jarak awal berdasarkan koordinat latitude dan longitude, bukan jarak tempuh berdasarkan jalur jalan. Oleh karena itu, hasil Haversine dapat berbeda dengan jarak rute dari Mapbox Directions API. Pada sistem ini, Haversine digunakan untuk mengurutkan kandidat petugas terdekat, sedangkan Mapbox Directions API digunakan setelah jemaah memilih petugas untuk menampilkan rute, durasi, dan instruksi navigasi.

## 10. BAB V - Banyak Jemaah Memilih Petugas yang Sama

**Cari di laporan:** `Saran`

**Letakkan pada bagian saran pengembangan.**

**Teks siap tempel:**

Pada pengembangan berikutnya, sistem dapat menambahkan mekanisme prioritas bantuan apabila terdapat beberapa jemaah yang memilih petugas yang sama. Prioritas dapat ditentukan berdasarkan jenis kendala, jarak jemaah ke petugas, beban permintaan yang sedang ditangani petugas, area tanggung jawab, atau informasi kloter. Dengan mekanisme tersebut, sistem tidak hanya menampilkan petugas terdekat, tetapi juga dapat membantu mengatur pembagian bantuan secara lebih terarah.

## 11. BAB V - Batasan Fitur Bantuan

**Cari di laporan:** `Saran`

**Letakkan setelah saran tentang prioritas bantuan atau pada paragraf akhir saran.**

**Teks siap tempel:**

Fitur bantuan, chat, dan notifikasi pada penelitian ini masih bersifat pendukung komunikasi. Fitur tersebut belum mencakup sistem prioritas darurat, eskalasi otomatis, pembagian tugas petugas, maupun integrasi dengan prosedur resmi layanan haji. Oleh karena itu, penelitian selanjutnya dapat mengembangkan fitur bantuan yang lebih lengkap dengan mempertimbangkan tingkat urgensi, kategori kendala, dan koordinasi antarpetugas.

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
- [ ] BAB II sudah menambahkan penjelasan simbol Haversine dan visualisasi.
- [ ] BAB III sudah memakai flowchart sistem yang baru.
- [ ] BAB III sudah menambahkan flowchart algoritma Haversine.
- [ ] BAB III sudah menambahkan ERD rancangan database.
- [ ] BAB III sudah menjelaskan rancangan bantuan, pesan, dan notifikasi.
- [x] Teks revisi BAB IV untuk contoh perhitungan manual Haversine sudah siap tempel dari awal sampai akhir.
- [x] BAB IV sudah menjelaskan satuan jarak dan perbedaan Haversine dengan Mapbox.
- [ ] BAB V sudah menambahkan saran prioritas bantuan jika banyak jemaah memilih petugas yang sama.

## Status Validasi Draft

Validasi dilakukan terhadap draft Word `Tugas Akhir - Muhamad Taopik (1197050081).docx`.

Sudah aman:

- BAB I sudah memuat batasan fitur bantuan, chat, dan notifikasi sebagai fitur pendukung komunikasi, serta sudah menegaskan bahwa fitur tersebut bukan pengganti prosedur resmi penanganan keadaan darurat.
- BAB I sudah memuat batasan pengujian perangkat, yaitu pengujian pada Android emulator, iOS simulator, dan iPhone fisik hanya untuk memastikan fungsi utama berjalan, bukan untuk pengukuran performa teknis rinci.
- BAB IV sudah memuat perbandingan Haversine dengan Mapbox Directions API dan sudah menjelaskan bahwa Haversine digunakan untuk pencarian, sedangkan Mapbox Directions API digunakan untuk navigasi.
- Teks revisi BAB IV untuk contoh perhitungan manual Haversine sudah disiapkan dengan 1 titik jemaah dan 2 titik petugas, serta sudah disesuaikan dengan hasil pada Tabel 4.1.

Belum tervalidasi / masih perlu ditambahkan:

- BAB II belum ditemukan penjelasan tambahan tentang `lat1`, `lon1`, `lat2`, `lon2`, `dlat`, `dlon`, dan penjelasan bahwa nilai `a` dibatasi untuk stabilitas perhitungan.
- BAB III belum ditemukan flowchart algoritma Haversine sebagai gambar terpisah.
- BAB III belum ditemukan subbagian Perancangan Database/ERD.
- BAB III belum ditemukan penjelasan detail rancangan fitur bantuan, pesan cepat, informasi jemaah untuk petugas, dan notifikasi.
- BAB III/BAB IV belum ditemukan penjelasan penyesuaian Bahasa Indonesia pada antarmuka aplikasi.
- BAB IV pada file Word masih perlu ditempelkan contoh perhitungan manual Haversine dari bagian revisi ini.
- BAB V belum ditemukan saran tentang mekanisme prioritas apabila banyak jemaah memilih petugas yang sama.
