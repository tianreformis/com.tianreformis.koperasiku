class SimpananModel {
  final String? id;
  final String userId;
  final String jenis;
  final double jumlah;
  final DateTime? tanggal;
  final String? keterangan;
  final String? adminId;
  final DateTime? createdAt;

  SimpananModel({
    this.id,
    required this.userId,
    required this.jenis,
    required this.jumlah,
    this.tanggal,
    this.keterangan,
    this.adminId,
    this.createdAt,
  });

  factory SimpananModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return SimpananModel(
      id: id,
      userId: data['userId'] ?? '',
      jenis: data['jenis'] ?? '',
      jumlah: (data['jumlah'] ?? 0).toDouble(),
      tanggal: data['tanggal']?.toDate(),
      keterangan: data['keterangan'],
      adminId: data['adminId'],
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'jenis': jenis,
      'jumlah': jumlah,
      'tanggal': tanggal ?? DateTime.now(),
      'keterangan': keterangan,
      'adminId': adminId,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  String get labelJenis {
    switch (jenis) {
      case 'pokok':
        return 'Simpanan Pokok';
      case 'wajib':
        return 'Simpanan Wajib';
      case 'sukarela':
        return 'Simpanan Sukarela';
      default:
        return 'Simpanan';
    }
  }
}
