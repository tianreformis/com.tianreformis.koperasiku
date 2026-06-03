import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final user = await authNotifier.register(
        nama: _namaController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        noTelepon: _noTelpController.text.trim(),
        alamat: _alamatController.text.trim(),
      );

      if (user != null && mounted) {
        Helpers.showSnackBar(
          context,
          'Pendaftaran berhasil! Silakan verifikasi email Anda.',
          isSuccess: true,
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Anggota')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bergabunglah bersama kami',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Isi data diri Anda untuk mendaftar',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (v) => Validators.required(v, 'Nama'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noTelpController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'No. Telepon (opsional)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alamatController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Alamat (opsional)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) =>
                      Validators.matchPassword(v, _passwordController.text),
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Daftar',
                  onPressed: _register,
                  isLoading: _isLoading,
                  icon: Icons.person_add_rounded,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, AppRoutes.login),
                      child: const Text('Masuk'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
