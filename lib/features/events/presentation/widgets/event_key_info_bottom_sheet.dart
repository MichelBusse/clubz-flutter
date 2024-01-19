import 'package:clubz/core/res/app_constants.dart';
import 'package:flutter/material.dart';

/// A bottom sheet to display the key info of an event.
class EventKeyInfoBottomSheet extends StatelessWidget {
  const EventKeyInfoBottomSheet({Key? key, required this.headline, required this.child})
      : super(key: key);

  final String headline;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppConstants.colorDarkGrey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 70,
          left: AppConstants.paddingMainBodyContainer + 10,
          right: AppConstants.paddingMainBodyContainer + 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              headline,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(
              height: 30,
            ),
            child,
          ],
        ),
      ),
    );
  }
}
