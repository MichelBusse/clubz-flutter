import 'package:clubz/features/profiles/data/models/follow.dart';
import 'package:flutter/foundation.dart';

/// A data model for follow entries.
class Profile {
  String id;
  String? fullName;
  String? username;
  String? avatarUrl;
  bool publicProfile;
  List<String> attending = [];
  List<String> interested = [];
  List<Follow> following = [];
  List<Follow> follower = [];

//<editor-fold desc="Data Methods">

  Profile({
    required this.id,
    this.fullName,
    this.username,
    this.avatarUrl,
    this.publicProfile = false,
    List<String>? attending,
    List<String>? interested,
    List<Follow>? following,
    List<Follow>? follower,
  }) {
    this.attending = attending ?? [];
    this.interested = interested ?? [];
    this.following = following ?? [];
    this.follower = follower ?? [];
  }

  /// Returns whether the essential fields of the profile have been initialized.
  bool isInitialized(){
    return fullName != null && fullName!.isNotEmpty && username != null && username!.isNotEmpty;
  }

  copyWith({
    String? fullName,
    String? username,
    bool? publicProfile,
    String? avatarUrl,
    List<String>? attending,
    List<String>? interested,
    List<Follow>? following,
    List<Follow>? follower,
  }) {
    follower?.sort(sortFollowerList);
    following?.sort(sortFollowerList);

    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      publicProfile: publicProfile ?? this.publicProfile,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      attending: attending ?? this.attending,
      interested: interested ?? this.interested,
      following: following ?? this.following,
      follower: follower ?? this.follower,
    );
  }

  copyWithMap({
    required Map<dynamic, dynamic> map,
  }) {
    List<Follow> follower = map['follower'] != null
        ? List<Map<String, dynamic>>.from(map['follower'])
            .map((e) => Follow(id: e['id'], accepted: e['accepted']))
            .toList()
        : [];

    List<Follow> following = map['following'] != null
        ? List<Map<String, dynamic>>.from(map['following'])
            .map((e) => Follow(id: e['id'], accepted: e['accepted']))
            .toList()
        : [];

    follower.sort(sortFollowerList);
    following.sort(sortFollowerList);

    return copyWith(
      fullName: map['full_name'] ?? fullName,
      username: map['username'] ?? username,
      publicProfile: map['public_profile'] ?? publicProfile,
      avatarUrl: map['avatar_url'] ?? avatarUrl,
      attending: map['attending'] != null
          ? List<Map<dynamic, dynamic>>.from(map['attending'])
              .map((attending) => attending['event_id'] as String)
              .toList()
          : attending,
      interested: map['interested'] != null
          ? List<Map<dynamic, dynamic>>.from(map['interested'])
          .map((interested) => interested['event_id'] as String)
          .toList()
          : interested,
      following: following,
      follower: follower,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'public_profile': publicProfile,
    };
  }

  factory Profile.fromMap({required Map<dynamic, dynamic> map}) {
    List<Follow> follower = map['follower'] != null
        ? List<Map<String, dynamic>>.from(map['follower'])
            .map((e) => Follow(id: e['id'], accepted: e['accepted']))
            .toList()
        : [];

    List<Follow> following = map['following'] != null
        ? List<Map<String, dynamic>>.from(map['following'])
            .map((e) => Follow(id: e['id'], accepted: e['accepted']))
            .toList()
        : [];

    follower.sort(sortFollowerList);
    following.sort(sortFollowerList);

    return Profile(
      id: map['id'],
      fullName: map['full_name'],
      username: map['username'],
      avatarUrl: map['avatar_url'],
      publicProfile: map['public_profile'],
      attending: map['attending'] != null
          ? List<Map<dynamic, dynamic>>.from(map['attending'])
              .map((attending) => attending['event_id'] as String)
              .toList()
          : [],
      interested: map['interested'] != null
          ? List<Map<dynamic, dynamic>>.from(map['interested'])
          .map((interested) => interested['event_id'] as String)
          .toList()
          : [],
      following: following,
      follower: follower,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Profile &&
            id == other.id &&
            fullName == other.fullName &&
            username == other.username &&
            avatarUrl == other.avatarUrl &&
            publicProfile == other.publicProfile &&
            listEquals(attending, other.attending) &&
            listEquals(following, other.following) &&
            listEquals(follower, other.follower));
  }

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      username.hashCode ^
      avatarUrl.hashCode ^
      publicProfile.hashCode ^
      following.hashCode ^
      follower.hashCode ^
      attending.hashCode;

//</editor-fold>
}