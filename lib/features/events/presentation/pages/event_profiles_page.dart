import 'package:clubz/core/data/service/profiles_database_api.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/data/models/event_state_type.dart';
import 'package:clubz/features/general/presentation/widgets/fetching_list.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

/// A data model for the arguments of [EventProfilesPage].
class EventProfilesPageArgs {
  final Event event;
  final int totalCount;
  final EventStateType type;

  const EventProfilesPageArgs({
    required this.event,
    required this.totalCount,
    required this.type,
  });
}

/// A page to display the profiles of [event] with the state of [type].
///
/// Takes [totalCount] as total number of profiles for [type] of [event].
class EventProfilesPage extends ConsumerStatefulWidget {
  const EventProfilesPage({
    Key? key,
    required this.args,
  }) : super(key: key);

  final EventProfilesPageArgs args;

  @override
  ConsumerState<EventProfilesPage> createState() => _EventProfilesPageState();
}

class _EventProfilesPageState extends ConsumerState<EventProfilesPage> {
  @override
  Widget build(BuildContext context) {
    String title = '';

    if (widget.args.type == EventStateType.attending) {
      title = AppLocalizations.of(context)!.eventAttending;
    } else if (widget.args.type == EventStateType.interested) {
      title = AppLocalizations.of(context)!.eventInterested;
    }

    return Scaffold(
      appBar: TransparentAppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      body: SafeArea(
        child: FetchingList(
          onRefresh: () async {},
          empty: false,
          refreshState: widget.args.event.id!,
          query: (int from, int to) => widget.args.type == EventStateType.attending
              ? GetIt.instance
                  .get<ProfilesDatabaseApi>()
                  .queryProfilesAttending(
                      eventId: widget.args.event.id!, from: from, to: to)
              : GetIt.instance
                  .get<ProfilesDatabaseApi>()
                  .queryProfilesInterested(
                      eventId: widget.args.event.id!, from: from, to: to),
          buildListElement: (Profile profile) =>
              ProfileOverview(profile: profile),
          buildSuffixElement: (int count) => (count < widget.args.totalCount)
              ? Padding(
                  padding: const EdgeInsets.all(15),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!
                          .eventProfilesMore(widget.args.totalCount - count),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
