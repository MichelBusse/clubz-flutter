/// A data model for reports of a profile.
class ProfileReport {
  final String profileId;
  final String reporterId;
  final String reason;

  const ProfileReport({
    required this.profileId,
    required this.reporterId,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'reporter_id': reporterId,
      'reason': reason,
    };
  }
}
