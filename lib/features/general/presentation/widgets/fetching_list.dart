import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/features/general/presentation/controllers/fetch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget to fetch and display data in set intervals.
class FetchingList<T> extends ConsumerStatefulWidget {
  const FetchingList({
    Key? key,
    required this.query,
    this.intervalSize = 10,
    this.isNestedScrollView = false,
    this.ignoreRefresh = false,
    this.empty = false,
    this.refreshState,
    required this.onRefresh,
    this.safeAreaBottom = true,
    required this.buildListElement,
    this.buildSuffixElement,
  }) : super(key: key);

  /// The query to fetch data.
  final Future<List<T>> Function(int from, int to) query;
  /// The size for the intervals (default: 10).
  final int intervalSize;
  /// Whether the list is empty (default: false).
  final bool empty;
  /// Whether the widget is nested inside another scroll view (default: false).
  final bool isNestedScrollView;
  /// The state to refresh the fetched data when changed.
  final String? refreshState;
  /// Whether the widget should ignore a refresh when [refreshState] or [empty] changes (default: false).
  final bool ignoreRefresh;
  /// Whether the widget should use the safe area on the bottom (default: true).
  final bool safeAreaBottom;
  /// The function to call for the refresh indicator of the list.
  final Future<void> Function() onRefresh;
  /// The function to build the suffix element of the list with the current length of the list as a parameter.
  final Widget? Function(int)? buildSuffixElement;
  /// The function to build the widgets of the elements of the list.
  final Widget Function(T) buildListElement;

  @override
  ConsumerState<FetchingList<T>> createState() => _FetchingListState<T>();
}

class _FetchingListState<T> extends ConsumerState<FetchingList<T>> {
  late FetchController<T> _fetchController;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _scrollController = widget.isNestedScrollView
          ? PrimaryScrollController.of(context)
          : ScrollController();
      _scrollController?.addListener(() => onScroll());
    });

    _initializeController();
    _fetchController.loadNext();
  }

  _initializeController() {
    _fetchController = FetchController<T>(
      query: widget.query,
      empty: widget.empty,
      intervalSize: widget.intervalSize,
      refreshState: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void didUpdateWidget(covariant FetchingList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ignoreRefresh) {
      return;
    }

    if (widget.refreshState != oldWidget.refreshState ||
        widget.empty != oldWidget.empty) {
      _fetchController.dispose();
      _initializeController();
      _fetchController.loadNext();
    }
  }

  @override
  void dispose() {
    if (!widget.isNestedScrollView) _scrollController?.dispose();
    _fetchController.dispose();
    super.dispose();
  }

  void onScroll() {
    if (_scrollController != null &&
        _scrollController!.positions.last.pixels >=
            _scrollController!.positions.last.maxScrollExtent) {
      if (_fetchController.hasNext) {
        _fetchController.loadNext();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      eventsRefreshProvider,
      (previous, next) {
        if (previous != next) {
          _initializeController();

          _fetchController.loadNext();
        }
      },
    );

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverSafeArea(
            bottom: widget.safeAreaBottom,
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  ..._fetchController.results.map<Widget>(
                    (t) => widget.buildListElement(t),
                  ),
                  if (!_fetchController.hasNext &&
                      _fetchController.results.isEmpty)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 15, end: 15, top: 20, bottom: 20),
                      child: Center(
                        child: Text(
                            AppLocalizations.of(context)!
                                .fetchingListNoEntriesFound,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    ),
                  if (_fetchController.hasNext)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: GestureDetector(
                          onTap: _fetchController.loadNext,
                          child: const SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  widget.buildSuffixElement?.call(_fetchController.results.length,) ?? Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
