import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/simpanan_provider.dart';
import '../../providers/pinjaman_provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_widget.dart';
import 'riwayat_simpanan_screen.dart';
import 'riwayat_pinjaman_screen.dart';

class AnggotaDashboardScreen extends ConsumerStatefulWidget {
  const AnggotaDashboardScreen({super.key});

  @override
  ConsumerState<AnggotaDashboardScreen> createState() =>
      _AnggotaDashboardScreenState();
}

class _AnggotaDashboardScreenState extends ConsumerState<AnggotaDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      const RiwayatSimpananScreen(),
      const RiwayatPinjamanScreen(),
      _buildProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0
            ? 'Dashboard Saya'
            : _currentIndex == 1
                ? 'Riwayat Simpanan'
                : _currentIndex == 2
                    ? 'Riwayat Pinjaman'
                    : 'Profil'),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Simpanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_rounded),
            label: 'Pinjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull;

    if (user == null) return const LoadingWidget();

    final simpananAsync = ref.watch(simpananByUserProvider(user.id!));
    final pinjamanAsync = ref.watch(pinjamanByUserProvider(user.id!));
    final angsuranAsync = ref.watch(angsuranByUserProvider(user.id!));

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.nama,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No. Anggota: ${user.nomorAnggota}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            simpananAsync.when(
              data: (simpananList) {
                final totalSimpanan =
                    simpananList.fold<double>(0, (sum, s) => sum + s.jumlah);
                return StatCard(
                  title: 'Total Simpanan Saya',
                  value: Formatters.formatRupiah(totalSimpanan),
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppTheme.primaryColor,
                  onTap: () => setState(() => _currentIndex = 1),
                );
              },
              loading: () => const CardShimmer(),
              error: (e, _) => StatCard(
                title: 'Total Simpanan Saya',
                value: 'Error',
                icon: Icons.account_balance_wallet_rounded,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 12),
            pinjamanAsync.when(
              data: (pinjamanList) {
                final aktif =
                    pinjamanList.where((p) => p.status == 'aktif').length;
                return StatCard(
                  title: 'Pinjaman Aktif',
                  value: '$aktif Pinjaman',
                  icon: Icons.monetization_on_rounded,
                  color: AppTheme.warningColor,
                  subtitle: aktif > 0
                      ? 'Lihat detail pinjaman'
                      : 'Tidak ada pinjaman aktif',
                  onTap: () => setState(() => _currentIndex = 2),
                );
              },
              loading: () => const CardShimmer(),
              error: (e, _) => StatCard(
                title: 'Pinjaman Aktif',
                value: 'Error',
                icon: Icons.monetization_on_rounded,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 12),
            angsuranAsync.when(
              data: (angsuranList) {
                final nextAngsuran = angsuranList
                    .where((a) => a.status != 'lunas')
                    .toList()
                    ..sort((a, b) => a.jatuhTempo.compareTo(b.jatuhTempo));
                final next = nextAngsuran.isNotEmpty ? nextAngsuran.first : null;

                return StatCard(
                  title: 'Angsuran Berikutnya',
                  value: next != null
                      ? Formatters.formatRupiah(next.jumlah)
                      : 'Tidak ada',
                  icon: Icons.calendar_today_rounded,
                  color: AppTheme.secondaryColor,
                  subtitle: next != null
                      ? 'Jatuh tempo: ${Formatters.formatDate(next.jatuhTempo)}'
                      : 'Semua angsuran lunas',
                );
              },
              loading: () => const CardShimmer(),
              error: (e, _) => StatCard(
                title: 'Angsuran Berikutnya',
                value: 'Error',
                icon: Icons.calendar_today_rounded,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.anggotaPengajuanPinjaman,
                ),
                icon: const Icon(Icons.add_circle_rounded),
                label: const Text('Ajukan Pinjaman Baru'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final authState = ref.watch(authProvider);
    return authState.when(
      data: (user) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                user?.nama.isNotEmpty == true
                    ? user!.nama[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.nama ?? 'Anggota',
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              user?.nomorAnggota ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Anggota',
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Informasi Profil',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.anggotaEditProfile),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (user?.noTelepon != null)
                      _ProfileItem(
                          icon: Icons.phone_rounded,
                          text: user!.noTelepon!),
                    if (user?.alamat != null)
                      _ProfileItem(
                          icon: Icons.location_on_rounded,
                          text: user!.alamat!),
                    _ProfileItem(
                        icon: Icons.calendar_today_rounded,
                        text: user?.createdAt != null
                            ? 'Bergabung ${Formatters.formatDate(user!.createdAt!)}'
                            : '-'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      loading: () => const LoadingWidget(),
      error: (e, _) => const LoadingWidget(),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProfileItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
