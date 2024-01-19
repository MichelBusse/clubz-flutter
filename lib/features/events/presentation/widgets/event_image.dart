import 'package:cached_network_image/cached_network_image.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/presentation/widgets/event_image_wrapper.dart';
import 'package:clubz/features/general/presentation/widgets/skeletons/skeleton_container.dart';
import 'package:flutter/material.dart';

/// A widget to display the image of [event].
///
/// Displays [centeredWidget] centered and [actionWidget] in the top right corner on top of the image.
class EventImage extends StatelessWidget {
  const EventImage(
      {Key? key, required this.event, this.centeredWidget, this.actionWidget})
      : super(key: key);

  final Event? event;
  final Widget? centeredWidget;
  final Widget? actionWidget;

  @override
  Widget build(BuildContext context) {
    return EventImageWrapper(children: [
      // Show event image if event.imageUrl is provided.
      if (event?.imageUrl != null)
        CachedNetworkImage(
          errorWidget: (context, url, error) => const Image(
            fit: BoxFit.cover,
            image: AssetImage(AppConstants.defaultEventImagePath),
          ),
          imageBuilder: (context, imageProvider) => Image(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
          imageUrl: event!.imageUrl!,
          placeholder: (context, url) => const SkeletonContainer.square(),
        ),
      // Show default event image if event is provided but has no imageUrl.
      if (event != null && event!.imageUrl == null)
        const Image(
          image: AssetImage(
            AppConstants.defaultEventImagePath,
          ),
          fit: BoxFit.fill,
        ),
      // Show loading skeleton if event is null.
      if(event == null)
        const SkeletonContainer.square(),
      // Display centeredWidget centered above image.
      if (centeredWidget != null) centeredWidget!,
      // Display actionWidget on top right corner above image.
      if (actionWidget != null)
        Positioned(
          top: 0,
          right: 0,
          child: actionWidget!,
        ),
    ]);
  }
}
