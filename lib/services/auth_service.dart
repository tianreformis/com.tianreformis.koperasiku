import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (result.user != null) {
        return await _getUserData(result.user!.uid);
      }
      return null;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserModel?> register({
    required String nama,
    required String email,
    required String password,
    String? noTelepon,
    String? alamat,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (result.user != null) {
        final nomorAnggota = await _generateNomorAnggota();
        final user = UserModel(
          id: result.user!.uid,
          nomorAnggota: nomorAnggota,
          nama: nama,
          email: email.trim(),
          noTelepon: noTelepon,
          alamat: alamat,
          role: 'anggota',
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(result.user!.uid)
            .set(user.toMap());
        await _sendEmailVerification(result.user!);
        return user;
      }
      return null;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> _sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String> _generateNomorAnggota() async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('nomorAnggota', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return 'AGN-001';
    }
    final lastNumber = snapshot.docs.first.data()['nomorAnggota'] as String;
    final number = int.parse(lastNumber.split('-')[1]);
    return 'AGN-${(number + 1).toString().padLeft(3, '0')}';
  }

  Future<UserModel?> _getUserData(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, id: doc.id);
    }
    return null;
  }

  Future<UserModel?> getCurrentUserData() async {
    if (_auth.currentUser == null) return null;
    return _getUserData(_auth.currentUser!.uid);
  }

  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar';
        case 'wrong-password':
          return 'Password salah';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'email-already-in-use':
          return 'Email sudah digunakan';
        case 'weak-password':
          return 'Password minimal 6 karakter';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan, coba lagi nanti';
        case 'network-request-failed':
          return 'Tidak ada koneksi internet';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    }
    return 'Terjadi kesalahan yang tidak diketahui';
  }
}
