import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/clubz_icons.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/feed/presentation/notifiers/feed_filter_notifier.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// An app bar for the feed page.
class FeedPageAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const FeedPageAppBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  ConsumerState<FeedPageAppBar> createState() => _FeedPageAppBarState();
}

class _FeedPageAppBarState extends ConsumerState<FeedPageAppBar> {
  @override
  Widget build(BuildContext context) {
    FilterDetails? filterDetails = ref.watch(feedFilterProvider);

    return TransparentAppBar(
      title: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: InkWell(
          onTap: () {
            context.push(AppRoutes.filterFeed);
          },
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    filterDetails?.locationDescription ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: Colors.black),
                    overflow: kIsWeb ? TextOverflow.clip : TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  filterDetails != null
                      ? '(${filterDetails.radius.toString()} km)'
                      : '',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
      leading: const Icon(
        ClubzIcons.appLogo,
        size: 28,
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.help_outline,
            size: 25,
          ),
        )
      ],
    );
  }
}
