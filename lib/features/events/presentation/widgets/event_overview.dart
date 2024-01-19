import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/data/models/event_state_type.dart';
import 'package:clubz/features/events/presentation/widgets/toggle_event_state_button.dart';
import 'package:clubz/features/events/presentation/widgets/event_status_count.dart';
import 'package:clubz/features/events/presentation/widgets/event_image.dart';
import 'package:clubz/features/events/presentation/widgets/event_share_bottom_sheet.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_avatar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

/// A widget to display the overview of an event.
class EventOverview extends ConsumerStatefulWidget {
  const EventOverview(
      {Key? key,
      required this.event,
      this.currentProfileId,
      required this.rootNavigatorKey})
      : super(key: key);

  final Event event;
  final String? currentProfileId;
  final GlobalKey rootNavigatorKey;

  @override
  ConsumerState<EventOverview> createState() => _EventOverviewState();
}

class _EventOverviewState extends ConsumerState<EventOverview> {
  /// Navigates user to EventDetailViewPage of event.
  _navigateToEvent() {
    context.push('${AppRoutes.eventDetailView}/${widget.event.id!}',
        extra: widget.event);
  }

  /// Navigates user to creator profile of event.
  _navigateToCreatorProfile() {
    // Prevent navigation if user is already on page of creator profile.
    if (widget.event.creatorProfile?.id != null && widget.event.creatorProfile!.id == widget.currentProfileId) {
      return;
    }

    if (widget.event.creatorProfile?.id != null &&
        ref.watch(profileStateProvider)?.id != null &&
        widget.event.creatorProfile!.id ==
            ref.watch(profileStateProvider)!.id) {
      // Navigate users to own profile page if they are the creator.
      context.go(AppRoutes.myProfile);
    } else if (widget.event.creatorProfile?.id != null) {
      context.push(
          '${AppRoutes.profileDetailView}/${widget.event.creatorProfile!.id}',
          extra: widget.event.creatorProfile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppConstants.paddingMainBodyContainer,
          bottom: 12,
          top: 12,
          right: AppConstants.paddingMainBodyContainer),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(
            Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x55222222),
              spreadRadius: 20,
              blurRadius: 20,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventImage(
              event: widget.event,
              actionWidget: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: const BoxDecoration(
                    color: Color(0xAF000000),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(38),
                      bottomLeft: Radius.circular(38),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: widget.rootNavigatorKey.currentContext!,
                        builder: (context) => EventShareBottomSheet(
                          event: widget.event,
                        ),
                      );
                    },
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(38),
                      topRight: Radius.circular(38),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(18),
                      child: Icon(
                        Icons.share,
                        size: AppConstants.largeIconSize,
                      ),
                    ),
                  ),
                ),
              ),
              centeredWidget: Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _navigateToEvent,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 15,
                right: 15,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: _navigateToEvent,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              widget.event.eventName,
                              style: Theme.of(context).textTheme.displayLarge,
                              overflow: kIsWeb
                                  ? TextOverflow.clip
                                  : TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ToggleEventStateButton(
                        event: widget.event,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Center(
                          child: ProfileAvatar(
                            avatarUrl: widget.event.creatorProfile!.avatarUrl,
                            maxRadius: 30,
                            onTap: _navigateToCreatorProfile,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: _navigateToCreatorProfile,
                        child: Text(
                          widget.event.creatorProfile!.fullName!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: Center(
                          child: Icon(
                            Icons.access_time_outlined,
                            size: AppConstants.largeIconSize,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('EEEE, dd.MM.yyyy',
                                Localizations.localeOf(context).toLanguageTag())
                            .format(widget.event.startDatetime),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  EventStatusCount(
                    event: widget.event,
                    type: EventStateType.interested,
                  ),
                  EventStatusCount(
                    event: widget.event,
                    type: EventStateType.attending,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
