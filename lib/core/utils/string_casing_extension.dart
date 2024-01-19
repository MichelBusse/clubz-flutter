extension StringCasingExtension on String {
  /// Transforms the first letter to uppercase.
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';

  /// Transforms the first letter and every letter after a space or opening bracket to uppercase.
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.split('(').map((str) => str.toCapitalized()).join('(')).join(' ');
}