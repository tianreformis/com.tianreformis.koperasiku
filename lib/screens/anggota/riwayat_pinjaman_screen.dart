import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pinjaman_provider.dart';
import '../../models/pinjaman_model.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/status_badge.dart';

class RiwayatPinjamanScreen extends ConsumerWidget {
  const RiwayatPinjamanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull;

    if (user == null) return const LoadingWidget();

    final pinjamanAsync = ref.watch(pinjamanByUserProvider(user.id!));

    return pinjamanAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return EmptyWidget(
            message: 'Belum ada pinjaman',
            icon: Icons.monetization_on_outlined,
            action: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajukan Pinjaman'),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final p = list[index];
            return _PinjamanCard(pinjaman: p);
          },
        );
      },
      loading: () => const ShimmerLoading(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
    );
  }
}

class _PinjamanCard extends StatelessWidget {
  final PinjamanModel pinjaman;

  const _PinjamanCard({required this.pinjaman});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.formatRupiah(pinjaman.jumlah),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 18, color: AppTheme.primaryColor),
                ),
                StatusBadge(status: pinjaman.labelStatus),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  pinjaman.createdAt != null
                      ? Formatters.formatDate(pinjaman.createdAt!)
                      : '-',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${pinjaman.tenor} bulan',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (pinjaman.status == 'aktif') ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: pinjaman.sisaPinjaman / pinjaman.totalBayar,
                backgroundColor: Colors.grey.shade200,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 4),
              Text(
                'Sisa: ${Formatters.formatRupiah(pinjaman.totalBayar - pinjaman.sisaPinjaman)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            if (pinjaman.status == 'ditolak' &&
                pinjaman.keterangan != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pinjaman.keterangan!,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
