import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/data/models/event_state_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Implement event images.

/// A class to hold all API functions for events.
class EventsDatabaseApi {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Returns event with [eventId].
  Future<Event> getEvent({required String eventId}) async {
    final data = await supabase.rpc(
      'get_event',
      params: {
        'filter_event_id': eventId,
      },
    ).single();

    return Event.fromMap(map: data);
  }

  /// Returns events created by user with [creatorId] which end before [endDatetime]
  /// for query range [from] - [to].
  Future<List<Event>> queryEventsProfilePast({
    required String creatorId,
    required String endDatetime,
    required int from,
    required int to,
  }) async {
    final data = await supabase.rpc(
      'query_events_profile_past',
      params: {
        'filter_creator_id': creatorId,
        'filter_end_datetime': endDatetime,
      },
    ).range(from, to);

    final parsedData = List<Map>.from(data);

    return parsedData
        .map(
          (map) => Event.fromMap(map: map),
        )
        .toList();
  }

  /// Returns events of [creatorId] which end after [endDatetime] (included)
  /// for query range [from] - [to].
  Future<List<Event>> queryEventsProfileUpcoming({
    required String creatorId,
    required String endDatetime,
    required int from,
    required int to,
  }) async {
    final data = await supabase.rpc(
      'query_events_profile_upcoming',
      params: {
        'filter_creator_id': creatorId,
        'filter_end_datetime': endDatetime,
      },
    ).range(from, to);

    final parsedData = List<Map>.from(data);

    return parsedData
        .map(
          (map) => Event.fromMap(map: map),
        )
        .toList();
  }

  /// Returns events at coordinates [lat], [lng] within [radius] which end after [endDatetime] (included)
  /// for query range [from] - [to].
  Future<List<Event>> queryEventsFeed({
    required double lat,
    required double lng,
    required int radius,
    required String endDatetime,
    required int from,
    required int to,
  }) async {
    final data = await supabase.rpc(
      'query_events_feed',
      params: {
        'filter_location': 'POINT($lng $lat)',
        'filter_radius': radius,
        'filter_end_datetime': endDatetime,
      },
    ).range(from, to);

    final parsedData = List<Map>.from(data);

    return parsedData
        .map(
          (map) => Event.fromMap(map: map),
        )
        .toList();
  }

  /// Inserts or updates event with data from [event].
  Future<Event> upsertEvent({
    required Event event,
  }) async {
    final data =
        await supabase.from('events').upsert(event.toMap()).select().single();

    return Event.fromMap(map: data);
  }

  /// Deletes event with [eventId].
  Future deleteEvent({required String eventId}) async {
    return supabase.from('events').delete().eq('id', eventId);
  }

  /// Toggles state of [type] ('interested' or 'attending') to [newValue] of event with [eventId] for current user.
  Future toggleStatus(
      EventStateType type, String eventId, bool newValue) async {
    final user = supabase.auth.currentUser!;

    // Insert or update status relation if newValue is true, delete status relation if newValue is false.
    if (newValue) {
      return supabase.from(type.toShortString()).upsert({
        'event_id': eventId,
        'profile_id': user.id,
      });
    } else {
      return supabase
          .from(type.toShortString())
          .delete()
          .eq(
            'event_id',
            eventId,
          )
          .eq(
            'profile_id',
            user.id,
          );
    }
  }
}
