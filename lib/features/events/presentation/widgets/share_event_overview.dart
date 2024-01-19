import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/clubz_icons.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/presentation/widgets/event_image.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_avatar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A widget to render the overview of [event] when sharing it as an image.
///
/// Requires [locale] to display in the correct language.
class ShareEventOverview extends StatelessWidget {
  const ShareEventOverview(
      {Key? key, required this.event, required this.locale})
      : super(key: key);

  final Event event;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(
            Radius.circular(40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            EventImage(
              event: event,
              actionWidget: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xAF000000),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(38),
                      bottomLeft: Radius.circular(38),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Icon(
                      ClubzIcons.appLogo,
                      size: 28 * constraints.maxWidth * 0.0028,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 15,
                right: 15,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            event.eventName,
                            style: Theme.of(context).textTheme.displayLarge,
                            overflow:
                                kIsWeb ? TextOverflow.clip : TextOverflow.fade,
                            softWrap: false,
                            textScaler: TextScaler.linear(constraints.maxWidth * 0.0028),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Center(
                          child: ProfileAvatar(
                            avatarUrl: event.creatorProfile!.avatarUrl,
                            maxRadius: 30 * constraints.maxWidth * 0.0028,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        event.creatorProfile!.fullName!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textScaler: TextScaler.linear(constraints.maxWidth * 0.0028),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Center(
                          child: Icon(
                            Icons.access_time_outlined,
                            size: AppConstants.largeIconSize * constraints.maxWidth * 0.0028,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat(
                          'EEEE, dd.MM.yyyy',
                          locale.toLanguageTag(),
                        ).format(event.startDatetime),
                        style: Theme.of(context).textTheme.bodyLarge,
                        textScaler: TextScaler.linear(constraints.maxWidth * 0.0028),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Center(
                          child: Icon(
                            Icons.link,
                            size: AppConstants.largeIconSize * constraints.maxWidth * 0.0028,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
