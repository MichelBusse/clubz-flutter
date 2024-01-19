import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/data/models/event_state_type.dart';
import 'package:clubz/features/events/presentation/widgets/event_status_count.dart';
import 'package:clubz/features/events/presentation/widgets/event_share_bottom_sheet.dart';
import 'package:clubz/features/events/presentation/widgets/event_key_info_bottom_sheet.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/report_profile_dialog.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:clubz/features/events/presentation/widgets/toggle_event_state_button.dart';
import 'package:clubz/features/events/presentation/widgets/event_key_info_button.dart';
import 'package:clubz/features/events/presentation/widgets/event_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:super_rich_text/super_rich_text.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher_string.dart';

/// A data model for the arguments of [EventDetailViewPage].
class EventDetailViewPageArgs {
  final String? eventId;
  final Event? event;

  EventDetailViewPageArgs({this.eventId, this.event});
}

/// A page to view the details of an event.
///
/// If [event] is not provided, the event for [eventId] is fetched from API.
class EventDetailViewPage extends ConsumerStatefulWidget {
  const EventDetailViewPage(
      {Key? key, this.eventId = '', this.event, required this.rootNavigatorKey})
      : super(key: key);

  final String? eventId;
  final Event? event;
  final GlobalKey rootNavigatorKey;

  @override
  ConsumerState<EventDetailViewPage> createState() =>
      _EventDetailViewPageState();
}

class _EventDetailViewPageState extends ConsumerState<EventDetailViewPage> {
  Event? event;
  bool descriptionOpen = false;

  @override
  void initState() {
    super.initState();

    _initializeEvent();
  }

  @override
  void didUpdateWidget(covariant EventDetailViewPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Initialize new event if event of widget changed.
    if (oldWidget.eventId != widget.eventId ||
        oldWidget.event != widget.event) {
      _initializeEvent();
    }
  }

  /// Initializes page with event data.
  _initializeEvent() async {
    // Use event data if provided to widget directly or otherwise fetch event data by eventId.
    if (widget.event != null) {
      setState(() {
        event = widget.event;
      });
    } else if (widget.eventId != null) {
      _fetchEvent();
    }
  }

  /// Fetches event data by provided eventId.
  _fetchEvent() async {
    if (widget.eventId != null) {
      Event newEvent = await ref
          .read(eventsControllerProvider)
          .getEvent(eventId: widget.eventId!);
      setState(() {
        event = newEvent;
      });
    }
  }

  /// Checks if event description is long enough to make its text box expandable.
  bool _descriptionHasTextOverflow(String text, TextStyle style,
      {double minWidth = 0,
      double maxWidth = double.infinity,
      int maxLines = 2}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: ui.TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  /// Navigates user to creator profile of event.
  _navigateToCreatorProfile() {
    Profile? profile = ref.read(profileStateProvider);
    if (event?.creatorProfile?.id != null &&
        profile?.id != null &&
        event!.creatorProfile!.id == profile!.id) {
      // Navigate users to own profile page if they are the creator.
      context.go(AppRoutes.myProfile);
    } else if (event?.creatorProfile?.id != null) {
      context.push(
        '${AppRoutes.profileDetailView}/${event!.creatorProfile!.id}',
        extra: event!.creatorProfile!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to eventRefreshProvider and fetch event again by its id
    // if a refresh should be performed.
    ref.listen(
      eventsRefreshProvider,
      (prev, current) async {
        if (prev != current &&
            (widget.eventId != null || widget.event?.id != null)) {
          try {
            // Prefer widget.event.id over widget.eventId if both are provided.
            Event newEvent = await ref
                .read(eventsControllerProvider)
                .getEvent(eventId: widget.event?.id ?? widget.eventId!);
            setState(() {
              event = newEvent;
            });
          } on FrontendException catch (e) {
            if (event == null) {
              if (context.mounted) {
                showErrorSnackBar(
                  context: context,
                  errorText: e.getMessage(context),
                );
              }
            }
          }
        }
      },
    );

    Profile? profile = ref.watch(profileStateProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: TransparentAppBar(
        actions: [
          if (event != null &&
              (profile == null || event!.creatorId != profile.id) &&
              profile != null)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ReportProfileDialog(
                    profileId: event!.creatorId,
                    title: AppLocalizations.of(context)!.reportEventDialogTitle,
                    text: AppLocalizations.of(context)!.reportEventDialogText,
                    callback: (String reason) async {
                      try {
                        await ref.read(reportsControllerProvider).reportEvent(
                              eventId: event!.id!,
                              reason: reason,
                            );
                        if (context.mounted) {
                          showInfoSnackBar(
                              context: widget.rootNavigatorKey.currentContext!,
                              infoText: AppLocalizations.of(context)!
                                  .reportEventDialogSuccess);
                        }
                      } on FrontendException catch (e) {
                        if(context.mounted) {
                          showErrorSnackBar(
                            context: widget.rootNavigatorKey.currentContext!,
                            errorText: e.getMessage(context),
                          );
                        }
                      }
                    },
                  ),
                );
              },
              icon: const Icon(
                Icons.report_gmailerrorred_rounded,
                size: 30,
              ),
            ),
          if (event != null &&
              profile != null &&
              event!.creatorId == profile.id)
            IconButton(
              onPressed: () {
                context.push(AppRoutes.editEvent, extra: event);
              },
              icon: const Icon(Icons.edit),
            ),
          IconButton(
            onPressed: event != null
                ? () {
                    showModalBottomSheet(
                      context: widget.rootNavigatorKey.currentContext!,
                      builder: (context) =>
                          EventShareBottomSheet(event: event!),
                    );
                  }
                : null,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchEvent();
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventImage(
                  event: event,
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppConstants.paddingMainBodyContainer,
                      right: AppConstants.paddingMainBodyContainer),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 10,
                              ),
                              child: Text(
                                event?.eventName ?? '---',
                                style: Theme.of(context).textTheme.displayLarge,
                                maxLines: 1,
                                overflow: kIsWeb
                                    ? TextOverflow.clip
                                    : TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                          ),
                          if (event != null)
                            const SizedBox(
                              width: 10,
                            ),
                          if (event != null) ToggleEventStateButton(event: event!),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (event != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Center(
                                    child: ProfileAvatar(
                                      avatarUrl:
                                          event!.creatorProfile!.avatarUrl,
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
                                    event!.creatorProfile!.fullName!,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
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
                                      Icons.calendar_today,
                                      size: AppConstants.largeIconSize,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  [
                                    DateFormat(
                                      'EEEE,',
                                      Localizations.localeOf(context)
                                          .toLanguageTag(),
                                    ).add_yMd().format(event!.startDatetime),
                                    if (event!.startDatetime
                                        .add(
                                          const Duration(
                                            days: 1,
                                          ),
                                        )
                                        .isBefore(event!.endDatetime))
                                      DateFormat(
                                        'EEEE,',
                                        Localizations.localeOf(context)
                                            .toLanguageTag(),
                                      ).add_yMd().format(event!.endDatetime),
                                  ].join(' - '),
                                  style: Theme.of(context).textTheme.bodyLarge,
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
                                    child: Icon(Icons.access_time,
                                        size: AppConstants.largeIconSize),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "${DateFormat(
                                    'jm',
                                    Localizations.localeOf(context)
                                        .toLanguageTag(),
                                  ).format(event!.startDatetime)}${AppLocalizations.of(context)!.eventDetailsPageTimeSuffix} - ${DateFormat(
                                    'jm',
                                    Localizations.localeOf(context)
                                        .toLanguageTag(),
                                  ).format(event!.endDatetime)}${AppLocalizations.of(context)!.eventDetailsPageTimeSuffix}",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                            if (event!.placeDescription.isNotEmpty)
                              const SizedBox(
                                height: 10,
                              ),
                            if (event!.placeDescription.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  MapsLauncher.launchQuery(
                                      event!.placeDescription);
                                },
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Center(
                                        child: Icon(Icons.location_on_outlined,
                                            size:
                                                AppConstants.largeIconSize),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        event!.placeDescription,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (event!.description.trim().isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    descriptionOpen = !descriptionOpen;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                    top: 20,
                                    bottom: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: AppConstants.colorDarkGrey,
                                  ),
                                  child: Stack(
                                    children: [
                                      SuperRichText(
                                        softWrap: true,
                                        text: event!.description,
                                        maxLines: descriptionOpen ? null : 10,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              height: 1.25,
                                            ),
                                      ),
                                      if (!descriptionOpen &&
                                          _descriptionHasTextOverflow(
                                              event!.description,
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!,
                                              maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              maxLines: 10))
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: AppConstants.colorDarkGrey,
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.only(
                                                left: 5,
                                                top: 5,
                                              ),
                                              child: Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                size: AppConstants
                                                    .largeIconSize,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            if (event!.description.trim().isNotEmpty)
                              const SizedBox(
                                height: 20,
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                EventKeyInfoButton(
                                  label: Event.dressCodeToString(
                                    context,
                                    event!.dressCode,
                                  ),
                                  icon: Icons.checkroom,
                                  onTab: event!.dressCodeDescription.isNotEmpty
                                      ? () {
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: widget.rootNavigatorKey
                                                .currentContext!,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(40),
                                              ),
                                            ),
                                            builder: (context) => EventKeyInfoBottomSheet(
                                              headline:
                                                  AppLocalizations.of(context)!
                                                      .editEventPageDressCode,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Text(
                                                    "${AppLocalizations.of(context)!.editEventPageCategory}: ",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    Event.dressCodeToString(
                                                        context,
                                                        event!.dressCode),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "${AppLocalizations.of(context)!.editEventPageDescription}: ",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    event!.dressCodeDescription,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                ),
                                EventKeyInfoButton(
                                  onTab: event!.agePolicyDescription.isNotEmpty
                                      ? () {
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: widget.rootNavigatorKey
                                                .currentContext!,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(40),
                                              ),
                                            ),
                                            builder: (context) => EventKeyInfoBottomSheet(
                                              headline:
                                                  AppLocalizations.of(context)!
                                                      .editEventPageAgePolicy,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Text(
                                                    "${AppLocalizations.of(context)!.editEventPageCategory}: ",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    Event.agePolicyToString(
                                                        context,
                                                        event!.agePolicy),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "${AppLocalizations.of(context)!.editEventPageDescription}: ",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    event!.agePolicyDescription,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  label: Event.agePolicyToString(
                                    context,
                                    event!.agePolicy,
                                  ),
                                  icon: Icons.person_search,
                                ),
                                EventKeyInfoButton(
                                  label: Event.pricePolicyToString(
                                    context,
                                    event!.pricePolicy,
                                  ),
                                  onTab: (event!.pricePolicyDescription
                                              .isNotEmpty ||
                                          event!.pricePolicyPrice != 0 ||
                                          event!.pricePolicyLink.isNotEmpty)
                                      ? () {
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: widget.rootNavigatorKey
                                                .currentContext!,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(40),
                                              ),
                                            ),
                                            builder: (context) => EventKeyInfoBottomSheet(
                                              headline:
                                                  AppLocalizations.of(context)!
                                                      .editEventPagePricePolicy,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Text(
                                                    "${AppLocalizations.of(context)!.editEventPageCategory}: ",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    Event.pricePolicyToString(
                                                        context,
                                                        event!.pricePolicy),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  if (event!
                                                      .pricePolicyDescription
                                                      .isNotEmpty)
                                                    Text(
                                                      "${AppLocalizations.of(context)!.editEventPageDescription}: ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium,
                                                    ),
                                                  if (event!
                                                      .pricePolicyDescription
                                                      .isNotEmpty)
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                  if (event!
                                                      .pricePolicyDescription
                                                      .isNotEmpty)
                                                    Text(
                                                      event!
                                                          .pricePolicyDescription,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge,
                                                    ),
                                                  if (event!
                                                      .pricePolicyDescription
                                                      .isNotEmpty)
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                  if (event!.pricePolicyPrice !=
                                                      0)
                                                    Text(
                                                      '${AppLocalizations.of(context)!.editEventPagePricePolicyPrice}: ',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium,
                                                    ),
                                                  if (event!.pricePolicyPrice !=
                                                      0)
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                  if (event!.pricePolicyPrice !=
                                                      0)
                                                    Text(
                                                      '${event!.pricePolicyPrice.toString()} €',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge,
                                                    ),
                                                  if (event!.pricePolicyPrice !=
                                                      0)
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                  if (event!.pricePolicyLink
                                                      .isNotEmpty)
                                                    Text(
                                                      '${AppLocalizations.of(context)!.editEventPagePricePolicyLink}: ',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium,
                                                    ),
                                                  if (event!.pricePolicyLink
                                                      .isNotEmpty)
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                  if (event!.pricePolicyLink
                                                      .isNotEmpty)
                                                    GestureDetector(
                                                      onTap: () {
                                                        launchUrlString(event!
                                                            .pricePolicyLink);
                                                      },
                                                      child: Text(
                                                        event!.pricePolicyLink,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  icon: Icons.credit_card,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (event != null)
                              EventStatusCount(
                                event: event!,
                                type: EventStateType.interested,
                              ),
                            if (event != null)
                              EventStatusCount(
                                event: event!,
                                type: EventStateType.attending,
                              ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
