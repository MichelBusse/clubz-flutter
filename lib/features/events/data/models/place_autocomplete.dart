/// A data model for place autocomplete results from Google Places.
class PlaceAutocomplete {
  final String mainText;
  final String secondaryText;
  final String description;
  final String placeId;

  PlaceAutocomplete({required this.description, required this.placeId, required this.mainText, required this.secondaryText});

  factory PlaceAutocomplete.fromJson(Map<String, dynamic> json) {
    return PlaceAutocomplete(
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
      description: json['description'],
      placeId: json['place_id'],
    );
  }
}
