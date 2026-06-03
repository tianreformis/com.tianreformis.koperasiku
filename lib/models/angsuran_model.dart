class AngsuranModel {
  final String? id;
  final String pinjamanId;
  final String userId;
  final int angsuranKe;
  final double jumlah;
  final double? dibayar;
  final DateTime jatuhTempo;
  final DateTime? tanggalBayar;
  final String status;
  final String? keterangan;

  AngsuranModel({
    this.id,
    required this.pinjamanId,
    required this.userId,
    required this.angsuranKe,
    required this.jumlah,
    this.dibayar,
    required this.jatuhTempo,
    this.tanggalBayar,
    this.status = 'belum',
    this.keterangan,
  });

  factory AngsuranModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return AngsuranModel(
      id: id,
      pinjamanId: data['pinjamanId'] ?? '',
      userId: data['userId'] ?? '',
      angsuranKe: data['angsuranKe'] ?? 0,
      jumlah: (data['jumlah'] ?? 0).toDouble(),
      dibayar: (data['dibayar'] ?? 0).toDouble(),
      jatuhTempo: (data['jatuhTempo']?.toDate()) ?? DateTime.now(),
      tanggalBayar: data['tanggalBayar']?.toDate(),
      status: data['status'] ?? 'belum',
      keterangan: data['keterangan'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pinjamanId': pinjamanId,
      'userId': userId,
      'angsuranKe': angsuranKe,
      'jumlah': jumlah,
      'dibayar': dibayar ?? 0,
      'jatuhTempo': jatuhTempo,
      'tanggalBayar': tanggalBayar,
      'status': status,
      'keterangan': keterangan,
    };
  }

  String get labelStatus {
    switch (status) {
      case 'lunas':
        return 'Lunas';
      case 'terlambat':
        return 'Terlambat';
      default:
        return 'Belum Dibayar';
    }
  }

  bool get isTerlambat {
    return status != 'lunas' && jatuhTempo.isBefore(DateTime.now());
  }
}
