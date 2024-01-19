import 'dart:ui';

/// An extension to convert colors to their hex codes and back.
extension ColorHexExtension on Color {
  /// Creates color from hex-code.
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();

    // Add 'ff' as alpha value if hex-string doesn't have alpha specified.
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');

    // Remove '#' from start of hex-string if there is one.
    buffer.write(hexString.replaceFirst('#', ''));

    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Converts color to hex-code.
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
