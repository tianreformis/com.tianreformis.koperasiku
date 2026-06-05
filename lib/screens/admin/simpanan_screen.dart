import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/simpanan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/simpanan_model.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/rupiah_input.dart';

class SimpananScreen extends ConsumerStatefulWidget {
  const SimpananScreen({super.key});

  @override
  ConsumerState<SimpananScreen> createState() => _SimpananScreenState();
}

class _SimpananScreenState extends ConsumerState<SimpananScreen> {
  @override
  Widget build(BuildContext context) {
    final simpananAsync = ref.watch(allSimpananProvider);

    return Scaffold(
      body: simpananAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyWidget(
              message: 'Belum ada transaksi simpanan',
              icon: Icons.account_balance_wallet_outlined,
            );
          }
          final total = list.fold<double>(0, (sum, s) => sum + s.jumlah);
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppTheme.primaryColor.withOpacity(0.05),
                child: Column(
                  children: [
                    Text(
                      'Total Seluruh Simpanan',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatRupiah(total),
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(color: AppTheme.primaryColor, fontSize: 24),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final s = list[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getJenisColor(s.jenis).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: _getJenisColor(s.jenis),
                          ),
                        ),
                        title: Text(s.labelJenis),
                        subtitle: Text(
                            '${s.userId} • ${Formatters.formatDate(s.tanggal ?? DateTime.now())}'),
                        trailing: Text(
                          Formatters.formatRupiah(s.jumlah),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getJenisColor(s.jenis),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const ShimmerLoading(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(allSimpananProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTambahSimpananDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Catat Simpanan'),
      ),
    );
  }

  Color _getJenisColor(String jenis) {
    switch (jenis) {
      case 'pokok':
        return AppTheme.primaryColor;
      case 'wajib':
        return AppTheme.secondaryColor;
      case 'sukarela':
        return AppTheme.accentColor;
      default:
        return Colors.grey;
    }
  }

  void _showTambahSimpananDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final jumlahCtrl = TextEditingController();
    String selectedJenis = 'wajib';
    String? selectedUserId;
    List<UserModel> anggotaList = [];

    ref.read(anggotaListProvider.future).then((list) {
      if (mounted) setState(() => anggotaList = list);
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Catat Simpanan'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: StatefulBuilder(builder: (ctx, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedUserId,
                    decoration:
                        const InputDecoration(labelText: 'Pilih Anggota'),
                    items: anggotaList
                        .map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text('${a.nama} (${a.nomorAnggota})'),
                            ))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedUserId = v),
                    validator: (v) => v == null ? 'Pilih anggota' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedJenis,
                    decoration:
                        const InputDecoration(labelText: 'Jenis Simpanan'),
                    items: const [
                      DropdownMenuItem(
                          value: 'pokok', child: Text('Simpanan Pokok')),
                      DropdownMenuItem(
                          value: 'wajib', child: Text('Simpanan Wajib')),
                      DropdownMenuItem(
                          value: 'sukarela', child: Text('Simpanan Sukarela')),
                    ],
                    onChanged: (v) => setDialogState(() => selectedJenis = v!),
                  ),
                  const SizedBox(height: 12),
                  RupiahInput(
                    controller: jumlahCtrl,
                    label: 'Jumlah',
                    validator: (v) => Validators.positiveNumber(v, 'Jumlah'),
                  ),
                ],
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              if (selectedUserId == null) {
                Helpers.showSnackBar(
                    context, 'Pilih anggota terlebih dahulu', isError: true);
                return;
              }
              final jumlah =
                  double.tryParse(jumlahCtrl.text.replaceAll(RegExp(r'\D'), '')) ?? 0;
              final currentUser = ref.read(authProvider).valueOrNull;
              Navigator.pop(ctx);
              await ref.read(simpananProvider.notifier).addSimpanan(
                    SimpananModel(
                      userId: selectedUserId!,
                      jenis: selectedJenis,
                      jumlah: jumlah,
                      adminId: currentUser?.id,
                      createdAt: DateTime.now(),
                      tanggal: DateTime.now(),
                    ),
                  );
              if (mounted) {
                Helpers.showSnackBar(context, 'Simpanan berhasil dicatat',
                    isSuccess: true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}


