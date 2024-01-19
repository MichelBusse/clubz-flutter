import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/data/models/event_state_type.dart';
import 'package:clubz/features/events/presentation/pages/event_profiles_page.dart';
import 'package:clubz/features/events/presentation/widgets/event_profiles_overview.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class EventStatusCount extends StatelessWidget {
  const EventStatusCount({Key? key, required this.event, required this.type})
      : super(key: key);

  final Event event;
  final EventStateType type;

  @override
  Widget build(BuildContext context) {
    List<Profile> profiles = [];
    int count = 0;
    String label = "";
    IconData icon = Icons.group;

    // Set fields according to type of event state.
    if (type == EventStateType.attending) {
      profiles = event.attendingPreview;
      count = event.attendingCount;
      label = AppLocalizations.of(context)!.eventAttending;
      icon = Icons.group;
    } else if (type == EventStateType.interested) {
      profiles = event.interestedPreview;
      count = event.interestedCount;
      label = AppLocalizations.of(context)!.eventInterested;
      icon = Icons.star;
    }

    return InkWell(
      onTap: profiles.isNotEmpty
          ? () {
              context.push(
                AppRoutes.eventProfiles,
                extra: EventProfilesPageArgs(
                  event: event,
                  totalCount: count,
                  type: type,
                ),
              );
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 5,
          bottom: 5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Center(
                child: Icon(
                  icon,
                  size: AppConstants.largeIconSize,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text("$count $label", style: Theme.of(context).textTheme.bodyLarge),
            Expanded(
              child: Container(),
            ),
            if (profiles.isNotEmpty)
              EventProfilesOverview(
                profiles: profiles,
              ),
          ],
        ),
      ),
    );
  }
}
