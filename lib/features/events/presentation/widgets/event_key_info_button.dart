import 'package:flutter/material.dart';

/// A button to open a key info of an event.
class EventKeyInfoButton extends StatelessWidget {
  const EventKeyInfoButton({
    Key? key,
    required this.icon,
    required this.label,
    this.onTab,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final Function()? onTab;

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTab,
        child: Stack(
          children: [
            if(onTab != null)
              const Positioned(
                top: 11,
                right: 11,
                child: Icon(
                  Icons.circle,
                  size: 15,
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
