/// A data model for the stats data of profiles.
class ProfileStats {
  final int follower;
  final int score;
  final int events;

  const ProfileStats({this.follower = 0, this.score = 0, this.events = 0});


  factory ProfileStats.fromMap({required Map<dynamic, dynamic> map}) {
    return ProfileStats(
      follower: map['follower'],
      score: map['score'],
      events: map['events'],
    );
  }
}