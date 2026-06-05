import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/pdf_service.dart';
import '../../services/firestore_service.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_button.dart';

class LaporanScreen extends ConsumerStatefulWidget {
  const LaporanScreen({super.key});

  @override
  ConsumerState<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends ConsumerState<LaporanScreen> {
  final _pdfService = PdfService();
  final _firestore = FirestoreService();
  bool _isExportingSimpanan = false;
  bool _isExportingPinjaman = false;
  bool _isExportingAngsuran = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Laporan',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih jenis laporan yang ingin di-export ke PDF',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildLaporanCard(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Laporan Simpanan',
              subtitle: 'Export data simpanan bulanan',
              color: AppTheme.primaryColor,
              isLoading: _isExportingSimpanan,
              onExport: () => _exportLaporanSimpanan(),
            ),
            const SizedBox(height: 12),
            _buildLaporanCard(
              icon: Icons.monetization_on_rounded,
              title: 'Laporan Pinjaman',
              subtitle: 'Export data pinjaman & angsuran',
              color: AppTheme.warningColor,
              isLoading: _isExportingPinjaman,
              onExport: () => _exportLaporanPinjaman(),
            ),
            const SizedBox(height: 12),
            _buildLaporanCard(
              icon: Icons.receipt_long_rounded,
              title: 'Laporan Angsuran',
              subtitle: 'Export data pembayaran angsuran',
              color: AppTheme.secondaryColor,
              isLoading: _isExportingAngsuran,
              onExport: () => _exportLaporanAngsuran(),
            ),
            const SizedBox(height: 32),
            Text(
              'Ringkasan Keuangan',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 16),
            _buildNeracaCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLaporanCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isLoading,
    required VoidCallback onExport,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: LoadingButton(
                label: 'Export',
                onPressed: onExport,
                isLoading: isLoading,
                backgroundColor: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeracaCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Neraca Keuangan Sederhana',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Divider(),
            const SizedBox(height: 8),
            FutureBuilder(
              future: Future.wait([
                _firestore.getTotalSimpananHariIni(),
                _firestore.getTotalPinjamanBerjalan(),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final totalSimpanan = snapshot.data![0];
                final totalPinjaman = snapshot.data![1];

                return Column(
                  children: [
                    _NeracaRow(
                      label: 'Total Simpanan',
                      value: Formatters.formatRupiah(totalSimpanan),
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    _NeracaRow(
                      label: 'Total Pinjaman Berjalan',
                      value: Formatters.formatRupiah(totalPinjaman),
                      color: AppTheme.warningColor,
                    ),
                    const Divider(thickness: 2),
                    _NeracaRow(
                      label: 'Selisih',
                      value: Formatters.formatRupiah(
                          totalSimpanan - totalPinjaman),
                      color: totalSimpanan >= totalPinjaman
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportLaporanSimpanan() async {
    setState(() => _isExportingSimpanan = true);
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      final data = await _firestore.getSimpananByDateRange(
          startOfMonth, endOfMonth);
      final file = await _pdfService.generateLaporanSimpanan(
        simpananList: data,
        namaKoperasi: 'KoperasiKu',
        periode: Formatters.formatMonthYear(now),
      );
      await _pdfService.openPdf(file);
      if (mounted) {
        Helpers.showSnackBar(context, 'Laporan berhasil di-export',
            isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
            context, 'Gagal export laporan: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isExportingSimpanan = false);
    }
  }

  Future<void> _exportLaporanPinjaman() async {
    setState(() => _isExportingPinjaman = true);
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      final data = await _firestore.getPinjamanByDateRange(
          startOfMonth, endOfMonth);
      final file = await _pdfService.generateLaporanPinjaman(
        pinjamanList: data,
        namaKoperasi: 'KoperasiKu',
        periode: Formatters.formatMonthYear(now),
      );
      await _pdfService.openPdf(file);
      if (mounted) {
        Helpers.showSnackBar(context, 'Laporan berhasil di-export',
            isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
            context, 'Gagal export laporan: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isExportingPinjaman = false);
    }
  }

  Future<void> _exportLaporanAngsuran() async {
    setState(() => _isExportingAngsuran = true);
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      final data = await _firestore.getAngsuranByDateRange(
          startOfMonth, endOfMonth);
      final file = await _pdfService.generateLaporanAngsuran(
        angsuranList: data,
        namaKoperasi: 'KoperasiKu',
        periode: Formatters.formatMonthYear(now),
      );
      await _pdfService.openPdf(file);
      if (mounted) {
        Helpers.showSnackBar(context, 'Laporan berhasil di-export',
            isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
            context, 'Gagal export laporan: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isExportingAngsuran = false);
    }
  }
}

class _NeracaRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NeracaRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
