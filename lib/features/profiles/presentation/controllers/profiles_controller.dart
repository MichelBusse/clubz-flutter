import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/data/service/profiles_database_api.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/data/models/profile_stats.dart';
import 'package:get_it/get_it.dart';

/// A class to provide functions to fetch profiles.
class ProfilesFetchController {
  final ProfilesDatabaseApi _profilesDatabaseApi =
      GetIt.instance.get<ProfilesDatabaseApi>();

  /// Fetches the profile with [profileId].
  ///
  /// Throws a [FrontendException] with [FrontendExceptionType.getProfile] if the fetching of the profile fails.
  Future<Profile> getProfile({required String profileId}) async {
    late Profile profile;
    try {
      profile = await _profilesDatabaseApi.getProfile(profileId: profileId);
    } catch (e) {
      // Could not get profile from server
      throw FrontendException(type: FrontendExceptionType.getProfile);
    }

    return profile;
  }

  /// Fetches the stats of the profile with [profileId].
  ///
  /// Throws a [FrontendException] with [FrontendExceptionType.getProfileStats] if the fetching of the profile stats fails.
  Future<ProfileStats> getProfileStats({required String profileId}) async {
    try {
      ProfileStats profileStats = await _profilesDatabaseApi.getProfileStats(profileId: profileId);
      return profileStats;
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.getProfileStats);
    }
  }
}
