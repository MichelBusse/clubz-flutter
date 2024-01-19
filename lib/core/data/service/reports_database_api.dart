import 'package:clubz/features/general/data/models/event_report.dart';
import 'package:clubz/features/general/data/models/profile_report.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A class to hold all API functions for reports.
class ReportsDatabaseApi {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Inserts or updates a [profileReport].
  Future reportProfile({
    required ProfileReport profileReport,
  }) async {
    return supabase.from('profile_reports').upsert(profileReport.toMap());
  }

  /// Inserts or updates a [eventReport].
  Future reportEvent({
    required EventReport eventReport,
  }) async {
    return supabase.from('event_reports').upsert(eventReport.toMap());
  }
}
