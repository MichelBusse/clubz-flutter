import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/data/service/events_database_api.dart';
import 'package:clubz/core/data/service/profiles_database_api.dart';
import 'package:clubz/features/events/data/models/event_state_type.dart';
import 'package:clubz/features/profiles/data/models/follow.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// A [StateNotifier] for notification of changes of the current user profile.
class ProfileStateNotifier extends StateNotifier<Profile?> {
  final supabase.Session? currentSession;
  final _profilesDatabaseApi = GetIt.instance.get<ProfilesDatabaseApi>();
  final _eventsDatabaseApi = GetIt.instance.get<EventsDatabaseApi>();
  supabase.RealtimeChannel? _onProfileChangeSubscription;

  ProfileStateNotifier({required this.currentSession}) : super(null) {
    getProfile().catchError((_) => null);
  }

  @override
  void dispose() {
    super.dispose();

    _unsubscribeFromProfileChanges();
  }

  /// Fetches profile of current user if user is logged in.
  ///
  /// Throws a [FrontendException] with [FrontendExceptionType.profileNotFound] if fetching of the profile fails.
  Future<Profile?> getProfile() async {
    // Set state to null if no user is signed in.
    if (supabase.Supabase.instance.client.auth.currentUser == null) {
      state = null;
      _unsubscribeFromProfileChanges();
      return state;
    }

    try {
      Profile profile = await _profilesDatabaseApi.getProfile(
          profileId: supabase.Supabase.instance.client.auth.currentUser!.id);
      if (mounted) {
        if (!(state == profile)) {
          state = profile;
        }
      }
    } catch (e) {
      if (mounted) {
        state = null;
      }
      throw FrontendException(type: FrontendExceptionType.profileNotFound);
    }

    if (!mounted) {
      return null;
    }

    _subscribeToProfileChanges();

    return state;
  }

  /// Subscribes to realtime changes of the current user profile, follower and followings.
  _subscribeToProfileChanges() async {
    if (state == null || _onProfileChangeSubscription != null) return;

    _onProfileChangeSubscription = supabase.Supabase.instance.client
        .channel('profile-changes')
        // Listen for updates of own profile.
        .onPostgresChanges(
            event: supabase.PostgresChangeEvent.update,
            schema: 'public',
            table: 'profiles',
            filter: supabase.PostgresChangeFilter(
                type: supabase.PostgresChangeFilterType.eq,
                column: 'id',
                value: state!.id),
            callback: (payload, [ref]) {
              if (mounted) {
                state = state?.copyWithMap(map: payload.newRecord);
              }
            })
        // Listen for changes of following entries where follower_id is current profile id.
        .onPostgresChanges(
            event: supabase.PostgresChangeEvent.all,
            schema: 'public',
            table: 'following',
            filter: supabase.PostgresChangeFilter(
              type: supabase.PostgresChangeFilterType.eq,
              column: 'follower_id',
              value: state!.id,
            ),
            callback: (payload, [ref]) {
              if (mounted) {
                List<Follow> newFollowing = state!.following;
                Map<String, dynamic> oldEntry = payload.oldRecord;
                Map<String, dynamic> newEntry = payload.newRecord;

                // Remove local copy of new entry.
                if (oldEntry['following_id'] != null) {
                  newFollowing.removeWhere(
                      (follow) => follow.id == oldEntry['following_id']);
                }

                // Add local copy of new entry.
                if (newEntry['following_id'] != null) {
                  newFollowing.add(Follow(
                    id: newEntry['following_id'],
                    accepted: newEntry['accepted'],
                  ));
                }

                state = state?.copyWith(following: newFollowing);
              }
            })
        // Listen for changes of following entries where following_id is current profile id.
        .onPostgresChanges(
            event: supabase.PostgresChangeEvent.all,
            schema: 'public',
            table: 'following',
            filter: supabase.PostgresChangeFilter(
              type: supabase.PostgresChangeFilterType.eq,
              column: 'following_id',
              value: state!.id,
            ),
            callback: (payload, [ref]) {
              if (mounted) {
                List<Follow> newFollower = state!.follower;
                Map<String, dynamic> oldEntry = payload.oldRecord;
                Map<String, dynamic> newEntry = payload.newRecord;

                // Remove local copy of old entry.
                if (oldEntry['follower_id'] != null) {
                  newFollower.removeWhere(
                      (follow) => follow.id == oldEntry['follower_id']);
                }

                // Remove local copy of new entry.
                if (newEntry['follower_id'] != null) {
                  newFollower.add(Follow(
                    id: newEntry['follower_id'],
                    accepted: newEntry['accepted'],
                  ));
                }

                state = state?.copyWith(follower: newFollower);
              }
            });
    _onProfileChangeSubscription!.subscribe();
  }

  /// Unsubscribes from realtime changes.
  _unsubscribeFromProfileChanges() async {
    if (_onProfileChangeSubscription != null) {
      await supabase.Supabase.instance.client
          .removeChannel(_onProfileChangeSubscription!);

      _onProfileChangeSubscription = null;
    }
  }

  /// Changes profile avatar.
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current profile exists.
  /// Throws [FrontendException] with [FrontendExceptionType.changeProfilePicture] if changing of profile avatar fails.
  Future<String> _changeAvatar(MemoryImage image) async {
    if (state == null) {
      throw FrontendException(type: FrontendExceptionType.notAuthenticated);
    }

    try {
      final supabase.SupabaseClient client = supabase.Supabase.instance.client;

      // Upload avatar image.
      await client.storage.from('avatars').uploadBinary(
            state!.id,
            image.bytes,
            fileOptions: const supabase.FileOptions(upsert: true),
          );

      // Create signed url for avatar image.
      final imageUrlResponse = await client.storage
          .from('avatars')
          .createSignedUrl(state!.id, 60 * 60 * 24 * 365 * 10);

      return imageUrlResponse;
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.changeProfilePicture);
    }
  }

  /// Updates profile of current user.
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current profile exists.
  /// Throws [FrontendException] with [FrontendExceptionType.updateProfile] if update of profile fails.
  Future<bool> updateProfile({
    String? userName,
    String? displayName,
    bool? publicProfile,
    MemoryImage? profilePicture,
    bool pictureChanged = false,
  }) async {
    if (state == null) {
      throw FrontendException(type: FrontendExceptionType.notAuthenticated);
    }

    String? imageUrlResponse;

    // Check if profile avatar should be changed.
    if (pictureChanged && profilePicture != null) {
      imageUrlResponse = await _changeAvatar(profilePicture);
    }

    // Insert updated data.
    Profile overwrittenProfile = state?.copyWith(
      username: userName,
      fullName: displayName,
      avatarUrl: imageUrlResponse, // avatarUrl is only changed when imageUrlResponse is set.
      publicProfile: publicProfile,
    );

    if (state == overwrittenProfile) {
      return true;
    }

    try {
      // Save updated changes.
      await _profilesDatabaseApi.updateProfile(
          data: overwrittenProfile.toMap());

      await getProfile();

      return true;
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.updateProfile);
    }
  }

  /// Accepts [followerProfile] as follower of current user.
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current profile exists.
  /// Throws [FrontendException] with [FrontendExceptionType.cancelFollowRequest] if accepting of follower fails.
  Future acceptFollower(Profile followerProfile) async {
    if (state == null) {
      throw FrontendException(
        type: FrontendExceptionType.notAuthenticated,
      );
    }

    try {
      await _profilesDatabaseApi.acceptFollower(
          followerProfile: followerProfile);

      await getProfile();
    } catch (e) {
      throw FrontendException(
        type: FrontendExceptionType.cancelFollowRequest,
      );
    }
  }

  /// Requests to follow [followingProfile].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current profile exists.
  /// Throws [FrontendException] with [FrontendExceptionType.sendFollowRequest] if request of following fails.
  Future requestFollowing(Profile followingProfile) async {
    if (state == null) {
      throw FrontendException(
        type: FrontendExceptionType.notAuthenticated,
      );
    }

    try {
      await _profilesDatabaseApi.requestFollowing(
          followingProfile: followingProfile);

      await getProfile();
    } catch (e) {
      throw FrontendException(
        type: FrontendExceptionType.sendFollowRequest,
      );
    }
  }

  /// Removes [followerProfile] from followers of current user.
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current profile exists.
  /// Throws [FrontendException] with [FrontendExceptionType.removeFollower] if removal of follower fails.
  Future removeFollower(Profile followerProfile) async {
    if (state == null) {
      throw FrontendException(
        type: FrontendExceptionType.notAuthenticated,
      );
    }

    try {
      await _profilesDatabaseApi.removeFollower(
          followerProfile: followerProfile);

      await getProfile();
    } catch (e) {
      throw FrontendException(
        type: FrontendExceptionType.removeFollower,
      );
    }
  }

  /// Removes current user from followers of [followingProfile].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current profile exists.
  /// Throws [FrontendException] with [FrontendExceptionType.removeFollowing] if removal of following fails.
  Future removeFollowing(Profile followingProfile) async {
    if (state == null) {
      throw FrontendException(
        type: FrontendExceptionType.notAuthenticated,
      );
    }

    try {
      await _profilesDatabaseApi.removeFollowing(
          followingProfile: followingProfile);

      await getProfile();
    } catch (e) {
      throw FrontendException(
        type: FrontendExceptionType.removeFollowing,
      );
    }
  }

  /// Toggles state of [type] ('interested' or 'attending') to [newValue] of event with [eventId] for current user.
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current profile exists.
  /// Throws [FrontendException] with [FrontendExceptionType.toggleEventState] if toggle of event state fails.
  Future toggleEventState(
      {required EventStateType type,
      required String eventId,
      required bool newValue}) async {
    if (state == null) {
      throw FrontendException(
        type: FrontendExceptionType.notAuthenticated,
      );
    }

    try {
      // Toggles event status in backend.
      await _eventsDatabaseApi.toggleStatus(type, eventId, newValue);

      // Toggles event status locally in state.
      if (type == EventStateType.interested) {
        List<String> updatedInterested = state!.interested;

        if (newValue) {
          updatedInterested.add(eventId);
        } else if (updatedInterested.contains(eventId)) {
          updatedInterested.remove(eventId);
        }
        state = state?.copyWith(interested: updatedInterested);
      } else if (type == EventStateType.attending) {
        List<String> updatedAttending = state!.attending;

        if (newValue) {
          updatedAttending.add(eventId);
        } else if (updatedAttending.contains(eventId)) {
          updatedAttending.remove(eventId);
        }
        state = state?.copyWith(attending: updatedAttending);
      }
    } catch (e) {
      throw FrontendException(
        type: FrontendExceptionType.toggleEventState,
      );
    }
  }
}
