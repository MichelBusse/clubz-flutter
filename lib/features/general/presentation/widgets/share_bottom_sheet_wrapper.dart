import 'package:clubz/core/res/app_constants.dart';
import 'package:flutter/material.dart';

/// A bottom sheet wrapper for the sharing options.
class ShareBottomSheetWrapper extends StatelessWidget {
  const ShareBottomSheetWrapper({Key? key, required this.children}) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppConstants.colorDarkGrey,
      ),
      padding: const EdgeInsets.only(
        top: 40,
        bottom: 50,
        left: 30,
        right: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }
}
