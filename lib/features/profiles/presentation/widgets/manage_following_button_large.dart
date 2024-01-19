import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/profiles/data/models/follow.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';

/// A button to manage the following state of other profiles.
class ManageFollowingButton extends ConsumerStatefulWidget {
  const ManageFollowingButton(
      {Key? key, required this.profile, this.minimalIcons = false})
      : super(key: key);

  final Profile? profile;
  final bool minimalIcons;

  @override
  ConsumerState<ManageFollowingButton> createState() =>
      _RequestFollowingButtonState();
}

class _RequestFollowingButtonState
    extends ConsumerState<ManageFollowingButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Profile? userProfile = ref.watch(profileStateProvider);

    // Show progress indicator if loading.
    if (loading || widget.profile == null) {
      return const SizedBox(
        width: 39,
        height: 39,
        child: Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    Follow? followingEntry = userProfile?.following
        .firstWhereOrNull((follow) => follow.id == widget.profile!.id);

    // Check if following exists and is already accepted (current user follows profile).
    if (followingEntry != null && followingEntry.accepted) {
      return RoundedButton(
        onTap: () async {
          setState(() {
            loading = true;
          });
          try {
            await ref
                .read(profileStateProvider.notifier)
                .removeFollowing(widget.profile!);
          } on FrontendException catch (e) {
            if (context.mounted) {
              showErrorSnackBar(
                  context: context, errorText: e.getMessage(context));
            }
          } finally {
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          }
        },
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 15,
          right: 15,
        ),
        color: Colors.grey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_remove,
              size: 18,
              color: Colors.black,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalizations.of(context)!.addFollowingButtonLargeUnfollow,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.black),
            ),
          ],
        ),
      );
    }

    // Check if following exists and is not accepted (current user requested to follow profile already).
    if (followingEntry != null && !followingEntry.accepted) {
      return RoundedButton(
        onTap: () async {
          setState(() {
            loading = true;
          });
          try {
            await ref
                .read(profileStateProvider.notifier)
                .removeFollowing(widget.profile!);
          } on FrontendException catch (e) {
            if(context.mounted) {
              showErrorSnackBar(
                  context: context, errorText: e.getMessage(context));
            }
          } finally {
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          }
        },
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 15,
          right: 15,
        ),
        color: Colors.grey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.close,
              size: 18,
              color: Colors.black,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalizations.of(context)!
                  .addFollowingButtonLargeCancelRequest,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.black),
            ),
          ],
        ),
      );
    }

    // No following exists (current user did not yet request to follow).
    return RoundedButton(
      onTap: () async {
        if (userProfile != null) {
          setState(() {
            loading = true;
          });
          try {
            await ref
                .read(profileStateProvider.notifier)
                .requestFollowing(widget.profile!);
          } on FrontendException catch (e) {
            if(context.mounted) {
              showErrorSnackBar(
                  context: context, errorText: e.getMessage(context));
            }
          } finally {
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          }
        } else {
          context.push(AppRoutes.signInMethods);
        }
      },
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
        left: 15,
        right: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_add,
            size: 18,
            color: Colors.black,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            AppLocalizations.of(context)!.addFollowingButtonLargeFollow,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
