/// A data model for event location details.
class EventLocationDetails {
  final String description;
  final double lat;
  final double lng;

  const EventLocationDetails({
    required this.description,
    required this.lat,
    required this.lng,
  });
}