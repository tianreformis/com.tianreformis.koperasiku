import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pinjaman_provider.dart';
import '../../models/pinjaman_model.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/rupiah_input.dart';

class PengajuanPinjamanScreen extends ConsumerStatefulWidget {
  const PengajuanPinjamanScreen({super.key});

  @override
  ConsumerState<PengajuanPinjamanScreen> createState() =>
      _PengajuanPinjamanScreenState();
}

class _PengajuanPinjamanScreenState
    extends ConsumerState<PengajuanPinjamanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  String _jenisBunga = 'flat';
  int _tenor = 6;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _jumlahController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final user = authState.valueOrNull;

      if (user == null) {
        Helpers.showSnackBar(context, 'Silakan login terlebih dahulu',
            isError: true);
        return;
      }

      final jumlah = double.parse(
          _jumlahController.text.replaceAll('.', '').replaceAll(',', '.'));
      final bunga = _jenisBunga == 'flat' ? 0.12 : 0.10;
      final angsuranPerBulan = _hitungAngsuran(jumlah, _tenor, bunga, _jenisBunga);
      final totalBayar = angsuranPerBulan * _tenor;

      final pinjaman = PinjamanModel(
        userId: user.id!,
        jumlah: jumlah,
        bunga: bunga,
        jenisBunga: _jenisBunga,
        tenor: _tenor,
        angsuranPerBulan: angsuranPerBulan,
        totalBayar: totalBayar,
        status: 'pending',
        keterangan: _keteranganController.text.isNotEmpty
            ? _keteranganController.text
            : null,
        createdAt: DateTime.now(),
      );

      await ref.read(pinjamanProvider.notifier).addPinjaman(pinjaman);

      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Pengajuan pinjaman berhasil dikirim! Silakan tunggu persetujuan admin.',
          isSuccess: true,
        );
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

  double _hitungAngsuran(
      double jumlah, int tenor, double bunga, String jenisBunga) {
    final pokokPerBulan = jumlah / tenor;
    if (jenisBunga == 'flat') {
      final bungaPerBulan = jumlah * bunga / 12;
      return double.parse((pokokPerBulan + bungaPerBulan).toStringAsFixed(0));
    } else {
      final bungaTotal = jumlah * bunga;
      return double.parse(
          ((jumlah + bungaTotal) / tenor).toStringAsFixed(0));
    }
  }

  List<Map<String, dynamic>> _hitungAngsuranDetail() {
    final jumlah = double.tryParse(
        _jumlahController.text.replaceAll('.', '').replaceAll(',', '.'));
    if (jumlah == null || jumlah < 500000) return [];
    final bunga = _jenisBunga == 'flat' ? 0.12 : 0.10;
    final pokokPerBulan = jumlah / _tenor;
    final List<Map<String, dynamic>> result = [];
    for (int i = 1; i <= _tenor; i++) {
      double angsuran;
      if (_jenisBunga == 'flat') {
        final bungaPerBulan = jumlah * bunga / 12;
        angsuran = pokokPerBulan + bungaPerBulan;
      } else {
        final sisaPinjaman = jumlah - (pokokPerBulan * (i - 1));
        final bungaPerBulan = sisaPinjaman * bunga / 12;
        angsuran = pokokPerBulan + bungaPerBulan;
      }
      result.add({
        'ke': i,
        'angsuran': double.parse(angsuran.toStringAsFixed(0)),
        'pokok': double.parse(pokokPerBulan.toStringAsFixed(0)),
      });
    }
    return result;
  }

  Widget _buildSimulasi() {
    final jumlah = double.tryParse(
        _jumlahController.text.replaceAll('.', '').replaceAll(',', '.'));
    if (jumlah == null || jumlah < 500000) return const SizedBox.shrink();
    final bunga = _jenisBunga == 'flat' ? 0.12 : 0.10;
    final angsuranPerBulan = _hitungAngsuran(jumlah, _tenor, bunga, _jenisBunga);
    final totalBayar = angsuranPerBulan * _tenor;
    final detail = _hitungAngsuranDetail();
    final totalBunga = detail.fold<double>(0, (s, d) => s + (d['angsuran'] as double) - (d['pokok'] as double));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text('Simulasi Angsuran',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const Divider(),
            _SimulasiRow(label: 'Jumlah Pinjaman',
                value: Formatters.formatRupiah(jumlah)),
            _SimulasiRow(label: 'Tenor', value: '$_tenor bulan'),
            _SimulasiRow(label: 'Bunga ${_jenisBunga == 'flat' ? 'Flat 12%' : 'Menurun 10%'}',
                value: Formatters.formatRupiah(totalBunga)),
            _SimulasiRow(label: 'Angsuran/Bulan',
                value: Formatters.formatRupiah(angsuranPerBulan),
                isBold: true),
            _SimulasiRow(label: 'Total Bayar',
                value: Formatters.formatRupiah(totalBayar)),
            if (detail.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Detail Angsuran',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade200, width: 0.5),
                    columnWidths: const {
                      0: FlexColumnWidth(0.8),
                      1: FlexColumnWidth(1.2),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                        children: const [
                          _TableCell('Bln', isHeader: true),
                          _TableCell('Angsuran', isHeader: true),
                          _TableCell('Pokok', isHeader: true),
                        ],
                      ),
                      ...detail.map((d) => TableRow(
                        children: [
                          _TableCell('${d['ke']}'),
                          _TableCell(Formatters.formatRupiah(d['angsuran'] as double)),
                          _TableCell(Formatters.formatRupiah(d['pokok'] as double)),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Pinjaman')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Form Pengajuan Pinjaman',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Isi data dengan lengkap untuk pengajuan pinjaman',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              RupiahInput(
                controller: _jumlahController,
                label: 'Jumlah Pinjaman',
                hint: 'Rp 1.000.000',
                validator: (v) => Validators.minimalAmount(v, 'Jumlah', 500000),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _tenor,
                decoration: const InputDecoration(
                  labelText: 'Tenor (Lama Pinjaman)',
                  prefixIcon: Icon(Icons.schedule_rounded),
                ),
                items: [3, 6, 9, 12].map((tenor) {
                  return DropdownMenuItem(
                    value: tenor,
                    child: Text('$tenor bulan'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _tenor = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _jenisBunga,
                decoration: const InputDecoration(
                  labelText: 'Jenis Bunga',
                  prefixIcon: Icon(Icons.percent_rounded),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'flat',
                    child: Text('Flat (12% / tahun)'),
                  ),
                  DropdownMenuItem(
                    value: 'menurun',
                    child: Text('Menurun (10% / tahun)'),
                  ),
                ],
                onChanged: (v) => setState(() => _jenisBunga = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keteranganController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                  hintText: 'Tujuan pinjaman, dll',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              if (_jumlahController.text.isNotEmpty)
                _buildSimulasi(),
              const SizedBox(height: 24),
              LoadingButton(
                label: 'Ajukan Pinjaman',
                onPressed: _submit,
                isLoading: _isLoading,
                icon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          color: isHeader ? AppTheme.primaryColor : null,
        ),
      ),
    );
  }
}

class _SimulasiRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SimulasiRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold ? AppTheme.primaryColor : null,
                ),
          ),
        ],
      ),
    );
  }
}
