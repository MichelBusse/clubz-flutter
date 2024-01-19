import 'package:clubz/core/data/service/profiles_database_api.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/general/presentation/widgets/fetching_list.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/follower_profile_overview.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_overview.dart';
import 'package:clubz/features/profiles/presentation/widgets/received_request_profile_overview.dart';
import 'package:clubz/features/profiles/presentation/widgets/sent_request_profile_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// A page to list all followers of the user and all profiles which the user is following.
class FollowersPage extends ConsumerStatefulWidget {
  const FollowersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends ConsumerState<FollowersPage>
    with TickerProviderStateMixin {
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

  /// Returns the according list of profiles for [tab].
  Widget _getProfileList(String tab, Profile? profile) {
    if (profile == null) {
      return Container();
    }

    switch (tab) {
      case "follower":
        return FetchingList(
          onRefresh: () async {},
          empty: profile.follower.isEmpty,
          refreshState: profile.follower.join(''),
          query: (int from, int to) =>
              GetIt.instance.get<ProfilesDatabaseApi>().queryProfilesFollower(
                    from: from,
                    to: to,
                  ),
          buildListElement: (Profile p) {
            if (profile.follower
                .any((follower) => follower.id == p.id && !follower.accepted)) {
              return ReceivedRequestProfileOverview(profile: p);
            } else {
              return FollowerProfileOverview(
                profile: p,
              );
            }
          },
        );
      case "following":
        return FetchingList(
          onRefresh: () async {},
          empty: profile.following.isEmpty,
          refreshState: profile.following.join(''),
          query: (int from, int to) =>
              GetIt.instance.get<ProfilesDatabaseApi>().queryProfilesFollowing(
                    from: from,
                    to: to,
                  ),
          buildListElement: (Profile p) {
            if (profile.following.any(
                (following) => following.id == p.id && !following.accepted)) {
              return SentRequestProfileOverview(profile: p);
            } else {
              return ProfileOverview(
                profile: p,
              );
            }
          },
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(
        title: Text(
          AppLocalizations.of(context)!.followersPageTitle,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push(AppRoutes.requestFollowing);
            },
            icon: const Icon(
              Icons.search,
              size: AppConstants.largeIconSize,
            ),
          ),
        ],
        bottom: TabBar(
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          labelPadding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          unselectedLabelColor: Colors.grey,
          controller: _tabController,
          tabs: [
            Text(
              AppLocalizations.of(context)!.followersPageFollowers,
            ),
            Text(
              AppLocalizations.of(context)!.followersPageFollowing,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _getProfileList(
            "follower",
            ref.watch(profileStateProvider),
          ),
          _getProfileList(
            "following",
            ref.watch(profileStateProvider),
          ),
        ],
      ),
    );
  }
}
