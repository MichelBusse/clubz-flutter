import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/data/service/events_database_api.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/presentation/widgets/event_overview.dart';
import 'package:clubz/features/general/presentation/widgets/fetching_list.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/report_profile_dialog.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:clubz/features/profiles/data/models/follow.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_info_header.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_share_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:collection/collection.dart';

/// A data model for the arguments of [ProfileDetailViewPage].
class ProfileDetailViewPageArgs {
  final Profile? profile;
  final String? profileId;

  ProfileDetailViewPageArgs({this.profile, this.profileId});
}

/// A page to view the profile of other users.
class ProfileDetailViewPage extends ConsumerStatefulWidget {
  const ProfileDetailViewPage({
    Key? key,
    this.profile,
    this.profileId = '',
    required this.rootNavigatorKey,
  }) : super(key: key);

  final GlobalKey rootNavigatorKey;
  final Profile? profile;
  final String? profileId;

  @override
  ConsumerState<ProfileDetailViewPage> createState() =>
      _ProfileDetailViewPageState();
}

class _ProfileDetailViewPageState extends ConsumerState<ProfileDetailViewPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  Profile? profile;
  String currentTab = "upcoming";

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );

    _initializeProfile();
  }

  /// Initializes page with profile data.
  _initializeProfile() async {
    // Use profile data if provided to widget directly or otherwise fetch profile data by profileId.
    if (widget.profile != null) {
      profile = widget.profile;
    } else if (widget.profileId != null) {
      _fetchProfile();
    }
  }

  /// Fetches profile data by provided profileId.
  _fetchProfile() async {
    if (widget.profileId != null) {
      Profile newProfile = await ref
          .read(profilesFetchControllerProvider)
          .getProfile(profileId: widget.profileId!);
      setState(() {
        profile = newProfile;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Returns the according list of events for [tab].
  Widget _getEventList(String tab) {
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
          refreshState: profile!.id,
          query: (int from, int to) =>
              GetIt.instance.get<EventsDatabaseApi>().queryEventsProfilePast(
                    creatorId: profile!.id,
                    endDatetime: nowToMinute.toIso8601String(),
                    from: from,
                    to: to,
                  ),
          isNestedScrollView: true,
          buildListElement: (Event e) => EventOverview(
            rootNavigatorKey: widget.rootNavigatorKey,
            event: e,
            currentProfileId: profile?.id,
          ),
        );
      default:
        return FetchingList(
          onRefresh: () async {
            ref.read(eventsRefreshProvider.notifier).refresh();
          },
          key: const Key("upcoming"),
          refreshState: profile!.id,
          query: (int from, int to) => GetIt.instance
              .get<EventsDatabaseApi>()
              .queryEventsProfileUpcoming(
                creatorId: profile!.id,
                endDatetime: nowToMinute.toIso8601String(),
                from: from,
                to: to,
              ),
          isNestedScrollView: true,
          buildListElement: (Event e) => EventOverview(
            rootNavigatorKey: widget.rootNavigatorKey,
            event: e,
            currentProfileId: profile?.id,
          ),
        );
    }
  }

  /// Opens report dialog for profile.
  _reportProfile(){
    showDialog(
      context: context,
      builder: (context) => ReportProfileDialog(
        profileId: profile!.id,
        title:
        AppLocalizations.of(context)!.reportProfileDialogTitle,
        text: AppLocalizations.of(context)!.reportProfileDialogText,
        callback: (String reason) async {
          try {
            await ref.read(reportsControllerProvider).reportProfile(
              profileId: profile!.id,
              reason: reason,
            );
            if (context.mounted) {
              showInfoSnackBar(
                  context: widget.rootNavigatorKey.currentContext!,
                  infoText: AppLocalizations.of(context)!
                      .reportProfileDialogSuccess);
            }
          } on FrontendException catch (e) {
            if (context.mounted) {
              showErrorSnackBar(
                context: widget.rootNavigatorKey.currentContext!,
                errorText: e.getMessage(context),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: TransparentAppBar(
        transparent: false,
        title: Text(
          profile?.username ?? '',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        actions: [
          if (profile != null && ref.watch(profileStateProvider) != null)
            IconButton(
              onPressed: _reportProfile,
              icon: const Icon(
                Icons.report_gmailerrorred_rounded,
                size: 30,
              ),
            ),
          if (profile != null)
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: widget.rootNavigatorKey.currentContext!,
                  isScrollControlled: true,
                  builder: (context) => ProfileShareBottomSheet(
                    profile: profile!,
                  ),
                );
              },
              icon: const Icon(
                Icons.share,
                size: AppConstants.largeIconSize,
              ),
            ),
        ],
      ),
      body: _buildProfileLayout(
        userProfile: ref.watch(profileStateProvider),
      ),
    );
  }

  /// Build page layout according to access permissions of current profile.
  Widget _buildProfileLayout({required Profile? userProfile}) {
    Follow? followingEntry = userProfile?.following
        .firstWhereOrNull((follow) => follow.id == profile?.id);

    // Check if profile is null or if current user has no permission to view it.
    if (profile == null ||
        (!profile!.publicProfile &&
            (userProfile == null || !(followingEntry?.accepted ?? false)))) {
      return Column(
        children: [
          ProfileInfoHeader(profile: profile),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
                AppLocalizations.of(context)!
                    .profileDetailViewPagePrivateProfile,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      );
    }

    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: ProfileInfoHeader(profile: profile),
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
                        style: Theme.of(context).textTheme.titleMedium),
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
          ),
          _getEventList(
            "past",
          ),
        ],
      ),
    );
  }
}
