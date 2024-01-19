import 'package:clubz/core/data/service/events_database_api.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/presentation/widgets/event_overview.dart';
import 'package:clubz/features/general/presentation/widgets/fetching_list.dart';
import 'package:clubz/features/feed/presentation/notifiers/feed_filter_notifier.dart';
import 'package:clubz/features/feed/presentation/widgets/feed_page_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// A page to display the feed to the user.
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({
    Key? key,
    required this.rootNavigatorKey,
  }) : super(key: key);

  final GlobalKey rootNavigatorKey;

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  @override
  void initState() {
    super.initState();

    ref.read(profileStateProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    FilterDetails? feedFilter = ref.watch(feedFilterProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: const FeedPageAppBar(),
      body: FetchingList<Event>(
        onRefresh: () async {
          ref.read(eventsRefreshProvider.notifier).refresh();
        },
        refreshState: (feedFilter?.lng.toString() ?? '0') +
            (feedFilter?.lat.toString() ?? '0') +
            (feedFilter?.radius.toString() ?? '40000'),
        query: (int from, int to) =>
            GetIt.instance.get<EventsDatabaseApi>().queryEventsFeed(
                  endDatetime: now.toIso8601String(),
                  lng: feedFilter?.lng ?? 0,
                  lat: feedFilter?.lat ?? 0,
                  radius: feedFilter?.radius ?? 40000,
                  from: from,
                  to: to,
                ),
        buildListElement: (e) => EventOverview(
          rootNavigatorKey: widget.rootNavigatorKey,
          event: e,
        ),
      ),
    );
  }
}
