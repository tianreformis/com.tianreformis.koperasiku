import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getColor().withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getColor(),
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'lunas':
      case 'lunas':
      case 'anggota':
        return Colors.green;
      case 'pending':
      case 'menunggu':
      case 'belum':
        return Colors.orange;
      case 'ditolak':
      case 'nonaktif':
      case 'terlambat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
