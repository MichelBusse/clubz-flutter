import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An overview for profiles that follow the current user.
class FollowerProfileOverview extends ConsumerStatefulWidget {
  const FollowerProfileOverview({Key? key, required this.profile})
      : super(key: key);

  final Profile profile;

  @override
  ConsumerState<FollowerProfileOverview> createState() =>
      _FollowerProfileOverviewState();
}

class _FollowerProfileOverviewState
    extends ConsumerState<FollowerProfileOverview> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return ProfileOverview(
      profile: widget.profile,
      actions: loading
          ? [
              const CircularProgressIndicator(),
            ]
          : [
              // Remove follower button.
              IconButton(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    try {
                      await ref
                          .read(profileStateProvider.notifier)
                          .removeFollower(widget.profile);
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
                  icon: const Icon(Icons.close))
            ],
    );
  }
}
