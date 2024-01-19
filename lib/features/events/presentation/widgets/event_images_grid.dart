import 'package:cached_network_image/cached_network_image.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Implement event images.

/// A widget to display the grid of images uploaded to an event.
class EventImagesGrid extends ConsumerStatefulWidget {
  const EventImagesGrid(
      {Key? key, required this.event, this.isNestedScrollView})
      : super(key: key);

  final Event event;
  final bool? isNestedScrollView;

  @override
  ConsumerState<EventImagesGrid> createState() => _EventImagesGridState();
}

class _EventImagesGridState extends ConsumerState<EventImagesGrid> {
  ScrollController? _scrollController;
  List<String> images = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _scrollController = (widget.isNestedScrollView ?? false)
          ? PrimaryScrollController.of(context)
          : ScrollController();
      _scrollController?.addListener(() => onScroll());
    });

    _fetchImages();
  }

  Future _fetchImages() async {
    List<String> images = await ref
        .read(eventsControllerProvider)
        .getEventImagesURLs(widget.event);
    setState(() {
      images = images;
    });
  }

  @override
  void didUpdateWidget(covariant EventImagesGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.event != oldWidget.event) {
      _fetchImages();
    }
  }

  @override
  void dispose() {
    if (!(widget.isNestedScrollView ?? false)) _scrollController?.dispose();
    super.dispose();
  }

  void onScroll() {
    if (_scrollController != null &&
        _scrollController!.positions.last.pixels >=
            _scrollController!.positions.last.maxScrollExtent) {
      //TODO load next data
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      mainAxisSpacing: 3.0,
      crossAxisSpacing: 3.0,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
            Ink(
              decoration: const BoxDecoration(
                color: AppConstants.colorDarkGrey,
              ),
              child: InkWell(
                onTap: () {},
                child: const Center(
                  child: Icon(
                    Icons.add,
                    size: 32,
                  ),
                ),
              ),
            ),
          ] +
          images
              .map((e) => Container(
                    decoration: const BoxDecoration(
                      color: AppConstants.colorDarkGrey,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: e,
                    ),
                  ))
              .toList(),
    );
  }
}
