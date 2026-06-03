class UserModel {
  final String? id;
  final String nomorAnggota;
  final String nama;
  final String email;
  final String? noTelepon;
  final String? alamat;
  final String role;
  final bool aktif;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? fotoUrl;
  final String? ktpUrl;
  final double totalSimpanan;
  final double totalPinjaman;

  UserModel({
    this.id,
    required this.nomorAnggota,
    required this.nama,
    required this.email,
    this.noTelepon,
    this.alamat,
    this.role = 'anggota',
    this.aktif = true,
    this.createdAt,
    this.updatedAt,
    this.fotoUrl,
    this.ktpUrl,
    this.totalSimpanan = 0,
    this.totalPinjaman = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return UserModel(
      id: id,
      nomorAnggota: data['nomorAnggota'] ?? '',
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      noTelepon: data['noTelepon'],
      alamat: data['alamat'],
      role: data['role'] ?? 'anggota',
      aktif: data['aktif'] ?? true,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      fotoUrl: data['fotoUrl'],
      ktpUrl: data['ktpUrl'],
      totalSimpanan: (data['totalSimpanan'] ?? 0).toDouble(),
      totalPinjaman: (data['totalPinjaman'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomorAnggota': nomorAnggota,
      'nama': nama,
      'email': email,
      'noTelepon': noTelepon,
      'alamat': alamat,
      'role': role,
      'aktif': aktif,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': DateTime.now(),
      'fotoUrl': fotoUrl,
      'ktpUrl': ktpUrl,
      'totalSimpanan': totalSimpanan,
      'totalPinjaman': totalPinjaman,
    };
  }

  UserModel copyWith({
    String? id,
    String? nomorAnggota,
    String? nama,
    String? email,
    String? noTelepon,
    String? alamat,
    String? role,
    bool? aktif,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fotoUrl,
    String? ktpUrl,
    double? totalSimpanan,
    double? totalPinjaman,
  }) {
    return UserModel(
      id: id ?? this.id,
      nomorAnggota: nomorAnggota ?? this.nomorAnggota,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noTelepon: noTelepon ?? this.noTelepon,
      alamat: alamat ?? this.alamat,
      role: role ?? this.role,
      aktif: aktif ?? this.aktif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      ktpUrl: ktpUrl ?? this.ktpUrl,
      totalSimpanan: totalSimpanan ?? this.totalSimpanan,
      totalPinjaman: totalPinjaman ?? this.totalPinjaman,
    );
  }
}
