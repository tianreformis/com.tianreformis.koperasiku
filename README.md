# KoperasiKu - Aplikasi Simpan Pinjam

Aplikasi manajemen Koperasi Simpan Pinjam berbasis Flutter & Firebase.

## Fitur Utama

### Admin (Pengurus Koperasi)
- **Dashboard** - Overview total anggota, simpanan, pinjaman, dan grafik bulanan
- **Manajemen Anggota** - CRUD anggota, detail profil, aktivasi/nonaktif
- **Manajemen Simpanan** - Catat simpanan pokok, wajib, sukarela, riwayat
- **Manajemen Pinjaman** - Approval pinjaman, jadwal angsuran, pembayaran
- **Laporan** - Export PDF (simpanan, pinjaman, angsuran), neraca keuangan

### Anggota
- **Dashboard Pribadi** - Saldo simpanan, pinjaman aktif, jadwal angsuran
- **Riwayat Transaksi** - Riwayat simpanan dan pinjaman
- **Pengajuan Pinjaman** - Form pengajuan dengan simulasi angsuran

## Tech Stack

- **Flutter** - UI Framework
- **Firebase Auth** - Autentikasi
- **Firebase Firestore** - Database
- **Firebase Storage** - Upload dokumen
- **Provider / Riverpod** - State Management
- **PDF** - Export laporan

## Struktur Database (Firestore)

```
/users/{userId}          - Data anggota & admin
/simpanan/{id}           - Transaksi simpanan
/pinjaman/{id}           - Data pinjaman
/angsuran/{id}           - Jadwal & pembayaran angsuran
/settings/config         - Konfigurasi koperasi
```

## Cara Install

### Prerequisites
- Flutter SDK >= 3.0
- Firebase project (Auth, Firestore, Storage diaktifkan)
- Android Studio / VS Code

### Langkah-langkah

1. **Clone repositori**
```bash
git clone https://github.com/username/koperasi_ku.git
cd koperasi_ku
```

2. **Setup Firebase**
   - Buat project di [Firebase Console](https://console.firebase.google.com)
   - Aktifkan Authentication (Email/Password), Firestore Database, Storage
   - Download `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS)
   - Letakkan file di folder `android/app/` dan `ios/Runner/`

3. **Install dependencies**
```bash
flutter pub get
```

4. **Generate Firebase options** (opsional)
```bash
flutter pub run firebase_core:configure
```

5. **Jalankan aplikasi**
```bash
flutter run
```

## Data Dummy Testing

### Login Akun

**Admin:**
- Email: `admin@koperasi.id`
- Password: `admin123`

**Anggota:**
- Email: `budi@email.com` / Password: `anggota123`
- Email: `siti@email.com` / Password: `anggota123`
- Email: `ahmad@email.com` / Password: `anggota123`
- Email: `dewi@email.com` / Password: `anggota123`
- Email: `rudi@email.com` / Password: `anggota123`

### Jalankan Seeder
```bash
# Jalankan sekali untuk mengisi data dummy
flutter run -t dummy_data.dart
```

**Catatan:** Hapus koleksi di Firestore jika ingin menjalankan seeder ulang.

## Firebase Security Rules

Deploy rules dari folder `firebase/`:
```bash
firebase deploy --only firestore:rules
```

## Format

- **Mata Uang:** Rupiah (Rp)
- **Tanggal:** dd/MM/yyyy
- **Bahasa:** Indonesia

## Lisensi

MIT License - Silakan digunakan untuk pembelajaran dan pengembangan.
