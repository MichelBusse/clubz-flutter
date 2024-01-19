import 'package:clubz/core/utils/string_casing_extension.dart';

/// A data model for filter location details.
class FilterLocationDetails {
  final String description;
  final double lat;
  final double lng;

  const FilterLocationDetails({
    required this.description,
    required this.lat,
    required this.lng,
  });

  factory FilterLocationDetails.fromJson(Map<String, dynamic> json) {
    return FilterLocationDetails(
      description: json['description'].toString().toTitleCase(),
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
    );
  }
}