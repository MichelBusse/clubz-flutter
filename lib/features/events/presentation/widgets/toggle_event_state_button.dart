import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/data/models/event_state_type.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A button to toggle the event state of [event] for the current user.
class ToggleEventStateButton extends ConsumerStatefulWidget {
  const ToggleEventStateButton({Key? key, required this.event})
      : super(key: key);

  final Event event;

  @override
  ConsumerState<ToggleEventStateButton> createState() =>
      _ToggleEventStateButtonState();
}

class _ToggleEventStateButtonState
    extends ConsumerState<ToggleEventStateButton> {
  bool _loadingInterested = false;
  bool _loadingAttending = false;

  @override
  Widget build(BuildContext context) {
    Profile? profile = ref.watch(profileStateProvider);

    // Return dummy buttons if no current profile is logged in or if profile is not initialized.
    if (profile == null ||
        !profile.isInitialized()) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              if (profile == null) {
                context.push(
                  AppRoutes.signInMethods,
                );
              } else if (!profile.isInitialized()) {
                context.push(AppRoutes.settingsProfile);
              }
            },
            child: const Icon(
              Icons.star_outline,
              size: 32,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              if (profile == null) {
                context.push(
                  AppRoutes.signInMethods,
                );
              } else if (!profile.isInitialized()) {
                context.push(AppRoutes.settingsProfile);
              }
            },
            child: const Icon(
              Icons.check_circle_outline,
              size: 32,
            ),
          ),
        ],
      );
    }

    bool attending = profile.attending.contains(widget.event.id);
    bool interested = profile.interested.contains(widget.event.id);

    return Row(
      children: [
        _loadingInterested
            ? const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(),
              )
            : GestureDetector(
                onTap: () async {
                  setState(() {
                    _loadingInterested = true;
                  });
                  try {
                    await ref
                        .read(profileStateProvider.notifier)
                        .toggleEventState(
                          type: EventStateType.interested,
                          eventId: widget.event.id!,
                          newValue: !interested,
                        );
                    setState(() {
                      interested = !interested;
                    });
                  } on FrontendException catch (e) {
                    if (context.mounted) {
                      showErrorSnackBar(
                          context: context, errorText: e.getMessage(context));
                    }
                  } finally {
                    setState(() {
                      _loadingInterested = false;
                    });
                  }
                },
                child: Icon(
                  interested ? Icons.star : Icons.star_outline,
                  size: 32,
                ),
              ),
        const SizedBox(
          width: 8,
        ),
        _loadingAttending
            ? const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(),
              )
            : GestureDetector(
                onTap: () async {
                  setState(() {
                    _loadingAttending = true;
                  });
                  try {
                    await ref
                        .read(profileStateProvider.notifier)
                        .toggleEventState(
                          type: EventStateType.attending,
                          eventId: widget.event.id!,
                          newValue: !attending,
                        );
                    setState(() {
                      attending = !attending;
                    });
                  } on FrontendException catch (e) {
                    if (context.mounted) {
                      showErrorSnackBar(
                          context: context, errorText: e.getMessage(context));
                    }
                  } finally {
                    setState(() {
                      _loadingAttending = false;
                    });
                  }
                },
                child: Icon(
                  attending ? Icons.check_circle : Icons.check_circle_outline,
                  size: 32,
                ),
              ),
      ],
    );
  }
}
