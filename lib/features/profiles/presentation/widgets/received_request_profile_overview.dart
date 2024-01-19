import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget to display the overview of profiles that requested to follow the current user.
class ReceivedRequestProfileOverview extends ConsumerStatefulWidget {
  const ReceivedRequestProfileOverview({Key? key, required this.profile})
      : super(key: key);

  final Profile profile;

  @override
  ConsumerState<ReceivedRequestProfileOverview> createState() =>
      _ReceivedRequestProfileOverviewState();
}

class _ReceivedRequestProfileOverviewState
    extends ConsumerState<ReceivedRequestProfileOverview> {
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
              // Accept request button.
              IconButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  try {
                    await ref
                        .read(profileStateProvider.notifier)
                        .acceptFollower(widget.profile);
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
                icon: const Icon(Icons.check),
              ),
              // Decline request button.
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
                icon: const Icon(Icons.close),
              ),
            ],
    );
  }
}
