import 'package:flutter/material.dart';

class CSSParser {
  final Map<String, String> _properties;

  CSSParser(String style)
      : _properties = _parseStyle(style);

  static Map<String, String> _parseStyle(String style) {
    return Map.fromEntries(style.split(';').map((prop) {
      final splitProp = prop.split(':');
      if (splitProp.length == 2) {
        return MapEntry(splitProp[0].trim(), splitProp[1].trim());
      } else {
        return null;
      }
    }).where((entry) => entry != null).cast<MapEntry<String, String>>());
  }

  String? get(String property) {
    return _properties[property];
  }

  double? getSize(String property) {
    final value = get(property);
    return value != null ? _extractSize(value) : null;
  }

  MainAxisAlignment? getAlignment() {
    final value = get('text-align');
    switch (value) {
      case 'left':
        return MainAxisAlignment.start;
      case 'right':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'justify':
        return MainAxisAlignment.spaceBetween;
      default:
        return null;
    }
  }

  static double? _extractSize(String? sizeStr) {
    if (sizeStr == null) {
      return null;
    }
    if (sizeStr.endsWith('px')) {
      return double.tryParse(sizeStr.substring(0, sizeStr.length - 2));
    }
    // Add handling for other units if necessary.
    return null;
  }
  Color? getColor(String property) {
    final value = get(property);
    return value != null ? _extractColor(value) : null;
  }


  static Color? _extractColor(String colorStr) {
    if (colorStr.startsWith('rgb')) {
      return _extractColorFromRgb(colorStr);
    } else if (colorStr.startsWith('#')) {
      return _extractColorFromHex(colorStr);
    }
    // Add handling for other color formats if necessary.
    return null;
  }

  static Color? _extractColorFromRgb(String colorStr) {
    final match = RegExp(r'rgb\((\d+),\s*(\d+),\s*(\d+)\)').firstMatch(colorStr);
    if (match != null) {
      return Color.fromARGB(
        255,
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
    }
    return null;
  }

  static Color? _extractColorFromHex(String colorStr) {
    if (colorStr.length == 7 || colorStr.length == 9) {
      return Color(int.parse(colorStr.substring(1), radix: 16) + (colorStr.length == 7 ? 0xFF000000 : 0x00000000));
    }
    return null;
  }
}
