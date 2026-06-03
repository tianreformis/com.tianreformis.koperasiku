import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/pinjaman_model.dart';
import '../models/angsuran_model.dart';
import 'user_provider.dart';

final pinjamanByUserProvider =
    StreamProvider.family<List<PinjamanModel>, String>((ref, userId) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getPinjamanByUser(userId);
});

final allPinjamanProvider = StreamProvider<List<PinjamanModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getAllPinjaman();
});

final angsuranByPinjamanProvider =
    StreamProvider.family<List<AngsuranModel>, String>((ref, pinjamanId) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getAngsuranByPinjaman(pinjamanId);
});

final angsuranByUserProvider =
    StreamProvider.family<List<AngsuranModel>, String>((ref, userId) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getAngsuranByUser(userId);
});

final totalPinjamanBerjalanProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getTotalPinjamanBerjalan();
});

final pinjamanBulananProvider = FutureProvider<Map<String, double>>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getPinjamanBulanan();
});

class PinjamanNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _service;

  PinjamanNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> addPinjaman(PinjamanModel pinjaman) async {
    try {
      state = const AsyncValue.loading();
      await _service.addPinjaman(pinjaman);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> approvePinjaman(String pinjamanId, String adminId) async {
    try {
      state = const AsyncValue.loading();
      await _service.approvePinjaman(pinjamanId, adminId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> tolakPinjaman(String pinjamanId, String adminId, String alasan) async {
    try {
      state = const AsyncValue.loading();
      await _service.tolakPinjaman(pinjamanId, adminId, alasan);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> bayarAngsuran(String angsuranId, double jumlah) async {
    try {
      state = const AsyncValue.loading();
      await _service.bayarAngsuran(angsuranId, jumlah);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final pinjamanProvider = StateNotifierProvider<PinjamanNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return PinjamanNotifier(service);
});
