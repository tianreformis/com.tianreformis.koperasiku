import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lib/models/user_model.dart';
import 'lib/models/simpanan_model.dart';
import 'lib/models/pinjaman_model.dart';
import 'lib/models/angsuran_model.dart';
import 'lib/config/constants.dart';
import 'lib/config/firebase_options.dart';

/// Script untuk mengisi data dummy ke Firestore
/// Jalankan: flutter run -t dummy_data.dart
class DummyDataSeeder {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  DummyDataSeeder() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
  }

  Future<void> seedAll() async {
    print('Memulai seeding data dummy...');

    // 1. Buat admin
    await _createAdmin();

    // 2. Buat anggota dummy
    final anggotaIds = await _createAnggota();

    // 3. Buat simpanan
    await _createSimpanan(anggotaIds);

    // 4. Buat pinjaman
    await _createPinjaman(anggotaIds);

    // 5. Settings
    await _createSettings();

    print('Seeding data dummy selesai!');
  }

  Future<void> _createAdmin() async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: 'admin@koperasi.id',
        password: 'admin123',
      );

      final admin = UserModel(
        id: result.user!.uid,
        nomorAnggota: 'ADM-001',
        nama: 'Admin Koperasi',
        email: 'admin@koperasi.id',
        noTelepon: '081234567890',
        alamat: 'Jl. Koperasi No. 1, Jakarta',
        role: 'admin',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(result.user!.uid)
          .set(admin.toMap());

      print('Admin created: admin@koperasi.id / admin123');
    } catch (e) {
      print('Admin creation error: $e');
    }
  }

  Future<List<String>> _createAnggota() async {
    final anggotaData = [
      {
        'nama': 'Budi Santoso',
        'email': 'budi@email.com',
        'password': 'anggota123',
        'noTelp': '081111111111',
        'alamat': 'Jl. Merdeka No. 10, Jakarta',
      },
      {
        'nama': 'Siti Rahmawati',
        'email': 'siti@email.com',
        'password': 'anggota123',
        'noTelp': '082222222222',
        'alamat': 'Jl. Sudirman No. 20, Bandung',
      },
      {
        'nama': 'Ahmad Hidayat',
        'email': 'ahmad@email.com',
        'password': 'anggota123',
        'noTelp': '083333333333',
        'alamat': 'Jl. Gatot Subroto No. 30, Surabaya',
      },
      {
        'nama': 'Dewi Lestari',
        'email': 'dewi@email.com',
        'password': 'anggota123',
        'noTelp': '084444444444',
        'alamat': 'Jl. Thamrin No. 40, Yogyakarta',
      },
      {
        'nama': 'Rudi Hermawan',
        'email': 'rudi@email.com',
        'password': 'anggota123',
        'noTelp': '085555555555',
        'alamat': 'Jl. Diponegoro No. 50, Semarang',
      },
    ];

    final List<String> userIds = [];

    for (int i = 0; i < anggotaData.length; i++) {
      try {
        final data = anggotaData[i];
        final result = await _auth.createUserWithEmailAndPassword(
          email: data['email'] as String,
          password: data['password'] as String,
        );

        final anggota = UserModel(
          id: result.user!.uid,
          nomorAnggota: 'AGN-${(i + 1).toString().padLeft(3, '0')}',
          nama: data['nama'] as String,
          email: data['email'] as String,
          noTelepon: data['noTelp'] as String,
          alamat: data['alamat'] as String,
          role: 'anggota',
          createdAt: DateTime.now().subtract(Duration(days: 90 - i * 10)),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(result.user!.uid)
            .set(anggota.toMap());

        userIds.add(result.user!.uid);
        print(
            'Anggota created: ${data['email']} / ${data['password']} (${data['nama']})');
      } catch (e) {
        print('Anggota creation error: $e');
      }
    }

    return userIds;
  }

  Future<void> _createSimpanan(List<String> userIds) async {
    final now = DateTime.now();

    for (int i = 0; i < userIds.length; i++) {
      // Simpanan Pokok (sekali)
      final pokok = SimpananModel(
        userId: userIds[i],
        jenis: 'pokok',
        jumlah: 100000,
        tanggal: now.subtract(Duration(days: 90 - i * 10)),
        keterangan: 'Simpanan pokok saat pendaftaran',
        createdAt: now.subtract(Duration(days: 90 - i * 10)),
      );
      await _firestore
          .collection(AppConstants.simpananCollection)
          .add(pokok.toMap());

      // Simpanan Wajib (bulanan)
      for (int m = 1; m <= 3; m++) {
        final wajib = SimpananModel(
          userId: userIds[i],
          jenis: 'wajib',
          jumlah: 50000,
          tanggal: now.subtract(Duration(days: 90 - i * 10 - m * 30)),
          keterangan: 'Simpanan wajib bulan ke-$m',
          createdAt: now.subtract(Duration(days: 90 - i * 10 - m * 30)),
        );
        await _firestore
            .collection(AppConstants.simpananCollection)
            .add(wajib.toMap());
      }

      // Simpanan Sukarela (beberapa anggota)
      if (i % 2 == 0) {
        final sukarela = SimpananModel(
          userId: userIds[i],
          jenis: 'sukarela',
          jumlah: 100000 + (i * 50000),
          tanggal: now.subtract(Duration(days: 30)),
          keterangan: 'Simpanan sukarela',
          createdAt: now.subtract(Duration(days: 30)),
        );
        await _firestore
            .collection(AppConstants.simpananCollection)
            .add(sukarela.toMap());
      }

      // Update total simpanan user
      final totalSimpanan = 100000 + (3 * 50000) + (i % 2 == 0 ? 100000 + (i * 50000) : 0);
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userIds[i])
          .update({'totalSimpanan': totalSimpanan});
    }

    print('Simpanan data created');
  }

  Future<void> _createPinjaman(List<String> userIds) async {
    if (userIds.length < 4) {
      print('Skip pinjaman: not enough members');
      return;
    }
    final now = DateTime.now();

    // Beberapa anggota memiliki pinjaman
    final pinjamanData = [
      {
        'userId': userIds[0],
        'jumlah': 3000000,
        'tenor': 6,
        'status': 'aktif',
      },
      {
        'userId': userIds[1],
        'jumlah': 5000000,
        'tenor': 12,
        'status': 'aktif',
      },
      {
        'userId': userIds[2],
        'jumlah': 2000000,
        'tenor': 3,
        'status': 'pending',
      },
      {
        'userId': userIds[3],
        'jumlah': 10000000,
        'tenor': 12,
        'status': 'lunas',
      },
    ];

    for (final data in pinjamanData) {
      final jumlah = (data['jumlah'] as num).toDouble();
      final tenor = data['tenor'] as int;
      final bunga = 0.12;
      final pokokPerBulan = jumlah / tenor;
      final bungaPerBulan = jumlah * bunga / 12;
      final angsuranPerBulan = double.parse(
          (pokokPerBulan + bungaPerBulan).toStringAsFixed(0));
      final totalBayar = angsuranPerBulan * tenor;

      final pinjamanRef =
          await _firestore.collection(AppConstants.pinjamanCollection).add({
        'userId': data['userId'],
        'jumlah': jumlah,
        'bunga': bunga,
        'jenisBunga': 'flat',
        'tenor': tenor,
        'angsuranPerBulan': angsuranPerBulan,
        'totalBayar': totalBayar,
        'status': data['status'],
        'keterangan': 'Pinjaman untuk modal usaha',
        'createdAt': now.subtract(const Duration(days: 60)),
        'disetujuiAt': data['status'] != 'pending'
            ? now.subtract(const Duration(days: 55))
            : null,
      });

      // Buat angsuran
      if (data['status'] == 'aktif' || data['status'] == 'lunas') {
        final awalPinjaman = now.subtract(const Duration(days: 55));
        for (int i = 1; i <= tenor; i++) {
          final jatuhTempo = DateTime(
            awalPinjaman.year,
            awalPinjaman.month + i,
            awalPinjaman.day,
          );

          final isLunas = data['status'] == 'lunas' ||
              (data['status'] == 'aktif' && i <= 2);

          await _firestore
              .collection(AppConstants.angsuranCollection)
              .add({
            'pinjamanId': pinjamanRef.id,
            'userId': data['userId'],
            'angsuranKe': i,
            'jumlah': angsuranPerBulan,
            'dibayar': isLunas ? angsuranPerBulan : 0,
            'jatuhTempo': jatuhTempo,
            'tanggalBayar': isLunas
                ? jatuhTempo.subtract(const Duration(days: 2))
                : null,
            'status': isLunas ? 'lunas' : 'belum',
          });
        }

        // Update user total pinjaman
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(data['userId'] as String)
            .update({'totalPinjaman': jumlah});
      }
    }

    print('Pinjaman & angsuran data created');
  }

  Future<void> _createSettings() async {
    final settings = {
      'namaKoperasi': 'KoperasiKu Sejahtera',
      'alamat': 'Jl. Koperasi No. 1, Jakarta Pusat',
      'noTelepon': '(021) 12345678',
      'email': 'info@koperasiku.id',
      'simpananPokok': 100000,
      'simpananWajib': 50000,
      'bungaFlat': 0.12,
      'bungaMenurun': 0.10,
      'maxTenor': 12,
      'maxPinjaman': 10000000,
    };

    await _firestore
        .collection(AppConstants.settingsCollection)
        .doc('config')
        .set(settings);

    print('Settings created');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final seeder = DummyDataSeeder();
  await seeder.seedAll();
}
