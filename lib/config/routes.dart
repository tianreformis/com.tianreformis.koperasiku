import 'package:flutter/material.dart';
import '../screens/shared/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/anggota_management_screen.dart';
import '../screens/admin/anggota_detail_screen.dart';
import '../screens/admin/simpanan_screen.dart';
import '../screens/admin/pinjaman_screen.dart';
import '../screens/admin/pinjaman_detail_screen.dart';
import '../screens/admin/laporan_screen.dart';
import '../screens/anggota/anggota_dashboard_screen.dart';
import '../screens/anggota/riwayat_simpanan_screen.dart';
import '../screens/anggota/riwayat_pinjaman_screen.dart';
import '../screens/anggota/pengajuan_pinjaman_screen.dart';
import '../screens/anggota/edit_profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminAnggota = '/admin/anggota';
  static const String adminAnggotaDetail = '/admin/anggota/detail';
  static const String adminSimpanan = '/admin/simpanan';
  static const String adminPinjaman = '/admin/pinjaman';
  static const String adminPinjamanDetail = '/admin/pinjaman/detail';
  static const String adminLaporan = '/admin/laporan';

  // Anggota
  static const String anggotaDashboard = '/anggota/dashboard';
  static const String anggotaRiwayatSimpanan = '/anggota/riwayat-simpanan';
  static const String anggotaRiwayatPinjaman = '/anggota/riwayat-pinjaman';
  static const String anggotaPengajuanPinjaman = '/anggota/pengajuan-pinjaman';
  static const String anggotaEditProfile = '/anggota/edit-profil';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
      adminAnggota: (context) => const AnggotaManagementScreen(),
      adminAnggotaDetail: (context) => const AnggotaDetailScreen(),
      adminSimpanan: (context) => const SimpananScreen(),
      adminPinjaman: (context) => const PinjamanScreen(),
      adminPinjamanDetail: (context) => const PinjamanDetailScreen(),
      adminLaporan: (context) => const LaporanScreen(),
      anggotaDashboard: (context) => const AnggotaDashboardScreen(),
      anggotaRiwayatSimpanan: (context) => const RiwayatSimpananScreen(),
      anggotaRiwayatPinjaman: (context) => const RiwayatPinjamanScreen(),
      anggotaPengajuanPinjaman: (context) => const PengajuanPinjamanScreen(),
      anggotaEditProfile: (context) => const EditProfileScreen(),
    };
  }
}
