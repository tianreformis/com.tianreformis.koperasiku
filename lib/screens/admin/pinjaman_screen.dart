import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pinjaman_provider.dart';
import '../../models/pinjaman_model.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/status_badge.dart';

class PinjamanScreen extends ConsumerWidget {
  const PinjamanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinjamanAsync = ref.watch(allPinjamanProvider);

    return Scaffold(
      body: pinjamanAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyWidget(
              message: 'Belum ada pengajuan pinjaman',
              icon: Icons.monetization_on_outlined,
            );
          }

          final pending = list.where((p) => p.status == 'pending').length;
          final aktif = list.where((p) => p.status == 'aktif').length;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.primaryColor.withOpacity(0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Pending',
                      value: '$pending',
                      color: AppTheme.warningColor,
                    ),
                    _SummaryItem(
                      label: 'Aktif',
                      value: '$aktif',
                      color: AppTheme.primaryColor,
                    ),
                    _SummaryItem(
                      label: 'Total',
                      value: '${list.length}',
                      color: AppTheme.secondaryColor,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final p = list[index];
                    return _PinjamanCard(pinjaman: p);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const ShimmerLoading(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(allPinjamanProvider),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: color,
                fontSize: 24,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
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
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.adminPinjamanDetail,
          arguments: pinjaman,
        ),
        borderRadius: BorderRadius.circular(16),
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
                  const Icon(Icons.person_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    pinjaman.userId,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    pinjaman.createdAt != null
                        ? Formatters.formatDate(pinjaman.createdAt!)
                        : '-',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tenor: ${pinjaman.tenor} bulan | Bunga: ${(pinjaman.bunga * 100).toInt()}% ${pinjaman.jenisBunga}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
