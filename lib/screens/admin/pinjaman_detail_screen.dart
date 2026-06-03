import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pinjaman_model.dart';
import '../../models/angsuran_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/pinjaman_provider.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/status_badge.dart';
import '../../utils/helpers.dart';

class PinjamanDetailScreen extends ConsumerStatefulWidget {
  const PinjamanDetailScreen({super.key});

  @override
  ConsumerState<PinjamanDetailScreen> createState() =>
      _PinjamanDetailScreenState();
}

class _PinjamanDetailScreenState extends ConsumerState<PinjamanDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final pinjaman = ModalRoute.of(context)!.settings.arguments as PinjamanModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pinjaman')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(pinjaman),
            const SizedBox(height: 16),
            if (pinjaman.status == 'pending') _buildActionButtons(pinjaman),
            if (pinjaman.status == 'aktif') _buildAngsuranSection(pinjaman),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(PinjamanModel pinjaman) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Pinjaman',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 16,
                      ),
                ),
                StatusBadge(status: pinjaman.labelStatus),
              ],
            ),
            const Divider(),
            _InfoRow(label: 'Jumlah', value: Formatters.formatRupiah(pinjaman.jumlah)),
            _InfoRow(
                label: 'Angsuran/Bulan',
                value: Formatters.formatRupiah(pinjaman.angsuranPerBulan)),
            _InfoRow(label: 'Tenor', value: '${pinjaman.tenor} bulan'),
            _InfoRow(
                label: 'Bunga',
                value:
                    '${(pinjaman.bunga * 100).toInt()}% (${pinjaman.jenisBunga})'),
            _InfoRow(
                label: 'Total Bayar',
                value: Formatters.formatRupiah(pinjaman.totalBayar)),
            if (pinjaman.createdAt != null)
              _InfoRow(
                  label: 'Tanggal Pengajuan',
                  value: Formatters.formatDate(pinjaman.createdAt!)),
            if (pinjaman.keterangan != null && pinjaman.keterangan!.isNotEmpty)
              _InfoRow(label: 'Keterangan', value: pinjaman.keterangan!),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(PinjamanModel pinjaman) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aksi',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approvePinjaman(pinjaman),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Setujui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _tolakPinjaman(pinjaman),
                    icon: const Icon(Icons.cancel_rounded),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAngsuranSection(PinjamanModel pinjaman) {
    final angsuranAsync = ref.watch(angsuranByPinjamanProvider(pinjaman.id!));

    return angsuranAsync.when(
      data: (angsuranList) {
        final totalDibayar = angsuranList
            .where((a) => a.status == 'lunas')
            .fold<double>(0, (sum, a) => sum + (a.dibayar ?? 0));
        final sisaAngsuran =
            angsuranList.where((a) => a.status != 'lunas').length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AngsuranSummary(
                        label: 'Dibayar',
                        value: '$totalDibayar',
                        color: Colors.green),
                    _AngsuranSummary(
                        label: 'Sisa',
                        value: '$sisaAngsuran',
                        color: AppTheme.warningColor),
                    _AngsuranSummary(
                        label: 'Total',
                        value: '${angsuranList.length}',
                        color: AppTheme.primaryColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Jadwal Angsuran',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 8),
            ...angsuranList.map((angsuran) => _AngsuranItem(
                  angsuran: angsuran,
                  onBayar: () => _bayarAngsuran(angsuran),
                )),
          ],
        );
      },
      loading: () => const ShimmerLoading(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
    );
  }

  Future<void> _approvePinjaman(PinjamanModel pinjaman) async {
    try {
      await ref.read(pinjamanProvider.notifier).approvePinjaman(
            pinjaman.id!,
            'admin',
          );
      if (mounted) {
        Helpers.showSnackBar(context, 'Pinjaman disetujui', isSuccess: true);
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  Future<void> _tolakPinjaman(PinjamanModel pinjaman) async {
    final alasanCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Pinjaman'),
        content: TextField(
          controller: alasanCtrl,
          decoration: const InputDecoration(
            labelText: 'Alasan penolakan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, alasanCtrl.text),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(pinjamanProvider.notifier).tolakPinjaman(
            pinjaman.id!,
            'admin',
            result,
          );
      if (mounted) {
        Helpers.showSnackBar(context, 'Pinjaman ditolak', isSuccess: true);
      }
    }
  }

  Future<void> _bayarAngsuran(AngsuranModel angsuran) async {
    try {
      await ref.read(pinjamanProvider.notifier).bayarAngsuran(
            angsuran.id!,
            angsuran.jumlah,
          );
      if (mounted) {
        Helpers.showSnackBar(
            context, 'Pembayaran angsuran berhasil', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _AngsuranSummary extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AngsuranSummary({
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
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(color: color, fontSize: 20),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _AngsuranItem extends StatelessWidget {
  final AngsuranModel angsuran;
  final VoidCallback onBayar;

  const _AngsuranItem({required this.angsuran, required this.onBayar});

  @override
  Widget build(BuildContext context) {
    final isLate = angsuran.status != 'lunas' &&
        angsuran.jatuhTempo.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: angsuran.status == 'lunas'
              ? Colors.green.withOpacity(0.1)
              : isLate
                  ? Colors.red.withOpacity(0.1)
                  : AppTheme.warningColor.withOpacity(0.1),
          child: Icon(
            angsuran.status == 'lunas'
                ? Icons.check_circle_rounded
                : Icons.pending_rounded,
            color: angsuran.status == 'lunas'
                ? Colors.green
                : isLate
                    ? Colors.red
                    : AppTheme.warningColor,
          ),
        ),
        title: Text('Angsuran ke-${angsuran.angsuranKe}'),
        subtitle: Text(
          'Jatuh tempo: ${Formatters.formatDate(angsuran.jatuhTempo)}',
          style: TextStyle(
            color: isLate ? Colors.red : null,
            fontWeight: isLate ? FontWeight.w600 : null,
          ),
        ),
        trailing: angsuran.status == 'lunas'
            ? Text(
                'Lunas',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              )
            : ElevatedButton(
                onPressed: onBayar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Bayar'),
              ),
      ),
    );
  }
}
