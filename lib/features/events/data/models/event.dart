import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A data model for events.
class Event {
  String? id;
  String eventName;
  DateTime startDatetime;
  DateTime endDatetime;
  String? imageUrl;
  String creatorId;
  List<Profile> attendingPreview = [];
  List<Profile> interestedPreview = [];
  String description;
  bool visible;
  Profile? creatorProfile;
  String placeDescription;
  String? location;
  int dressCode;
  String dressCodeDescription;
  int agePolicy;
  String agePolicyDescription;
  int pricePolicy;
  String pricePolicyDescription;
  double pricePolicyPrice;
  String pricePolicyLink;
  int attendingCount;
  int interestedCount;
  bool repeatWeekly;

  /// Available dressCode type.
  static final List<int> dressCodes = [0, 1, 2, 3];

  /// Converts dressCode type to its according string.
  static String dressCodeToString(BuildContext context, int dressCode) {
    String? dressCodeString;
    switch (dressCode) {
      case 3:
        dressCodeString = AppLocalizations.of(context)?.dressCode3;
        break;
      case 2:
        dressCodeString = AppLocalizations.of(context)?.dressCode2;
        break;
      case 1:
        dressCodeString = AppLocalizations.of(context)?.dressCode1;
        break;
      default:
        dressCodeString = AppLocalizations.of(context)?.dressCode0;
        break;
    }
    return dressCodeString ?? '';
  }

  /// Available agePolicy types.
  static final List<int> agePolicies = [0, 1, 2, 3, 4];

  /// Converts agePolicy type to its according string.
  static String agePolicyToString(BuildContext context, int agePolicy) {
    String? agePolicyString;
    switch (agePolicy) {
      case 4:
        agePolicyString = AppLocalizations.of(context)?.agePolicy4;
        break;
      case 3:
        agePolicyString = AppLocalizations.of(context)?.agePolicy3;
        break;
      case 2:
        agePolicyString = AppLocalizations.of(context)?.agePolicy2;
        break;
      case 1:
        agePolicyString = AppLocalizations.of(context)?.agePolicy1;
        break;
      default:
        agePolicyString = AppLocalizations.of(context)?.agePolicy0;
        break;
    }
    return agePolicyString ?? '';
  }

  /// Available pricePolicy types.
  static final List<int> pricePolicies = [0, 1, 2, 3];

  /// Converts pricePolicy type to its according string.
  static String pricePolicyToString(BuildContext context, int pricePolicy) {
    String? pricePolicyString;
    switch (pricePolicy) {
      case 3:
        pricePolicyString = AppLocalizations.of(context)?.pricePolicy3;
        break;
      case 2:
        pricePolicyString = AppLocalizations.of(context)?.pricePolicy2;
        break;
      case 1:
        pricePolicyString = AppLocalizations.of(context)?.pricePolicy1;
        break;
      default:
        pricePolicyString = AppLocalizations.of(context)?.pricePolicy0;
        break;
    }
    return pricePolicyString ?? '';
  }

  Event({
    this.id,
    required this.eventName,
    required this.startDatetime,
    required this.endDatetime,
    this.imageUrl,
    required this.creatorId,
    List<Profile>? attendingPreview,
    List<Profile>? interestedPreview,
    required this.description,
    required this.visible,
    this.creatorProfile,
    required this.placeDescription,
    this.location,
    required this.dressCode,
    required this.dressCodeDescription,
    required this.agePolicy,
    required this.agePolicyDescription,
    required this.pricePolicy,
    required this.pricePolicyDescription,
    required this.pricePolicyPrice,
    required this.pricePolicyLink,
    this.attendingCount = 0,
    this.interestedCount = 0,
    required this.repeatWeekly,
  }) {
    this.attendingPreview = attendingPreview ?? [];
    this.interestedPreview = interestedPreview ?? [];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          id == other.id &&
          runtimeType == other.runtimeType &&
          eventName == other.eventName &&
          startDatetime == other.startDatetime &&
          endDatetime == other.endDatetime &&
          creatorId == other.creatorId &&
          imageUrl == other.imageUrl &&
          visible == other.visible &&
          description == other.description &&
          creatorId == other.creatorId &&
          placeDescription == other.placeDescription &&
          location == other.location &&
          listEquals(attendingPreview, other.attendingPreview) &&
          listEquals(interestedPreview, other.interestedPreview) &&
          dressCode == other.dressCode &&
          dressCodeDescription == other.dressCodeDescription &&
          agePolicy == other.agePolicy &&
          agePolicyDescription == other.agePolicyDescription &&
          pricePolicy == other.pricePolicy &&
          pricePolicyDescription == other.pricePolicyDescription &&
          pricePolicyPrice == other.pricePolicyPrice &&
          pricePolicyLink == other.pricePolicyLink &&
          attendingCount == other.attendingCount &&
          interestedCount == other.interestedCount &&
          repeatWeekly == other.repeatWeekly);

  @override
  int get hashCode =>
      id.hashCode ^
      eventName.hashCode ^
      startDatetime.hashCode ^
      endDatetime.hashCode ^
      creatorId.hashCode ^
      imageUrl.hashCode ^
      visible.hashCode ^
      description.hashCode ^
      attendingPreview.hashCode ^
      interestedPreview.hashCode ^
      placeDescription.hashCode ^
      location.hashCode ^
      dressCode.hashCode ^
      dressCodeDescription.hashCode ^
      agePolicy.hashCode ^
      agePolicyDescription.hashCode ^
      pricePolicy.hashCode ^
      pricePolicyDescription.hashCode ^
      pricePolicyPrice.hashCode ^
      pricePolicyLink.hashCode ^
      attendingCount.hashCode ^
      interestedCount.hashCode ^
      repeatWeekly.hashCode;

  @override
  String toString() {
    return 'Event{'
        ' eventName: $eventName,'
        ' startDatetime: $startDatetime'
        ' endDatetime: $endDatetime'
        ' creatorId: $creatorId'
        ' imageUrl: $imageUrl'
        ' visibility: $visible'
        ' description: $description'
        ' attendingPreview: $attendingPreview'
        ' interestedPreview: $interestedPreview'
        ' placeDescription: $placeDescription'
        ' location: $location'
        ' dressCode: $dressCode'
        ' dressCodeDescription: $dressCodeDescription'
        ' agePolicy: $agePolicy'
        ' agePolicyDescription: $agePolicyDescription'
        ' pricePolicy: $pricePolicy'
        ' pricePolicyDescription: $pricePolicyDescription'
        ' pricePolicyPrice: $pricePolicyPrice'
        ' pricePolicyLink: $pricePolicyLink'
        ' attendingCount: $attendingCount'
        ' interestedCount: $interestedCount'
        ' repeatWeekly: $repeatWeekly'
        '}';
  }

  Event copyWith({
    String? eventName,
    DateTime? startDatetime,
    DateTime? endDatetime,
    String? imageUrl,
    String? creatorId,
    List<Profile>? attendingPreview,
    List<Profile>? interestedPreview,
    String? description,
    bool? visible,
    Profile? creatorProfile,
    String? placeDescription,
    String? location,
    int? dressCode,
    String? dressCodeDescription,
    int? agePolicy,
    String? agePolicyDescription,
    int? pricePolicy,
    String? pricePolicyDescription,
    double? pricePolicyPrice,
    String? pricePolicyLink,
    bool? repeatWeekly,
  }) {
    return Event(
      id: id,
      eventName: eventName ?? this.eventName,
      startDatetime: startDatetime ?? this.startDatetime,
      endDatetime: endDatetime ?? this.endDatetime,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorId: creatorId ?? this.creatorId,
      attendingPreview: attendingPreview ?? this.attendingPreview,
      interestedPreview: interestedPreview ?? this.interestedPreview,
      description: description ?? this.description,
      visible: visible ?? this.visible,
      creatorProfile: creatorProfile ?? this.creatorProfile,
      placeDescription: placeDescription ?? this.placeDescription,
      // If location string is empty, set location to null.
      location: location != null
          ? location.trim().isNotEmpty
              ? location
              : null
          : this.location,
      dressCode: dressCode ?? this.dressCode,
      dressCodeDescription: dressCodeDescription ?? this.dressCodeDescription,
      agePolicy: agePolicy ?? this.agePolicy,
      agePolicyDescription: agePolicyDescription ?? this.agePolicyDescription,
      pricePolicy: pricePolicy ?? this.pricePolicy,
      pricePolicyDescription:
          pricePolicyDescription ?? this.pricePolicyDescription,
      pricePolicyPrice: pricePolicyPrice ?? this.pricePolicyPrice,
      pricePolicyLink: pricePolicyLink ?? this.pricePolicyLink,
      repeatWeekly: repeatWeekly ?? this.repeatWeekly,
    );
  }

  Map<dynamic, dynamic> toMap() {
    Map<dynamic, dynamic> map = {
      'event_name': eventName,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
      'image_url': imageUrl,
      'creator_id': creatorId,
      'description': description,
      'visible': visible,
      'place_description': placeDescription,
      'location': location,
      'dress_code': dressCode,
      'dress_code_description': dressCodeDescription,
      'age_policy': agePolicy,
      'age_policy_description': agePolicyDescription,
      'price_policy': pricePolicy,
      'price_policy_description': pricePolicyDescription,
      'price_policy_price': pricePolicyPrice,
      'price_policy_link': pricePolicyLink,
      'repeat_weekly': repeatWeekly,
    };

    // Only set id field if id is not null.
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory Event.fromMap({
    required Map<dynamic, dynamic> map,
  }) {
    return Event(
      id: map['id'] as String,
      eventName: map['event_name'] as String,
      startDatetime: DateTime.parse(map['start_datetime']),
      endDatetime: DateTime.parse(map['end_datetime']),
      imageUrl: map['image_url'],
      creatorId: map['creator_id'],
      description: map['description'],
      visible: map['visible'],
      attendingPreview: map['attending_preview'] != null ? List<Map<dynamic, dynamic>>.from(map['attending_preview'])
          .map((attending) => Profile.fromMap(map: attending))
          .toList() : [],
      interestedPreview: map['interested_preview'] != null ? List<Map<dynamic, dynamic>>.from(map['interested_preview'])
          .map((interested) => Profile.fromMap(map: interested))
          .toList() : [],
      creatorProfile:
          map['creator'] != null ? Profile.fromMap(map: map['creator']) : null,
      placeDescription: map['place_description'],
      location: map['location'],
      dressCode: map['dress_code'],
      dressCodeDescription: map['dress_code_description'],
      agePolicy: map['age_policy'],
      agePolicyDescription: map['age_policy_description'],
      pricePolicy: map['price_policy'],
      pricePolicyDescription: map['price_policy_description'],
      pricePolicyPrice: double.parse(map['price_policy_price'].toString()),
      pricePolicyLink: map['price_policy_link'],
      attendingCount: map['attending_count'] ?? 0,
      interestedCount: map['interested_count'] ?? 0,
      repeatWeekly: map['repeat_weekly'],
    );
  }
}
