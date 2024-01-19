import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:flutter/material.dart';

/// A custom dropdown button which opens a dialog of options.
class DropdownDialogButton extends StatelessWidget {
  const DropdownDialogButton(
      {Key? key, required this.value, required this.icon, required this.options, required this.onChanged})
      : super(key: key);

  final int? value;
  final IconData icon;
  final List<DropdownMenuItem> options;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      color: AppConstants.colorDarkGrey,
      onTap: () async {
        await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: options.map(
                      (option) =>
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          onChanged(option.value);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              option.child,
                            ],
                          ),
                        ),
                      ),
                )
                    .toList(),
              ),
            );
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          options
              .firstWhere((element) => element.value == value)
              .child,
          Icon(
            icon,
            size: AppConstants.largeIconSize,
          ),
        ],
      ),
    );
  }
}
