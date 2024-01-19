import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/features/general/presentation/widgets/animated_count.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/data/models/profile_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A widget to display the stats of a profile.
class ProfileStatsView extends ConsumerStatefulWidget {
  const ProfileStatsView({Key? key, this.profile}) : super(key: key);

  final Profile? profile;

  @override
  ConsumerState<ProfileStatsView> createState() => _ProfileStatsViewState();
}

class _ProfileStatsViewState extends ConsumerState<ProfileStatsView> {
  ProfileStats stats = const ProfileStats();

  @override
  void initState() {
    super.initState();
    _getProfileStats();
  }

  @override
  void didUpdateWidget(covariant ProfileStatsView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.profile != widget.profile) {
      _getProfileStats();
    }
  }

  /// Fetches stats for the profile.
  void _getProfileStats() async {
    if (widget.profile != null) {
      ProfileStats newStats = await ref
          .read(profilesFetchControllerProvider)
          .getProfileStats(profileId: widget.profile!.id);

      setState(() {
        stats = newStats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            children: [
              AnimatedCount(
                count: stats.follower,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                AppLocalizations.of(context)!.profileStatsFollower,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              AnimatedCount(
                count: stats.score,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                AppLocalizations.of(context)!.profileStatsScore,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              AnimatedCount(
                count: stats.events,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                AppLocalizations.of(context)!.profileStatsEvents,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
