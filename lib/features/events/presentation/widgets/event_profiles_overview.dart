import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';

/// A widget to display an overview of profiles with a relation to the event.
class EventProfilesOverview extends StatelessWidget {
  const EventProfilesOverview({
    Key? key,
    required this.profiles,
  }) : super(key: key);

  final List<Profile> profiles;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 10),
          child: Row(
            children: profiles
                .map(
                  (p) => Align(
                    widthFactor: 0.75,
                    child: ProfileAvatar(
                      avatarUrl: p.avatarUrl,
                      maxRadius: 30,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }
}
