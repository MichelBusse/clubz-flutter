/// A data model for follow entries.
class Follow {
  String id;
  bool accepted;

  Follow({required this.id, required this.accepted});


  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Follow &&
            id == other.id &&
            accepted == other.accepted);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      accepted.hashCode;
}

/// Sorts a list of follow entries to put unaccepted first.
int sortFollowerList(Follow a, Follow b) {
  if (a.accepted && !b.accepted) {
    return 1;
  } else if (!a.accepted && b.accepted) {
    return -1;
  } else {
    return 0;
  }
}
