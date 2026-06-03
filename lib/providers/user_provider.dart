import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final anggotaListProvider = FutureProvider<List<UserModel>>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getAllAnggota();
});

final totalAnggotaAktifProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getTotalAnggotaAktif();
});

final userDetailProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getUserById(userId);
});
