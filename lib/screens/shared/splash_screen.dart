import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _delayedCheck);
    Future.delayed(const Duration(seconds: 5), _forceProceed);
  }

  void _delayedCheck() {
    if (_navigated || !mounted) return;
    final state = ref.read(authStateProvider);
    state.whenOrNull(
      data: (user) => _navigate(user),
      error: (_, __) => _navigate(null),
    );
  }

  void _forceProceed() {
    if (!_navigated && mounted) _navigate(null);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      next.whenOrNull(
        data: (user) => _navigate(user),
        error: (_, __) => _navigate(null),
      );
    });

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'KoperasiKu',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Simpan Pinjam',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(UserModel? user) {
    if (_navigated || !mounted) return;
    _navigated = true;
    if (user != null) {
      if (user.role == 'admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.anggotaDashboard);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

}
