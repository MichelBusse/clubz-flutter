/// A data model for reports of an event.
class EventReport {
  final String eventId;
  final String reporterId;
  final String reason;

  const EventReport({
    required this.eventId,
    required this.reporterId,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'reporter_id': reporterId,
      'reason': reason,
    };
  }
}
