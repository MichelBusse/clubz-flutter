import 'dart:io';
import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/utils/random_string.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Returns the content of the [url] as a file.
Future<File> urlToFile(String url) async {
  try {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    // Save url to temporary directory with random filename.
    File file = File(tempPath + getRandomString(10));
    http.Response response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }catch(e){
    throw FrontendException(type:  FrontendExceptionType.share);
  }
}
