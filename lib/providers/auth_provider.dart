import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authState.asyncMap((user) async {
    if (user == null) return null;
    return authService.getCurrentUserData();
  });
});

final authLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<UserModel?> login(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.login(email, password);
      state = AsyncValue.data(user);
      return user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
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
      state = const AsyncValue.loading();
      final user = await _authService.register(
        nama: nama,
        email: email,
        password: password,
        noTelepon: noTelepon,
        alamat: alamat,
      );
      state = AsyncValue.data(user);
      return user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _authService.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
