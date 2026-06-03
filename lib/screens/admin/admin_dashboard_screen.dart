import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/simpanan_provider.dart';
import '../../providers/pinjaman_provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_widget.dart';
import 'anggota_management_screen.dart';
import 'simpanan_screen.dart';
import 'pinjaman_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      const AnggotaManagementScreen(),
      const SimpananScreen(),
      const PinjamanScreen(),
      _buildProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0
            ? 'Dashboard Admin'
            : _currentIndex == 1
                ? 'Anggota'
                : _currentIndex == 2
                    ? 'Simpanan'
                    : _currentIndex == 3
                        ? 'Pinjaman'
                        : 'Profil'),
        actions: [
          if (_currentIndex == 0) ...[
            IconButton(
              icon: const Icon(Icons.assessment_rounded),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.adminLaporan),
            ),
          ],
        ],
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
            icon: Icon(Icons.people_rounded),
            label: 'Anggota',
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
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ref.watch(totalAnggotaAktifProvider).when(
                  data: (total) => StatCard(
                    title: 'Total Anggota Aktif',
                    value: '$total Anggota',
                    icon: Icons.people_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  error: (e, _) => StatCard(
                    title: 'Total Anggota Aktif',
                    value: 'Error',
                    icon: Icons.people_rounded,
                    color: AppTheme.errorColor,
                  ),
                  loading: () => const CardShimmer(),
                ),
            const SizedBox(height: 12),
            ref.watch(totalSimpananHariIniProvider).when(
                  data: (total) => StatCard(
                    title: 'Total Simpanan Hari Ini',
                    value: Formatters.formatRupiah(total),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppTheme.secondaryColor,
                  ),
                  error: (e, _) => StatCard(
                    title: 'Total Simpanan Hari Ini',
                    value: 'Error',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppTheme.errorColor,
                  ),
                  loading: () => const CardShimmer(),
                ),
            const SizedBox(height: 12),
            ref.watch(totalPinjamanBerjalanProvider).when(
                  data: (total) => StatCard(
                    title: 'Total Pinjaman Berjalan',
                    value: Formatters.formatRupiah(total),
                    icon: Icons.monetization_on_rounded,
                    color: AppTheme.warningColor,
                  ),
                  error: (e, _) => StatCard(
                    title: 'Total Pinjaman Berjalan',
                    value: 'Error',
                    icon: Icons.monetization_on_rounded,
                    color: AppTheme.errorColor,
                  ),
                  loading: () => const CardShimmer(),
                ),
            const SizedBox(height: 24),
            Text(
              'Grafik Bulanan',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simpanan & Pinjaman',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildChart(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final simpananAsync = ref.watch(simpananBulananProvider);
    final pinjamanAsync = ref.watch(pinjamanBulananProvider);

    return simpananAsync.when(
      data: (simpananData) => pinjamanAsync.when(
        data: (pinjamanData) {
          final spotData = <FlSpot>[];
          final pinjamanSpotData = <FlSpot>[];

          for (int i = 1; i <= 12; i++) {
            final month = i.toString().padLeft(2, '0');
            final simpananVal = (simpananData[month] ?? 0);
            final pinjamanVal = (pinjamanData[month] ?? 0);
            spotData.add(FlSpot(i.toDouble(), simpananVal / 1000000));
            pinjamanSpotData.add(FlSpot(i.toDouble(), pinjamanVal / 1000000));
          }

          final maxY = [
            ...spotData.map((e) => e.y),
            ...pinjamanSpotData.map((e) => e.y),
          ].reduce((a, b) => a > b ? a : b);

          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY > 0 ? maxY / 4 : 1,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}jt',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final months = [
                        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
                      ];
                      return Text(
                        months[value.toInt()],
                        style: const TextStyle(fontSize: 9),
                      );
                    },
                    reservedSize: 22,
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 1,
              maxX: 12,
              minY: 0,
              maxY: maxY > 0 ? maxY * 1.2 : 10,
              lineBarsData: [
                LineChartBarData(
                  spots: spotData,
                  isCurved: true,
                  color: AppTheme.primaryColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: pinjamanSpotData,
                  isCurved: true,
                  color: AppTheme.warningColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Error grafik')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('Error grafik')),
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
                    : 'A',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.nama ?? 'Admin',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 20,
                  ),
            ),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Administrator',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
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
