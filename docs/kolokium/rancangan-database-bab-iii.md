# Rancangan Basis Data Firebase Realtime Database

Bagian ini dapat ditempatkan pada BAB III, subbab perancangan basis data. Aplikasi menggunakan Firebase Realtime Database sebagai penyimpanan data akun, lokasi terakhir, percakapan bantuan, sesi aktif, dan permintaan notifikasi bantuan. Struktur data disusun dalam bentuk node JSON, sehingga relasi antar data dilakukan melalui penyimpanan nilai ID seperti `userId`, `pilgrimId`, `officerId`, dan `conversationId`.

| No | Node | Field | Tipe Data | Keterangan |
|---:|---|---|---|---|
| 1 | `users/{userId}` | `userId` | String | Identitas akun dari Firebase Authentication. |
| 2 | `users/{userId}` | `displayName` | String | Nama jemaah atau petugas. |
| 3 | `users/{userId}` | `email` | String | Email yang digunakan untuk login. |
| 4 | `users/{userId}` | `roles` | String | Peran akun, seperti Jemaah Haji atau Petugas Haji. |
| 5 | `users/{userId}` | `kloter` | String | Informasi kloter atau asal jemaah jika tersedia. |
| 6 | `users/{userId}` | `imageUrl` | String | URL gambar profil atau avatar akun. |
| 7 | `users/{userId}` | `latitude` | Number | Koordinat lintang lokasi terakhir akun. |
| 8 | `users/{userId}` | `longitude` | Number | Koordinat bujur lokasi terakhir akun. |
| 9 | `helpConversations/{conversationId}` | `conversationId` | String | Identitas percakapan bantuan. |
| 10 | `helpConversations/{conversationId}` | `pairKey` | String | Gabungan ID jemaah dan petugas untuk mengecek sesi aktif. |
| 11 | `helpConversations/{conversationId}` | `pilgrimId` | String | Identitas jemaah yang meminta bantuan. |
| 12 | `helpConversations/{conversationId}` | `pilgrimName` | String | Nama jemaah yang meminta bantuan. |
| 13 | `helpConversations/{conversationId}` | `pilgrimImageUrl` | String | Gambar profil jemaah. |
| 14 | `helpConversations/{conversationId}` | `pilgrimRole` | String | Role jemaah pada percakapan. |
| 15 | `helpConversations/{conversationId}` | `officerId` | String | Identitas petugas yang dipilih. |
| 16 | `helpConversations/{conversationId}` | `officerName` | String | Nama petugas yang dipilih. |
| 17 | `helpConversations/{conversationId}` | `officerImageUrl` | String | Gambar profil petugas. |
| 18 | `helpConversations/{conversationId}` | `officerRole` | String | Role petugas pada percakapan. |
| 19 | `helpConversations/{conversationId}` | `status` | String | Status percakapan, misalnya `open` atau `closed`. |
| 20 | `helpConversations/{conversationId}` | `archived` | Boolean | Penanda apakah percakapan sudah diarsipkan. |
| 21 | `helpConversations/{conversationId}` | `openedAt` | Timestamp | Waktu percakapan bantuan dibuat. |
| 22 | `helpConversations/{conversationId}` | `updatedAt` | Timestamp | Waktu pembaruan terakhir pada percakapan. |
| 23 | `helpConversations/{conversationId}` | `lastMessage` | String | Isi pesan terakhir. |
| 24 | `helpConversations/{conversationId}` | `lastSenderId` | String | Identitas pengirim pesan terakhir. |
| 25 | `helpConversations/{conversationId}` | `lastSenderName` | String | Nama pengirim pesan terakhir. |
| 26 | `helpConversations/{conversationId}` | `lastMessageAt` | Timestamp | Waktu pesan terakhir dikirim. |
| 27 | `helpConversations/{conversationId}` | `lastMessageType` | String | Jenis pesan terakhir, misalnya pesan cepat atau pesan manual. |
| 28 | `helpConversations/{conversationId}` | `pilgrimLat` | Number | Koordinat lintang jemaah saat percakapan bantuan. |
| 29 | `helpConversations/{conversationId}` | `pilgrimLng` | Number | Koordinat bujur jemaah saat percakapan bantuan. |
| 30 | `helpConversations/{conversationId}` | `officerLat` | Number | Koordinat lintang petugas saat percakapan bantuan. |
| 31 | `helpConversations/{conversationId}` | `officerLng` | Number | Koordinat bujur petugas saat percakapan bantuan. |
| 32 | `helpConversations/{conversationId}` | `readMeta` | Object | Data waktu baca terakhir untuk masing-masing partisipan. |
| 33 | `helpConversations/{conversationId}` | `messages` | Object | Kumpulan pesan yang dikirim selama percakapan bantuan. |
| 34 | `helpConversations/{conversationId}/messages/{messageId}` | `id` | String | Identitas pesan. |
| 35 | `helpConversations/{conversationId}/messages/{messageId}` | `senderId` | String | Identitas pengirim pesan. |
| 36 | `helpConversations/{conversationId}/messages/{messageId}` | `senderName` | String | Nama pengirim pesan. |
| 37 | `helpConversations/{conversationId}/messages/{messageId}` | `senderImageUrl` | String | Gambar profil pengirim pesan. |
| 38 | `helpConversations/{conversationId}/messages/{messageId}` | `senderRole` | String | Role pengirim pesan. |
| 39 | `helpConversations/{conversationId}/messages/{messageId}` | `senderRoleType` | String | Tipe pengirim, yaitu jemaah atau petugas. |
| 40 | `helpConversations/{conversationId}/messages/{messageId}` | `senderLat` | Number | Koordinat lintang pengirim saat pesan dikirim. |
| 41 | `helpConversations/{conversationId}/messages/{messageId}` | `senderLng` | Number | Koordinat bujur pengirim saat pesan dikirim. |
| 42 | `helpConversations/{conversationId}/messages/{messageId}` | `text` | String | Isi pesan bantuan. |
| 43 | `helpConversations/{conversationId}/messages/{messageId}` | `type` | String | Jenis pesan, seperti pesan cepat atau pesan manual. |
| 44 | `helpConversations/{conversationId}/messages/{messageId}` | `templateKey` | String | Kunci template jika pesan berasal dari pilihan pesan cepat. |
| 45 | `helpConversations/{conversationId}/messages/{messageId}` | `createdAt` | Timestamp | Waktu pesan dibuat. |
| 46 | `helpConversationSessions/{pairKey}` | `conversationId` | String | Pointer ke percakapan aktif untuk pasangan jemaah dan petugas. |
| 47 | `helpNotificationRequests/{requestId}` | `id` | String | Identitas permintaan notifikasi bantuan. |
| 48 | `helpNotificationRequests/{requestId}` | `receiverUid` | String | Identitas penerima notifikasi. |
| 49 | `helpNotificationRequests/{requestId}` | `senderUid` | String | Identitas pengirim notifikasi. |
| 50 | `helpNotificationRequests/{requestId}` | `senderName` | String | Nama pengirim notifikasi. |
| 51 | `helpNotificationRequests/{requestId}` | `senderRole` | String | Role pengirim notifikasi. |
| 52 | `helpNotificationRequests/{requestId}` | `conversationId` | String | Identitas percakapan yang berkaitan dengan notifikasi. |
| 53 | `helpNotificationRequests/{requestId}` | `title` | String | Judul notifikasi bantuan. |
| 54 | `helpNotificationRequests/{requestId}` | `body` | String | Isi notifikasi bantuan. |
| 55 | `helpNotificationRequests/{requestId}` | `createdAt` | Timestamp | Waktu permintaan notifikasi dibuat. |
| 56 | `helpNotificationRequests/{requestId}` | `status` | String | Status notifikasi, misalnya `pending`. |

Keterangan relasi:

- `userId` pada node `users` digunakan kembali sebagai `pilgrimId`, `officerId`, `senderId`, `senderUid`, dan `receiverUid`.
- `conversationId` digunakan untuk menghubungkan data percakapan pada `helpConversations` dengan sesi aktif pada `helpConversationSessions` dan permintaan notifikasi pada `helpNotificationRequests`.
- `helpConversationSessions` berfungsi sebagai penanda percakapan bantuan yang masih aktif, sehingga sistem dapat membuka kembali sesi yang sama ketika jemaah atau petugas kembali ke halaman chat.
