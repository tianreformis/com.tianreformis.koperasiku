import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../config/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).valueOrNull;
    if (user != null) {
      _namaController.text = user.nama;
      _teleponController.text = user.noTelepon ?? '';
      _alamatController.text = user.alamat ?? '';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).valueOrNull;
      if (user?.id == null) {
        Helpers.showSnackBar(context, 'User tidak ditemukan', isError: true);
        return;
      }

      final service = ref.read(firestoreServiceProvider);
      await service.updateUser(user!.id!, {
        'nama': _namaController.text.trim(),
        'noTelepon': _teleponController.text.trim().isEmpty
            ? null
            : _teleponController.text.trim(),
        'alamat': _alamatController.text.trim().isEmpty
            ? null
            : _alamatController.text.trim(),
        'updatedAt': DateTime.now(),
      });

      if (mounted) {
        Helpers.showSnackBar(context, 'Profil berhasil diperbarui', isSuccess: true);
        Navigator.pop(context);
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
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    user?.nama.isNotEmpty == true
                        ? user!.nama[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teleponController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. Telepon',
                  hintText: '081234567890',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  hintText: 'Jl. Contoh No. 123, Kota',
                  prefixIcon: Icon(Icons.location_on_rounded),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              LoadingButton(
                label: 'Simpan Perubahan',
                onPressed: _save,
                isLoading: _isLoading,
                icon: Icons.save_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
