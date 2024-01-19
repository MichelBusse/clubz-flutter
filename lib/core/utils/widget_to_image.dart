import 'dart:ui';

import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Creates an image from the given widget by first spinning up a element and render tree,
/// then waiting for the given [wait] amount of time and then creating an image via a [RepaintBoundary].
///
/// The final image will be of size [imageSize] and the the widget will be layout, ... with the given [logicalSize].
/// Throws an [FrontendException] with [FrontendExceptionType.generateImage] if image generation fails.
Future<Uint8List> createImageFromWidget(Widget widget,
    {Duration? wait,
    Size? logicalSize,
    Size? imageSize,
    required ThemeData themeData}) async {
  final repaintBoundary = RenderRepaintBoundary();

  logicalSize ??= WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  imageSize ??= WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;

  assert(logicalSize.aspectRatio == imageSize.aspectRatio,
      'logicalSize and imageSize must not be the same');

  final renderView = RenderView(
    view: WidgetsBinding.instance.platformDispatcher.views.first,
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      size: logicalSize,
      devicePixelRatio: 1,
    ),
  );

  final pipelineOwner = PipelineOwner();
  final buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: themeData.copyWith(
            scaffoldBackgroundColor: Colors.transparent,
            dialogBackgroundColor: Colors.transparent,
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(background: Colors.transparent),
          ),
          child: widget,
        ),
      )).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);

  if (wait != null) {
    await Future.delayed(wait);
  }

  buildOwner
    ..buildScope(rootElement)
    ..finalizeTree();

  pipelineOwner
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();

  final image = await repaintBoundary.toImage(
      pixelRatio: imageSize.width / logicalSize.width);

  final ByteData? byteData =
      await image.toByteData(format: ImageByteFormat.png);

  if (byteData == null) {
    throw FrontendException(
      type: FrontendExceptionType.generateImage,
    );
  }

  return byteData.buffer.asUint8List();
}
