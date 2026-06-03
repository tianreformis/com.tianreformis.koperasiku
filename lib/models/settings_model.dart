class SettingsModel {
  final String? id;
  final String namaKoperasi;
  final String alamat;
  final String? noTelepon;
  final String? email;
  final double simpananPokok;
  final double simpananWajib;
  final double bungaFlat;
  final double bungaMenurun;
  final int maxTenor;
  final double maxPinjaman;
  final String? logoUrl;

  SettingsModel({
    this.id,
    this.namaKoperasi = 'KoperasiKu',
    this.alamat = '',
    this.noTelepon,
    this.email,
    this.simpananPokok = 100000,
    this.simpananWajib = 50000,
    this.bungaFlat = 0.12,
    this.bungaMenurun = 0.10,
    this.maxTenor = 12,
    this.maxPinjaman = 10000000,
    this.logoUrl,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return SettingsModel(
      id: id,
      namaKoperasi: data['namaKoperasi'] ?? 'KoperasiKu',
      alamat: data['alamat'] ?? '',
      noTelepon: data['noTelepon'],
      email: data['email'],
      simpananPokok: (data['simpananPokok'] ?? 100000).toDouble(),
      simpananWajib: (data['simpananWajib'] ?? 50000).toDouble(),
      bungaFlat: (data['bungaFlat'] ?? 0.12).toDouble(),
      bungaMenurun: (data['bungaMenurun'] ?? 0.10).toDouble(),
      maxTenor: data['maxTenor'] ?? 12,
      maxPinjaman: (data['maxPinjaman'] ?? 10000000).toDouble(),
      logoUrl: data['logoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaKoperasi': namaKoperasi,
      'alamat': alamat,
      'noTelepon': noTelepon,
      'email': email,
      'simpananPokok': simpananPokok,
      'simpananWajib': simpananWajib,
      'bungaFlat': bungaFlat,
      'bungaMenurun': bungaMenurun,
      'maxTenor': maxTenor,
      'maxPinjaman': maxPinjaman,
      'logoUrl': logoUrl,
    };
  }
}
