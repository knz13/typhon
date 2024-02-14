import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

class FloatingPointTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    if (oldValue.text.isNotEmpty &&
        newValue.text == oldValue.text.substring(0, oldValue.text.length - 1)) {
      return newValue;
    }
    return FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'),
            replacementString: '')
        .formatEditUpdate(oldValue, newValue);
  }
}
