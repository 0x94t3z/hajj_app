# Draft Revisi Pasca Kolokium

Dokumen ini merangkum catatan pembimbing setelah kolokium dan menyiapkan bahan revisi yang dapat dimasukkan ke naskah tugas akhir, presentasi lanjutan, serta aplikasi Hajj App.

## Catatan Form Pembimbing

### Pembimbing I

Mengikuti catatan dan arahan revisi dari Pembimbing II, dengan fokus perbaikan sebagai berikut:

1. Memperbaiki diagram/flowchart agar simbol proses dan decision sesuai.
2. Menambahkan contoh perhitungan Haversine sederhana.
3. Menambahkan visualisasi Haversine pada penjelasan rumus.
4. Melengkapi rancangan sistem, antarmuka, dan basis data.
5. Menjelaskan batasan fitur bantuan dan notifikasi.
6. Menyesuaikan bahasa aplikasi agar lebih mudah dipahami jemaah.

### Pembimbing II

1. Perbaiki diagram/flowchart agar penggunaan simbol proses dan decision sesuai.
2. Tambahkan contoh perhitungan manual Haversine dengan 1 titik jemaah dan 2 titik petugas, kemudian tampilkan hasil pengurutannya.
3. Tambahkan ilustrasi Haversine Formula, seperti titik jemaah, titik petugas, lingkaran bumi, latitude, longitude, dan jarak.
4. Perjelas satuan jarak pada aplikasi, apakah menggunakan kilometer atau meter.
5. Lengkapi BAB III dengan rancangan sistem, activity/alur sistem, rancangan antarmuka, rancangan basis data, dan rancangan pesan/notifikasi.
6. Tambahkan rancangan basis data Firebase, seperti data pengguna, percakapan bantuan, sesi bantuan, dan notifikasi.
7. Jelaskan kemungkinan banyak jemaah memilih petugas yang sama, serta batasan atau pengembangan terkait prioritas/limit bantuan.
8. Tambahkan informasi detail jemaah yang perlu diketahui petugas, seperti nama, kloter/asal, pesan bantuan, dan lokasi.
9. Gunakan Bahasa Indonesia pada aplikasi atau sediakan versi Bahasa Indonesia agar sesuai dengan konteks jemaah.

## Prioritas Revisi

1. Memperbaiki diagram/flowchart agar simbol proses dan decision sesuai.
2. Menambahkan contoh perhitungan Haversine sederhana dengan 1 titik jemaah dan 2 titik petugas.
3. Menambahkan visualisasi Haversine pada penjelasan rumus.
4. Melengkapi rancangan sistem, antarmuka, basis data, pesan, dan notifikasi pada BAB III.
5. Menjelaskan batasan fitur bantuan jika banyak jemaah memilih petugas yang sama.
6. Menyesuaikan bahasa aplikasi agar lebih mudah dipahami jemaah Indonesia.

## Revisi BAB II - Ilustrasi Haversine Formula

Tambahkan penjelasan visual setelah bagian rumus Haversine Formula.

### Narasi Tambahan

Haversine Formula menghitung jarak antara dua titik koordinat geografis pada permukaan bumi. Dalam konteks penelitian ini, titik pertama merepresentasikan lokasi jemaah, sedangkan titik kedua merepresentasikan lokasi petugas haji. Nilai latitude dan longitude dari kedua titik tersebut dikonversi ke radian, kemudian selisih latitude dan longitude digunakan untuk menghitung jarak awal antarkoordinat.

Ilustrasi Haversine Formula dapat dilihat sebagai dua titik pada permukaan bumi yang dihubungkan oleh jarak lingkaran besar. Jarak yang dihasilkan bukan jarak tempuh jalan, melainkan estimasi jarak awal berdasarkan koordinat. Oleh karena itu, hasil Haversine digunakan untuk proses pengurutan petugas terdekat, sedangkan rute perjalanan setelah petugas dipilih ditangani oleh Mapbox Directions API.

### Keterangan Simbol yang Disarankan

| Simbol | Keterangan |
| --- | --- |
| `lat1` | Latitude titik jemaah dalam radian |
| `lon1` | Longitude titik jemaah dalam radian |
| `lat2` | Latitude titik petugas dalam radian |
| `lon2` | Longitude titik petugas dalam radian |
| `Delta lat` | Selisih latitude antara petugas dan jemaah |
| `Delta lon` | Selisih longitude antara petugas dan jemaah |
| `a` | Nilai antara pada perhitungan Haversine |
| `r` | Radius bumi, yaitu 6371.0088 km |
| `d` | Jarak hasil perhitungan Haversine dalam kilometer |

Gambar pendukung: [Ilustrasi Haversine](assets/haversine-ilustrasi.svg)

## Revisi BAB III - Metodologi SDLC

Tambahkan penegasan bahwa penelitian menggunakan System Development Life Cycle (SDLC).

### Narasi Tambahan

Metode pengembangan sistem yang digunakan pada penelitian ini adalah System Development Life Cycle (SDLC). SDLC digunakan agar proses pembangunan aplikasi dilakukan secara terstruktur, mulai dari identifikasi kebutuhan, analisis sistem, perancangan, implementasi, pengujian, hingga evaluasi hasil. Dengan menggunakan SDLC, setiap tahap pengembangan memiliki keluaran yang jelas dan dapat ditelusuri kembali pada kebutuhan penelitian.

Tahapan SDLC pada penelitian ini meliputi:

1. Perencanaan, yaitu mengidentifikasi kebutuhan sistem bantu pencarian petugas haji terdekat.
2. Analisis, yaitu menentukan kebutuhan data, aktor, fitur, dan batasan sistem.
3. Perancangan, yaitu menyusun alur sistem, rancangan antarmuka, rancangan basis data, dan rancangan proses bantuan.
4. Implementasi, yaitu membangun aplikasi menggunakan Flutter, Firebase, GPS, Haversine Formula, dan Mapbox.
5. Pengujian, yaitu menguji fungsi utama sistem, perhitungan jarak, pengurutan petugas, peta, dan rute.
6. Evaluasi, yaitu meninjau hasil pengujian serta mencatat batasan dan saran pengembangan.

## Revisi BAB III - Flowchart Sistem

Flowchart perlu menggunakan simbol yang konsisten.

### Aturan Perbaikan

- Gunakan oval hanya untuk `Start` dan `End`.
- Gunakan persegi panjang untuk proses, seperti login, baca lokasi, baca data petugas, dan hitung jarak.
- Gunakan belah ketupat hanya untuk kondisi/decision, misalnya `Lokasi valid?` atau `Data petugas tersedia?`.
- Gunakan jajar genjang hanya untuk input/output, misalnya koordinat jemaah, data petugas, dan daftar petugas terdekat.
- Jangan membuat alur seolah-olah dimulai lebih dari satu kali.
- Jika tidak ada percabangan keputusan, gunakan kotak proses biasa.

Gambar pendukung: [Flowchart Pencarian Revisi](assets/flowchart-pencarian-revisi.svg)

## Revisi BAB III - Rancangan Basis Data Firebase

Tambahkan rancangan data agar penggunaan Firebase tetap terlihat sebagai hasil perancangan, bukan hanya implementasi.

### Narasi Tambahan

Firebase Realtime Database digunakan sebagai basis data utama untuk menyimpan data akun, profil, lokasi, percakapan bantuan, sesi bantuan, dan permintaan notifikasi. Struktur data dirancang berbasis node karena Firebase Realtime Database menyimpan data dalam bentuk JSON tree. Setiap node memiliki fungsi tertentu sesuai kebutuhan aplikasi.

### Rancangan Node Firebase

| Node | Fungsi | Data Utama |
| --- | --- | --- |
| `users` | Menyimpan data akun, role, profil, dan lokasi terbaru jemaah/petugas | `uid`, `name`, `email`, `role`, `latitude`, `longitude`, `category`, `locationName` |
| `helpConversations` | Menyimpan pesan bantuan antara jemaah dan petugas | `conversationId`, `senderId`, `receiverId`, `message`, `timestamp`, `type` |
| `helpConversationSessions` | Menyimpan status sesi bantuan | `sessionId`, `pilgrimId`, `officerId`, `status`, `createdAt`, `endedAt` |
| `helpNotificationRequests` | Menyimpan permintaan notifikasi bantuan untuk petugas | `requestId`, `conversationId`, `targetOfficerId`, `pilgrimId`, `message`, `isRead`, `createdAt` |

### Narasi Keamanan dan Batasan

Data lokasi dan percakapan bantuan termasuk data sensitif karena berkaitan dengan posisi jemaah dan komunikasi bantuan. Oleh karena itu, akses data perlu dibatasi berdasarkan autentikasi dan role akun. Pada penelitian ini, struktur data digunakan untuk mendukung kebutuhan prototipe dan pengujian fungsi utama. Pengaturan keamanan Firebase Rules tetap diperlukan agar hanya partisipan yang berhak dapat membaca atau menulis data percakapan.

## Revisi BAB III - Rancangan Fitur Bantuan dan Notifikasi

Tambahkan batasan agar pertanyaan tentang banyak jemaah memilih petugas yang sama bisa dijawab aman.

### Narasi Tambahan

Fitur bantuan digunakan sebagai fitur pendukung ketika jemaah mengalami kendala seperti tersesat, terpisah dari rombongan, sakit, atau membutuhkan arahan. Pada alur saat ini, jemaah memilih salah satu petugas dari hasil pencarian, kemudian sistem membuka percakapan bantuan dan mengirim permintaan notifikasi kepada petugas yang dipilih.

Terdapat batasan pada fitur bantuan, yaitu sistem belum menerapkan mekanisme prioritas, kuota beban petugas, atau pengalihan otomatis ke petugas lain jika banyak jemaah memilih petugas yang sama. Oleh karena itu, fitur bantuan pada penelitian ini diposisikan sebagai fitur pendukung komunikasi, bukan sebagai sistem manajemen penanganan darurat resmi. Pengembangan lanjutan dapat menambahkan prioritas berdasarkan jenis kendala, jarak, beban petugas, area tanggung jawab, atau kloter.

## Revisi BAB IV - Contoh Perhitungan Manual Haversine

Tambahkan contoh sederhana agar pembimbing melihat hubungan antara rumus, data koordinat, dan ranking.

### Data Contoh

Titik jemaah menggunakan titik uji di sekitar Jabal Al Kaabah. Koordinat ini disesuaikan dengan hasil tabel pengujian agar jarak yang dihasilkan konsisten dengan Tabel 4.1.

| Titik | Latitude | Longitude |
| --- | ---: | ---: |
| Jemaah | 21.424988 | 39.818937 |
| Petugas A - Souq Al-Khalil | 21.425382 | 39.824153 |
| Petugas B - Zamzam Well | 21.426062 | 39.825126 |

### Langkah Perhitungan Ringkas

1. Konversi latitude dan longitude dari derajat ke radian.
2. Hitung `Delta lat` dan `Delta lon`.
3. Hitung nilai `a` menggunakan rumus Haversine.
4. Batasi nilai `a` pada rentang 0 sampai 1 untuk menjaga stabilitas perhitungan.
5. Hitung jarak `d = 2r x asin(sqrt(a))`.
6. Urutkan hasil dari jarak paling kecil.

### Hasil Perhitungan

| Petugas | Nilai `a` | Jarak Haversine | Urutan |
| --- | ---: | ---: | ---: |
| Souq Al-Khalil | 0.000000001807 | 0.542 km | 1 |
| Zamzam Well | 0.000000002616 | 0.652 km | 2 |

Berdasarkan contoh tersebut, Souq Al-Khalil berada pada urutan pertama karena memiliki jarak Haversine lebih kecil dibandingkan Zamzam Well. Contoh ini menunjukkan bahwa Haversine Formula digunakan untuk menghasilkan nilai jarak awal, kemudian sistem mengurutkan petugas berdasarkan jarak terkecil.

## Revisi Aplikasi - Bahasa Indonesia

Catatan pembimbing menyarankan penggunaan Bahasa Indonesia agar sesuai dengan konteks jemaah Indonesia.

### Rekomendasi Perubahan Label

| Label Saat Ini | Rekomendasi |
| --- | --- |
| `Find Officers` | `Cari Petugas` |
| `Find Pilgrims` | `Cari Jemaah` |
| `Nearest Hajj Officers` | `Petugas Haji Terdekat` |
| `Help Requests` | `Permintaan Bantuan` |
| `Archived` | `Diarsipkan` |
| `Active Requests` | `Permintaan Aktif` |
| `End Session` | `Akhiri Sesi` |
| `Urgent Help Request` | `Permintaan Bantuan Mendesak` |
| `View` | `Lihat` |
| `No` | `Tidak` |
| `Find Pilgrim` | `Cari Jemaah` |

## Revisi Lanjutan yang Aman Dijadikan Saran

Jika belum diimplementasikan pada aplikasi, poin berikut sebaiknya ditulis sebagai pengembangan lanjutan:

1. Prioritas bantuan berdasarkan kategori kendala, misalnya medis, tersesat, terpisah rombongan, atau kebutuhan arahan.
2. Limit atau kuota permintaan bantuan untuk setiap petugas.
3. Pengalihan otomatis ke petugas lain jika satu petugas menerima terlalu banyak permintaan.
4. Penyesuaian pencarian berdasarkan kloter, area tanggung jawab, atau kategori petugas.
5. Detail jemaah pada halaman petugas, seperti nama, asal/kloter, pesan bantuan, dan lokasi.
