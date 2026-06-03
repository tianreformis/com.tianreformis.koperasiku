class PinjamanModel {
  final String? id;
  final String userId;
  final double jumlah;
  final double bunga;
  final String jenisBunga;
  final int tenor;
  final double angsuranPerBulan;
  final double totalBayar;
  final String status;
  final String? keterangan;
  final String? dokumenUrl;
  final String? adminId;
  final DateTime? createdAt;
  final DateTime? disetujuiAt;
  final DateTime? jatuhTempo;

  PinjamanModel({
    this.id,
    required this.userId,
    required this.jumlah,
    this.bunga = 0.12,
    this.jenisBunga = 'flat',
    required this.tenor,
    this.angsuranPerBulan = 0,
    this.totalBayar = 0,
    this.status = 'pending',
    this.keterangan,
    this.dokumenUrl,
    this.adminId,
    this.createdAt,
    this.disetujuiAt,
    this.jatuhTempo,
  });

  factory PinjamanModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return PinjamanModel(
      id: id,
      userId: data['userId'] ?? '',
      jumlah: (data['jumlah'] ?? 0).toDouble(),
      bunga: (data['bunga'] ?? 0.12).toDouble(),
      jenisBunga: data['jenisBunga'] ?? 'flat',
      tenor: data['tenor'] ?? 1,
      angsuranPerBulan: (data['angsuranPerBulan'] ?? 0).toDouble(),
      totalBayar: (data['totalBayar'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      keterangan: data['keterangan'],
      dokumenUrl: data['dokumenUrl'],
      adminId: data['adminId'],
      createdAt: data['createdAt']?.toDate(),
      disetujuiAt: data['disetujuiAt']?.toDate(),
      jatuhTempo: data['jatuhTempo']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'jumlah': jumlah,
      'bunga': bunga,
      'jenisBunga': jenisBunga,
      'tenor': tenor,
      'angsuranPerBulan': angsuranPerBulan,
      'totalBayar': totalBayar,
      'status': status,
      'keterangan': keterangan,
      'dokumenUrl': dokumenUrl,
      'adminId': adminId,
      'createdAt': createdAt ?? DateTime.now(),
      'disetujuiAt': disetujuiAt,
      'jatuhTempo': jatuhTempo,
    };
  }

  String get labelStatus {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'aktif':
        return 'Aktif';
      case 'lunas':
        return 'Lunas';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  double get sisaPinjaman {
    return totalBayar - (angsuranPerBulan * tenor);
  }

  PinjamanModel copyWith({
    String? id,
    String? userId,
    double? jumlah,
    double? bunga,
    String? jenisBunga,
    int? tenor,
    double? angsuranPerBulan,
    double? totalBayar,
    String? status,
    String? keterangan,
    String? dokumenUrl,
    String? adminId,
    DateTime? createdAt,
    DateTime? disetujuiAt,
    DateTime? jatuhTempo,
  }) {
    return PinjamanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jumlah: jumlah ?? this.jumlah,
      bunga: bunga ?? this.bunga,
      jenisBunga: jenisBunga ?? this.jenisBunga,
      tenor: tenor ?? this.tenor,
      angsuranPerBulan: angsuranPerBulan ?? this.angsuranPerBulan,
      totalBayar: totalBayar ?? this.totalBayar,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
      dokumenUrl: dokumenUrl ?? this.dokumenUrl,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt,
      disetujuiAt: disetujuiAt ?? this.disetujuiAt,
      jatuhTempo: jatuhTempo ?? this.jatuhTempo,
    );
  }
}
