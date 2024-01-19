import 'package:flutter/material.dart';

/// A container to display an indicator badge.
class IndicatorBadgeContainer extends StatelessWidget {
  const IndicatorBadgeContainer({
    Key? key,
    required this.child,
    required this.active,
  }) : super(key: key);

  final Widget child;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (active)
          const Positioned(
            top: -5,
            right: -5,
            child: Icon(
              Icons.circle,
              color: Colors.red,
              size: 18,
            ),
          ),
      ],
    );
  }
}
