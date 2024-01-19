import 'package:clubz/features/auth/presentation/notifiers/auth_state_notifier.dart';
import 'package:clubz/features/feed/presentation/notifiers/feed_filter_notifier.dart';
import 'package:clubz/features/general/presentation/controllers/blocked_controller.dart';
import 'package:clubz/features/general/presentation/controllers/reports_controller.dart';
import 'package:clubz/features/profiles/presentation/notifiers/profile_state_notifier.dart';
import 'package:clubz/features/events/presentation/controllers/events_controller.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/controllers/profiles_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// The [StateNotifierProvider] for the [AuthStateNotifier].
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, supabase.Session?>(
  (ref) {
    AuthStateNotifier notifier = AuthStateNotifier();
    return notifier;
  },
);

/// The [StateNotifierProvider] for the [ProfileStateNotifier].
///
/// Depends on the [authStateProvider].
final profileStateProvider =
    StateNotifierProvider<ProfileStateNotifier, Profile?>(
  (ref) {
    ProfileStateNotifier notifier = ProfileStateNotifier(
      currentSession: ref.watch(authStateProvider),
    );
    return notifier;
  },
);


/// The [StateNotifierProvider] for the [FeedFilterNotifier].
///
/// Depends on the [authStateProvider].
final feedFilterProvider =
    StateNotifierProvider<FeedFilterNotifier, FilterDetails?>(
  (ref) {
    FeedFilterNotifier notifier = FeedFilterNotifier(
      currentSession: ref.watch(authStateProvider),
    );
    return notifier;
  },
);

/// The [Provider] for the [ProfilesController].
final profilesFetchControllerProvider = Provider(
  (ref) => ProfilesFetchController(),
);

/// The [Provider] for the [ReportsController].
///
/// Depends on the [profileStateProvider].
final reportsControllerProvider = Provider(
  (ref) => ReportsController(userProfile: ref.watch(profileStateProvider)),
);

/// The [Provider] for the [BlockedController].
///
/// Depends on the [profileStateProvider].
final blockedControllerProvider = Provider(
  (ref) => BlockedController(userProfile: ref.watch(profileStateProvider)),
);

/// The [StateNotifierProvider] for the [RefreshNotifier].
final eventsRefreshProvider =
    StateNotifierProvider<RefreshNotifier, int>((ref) {
  return RefreshNotifier();
});

/// [StateNotifier] to refresh other providers.
class RefreshNotifier extends StateNotifier<int> {
  RefreshNotifier() : super(0);

  /// Changes state of [StateNotifier] and thereby refreshes depending providers.
  void refresh() {
    state = state + 1;
  }
}

/// The [Provider] for the [EventsController].
final eventsControllerProvider = Provider((ref) {
  return EventsController(
    profile: ref.watch(profileStateProvider),
    eventsRefreshNotifier: ref.read(eventsRefreshProvider.notifier),
  );
});
