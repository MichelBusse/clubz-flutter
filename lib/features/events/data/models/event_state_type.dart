
/// An enum for status types of events concerning the user ([interested], [attending]).
enum EventStateType {
  interested,
  attending
}

/// An extension to convert an [EventStateType] to its string.
extension ConvertToString on EventStateType {
  String toShortString() {
    return toString().split('.').last;
  }
}