class AppConstants {
  static const String appName = 'KoperasiKu';
  static const String appVersion = '1.0.0';

  // Collection names
  static const String usersCollection = 'users';
  static const String simpananCollection = 'simpanan';
  static const String pinjamanCollection = 'pinjaman';
  static const String angsuranCollection = 'angsuran';
  static const String settingsCollection = 'settings';

  // Simpanan types
  static const String simpananPokok = 'pokok';
  static const String simpananWajib = 'wajib';
  static const String simpananSukarela = 'sukarela';

  // Pinjaman status
  static const String pinjamanPending = 'pending';
  static const String pinjamanAktif = 'aktif';
  static const String pinjamanLunas = 'lunas';
  static const String pinjamanDitolak = 'ditolak';

  // User roles
  static const String roleAdmin = 'admin';
  static const String roleAnggota = 'anggota';

  // Default values
  static const double simpananPokokAmount = 100000;
  static const double simpananWajibAmount = 50000;

  // Interest rates
  static const double bungaFlat = 0.12;
  static const double bungaMenurun = 0.10;

  // Shared Preferences keys
  static const String prefUserId = 'user_id';
  static const String prefUserRole = 'user_role';
  static const String prefIsLoggedIn = 'is_logged_in';
}
