import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// A data model for the current filter information for the [FeedPage].
class FilterDetails {
  String locationDescription;
  double lat;
  double lng;
  int radius;

  FilterDetails(
      {required this.locationDescription,
      required this.lat,
      required this.lng,
      required this.radius});
}

/// A [StateNotifier] for notification of changes of [FilterDetails].
class FeedFilterNotifier extends StateNotifier<FilterDetails?> {
  final supabase.Session? currentSession;

  /// Initializes notifier with initial [FilterDetails].
  FeedFilterNotifier({required this.currentSession}) : super(null) {
    state = FilterDetails(
      locationDescription: 'Leipzig',
      lat: 51.339,
      lng: 12.377,
      radius: 20,
    );
  }

  /// Sets new [FilterDetails].
  void setFilterDetails(FilterDetails filterDetails) {
    state = filterDetails;
  }
}
