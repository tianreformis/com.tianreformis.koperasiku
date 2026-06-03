import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RupiahInput extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool readOnly;

  const RupiahInput({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _RupiahFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? 'Rp 0',
        prefixText: 'Rp ',
        prefixStyle: Theme.of(context).textTheme.bodyLarge,
      ),
      validator: validator,
    );
  }
}

class _RupiahFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final value = newValue.text.replaceAll('.', '');
    if (int.tryParse(value) == null) return oldValue;

    final formatted = _formatRupiah(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatRupiah(String value) {
    final number = int.parse(value);
    final formatted = StringBuffer();
    final str = number.toString();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted.write('.');
      }
      formatted.write(str[i]);
      count++;
    }

    return formatted.toString().split('').reversed.join();
  }
}
