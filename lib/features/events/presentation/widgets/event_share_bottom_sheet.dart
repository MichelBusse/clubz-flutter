import 'dart:io';

import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/core/utils/image_color_extension.dart';
import 'package:clubz/core/utils/url_to_file.dart';
import 'package:clubz/core/utils/widget_to_image.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/presentation/widgets/share_event_overview.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/share_bottom_sheet_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:social_share/social_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:clubz/core/utils/color_hex_extension.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// A bottom sheet to display the share functions for [event].
class EventShareBottomSheet extends StatefulWidget {
  const EventShareBottomSheet({
    Key? key,
    required this.event,
  }) : super(key: key);

  final Event event;

  @override
  State<EventShareBottomSheet> createState() => _EventShareBottomSheetState();
}

class _EventShareBottomSheetState extends State<EventShareBottomSheet> {
  int? _loadingId;

  /// Generates and shares an image as snippet of the event to instagram story.
  void _shareToInstagram(BuildContext context) async {
    if (_loadingId != null) {
      return;
    }

    setState(() {
      _loadingId = 0;
    });

    try {
      // Create image to share to instagram story.
      Uint8List bytes = await createImageFromWidget(
        ShareEventOverview(
          event: widget.event,
          locale: Localizations.localeOf(context),
        ),
        themeData: Theme.of(context),
      );

      // Save list of bytes as file in temporary directory.
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File file = await File('$tempPath/image.png').create();
      file.writeAsBytesSync(bytes);

      // Get background color for instagram story from dominant color of event image if provided.
      late Color color;
      if (widget.event.imageUrl != null) {
        File imageFile = await urlToFile(widget.event.imageUrl!);
        color = await Image.asset(imageFile.path).image.getDominantColorFromImage();
      } else {
        color = const Color(0xFF999999);
      }

      // Share to instagram story.
      SocialShare.shareInstagramStory(
        appId: dotenv.get("FACEBOOK_APP_ID"),
        imagePath: file.path,
        backgroundTopColor:
            Color.alphaBlend(const Color(0x99000000), color).toHex(),
        backgroundBottomColor: color.toHex(),
        attributionURL:
            '${dotenv.get("WEBSITE_URL")}${AppRoutes.eventDetailView}/${widget.event.id!}',
      );
    } on FrontendException catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context: context, errorText: e.getMessage(context));
      }
    } finally {
      setState(() {
        _loadingId = null;
      });
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // TODO: Generate more personalized message.
  /// Shares url of event to WhatsApp.
  void _shareToWhatsapp(BuildContext context) {
    if (_loadingId != null) {
      return;
    }

    setState(() {
      _loadingId = 1;
    });

    SocialShare.shareWhatsapp(
      '${dotenv.get("WEBSITE_URL")}${AppRoutes.eventDetailView}/${widget.event.id!}',
    );

    setState(() {
      _loadingId = null;
    });
    Navigator.of(context).pop();
  }

  /// Copies url of event to clipboard.
  void _copyToClipboard(BuildContext context) async {
    if (_loadingId != null) {
      return;
    }

    setState(() {
      _loadingId = 2;
    });

    await Clipboard.setData(
      ClipboardData(
        text:
            '${dotenv.get("WEBSITE_URL")}${AppRoutes.eventDetailView}/${widget.event.id!}',
      ),
    );

    setState(() {
      _loadingId = null;
    });
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShareBottomSheetWrapper(
      children: [
        if (!kIsWeb)
          _loadingId == 0
              ? const SizedBox(
                  width: 70,
                  height: 70,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Material(
                  color: Colors.transparent,
                  child: Ink(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: InkWell(
                      onTap: () => _shareToInstagram(context),
                      borderRadius: BorderRadius.circular(50),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Image.asset(
                          'assets/icons/instagram_icon.png',
                        ),
                      ),
                    ),
                  ),
                ),
        if (!kIsWeb)
          _loadingId == 1
              ? const SizedBox(
                  width: 70,
                  height: 70,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Material(
                  color: Colors.transparent,
                  child: Ink(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: InkWell(
                      onTap: () => _shareToWhatsapp(context),
                      borderRadius: BorderRadius.circular(50),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Image.asset(
                          'assets/icons/whatsapp_icon.png',
                        ),
                      ),
                    ),
                  ),
                ),
        _loadingId == 2
            ? const SizedBox(
                width: 70,
                height: 70,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            : Material(
                color: Colors.transparent,
                child: Ink(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: InkWell(
                    onTap: () => _copyToClipboard(context),
                    borderRadius: BorderRadius.circular(50),
                    child: const Icon(
                      Icons.copy,
                      size: 40,
                      color: Color(0xFFDDDDDD),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
