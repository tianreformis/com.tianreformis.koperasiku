import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/simpanan_provider.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class RiwayatSimpananScreen extends ConsumerWidget {
  const RiwayatSimpananScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull;

    if (user == null) return const LoadingWidget();

    final simpananAsync = ref.watch(simpananByUserProvider(user.id!));

    return simpananAsync.when(
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
              padding: const EdgeInsets.all(20),
              color: AppTheme.primaryColor.withOpacity(0.05),
              child: Column(
                children: [
                  Text(
                    'Total Simpanan',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatRupiah(total),
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: AppTheme.primaryColor, fontSize: 28),
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
                          Formatters.formatDate(s.tanggal ?? DateTime.now())),
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
      error: (e, _) => AppErrorWidget(message: e.toString()),
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
}


