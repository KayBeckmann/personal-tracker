import 'package:flutter/services.dart';

/// TextInputFormatter für Dezimalzahlen mit Komma-Eingabe
///
/// Erlaubt die Eingabe von Zahlen mit Komma (,) oder Punkt (.) als Dezimaltrennzeichen.
/// Konvertiert Kommas automatisch in Punkte für die interne Verarbeitung.
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalDigits = 2});

  final int decimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Erlaube leeren Text
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Ersetze Komma durch Punkt
    String text = newValue.text.replaceAll(',', '.');

    // Validiere, dass es eine gültige Dezimalzahl ist
    if (!_isValidDecimal(text)) {
      return oldValue;
    }

    // Begrenze Dezimalstellen
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length == 2 && parts[1].length > decimalDigits) {
        text = '${parts[0]}.${parts[1].substring(0, decimalDigits)}';
      }
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length.clamp(0, text.length),
      ),
    );
  }

  bool _isValidDecimal(String text) {
    // Erlaube nur Ziffern und maximal einen Punkt
    if (!RegExp(r'^[0-9]*\.?[0-9]*$').hasMatch(text)) {
      return false;
    }

    // Maximal ein Dezimalpunkt
    if (text.split('.').length > 2) {
      return false;
    }

    return true;
  }
}
