import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

extension ImageColorExtension on ImageProvider {
  /// Returns the dominant color.
  Future<Color> getDominantColorFromImage() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(this);

    // Defaults to black color, if there is no dominantColor.
    return paletteGenerator.dominantColor?.color ?? Colors.black;
  }
}
