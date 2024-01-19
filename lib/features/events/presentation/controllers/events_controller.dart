import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/data/service/events_database_api.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/utils/random_string.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Implement event images.

/// A class to provide all functions to control events.
class EventsController {
  final EventsDatabaseApi _eventsDatabaseApi =
      GetIt.instance.get<EventsDatabaseApi>();
  final Profile? profile;
  final RefreshNotifier eventsRefreshNotifier;

  EventsController(
      {required this.profile, required this.eventsRefreshNotifier});

  Future<String> _changeEventThumbnail(
      String eventId, MemoryImage image) async {
    if (profile == null) {
      throw FrontendException(type: FrontendExceptionType.notAuthenticated);
    }

    try {
      final SupabaseClient client = Supabase.instance.client;

      // Upload event thumbnail.
      await client.storage.from('event-images').uploadBinary(
            '${profile!.id}/$eventId/thumbnail',
            image.bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get signed url of event thumbnail.
      final imageUrlResponse =
          await client.storage.from('event-images').createSignedUrl(
                '${profile!.id}/$eventId/thumbnail',
                60 * 60 * 24 * 365 * 10,
              );

      return imageUrlResponse;
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.changeEventThumbnail);
    }
  }

  /// Adds [image] to images of [event].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current user is logged in.
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthorized] if current user is not creator of event.
  /// Throws [FrontendException] with [FrontendExceptionType.addEventImage] if addition of image to event fails.
  Future<bool> addEventImage(Event event, MemoryImage image) async {
    if (profile == null) {
      throw FrontendException(type: FrontendExceptionType.notAuthenticated);
    }
    if (event.creatorId != profile!.id) {
      throw FrontendException(type: FrontendExceptionType.notAuthorized);
    }

    try {
      final SupabaseClient client = Supabase.instance.client;

      String imageId = getRandomString(25);

      // Upload event image.
      await client.storage.from('event-images').uploadBinary(
            '${event.creatorId}/${event.id!}/$imageId',
            image.bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return true;
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.addEventImage);
    }
  }

  /// Removes image with [imageId] from images of [event].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current user is logged in.
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthorized] if current user is not creator of event.
  /// Throws [FrontendException] with [FrontendExceptionType.removeEventImage] if removal of image from event fails.
  Future<bool> removeEventImage(Event event, String imageId) async {
    if (profile == null) {
      throw FrontendException(type: FrontendExceptionType.notAuthenticated);
    }
    if (event.creatorId != profile!.id) {
      throw FrontendException(type: FrontendExceptionType.notAuthorized);
    }

    try {
      final SupabaseClient client = Supabase.instance.client;

      await client.storage.from('event-images').remove(
        ['${event.creatorId}/${event.id!}/$imageId'],
      );

      return true;
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.removeEventImage);
    }
  }

  /// Returns list of URLs for images of [event].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.getEventImagesURLs] if fetching fails.
  Future<List<String>> getEventImagesURLs(Event event,) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      // Get list of file names in event images folder.
      List<FileObject> images = await client.storage.from('event-images').list(
        path: '${event.creatorId}/${event.id}',
      );

      // Create urls for event images.
      List<SignedUrl> imageUrls = await client.storage.from('event-images').createSignedUrls(images.map((e) => '${event.creatorId}/${event.id}/${e.name}').toList(), 60 * 60 * 24 * 365 * 10,);

      return imageUrls.map((e) => e.signedUrl).toList();
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.getEventImagesURLs);
    }
  }

  /// Inserts or updates [event].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current user is logged in.
  /// Throws [FrontendException] with [FrontendExceptionType.upsertEvent] if update of event fails.
  Future<bool> upsertEvent({
    required Event event,
    MemoryImage? image,
  }) async {
    if (profile == null) {
      throw FrontendException(type: FrontendExceptionType.notAuthenticated);
    }

    try {
      // Perform first upsert if event has no id (new event) or if image has not changed.
      if(event.id == null || image == null) {
        event = await _eventsDatabaseApi.upsertEvent(
            event: event);
      }

      // Change image and upsert event if image has changed and event has id.
      if (image != null && event.id != null) {
        String imageUrl = await _changeEventThumbnail(event.id!, image);
        event.imageUrl = imageUrl;

        await _eventsDatabaseApi.upsertEvent(event: event);
      }

      eventsRefreshNotifier.refresh();
      return true;
    }on FrontendException{
      rethrow;
    }catch (e) {
      throw FrontendException(type: FrontendExceptionType.upsertEvent);
    }
  }

  /// Returns event with [eventId].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.getEvent] if fetching of event fails.
  Future<Event> getEvent({required String eventId}) async {
    try {
      Event event = await _eventsDatabaseApi.getEvent(eventId: eventId);
      return event;
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.getEvent);
    }
  }

  /// Deletes [event].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current user is logged in.
  /// Throws [FrontendException] with [FrontendExceptionType.eventWithoutId] if [event] has no id.
  /// Throws [FrontendException] with [FrontendExceptionType.deleteEvent] if update of event fails.
  Future<bool> deleteEvent({required Event event}) async {
    if (profile == null) {
      throw FrontendException(type: FrontendExceptionType.notAuthenticated);
    }
    if (event.id == null) {
      throw FrontendException(type: FrontendExceptionType.eventWithoutId);
    }

    try {
      // Delete all event images.
      if (event.imageUrl != null) {
        final SupabaseClient client = Supabase.instance.client;

        final List<FileObject> files =
            await client.storage.from('event-images').list(
                  path: '${profile!.id}/${event.id!}',
                );

        await client.storage.from('event-images').remove(
            files.map((e) => '${profile!.id}/${event.id!}/${e.name}').toList());
      }

      // Delete event.
      await _eventsDatabaseApi.deleteEvent(eventId: event.id!);

      eventsRefreshNotifier.refresh();
      return true;
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.deleteEvent);
    }
  }
}
