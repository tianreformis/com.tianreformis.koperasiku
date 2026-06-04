import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';

class SessionWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const SessionWrapper({super.key, required this.child});

  @override
  ConsumerState<SessionWrapper> createState() => _SessionWrapperState();
}

class _SessionWrapperState extends ConsumerState<SessionWrapper> {
  Timer? _timer;
  int _remainingSeconds = 0;

  static const _timeoutMinutes = 3;
  static const _warningSeconds = 30;

  void _resetTimer() {
    _remainingSeconds = _timeoutMinutes * 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (now) {
      if (!mounted) return;
      _remainingSeconds--;
      if (_remainingSeconds <= _warningSeconds) {
        setState(() {});
      }
      if (_remainingSeconds <= 0) {
        _logout();
      }
    });
  }

  Future<void> _logout() async {
    _timer?.cancel();
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull;
    final authenticated = user != null;

    if (authenticated && (_timer == null || !_timer!.isActive)) {
      _resetTimer();
    } else if (!authenticated && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (authenticated) _resetTimer();
      },
      onPointerMove: (_) {
        if (authenticated) _resetTimer();
      },
      child: Stack(
        children: [
          widget.child,
          if (authenticated && _timer != null && _remainingSeconds > 0 && _remainingSeconds <= _warningSeconds)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.warningColor.withValues(alpha: 0.9),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        const Icon(Icons.timer_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sesi akan berakhir dalam $_remainingSeconds detik',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: _resetTimer,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Perpanjang', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
