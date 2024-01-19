import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/data/service/blocked_database_api.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:get_it/get_it.dart';

/// A class to provide all functions to control blocked profiles.
class BlockedController {
  final BlockedDatabaseApi _blockedDatabaseApi =
      GetIt.instance.get<BlockedDatabaseApi>();
  final Profile? userProfile;

  BlockedController({required this.userProfile});

  /// Blocks profile with [blockedId] for current user.
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current user is logged in.
  /// Throws [FrontendException] with [FrontendExceptionType.blockProfile] if blocking of profile fails.
  Future blockProfile(
      {required String blockedId}) async {
    if (userProfile == null) {
      throw FrontendException(type: FrontendExceptionType.notAuthenticated);
    }

    try {
      await _blockedDatabaseApi.blockProfile(
        profileId: userProfile!.id,
        blockedId: blockedId,
      );
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.blockProfile);
    }
  }
}
