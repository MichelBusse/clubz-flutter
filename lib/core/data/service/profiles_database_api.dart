import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/data/models/profile_stats.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A class to hold all API functions for profiles.
class ProfilesDatabaseApi {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Returns profile with [id].
  Future<Profile> getProfile({required String profileId}) async {
    // Selects:
    // profile information of requested profile,
    // a list of event ids which the requested profile attends,
    // a list of event ids which the requested profile is interested in,
    // a map of profile ids and accepted status for all following relations of other profiles that follow the requested profile,
    // a map of profile ids and accepted status for all following relations of other profiles that the requested profile follows,
    final data = await supabase
        .from(
          'profiles',
        )
        .select(
            '*, attending(event_id), interested(event_id), following:following!following_follower_id_fkey(id:following_id, accepted), follower:following!following_following_id_fkey(id:follower_id, accepted)')
        .eq(
          'id',
          profileId,
        )
        .single();

    return Profile.fromMap(map: data);
  }

  /// Returns profiles where username starts with [searchString] but is not the same [excludedUsername].
  ///
  /// Limits the result to rows within the range [from] - [to].
  Future<List<Profile>> searchProfilesByUsername({
    required String searchString,
    required String excludedUsername,
    required int from,
    required int to,
  }) async {
    final data = await supabase
        .from('profiles')
        .select('*, attending(event_id), interested(event_id)')
        .filter("username", "like", "$searchString%")
        .filter("username", "neq", excludedUsername)
        .range(from, to);

    final parsedData = List<Map>.from(data);

    return parsedData
        .map(
          (map) => Profile.fromMap(map: map),
        )
        .toList();
  }

  /// Returns followers of current user for query range [from] - [to].
  Future<List<Profile>> queryProfilesFollower({
    required int from,
    required int to,
  }) async {
    final data = await supabase
        .rpc(
          'query_profiles_follower',
        )
        .range(from, to);
    final parsedData = List<Map>.from(data);

    return parsedData
        .map(
          (map) => Profile.fromMap(map: map),
        )
        .toList();
  }

  /// Returns profiles which current user follows for query range [from] - [to].
  Future<List<Profile>> queryProfilesFollowing({
    required int from,
    required int to,
  }) async {
    final data = await supabase
        .rpc(
          'query_profiles_following',
        )
        .range(from, to);
    final parsedData = List<Map>.from(data);

    return parsedData
        .map(
          (map) => Profile.fromMap(map: map),
        )
        .toList();
  }

  /// Returns attending profiles of event with [eventId] for query range [from] - [to].
  Future<List<Profile>> queryProfilesAttending({
    required String eventId,
    required int from,
    required int to,
  }) async {
    final data = await supabase.rpc(
      'query_profiles_attending',
      params: {'filter_event_id': eventId},
    ).range(from, to);
    final parsedData = List<Map>.from(data);

    return parsedData
        .map(
          (map) => Profile.fromMap(map: map),
        )
        .toList();
  }

  /// Returns interested profiles of event with [eventId] for query range [from] - [to].
  Future<List<Profile>> queryProfilesInterested({
    required String eventId,
    required int from,
    required int to,
  }) async {
    final data = await supabase.rpc(
      'query_profiles_interested',
      params: {'filter_event_id': eventId},
    ).range(from, to);
    final parsedData = List<Map>.from(data);

    return parsedData
        .map(
          (map) => Profile.fromMap(map: map),
        )
        .toList();
  }

  /// Returns ProfileStatsData of profile with [id].
  Future<ProfileStats> getProfileStats({
    required String profileId,
  }) async {
    final data = await supabase.rpc(
      'get_profile_stats',
      params: {'filter_profile_id': profileId},
    );

    return ProfileStats.fromMap(map: data);
  }

  /// Updates profile with data from [data].
  Future updateProfile({required Map<dynamic, dynamic> data}) async {
    final user = supabase.auth.currentUser!;

    final updates = {
      ...data,
      'id': user.id,
    };

    return supabase.from('profiles').upsert(updates);
  }

  /// Requests to add current user to followers of [followingProfile].
  Future requestFollowing({required Profile followingProfile}) {
    final user = supabase.auth.currentUser!;

    final following = {
      'follower_id': user.id,
      'following_id': followingProfile.id,
      'accepted': followingProfile.publicProfile,
    };

    return supabase.from('following').insert(following);
  }

  /// Removes current user from followers of [followingProfile].
  Future removeFollowing({required Profile followingProfile}) {
    final user = supabase.auth.currentUser!;

    return supabase
        .from('following')
        .delete()
        .eq('follower_id', user.id)
        .eq('following_id', followingProfile.id);
  }

  /// Accepts [followerProfile] as follower of current user.
  Future acceptFollower({required Profile followerProfile}) {
    final user = supabase.auth.currentUser!;

    final updates = {
      'accepted': true,
    };

    return supabase
        .from('following')
        .update(updates)
        .eq('follower_id', followerProfile.id)
        .eq('following_id', user.id);
  }

  /// Removes [followerProfile] from followers of current user.
  Future removeFollower({required Profile followerProfile}) {
    final user = supabase.auth.currentUser!;

    return supabase
        .from('following')
        .delete()
        .eq('follower_id', followerProfile.id)
        .eq('following_id', user.id);
  }
}
