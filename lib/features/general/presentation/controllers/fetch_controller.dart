/// A class to fetch data of a query in set intervals.
class FetchController<T> {
  /// The query to fetch data.
  final Future<List<T>> Function(int from, int to) query;
  /// The size for the intervals (default: 10).
  final int intervalSize;
  /// A function to refresh the state of the widget that uses the [FetchController].
  void Function()? refreshState;
  /// A list to hold the fetched data.
  List<T> results = <T>[];
  /// Whether the query has fetched all data (default: false).
  bool hasNext;
  /// Whether the results should be empty (default: false).
  bool empty;

  bool _loading = false;

  FetchController({this.hasNext = true, required this.intervalSize, this.empty = false, required this.query, required this.refreshState,}) : super();

  dispose() {
    refreshState = null;
  }

  /// Loads the next interval of data and adds it to [results].
  loadNext() async {
    if (_loading) return;
    if (empty) {
      hasNext = false;
      return;
    }
    if (!hasNext) return;

    _loading = true;

    int offset = results.length;

    // TODO: Range has no effect
    // Limits the result to rows within the specified range, inclusive.
    List<T> newResults = await query(offset, offset + intervalSize - 1);

    if (newResults.length < intervalSize) hasNext = false;

    results.addAll(newResults);

    refreshState?.call();

    _loading = false;
  }
}
