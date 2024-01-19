import 'package:flutter/material.dart';

/// A custom styled rounded button.
class RoundedButton extends StatelessWidget {
  const RoundedButton({Key? key, required this.child, this.onTap, this.color, this.padding})
      : super(key: key);

  final EdgeInsetsGeometry? padding;
  final Widget child;
  final Color? color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: InkWell(
        splashColor: const Color(0x55333333),
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(15),
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
