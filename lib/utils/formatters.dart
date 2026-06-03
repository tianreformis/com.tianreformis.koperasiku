import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _rupiahFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _monthFormat = DateFormat('MMM', 'id_ID');

  static String formatRupiah(dynamic amount) {
    if (amount == null) return 'Rp 0';
    return _rupiahFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String formatMonth(int month) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month];
  }

  static String getBulanIndonesia(int month) {
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month];
  }

  static String getHariIndonesia(int day) {
    final days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return days[day - 1];
  }
}
