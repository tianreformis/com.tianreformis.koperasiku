import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/simpanan_model.dart';
import 'user_provider.dart';

final simpananByUserProvider =
    StreamProvider.family<List<SimpananModel>, String>((ref, userId) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getSimpananByUser(userId);
});

final allSimpananProvider = StreamProvider<List<SimpananModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getAllSimpanan();
});

final totalSimpananHariIniProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getTotalSimpananHariIni();
});

final simpananBulananProvider = FutureProvider<Map<String, double>>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getSimpananBulanan();
});

class SimpananNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _service;

  SimpananNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> addSimpanan(SimpananModel simpanan) async {
    try {
      state = const AsyncValue.loading();
      await _service.addSimpanan(simpanan);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final simpananProvider = StateNotifierProvider<SimpananNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return SimpananNotifier(service);
});
