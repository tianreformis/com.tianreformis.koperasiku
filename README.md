# KoperasiKu - Aplikasi Simpan Pinjam

Aplikasi manajemen Koperasi Simpan Pinjam berbasis Flutter & Firebase.

## Fitur Utama

### Admin (Pengurus Koperasi)
- **Dashboard** — Overview total anggota, simpanan, pinjaman, dan grafik bulanan
- **Manajemen Anggota** — CRUD anggota, detail profil, aktivasi/nonaktif
- **Manajemen Simpanan** — Catat simpanan pokok, wajib, sukarela, riwayat
- **Manajemen Pinjaman** — Approval pinjaman, jadwal angsuran, pembayaran
- **Laporan** — Export PDF (simpanan, pinjaman, angsuran), neraca keuangan

### Anggota
- **Dashboard Pribadi** — Saldo simpanan, pinjaman aktif, jadwal angsuran
- **Riwayat Transaksi** — Riwayat simpanan dan pinjaman
- **Pengajuan Pinjaman** — Form pengajuan dengan simulasi angsuran

## Tech Stack

- **Flutter** — UI Framework
- **Firebase Auth** — Autentikasi
- **Firebase Firestore** — Database
- **Firebase Storage** — Upload dokumen
- **Provider / Riverpod** — State Management
- **PDF** — Export laporan

## Struktur Database (Firestore)

```
/users/{userId}          — Data anggota & admin
/simpanan/{id}           — Transaksi simpanan
/pinjaman/{id}           — Data pinjaman
/angsuran/{id}           — Jadwal & pembayaran angsuran
/settings/config         — Konfigurasi koperasi
```

## Prasyarat

| Tool | Versi Minimal | Catatan |
|------|--------------|---------|
| Flutter SDK | >= 3.0 | Hindari path dengan spasi |
| Java JDK | 17 | Digunakan oleh Gradle |
| Android Studio | Hedgehog+ | Untuk emulator & toolchain |
| Android SDK | 34+ | Via SDK Manager |
| Emulator / Device | API 34+ | x86_64 recommended |
| Firebase Project | - | Auth, Firestore, Storage aktif |

## Setup Lingkungan

### 1. Flutter SDK — Hindari Path dengan Spasi

Flutter SDK **tidak boleh** di path yang mengandung spasi (mis. `C:\Users\Nama User\flutter`), karena native assets hooks akan crash.

Jika sudah terlanjur terinstall di path berspasi:
```powershell
# Copy SDK ke path tanpa spasi
xcopy /E /I /H "C:\Users\Nama User\develop\flutter" "C:\flutter"
# Update PATH
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\flutter\bin", "User")
```

### 2. Install Dependencies

```powershell
flutter pub get
```

### 3. Setup Firebase

1. Buat project di [Firebase Console](https://console.firebase.google.com)
2. Aktifkan:
   - **Authentication** → Sign-in method → Email/Password
   - **Cloud Firestore** → Mode uji coba (atau production nanti)
   - **Storage** (opsional, untuk upload dokumen)
3. **Android**: Register aplikasi Android dengan package name `com.tianreformis.koperasiku`
4. Download `google-services.json` dan letakkan di `android/app/`
5. Generate Firebase options:
   ```powershell
   dart run flutterfire_cli:configure --project=nama-project-firebase
   ```
   Atau update manual `lib/config/firebase_options.dart` dengan credential dari `google-services.json`.

### 4. Build & Run

```powershell
# Cek koneksi device / emulator
flutter devices

# Run di emulator tertentu
flutter run -d emulator-5554

# Build APK debug
flutter build apk --debug
```

APK hasil build: `build\app\outputs\flutter-apk\app-debug.apk`

## Data Dummy Testing

Seeder `dummy_data.dart` membuat akun-akun berikut:

### Admin

| Email | Password |
|-------|----------|
| `admin@koperasi.id` | `admin123` |

### Anggota

| Email | Password | Nama |
|-------|----------|------|
| `budi@email.com` | `anggota123` | Budi Santoso |
| `siti@email.com` | `anggota123` | Siti Rahayu |
| `ahmad@email.com` | `anggota123` | Ahmad Hidayat |
| `dewi@email.com` | `anggota123` | Dewi Sartika |
| `rudi@email.com` | `anggota123` | Rudi Hermawan |

### Jalankan Seeder

```powershell
flutter run -t dummy_data.dart -d emulator-5554
```

Seeder akan:
1. Membuat user di Firebase Auth (skip jika email sudah terdaftar)
2. Membuat dokumen user di Firestore
3. Membuat data simpanan, pinjaman, dan angsuran (jika belum ada)

**Catatan:** Hapus koleksi di Firestore Console jika ingin menjalankan seeder ulang.

## Login & Navigasi

1. Buka app di emulator
2. Login dengan akun admin atau anggota
3. Admin → langsung ke Admin Dashboard
4. Anggota → langsung ke Anggota Dashboard

## Firestore: Composite Index

Karena semua query menggunakan sorting via Dart (bukan `orderBy`), **tidak diperlukan composite index**. Aplikasi bisa langsung berjalan tanpa menunggu index selesai dibuat.

## Troubleshooting

### Error: `Could not find the correct Provider` di Splash Screen

Penyebab: `ref.listen` dipanggil di `build()` tanpa menggunakan `ConsumerWidget` / `ConsumerStatefulWidget`.

Solusi: Pastikan widget adalah `ConsumerStatefulWidget` dan `ref.listen` dipanggil di dalam `build()`.

### Error: `MissingPluginException` atau native assets hook crash

Penyebab: Flutter SDK di path berspasi.

Solusi: Copy Flutter SDK ke `C:\flutter` (tanpa spasi). Lihat bagian Setup.

### Error: `FAILED_PRECONDITION` pada query Firestore

Penyebab: Query menggunakan `.where()` + `.orderBy()` tanpa composite index.

Solusi: Hapus `.orderBy()` dari query dan gunakan sorting Dart.

### Error: Build Gagal — `compileSdk` terlalu rendah

```gradle
compileSdk = 36
```

Update di `android/app/build.gradle.kts`.

### Error: `java.lang.ClassNotFoundException: com.tianreformis.koperasiku.MainActivity`

Penyebab: File `MainActivity.kt` masih di package lama.

Solusi: Pindahkan ke direktori `android/app/src/main/kotlin/com/tianreformis/koperasiku/MainActivity.kt`.

### KGP Warning: `share_plus`

```
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): share_plus
```

Ini **advisory**, bukan error. Bisa diabaikan. Tunggu update dari maintainer `share_plus`.

## Deploy Firebase Rules

```powershell
firebase deploy --only firestore:rules
```

Rules file: `firebase/firestore.rules`

## Format Aplikasi

- **Mata Uang:** Rupiah (Rp)
- **Tanggal:** dd/MM/yyyy
- **Bahasa:** Indonesia

## Lisensi

MIT License — Silakan digunakan untuk pembelajaran dan pengembangan.
