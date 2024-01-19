import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/general/presentation/widgets/icon_indicator.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// An app bar for the profile page of the current user.
class MyProfilePageAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const MyProfilePageAppBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  ConsumerState<MyProfilePageAppBar> createState() => _ProfilePageAppBarState();
}

class _ProfilePageAppBarState extends ConsumerState<MyProfilePageAppBar> {
  @override
  Widget build(BuildContext context) {
    return TransparentAppBar(
      leading: IconButton(
        icon: IndicatorBadgeContainer(
          active: (ref
                  .watch(profileStateProvider)
                  ?.follower
                  .any((element) => !element.accepted) ??
              false),
          child: const Icon(
            Icons.group_sharp,
            color: Colors.white,
            size: AppConstants.largeIconSize,
          ),
        ),
        onPressed: () {
          context.push(AppRoutes.followers);
        },
      ),
      title: Text(
        ref.watch(profileStateProvider)?.username ?? '',
        style: Theme.of(context).textTheme.displayMedium,
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
            size: AppConstants.largeIconSize,
          ),
          onPressed: () async {
            context.push(AppRoutes.settingsProfile);
          },
        )
      ],
    );
  }
}
