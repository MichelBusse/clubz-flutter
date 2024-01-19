import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

/// A container to display the skeleton animation.
class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius radius;

  /// Default constructor for skeleton animation container.
  const SkeletonContainer._(
      {Key? key, this.width = double.infinity, this.height = double.infinity, this.radius = const BorderRadius.all(Radius.circular(0))})
      : super(key: key);

  /// Constructor for rectangular skeleton animation container.
  const SkeletonContainer.square(
      {Key? key, double width = double.infinity, double height = double.infinity})
      : this._(key: key, width: width, height: height);

  /// Constructor for rounded skeleton animation container.
  const SkeletonContainer.rounded(
      {Key? key, double width = double.infinity, double height = double.infinity, BorderRadius radius = const BorderRadius.all(Radius.circular(12))})
      : this._(key: key, width: width, height: height, radius: radius);

  @override
  Widget build(BuildContext context) {
    return SkeletonAnimation(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: radius,
        ),
      ),
    );
  }
}
