import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/simpanan_model.dart';
import '../models/pinjaman_model.dart';
import '../models/angsuran_model.dart';
import '../models/settings_model.dart';
import '../config/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== USERS =====

  Future<List<UserModel>> getAllAnggota() async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: 'anggota')
        .get();
    final list = snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), id: doc.id))
        .toList();
    list.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    return list;
  }

  Future<UserModel?> getUserById(String userId) async {
    final doc =
        await _firestore.collection(AppConstants.usersCollection).doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, id: doc.id);
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update(data);
  }

  Future<void> nonaktifkanAnggota(String userId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'aktif': false, 'updatedAt': DateTime.now()});
  }

  Future<void> aktifkanAnggota(String userId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'aktif': true, 'updatedAt': DateTime.now()});
  }

  Future<int> getTotalAnggotaAktif() async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: 'anggota')
        .where('aktif', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }

  // ===== SIMPANAN =====

  Future<void> addSimpanan(SimpananModel simpanan) async {
    final batch = _firestore.batch();
    final simpananRef =
        _firestore.collection(AppConstants.simpananCollection).doc();
    batch.set(simpananRef, simpanan.toMap());

    final userRef =
        _firestore.collection(AppConstants.usersCollection).doc(simpanan.userId);
    batch.update(userRef, {
      'totalSimpanan': FieldValue.increment(simpanan.jumlah),
      'updatedAt': DateTime.now(),
    });

    await batch.commit();
  }

  Stream<List<SimpananModel>> getSimpananByUser(String userId) {
    return _firestore
        .collection(AppConstants.simpananCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => SimpananModel.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => (b.tanggal ?? DateTime.now()).compareTo(a.tanggal ?? DateTime.now()));
      return list;
    });
  }

  Stream<List<SimpananModel>> getAllSimpanan() {
    return _firestore
        .collection(AppConstants.simpananCollection)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => SimpananModel.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => (b.tanggal ?? DateTime.now()).compareTo(a.tanggal ?? DateTime.now()));
      return list;
    });
  }

  Future<double> getTotalSimpananHariIni() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final snapshot = await _firestore
        .collection(AppConstants.simpananCollection)
        .where('tanggal', isGreaterThanOrEqualTo: startOfDay)
        .where('tanggal', isLessThan: endOfDay)
        .get();
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['jumlah'] ?? 0).toDouble();
    }
    return total;
  }

  Future<Map<String, double>> getSimpananBulanan() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final snapshot = await _firestore
        .collection(AppConstants.simpananCollection)
        .where('tanggal', isGreaterThanOrEqualTo: startOfYear)
        .get();

    final Map<String, double> bulanan = {};
    for (int i = 1; i <= 12; i++) {
      bulanan[i.toString().padLeft(2, '0')] = 0;
    }

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final tanggal = (data['tanggal'] as Timestamp).toDate();
      final bulan = tanggal.month.toString().padLeft(2, '0');
      bulanan[bulan] = (bulanan[bulan] ?? 0) + (data['jumlah'] ?? 0).toDouble();
    }

    return bulanan;
  }

  // ===== PINJAMAN =====

  Future<void> addPinjaman(PinjamanModel pinjaman) async {
    await _firestore.collection(AppConstants.pinjamanCollection).doc().set(pinjaman.toMap());
  }

  Stream<List<PinjamanModel>> getPinjamanByUser(String userId) {
    return _firestore
        .collection(AppConstants.pinjamanCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => PinjamanModel.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
      return list;
    });
  }

  Stream<List<PinjamanModel>> getAllPinjaman() {
    return _firestore
        .collection(AppConstants.pinjamanCollection)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => PinjamanModel.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
      return list;
    });
  }

  Future<void> approvePinjaman(String pinjamanId, String adminId) async {
    final pinjamanRef =
        _firestore.collection(AppConstants.pinjamanCollection).doc(pinjamanId);
    final pinjaman = await pinjamanRef.get();
    if (!pinjaman.exists) throw Exception('Pinjaman tidak ditemukan');

    final data = PinjamanModel.fromMap(pinjaman.data()!, id: pinjaman.id);
    final angsuranList = _hitungAngsuran(data);

    final batch = _firestore.batch();
    batch.update(pinjamanRef, {
      'status': 'aktif',
      'adminId': adminId,
      'disetujuiAt': DateTime.now(),
      'angsuranPerBulan': angsuranList.isNotEmpty ? angsuranList[0].jumlah : 0,
      'totalBayar': angsuranList.fold<double>(0, (sum, a) => sum + a.jumlah),
    });

    for (var angsuran in angsuranList) {
      final angsuranRef =
          _firestore.collection(AppConstants.angsuranCollection).doc();
      batch.set(angsuranRef, angsuran.toMap());
    }

    await batch.commit();
  }

  Future<void> tolakPinjaman(String pinjamanId, String adminId, String alasan) async {
    await _firestore.collection(AppConstants.pinjamanCollection).doc(pinjamanId).update({
      'status': 'ditolak',
      'adminId': adminId,
      'keterangan': alasan,
    });
  }

  List<AngsuranModel> _hitungAngsuran(PinjamanModel pinjaman) {
    final List<AngsuranModel> angsuranList = [];
    final double pokokPerBulan = pinjaman.jumlah / pinjaman.tenor;

    for (int i = 1; i <= pinjaman.tenor; i++) {
      double angsuranPerBulan;
      if (pinjaman.jenisBunga == 'flat') {
        final bungaPerBulan = pinjaman.jumlah * pinjaman.bunga / 12;
        angsuranPerBulan = pokokPerBulan + bungaPerBulan;
      } else {
        final sisaPinjaman = pinjaman.jumlah - (pokokPerBulan * (i - 1));
        final bungaPerBulan = sisaPinjaman * pinjaman.bunga / 12;
        angsuranPerBulan = pokokPerBulan + bungaPerBulan;
      }

      final jatuhTempo = DateTime(
        pinjaman.createdAt!.year,
        pinjaman.createdAt!.month + i,
        pinjaman.createdAt!.day,
      );

      angsuranList.add(AngsuranModel(
        pinjamanId: pinjaman.id!,
        userId: pinjaman.userId,
        angsuranKe: i,
        jumlah: double.parse(angsuranPerBulan.toStringAsFixed(0)),
        jatuhTempo: jatuhTempo,
        status: 'belum',
      ));
    }
    return angsuranList;
  }

  Future<double> getTotalPinjamanBerjalan() async {
    final snapshot = await _firestore
        .collection(AppConstants.pinjamanCollection)
        .where('status', isEqualTo: 'aktif')
        .get();
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['jumlah'] ?? 0).toDouble();
    }
    return total;
  }

  Future<Map<String, double>> getPinjamanBulanan() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final snapshot = await _firestore
        .collection(AppConstants.pinjamanCollection)
        .where('createdAt', isGreaterThanOrEqualTo: startOfYear)
        .get();

    final Map<String, double> bulanan = {};
    for (int i = 1; i <= 12; i++) {
      bulanan[i.toString().padLeft(2, '0')] = 0;
    }

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final tanggal = (data['createdAt'] as Timestamp).toDate();
      final bulan = tanggal.month.toString().padLeft(2, '0');
      bulanan[bulan] = (bulanan[bulan] ?? 0) + (data['jumlah'] ?? 0).toDouble();
    }

    return bulanan;
  }

  // ===== ANGSURAN =====

  Stream<List<AngsuranModel>> getAngsuranByPinjaman(String pinjamanId) {
    return _firestore
        .collection(AppConstants.angsuranCollection)
        .where('pinjamanId', isEqualTo: pinjamanId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AngsuranModel.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => a.angsuranKe.compareTo(b.angsuranKe));
      return list;
    });
  }

  Stream<List<AngsuranModel>> getAngsuranByUser(String userId) {
    return _firestore
        .collection(AppConstants.angsuranCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AngsuranModel.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => (b.jatuhTempo ?? DateTime.now()).compareTo(a.jatuhTempo ?? DateTime.now()));
      return list;
    });
  }

  Future<List<AngsuranModel>> getAngsuranByDateRange(
      DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection(AppConstants.angsuranCollection)
        .where('jatuhTempo', isGreaterThanOrEqualTo: start)
        .where('jatuhTempo', isLessThanOrEqualTo: end)
        .get();
    final list = snapshot.docs
        .map((doc) => AngsuranModel.fromMap(doc.data(), id: doc.id))
        .toList();
    list.sort((a, b) =>
        (a.jatuhTempo ?? DateTime.now()).compareTo(b.jatuhTempo ?? DateTime.now()));
    return list;
  }

  Future<void> bayarAngsuran(String angsuranId, double jumlah) async {
    final batch = _firestore.batch();
    final angsuranRef =
        _firestore.collection(AppConstants.angsuranCollection).doc(angsuranId);
    batch.update(angsuranRef, {
      'status': 'lunas',
      'dibayar': jumlah,
      'tanggalBayar': DateTime.now(),
    });

    await batch.commit();
  }

  // ===== SETTINGS =====

  Future<SettingsModel?> getSettings() async {
    final doc =
        await _firestore.collection(AppConstants.settingsCollection).doc('config').get();
    if (doc.exists) {
      return SettingsModel.fromMap(doc.data()!, id: doc.id);
    }
    return null;
  }

  Future<void> updateSettings(SettingsModel settings) async {
    await _firestore
        .collection(AppConstants.settingsCollection)
        .doc('config')
        .set(settings.toMap());
  }

  // ===== LAPORAN DATA =====

  Future<List<SimpananModel>> getSimpananByDateRange(
      DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection(AppConstants.simpananCollection)
        .where('tanggal', isGreaterThanOrEqualTo: start)
        .where('tanggal', isLessThanOrEqualTo: end)
        .get();
    final list = snapshot.docs
        .map((doc) => SimpananModel.fromMap(doc.data(), id: doc.id))
        .toList();
    list.sort((a, b) => (a.tanggal ?? DateTime.now()).compareTo(b.tanggal ?? DateTime.now()));
    return list;
  }

  Future<List<PinjamanModel>> getPinjamanByDateRange(
      DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection(AppConstants.pinjamanCollection)
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .get();
    final list = snapshot.docs
        .map((doc) => PinjamanModel.fromMap(doc.data(), id: doc.id))
        .toList();
    list.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
    return list;
  }
}
