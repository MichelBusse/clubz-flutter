import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/data/service/reports_database_api.dart';
import 'package:clubz/features/general/data/models/event_report.dart';
import 'package:clubz/features/general/data/models/profile_report.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:get_it/get_it.dart';

/// A class to provide all functions to control reports of profiles and events.
class ReportsController {
  final ReportsDatabaseApi _reportsDatabaseApi =
  GetIt.instance.get<ReportsDatabaseApi>();
  final Profile? userProfile;

  ReportsController({required this.userProfile});

  /// Reports a profile with [profileId] for [reason].
  ///
  /// Throws a [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current user is logged in.
  /// Throws a [FrontendException] with [FrontendExceptionType.reportProfile] if report of profile fails.
  Future reportProfile({required String profileId, String? reason}) async {
    if (userProfile == null) {
      throw FrontendException(type: FrontendExceptionType.notAuthenticated);
    }

    ProfileReport report = ProfileReport(
      reporterId: userProfile!.id,
      profileId: profileId,
      reason: reason ?? '',
    );
    try {
      await _reportsDatabaseApi.reportProfile(profileReport: report);
    }catch(e) {
      throw FrontendException(type: FrontendExceptionType.reportProfile);
    }
  }

  /// Reports an event with [eventId] for [reason].
  ///
  /// Throws a [FrontendException] with [FrontendExceptionType.notAuthenticated] if no current user is logged in.
  /// Throws a [FrontendException] with [FrontendExceptionType.reportEvent] if report of event fails.
  Future reportEvent({required String eventId, String? reason}) async {
    if (userProfile == null) {
      throw FrontendException(type: FrontendExceptionType.notAuthenticated);
    }

    EventReport report = EventReport(
      reporterId: userProfile!.id,
      eventId: eventId,
      reason: reason ?? '',
    );
    try {
      await _reportsDatabaseApi.reportEvent(eventReport: report);
    }catch(e) {
      throw FrontendException(type: FrontendExceptionType.reportEvent);
    }
  }
}
