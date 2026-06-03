class Validators {
  static String? required(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field tidak boleh kosong';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final phoneRegex = RegExp(r'^[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Nomor telepon tidak valid (10-13 digit)';
    }
    return null;
  }

  static String? number(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field tidak boleh kosong';
    }
    if (double.tryParse(value.replaceAll('.', '').replaceAll(',', '.')) == null) {
      return 'Format $field tidak valid';
    }
    return null;
  }

  static String? positiveNumber(String? value, String field) {
    final numberError = number(value, field);
    if (numberError != null) return numberError;
    final parsed = double.parse(value!.replaceAll('.', '').replaceAll(',', '.'));
    if (parsed <= 0) {
      return '$field harus lebih dari 0';
    }
    return null;
  }

  static String? matchPassword(String? value, String? confirmValue) {
    if (value != confirmValue) {
      return 'Password tidak cocok';
    }
    return null;
  }

  static String? minimalAmount(String? value, String field, double minAmount) {
    final numberError = number(value, field);
    if (numberError != null) return numberError;
    final parsed = double.parse(value!.replaceAll('.', '').replaceAll(',', '.'));
    if (parsed < minAmount) {
      return '$field minimal ${minAmount.toStringAsFixed(0)}';
    }
    return null;
  }
}
