import 'package:supabase_flutter/supabase_flutter.dart';

/// A class to hold all API functions to block profiles.
class BlockedDatabaseApi {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Blocks profile with [blockedId] for user with [profileId].
  Future blockProfile(
      {required String profileId, required String blockedId}) async {
    return supabase.from('profiles_blocked').upsert({
      'profile_id': profileId,
      'blocked_id': blockedId,
    });
  }
}
