import 'package:clubz/core/data/service/events_database_api.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/presentation/widgets/event_overview.dart';
import 'package:clubz/features/general/presentation/widgets/fetching_list.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/my_profile_page_app_bar.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_info_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A page to display the current users profile.
class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({
    Key? key,
    required this.rootNavigatorKey,
  }) : super(key: key);

  final GlobalKey rootNavigatorKey;

  @override
  ConsumerState<MyProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<MyProfilePage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Returns the according list of events for [tab].
  Widget _getEventList(String tab, Profile? profile) {
    if (profile == null) {
      return Container();
    }

    DateTime now = DateTime.now();
    DateTime nowToMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    switch (tab) {
      case "past":
        return FetchingList(
          onRefresh: () async {
            ref.read(eventsRefreshProvider.notifier).refresh();
          },
          key: const Key("past"),
          ignoreRefresh: true,
          refreshState: "${profile.id},${profile.attending.join(',')}",
          query: (int from, int to) =>
              GetIt.instance.get<EventsDatabaseApi>().queryEventsProfilePast(
                    creatorId: profile.id,
                    endDatetime: nowToMinute.toIso8601String(),
                    from: from,
                    to: to,
                  ),
          buildListElement: (Event e) => EventOverview(
            rootNavigatorKey: widget.rootNavigatorKey,
            event: e,
            currentProfileId: ref.watch(profileStateProvider)?.id,
          ),
          isNestedScrollView: true,
        );
      case "upcoming":
        return FetchingList(
          onRefresh: () async {
            ref.read(eventsRefreshProvider.notifier).refresh();
          },
          key: const Key("upcoming"),
          ignoreRefresh: true,
          refreshState: "${profile.id},${profile.attending.join(',')}",
          query: (int from, int to) => GetIt.instance
              .get<EventsDatabaseApi>()
              .queryEventsProfileUpcoming(
                creatorId: profile.id,
                endDatetime: nowToMinute.toIso8601String(),
                from: from,
                to: to,
              ),
          isNestedScrollView: true,
          buildListElement: (Event e) => EventOverview(
            rootNavigatorKey: widget.rootNavigatorKey,
            event: e,
            currentProfileId: ref.watch(profileStateProvider)?.id,
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: const MyProfilePageAppBar(),
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: ProfileInfoHeader(
                  profile: ref.watch(profileStateProvider),
                ),
              ),
              SliverPinnedHeader(
                child: Container(
                  color: Colors.black,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      labelPadding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                      unselectedLabelColor: Colors.grey,
                      controller: _tabController,
                      tabs: [
                        Text(
                          AppLocalizations.of(context)!
                              .profileDetailViewPageFilterUpcoming,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .profileDetailViewPageFilterPast,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _getEventList(
                "upcoming",
                ref.watch(profileStateProvider),
              ),
              _getEventList(
                "past",
                ref.watch(profileStateProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
