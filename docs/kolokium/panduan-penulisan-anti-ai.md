# Panduan Penulisan Laporan Agar Tidak Terasa AI

Panduan ini dipakai untuk menulis dan merevisi kalimat pada laporan tugas akhir. Sumber awalnya dari folder `anti-slop-writing-1.0.0`, lalu disesuaikan untuk konteks laporan akademik Bahasa Indonesia.

Tujuannya bukan membuat tulisan menjadi santai. Tujuannya agar kalimat tetap formal, tetapi terasa ditulis oleh manusia: jelas, tidak berlebihan, dan tidak penuh frasa yang biasa muncul dari AI.

## Prinsip Utama

Tulisan laporan harus menjelaskan apa yang benar-benar dilakukan pada penelitian. Hindari klaim besar yang tidak perlu.

Contoh yang kurang baik:

```text
Sistem ini menjadi solusi penting dalam meningkatkan efektivitas layanan bantuan jemaah haji.
```

Lebih aman:

```text
Sistem ini membantu jemaah melihat petugas terdekat berdasarkan koordinat yang tersedia pada aplikasi.
```

Kalimat kedua lebih sempit, tapi lebih kuat. Dosen biasanya lebih suka yang seperti ini.

## Kata dan Frasa yang Sebaiknya Dihindari

Hindari kata yang terdengar terlalu promosi:

- sangat penting
- signifikan, jika tidak ada angka atau bukti
- komprehensif
- inovatif
- optimal, jika tidak ada pembuktian optimasi
- efektif, jika tidak ada pengukuran efektivitas
- efisien, jika tidak ada pengukuran waktu atau sumber daya
- memfasilitasi, jika bisa ditulis `membantu`
- mengoptimalkan, jika hanya berarti `menggunakan`
- menunjukkan pentingnya
- menjadi solusi
- berperan penting

Gunakan kata yang lebih langsung:

- `menggunakan`
- `membantu`
- `menampilkan`
- `menghitung`
- `mengurutkan`
- `membaca data`
- `menyimpan data`
- `membandingkan`

## Pola Kalimat yang Perlu Dihindari

### 1. Jangan terlalu sering memakai pola "tidak hanya ..., tetapi juga ..."

Kurang baik:

```text
Aplikasi tidak hanya menampilkan lokasi petugas, tetapi juga menyediakan navigasi.
```

Lebih natural:

```text
Aplikasi menampilkan lokasi petugas dan menyediakan navigasi menuju petugas yang dipilih.
```

### 2. Jangan menutup paragraf dengan kesimpulan kosong

Kurang baik:

```text
Hal ini menunjukkan bahwa sistem memiliki manfaat yang baik bagi pengguna.
```

Lebih aman:

```text
Dengan alur tersebut, jemaah dapat melihat urutan petugas terdekat sebelum memilih petugas yang akan dituju.
```

### 3. Jangan membuat klaim yang terlalu luas

Kurang baik:

```text
Aplikasi ini dapat meningkatkan layanan haji secara menyeluruh.
```

Lebih aman:

```text
Aplikasi ini dibatasi pada pencarian petugas terdekat, penampilan peta, dan navigasi menuju petugas yang dipilih.
```

### 4. Jangan memakai kalimat yang terlalu halus tapi tidak menambah informasi

Kurang baik:

```text
Fitur ini memberikan pengalaman yang lebih baik bagi pengguna dalam mengakses layanan bantuan.
```

Lebih aman:

```text
Fitur ini menyediakan pesan cepat agar jemaah dapat mengirim permintaan bantuan tanpa mengetik pesan dari awal.
```

## Aturan Khusus untuk Laporan Ini

Gunakan `jemaah` jika konteksnya:

- mencari petugas
- melihat hasil Haversine
- membuka peta hasil pencarian
- memilih petugas
- membuka rute
- mengirim bantuan

Gunakan `petugas` jika konteksnya:

- menerima permintaan bantuan
- membaca pesan jemaah
- melihat lokasi jemaah
- memberi respons

Gunakan `pengguna` jika konteksnya:

- teori umum
- login untuk semua role
- antarmuka pengguna
- analisis pengguna
- data pengguna yang mencakup jemaah dan petugas
- autentikasi dan izin akses

Gunakan `data akun` jika kalimat terasa ambigu antara jemaah, petugas, dan administrator.

## Cara Menulis Kalimat Revisi

Saat memberi teks siap tempel untuk laporan, gunakan pola ini:

1. Sebutkan fungsi yang benar-benar ada.
2. Sebutkan data yang dipakai.
3. Sebutkan batasannya jika perlu.
4. Hindari kata besar yang tidak dibuktikan.

Contoh:

```text
Haversine Formula digunakan untuk menghitung jarak awal antara jemaah dan petugas berdasarkan latitude dan longitude. Hasil perhitungan digunakan untuk mengurutkan petugas dari jarak terkecil. Setelah jemaah memilih petugas, rute navigasi ditampilkan menggunakan Mapbox Directions API.
```

Kalimat tersebut cukup. Tidak perlu ditambah klaim seperti `meningkatkan efektivitas layanan` jika tidak diuji.

## Checklist Sebelum Kalimat Ditempel ke Laporan

- Apakah kalimatnya sesuai dengan fitur yang benar-benar dibuat?
- Apakah subjeknya jelas: jemaah, petugas, atau pengguna umum?
- Apakah ada klaim yang tidak diuji?
- Apakah ada kata promosi yang bisa dihapus?
- Apakah kalimat terakhir paragraf hanya mengulang kalimat sebelumnya?
- Apakah istilah teknis seperti Haversine, Mapbox, Firebase, GPS, dan database ditulis konsisten?

Kalau ada kalimat yang terasa terlalu mulus atau terlalu luas, kecilkan klaimnya. Biasanya itu yang membuat tulisan terasa lebih manusia.
