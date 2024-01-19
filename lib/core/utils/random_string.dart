import 'dart:math';

/// Available characters for the random string generation.
const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

/// Returns a random string with [length] characters.
String getRandomString(int length) {
  Random rnd = Random();

  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => _chars.codeUnitAt(rnd.nextInt(_chars.length)),
    ),
  );
}
