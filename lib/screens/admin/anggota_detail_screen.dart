import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/simpanan_provider.dart';
import '../../providers/pinjaman_provider.dart';
import '../../providers/user_provider.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/status_badge.dart';
import '../../utils/helpers.dart';

class AnggotaDetailScreen extends ConsumerStatefulWidget {
  const AnggotaDetailScreen({super.key});

  @override
  ConsumerState<AnggotaDetailScreen> createState() =>
      _AnggotaDetailScreenState();
}

class _AnggotaDetailScreenState extends ConsumerState<AnggotaDetailScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final anggota = ModalRoute.of(context)!.settings.arguments as UserModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(anggota.nama),
        actions: [
          IconButton(
            icon: Icon(
              anggota.aktif ? Icons.block_rounded : Icons.check_circle_rounded,
              color: anggota.aktif ? Colors.orange : Colors.green,
            ),
            onPressed: () => _toggleStatus(anggota),
            tooltip: anggota.aktif ? 'Nonaktifkan' : 'Aktifkan',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(anggota),
          _buildTabs(),
          Expanded(
            child: _selectedTab == 0
                ? _buildSimpananTab(anggota.id!)
                : _buildPinjamanTab(anggota.id!),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel anggota) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              anggota.nama.isNotEmpty ? anggota.nama[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 28,
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
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  anggota.nomorAnggota,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(anggota.email,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          StatusBadge(status: anggota.aktif ? 'Aktif' : 'Nonaktif'),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTab('Simpanan', 0),
          _buildTab('Pinjaman', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpananTab(String userId) {
    final simpananAsync = ref.watch(simpananByUserProvider(userId));
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: StatCard(
                title: 'Total Simpanan',
                value: Formatters.formatRupiah(total),
                icon: Icons.account_balance_wallet_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final s = list[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: Text(s.labelJenis),
                      subtitle: Text(
                          Formatters.formatDate(s.tanggal ?? DateTime.now())),
                      trailing: Text(
                        Formatters.formatRupiah(s.jumlah),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
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

  Widget _buildPinjamanTab(String userId) {
    final pinjamanAsync = ref.watch(pinjamanByUserProvider(userId));
    return pinjamanAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return const EmptyWidget(
            message: 'Belum ada pinjaman',
            icon: Icons.monetization_on_outlined,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final p = list[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.monetization_on_rounded,
                    color: AppTheme.warningColor,
                  ),
                ),
                title: Text(Formatters.formatRupiah(p.jumlah)),
                subtitle: Text('Tenor: ${p.tenor} bulan'),
                trailing: StatusBadge(status: p.labelStatus),
              ),
            );
          },
        );
      },
      loading: () => const ShimmerLoading(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
    );
  }

  void _toggleStatus(UserModel anggota) async {
    final service = FirestoreService();
    if (anggota.aktif) {
      await service.nonaktifkanAnggota(anggota.id!);
      Helpers.showSnackBar(context, 'Anggota dinonaktifkan', isSuccess: true);
    } else {
      await service.aktifkanAnggota(anggota.id!);
      Helpers.showSnackBar(context, 'Anggota diaktifkan kembali',
          isSuccess: true);
    }
    ref.invalidate(anggotaListProvider);
  }
}
