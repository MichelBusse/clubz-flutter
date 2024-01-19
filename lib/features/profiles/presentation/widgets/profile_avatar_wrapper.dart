import 'package:flutter/material.dart';

/// A widget to wrap the profile avatar.
class ProfileAvatarWrapper extends StatelessWidget {
  const ProfileAvatarWrapper({Key? key, required this.child, this.maxRadius = 110, this.onTap, this.onTapChild})
      : super(key: key);

  final Widget child;
  final double maxRadius;
  final Function()? onTap;
  final Widget? onTapChild;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: child,
    );
  }
}
