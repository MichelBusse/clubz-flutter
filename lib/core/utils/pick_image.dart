import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;

/// Opens an [ImagePicker] to let user pick an image, then an [ImageCropper] with the [cropperTitle]
/// and finally compresses the cropped image with [FlutterImageCompress] and [minWidth], [maxWidth] and [quality].
///
/// Throws an [FrontendException] with [FrontendExceptionType.pickImagePermission] if the access to gallery is denied.
/// Throws an [FrontendException] with [FrontendExceptionType.pickImage] if the [ImagePicker] fails.
/// Throws an [FrontendException] with [FrontendExceptionType.pickImage] if the [ImageCropper] fails.
Future<Uint8List?> pickCropAndCompressImage(
    {required BuildContext context,
    String? cropperTitle,
    int minWidth = 600,
    int minHeight = 600,
    int quality = 95}) async {
  XFile? image;
  try {
    // Try to pick image from gallery.
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
  } on PlatformException catch (e) {
    if (e.code == 'photo_access_denied') {
      throw FrontendException(type: FrontendExceptionType.pickImagePermission);
    }
  } catch (e) {
    throw FrontendException(type: FrontendExceptionType.pickImage);
  }

  // Cancel if ImagePicker returned no image.
  if (image == null) {
    return null;
  }

  // Cancel if context is no longer mounted.
  if (!context.mounted) {
    return null;
  }

  CroppedFile? croppedFile;

  try {
    // Try to crop the picked image to aspect ratio 1:1.
    croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: cropperTitle,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: cropperTitle,
            aspectRatioPickerButtonHidden: true,
            resetAspectRatioEnabled: false,
            aspectRatioLockEnabled: true,
            resetButtonHidden: true,
          ),
          WebUiSettings(
            context: context,
            enableResize: false,
          ),
        ],
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
  } catch (e) {
    throw FrontendException(type: FrontendExceptionType.pickImage);
  }

  // Cancel if ImageCropper returned no file.
  if (croppedFile == null) {
    return null;
  }

  // Converted cropped image to byte list.
  final Uint8List bytes = await io.File(croppedFile.path).readAsBytes();

  // Compress image bytes.
  final Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
    bytes,
    minHeight: minWidth,
    minWidth: minHeight,
    quality: quality,
  );

  return compressedBytes;
}
