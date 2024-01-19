import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A widget to display the overview information for profiles.
class ProfileOverview extends ConsumerWidget {
  final Profile profile;
  final List<Widget>? actions;

  const ProfileOverview({Key? key, required this.profile, this.actions})
      : super(key: key);

  _navigateToProfile(BuildContext context, WidgetRef ref) {
    if (ref.watch(profileStateProvider)?.id != null &&
        profile.id == ref.watch(profileStateProvider)!.id) {
      Navigator.popUntil(context, (route) => route.isFirst);
      context.go(AppRoutes.myProfile);
    } else {
      context.push('${AppRoutes.profileDetailView}/${profile.id}',
          extra: profile);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _navigateToProfile(context, ref),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: AppConstants.paddingMainBodyContainer,
          right: AppConstants.paddingMainBodyContainer,
        ),
        child: Row(
          children: [
            ProfileAvatar(
              avatarUrl: profile.avatarUrl,
              maxRadius: 65,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    profile.fullName ?? "",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    profile.username ?? "",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (actions != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: actions!,
              ),
          ],
        ),
      ),
    );
  }
}
