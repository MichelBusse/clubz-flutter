import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Shows an alert dialog with a 'continue' and 'cancel' option to the user.
void showAlertDialog({
  required BuildContext context,
  required String title,
  required String description,
  required void Function() callback,
  Color? continueButtonTextColor,
}) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.displayMedium,
      ),
      content: Text(
        description,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.alertDialogCancel,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            callback();
          },
          child: Text(
            AppLocalizations.of(context)!.alertDialogContinue,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: continueButtonTextColor,
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        )
      ],
    ),
  );
}