import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget to display the overview of profiles that the current user sent a follow request to.
class SentRequestProfileOverview extends ConsumerStatefulWidget {
  const SentRequestProfileOverview({
    Key? key,
    required this.profile,
  }) : super(key: key);

  final Profile profile;

  @override
  ConsumerState<SentRequestProfileOverview> createState() =>
      _SentRequestProfileOverviewState();
}

class _SentRequestProfileOverviewState
    extends ConsumerState<SentRequestProfileOverview> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return ProfileOverview(
      profile: widget.profile,
      actions: [
        // Cancel request button.
        IconButton(
          onPressed: () async {
            setState(() {
              loading = true;
            });
            try {
              await ref
                  .read(profileStateProvider.notifier)
                  .removeFollowing(widget.profile);
            } on FrontendException catch (e) {
              if(context.mounted) {
                showErrorSnackBar(
                    context: context,
                    errorText: e.getMessage(context));
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
