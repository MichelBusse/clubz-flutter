import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/manage_following_button_large.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_avatar.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_stats_view.dart';
import 'package:clubz/features/profiles/presentation/widgets/skeletons/profile_info_header_skeleton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget to display the header for the profile information.
class ProfileInfoHeader extends ConsumerWidget {
  const ProfileInfoHeader({Key? key, required this.profile}) : super(key: key);
  final Profile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Profile? userProfile = ref.watch(profileStateProvider);

    if (profile != null) {
      return Padding(
        padding: const EdgeInsets.only(
          left: AppConstants.paddingMainBodyContainer,
          right: AppConstants.paddingMainBodyContainer,
          top: 20,
          bottom: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileAvatar(
              avatarUrl: profile?.avatarUrl,
              maxRadius: 110,
            ),
            const SizedBox(
              height: 15,
            ),
            Flexible(
              child: Text(
                profile?.fullName ?? '',
                style: Theme.of(context).textTheme.displayLarge,
                softWrap: false,
                overflow: kIsWeb ? TextOverflow.clip : TextOverflow.fade,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ProfileStatsView(profile: profile,),
            if (profile?.id != userProfile?.id)
              const SizedBox(
                height: 20,
              ),
            if (profile?.id != userProfile?.id)
              ManageFollowingButton(profile: profile),
          ],
        ),
      );
    } else {
      return const ProfileInfoHeaderSkeleton();
    }
  }
}
