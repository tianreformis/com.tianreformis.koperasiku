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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Simulasi Angsuran',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Divider(),
                        _SimulasiRow(
                          label: 'Jumlah Pinjaman',
                          value: _jumlahController.text.isNotEmpty
                              ? Formatters.formatRupiah(double.parse(
                                  _jumlahController.text.replaceAll('.', '')))
                              : 'Rp 0',
                        ),
                        _SimulasiRow(
                          label: 'Tenor',
                          value: '$_tenor bulan',
                        ),
                        _SimulasiRow(
                          label: 'Angsuran/Bulan',
                          value: _jumlahController.text.isNotEmpty
                              ? Formatters.formatRupiah(_hitungAngsuran(
                                  double.parse(_jumlahController.text
                                      .replaceAll('.', '')),
                                  _tenor,
                                  _jenisBunga == 'flat' ? 0.12 : 0.10,
                                  _jenisBunga,
                                ))
                              : 'Rp 0',
                          isBold: true,
                        ),
                        _SimulasiRow(
                          label: 'Total Bayar',
                          value: _jumlahController.text.isNotEmpty
                              ? Formatters.formatRupiah(
                                  _hitungAngsuran(
                                        double.parse(_jumlahController.text
                                            .replaceAll('.', '')),
                                        _tenor,
                                        _jenisBunga == 'flat' ? 0.12 : 0.10,
                                        _jenisBunga,
                                      ) *
                                      _tenor)
                              : 'Rp 0',
                        ),
                      ],
                    ),
                  ),
                ),
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
