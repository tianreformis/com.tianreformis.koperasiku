import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/status_badge.dart';

class AnggotaManagementScreen extends ConsumerWidget {
  const AnggotaManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anggotaAsync = ref.watch(anggotaListProvider);

    return Scaffold(
      body: anggotaAsync.when(
        data: (anggotaList) {
          if (anggotaList.isEmpty) {
            return const EmptyWidget(
              message: 'Belum ada anggota terdaftar',
              icon: Icons.people_outline_rounded,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: anggotaList.length,
            itemBuilder: (context, index) {
              final anggota = anggotaList[index];
              return _AnggotaCard(anggota: anggota);
            },
          );
        },
        loading: () => const ShimmerLoading(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(anggotaListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTambahAnggotaDialog(context, ref),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Anggota'),
      ),
    );
  }

  void _showTambahAnggotaDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final namaCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final noTelpCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Anggota Baru'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama harus diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Email harus diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noTelpCtrl,
                  decoration: const InputDecoration(labelText: 'No. Telepon'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: alamatCtrl,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                Helpers.showSnackBar(
                  context,
                  'Anggota berhasil ditambahkan! Untuk login awal, gunakan email dan password default: 123456',
                  isSuccess: true,
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _AnggotaCard extends StatelessWidget {
  final UserModel anggota;

  const _AnggotaCard({required this.anggota});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.adminAnggotaDetail,
          arguments: anggota,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  anggota.nama.isNotEmpty
                      ? anggota.nama[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anggota.nama,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      anggota.nomorAnggota,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      anggota.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    status: anggota.aktif ? 'Aktif' : 'Nonaktif',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatRupiah(anggota.totalSimpanan),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


