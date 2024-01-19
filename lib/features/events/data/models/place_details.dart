/// A data model for place details results from Google Places.
class PlaceDetails{
  final double lat;
  final double lng;

  PlaceDetails({required this.lat, required this.lng,});

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      lat: json['geometry']['location']['lat'],
      lng: json['geometry']['location']['lng'],
    );
  }

}