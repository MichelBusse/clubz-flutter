import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// A dialog to report a profile.
class ReportProfileDialog extends ConsumerStatefulWidget {
  const ReportProfileDialog(
      {Key? key,
      required this.title,
      required this.text,
      required this.callback,
      required this.profileId})
      : super(key: key);

  final String title;
  final String text;
  final Future Function(String) callback;
  final String profileId;

  @override
  ConsumerState<ReportProfileDialog> createState() => _ReportProfileDialogState();
}

class _ReportProfileDialogState extends ConsumerState<ReportProfileDialog> {
  final TextEditingController _reason = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(
        AppConstants.paddingMainBodyContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
          bottom: 30,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.white,
            ),
            TextField(
              controller: _reason,
              minLines: 3,
              maxLines: 3,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppLocalizations.of(context)!.reportDialogReasonHint,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(
              color: Colors.white,
            ),
            const SizedBox(
              height: 20,
            ),
            RoundedButton(
              child: Text(
                AppLocalizations.of(context)!.reportDialogSubmitButton,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black,
                    ),
              ),
              onTap: () async {
                await widget.callback(_reason.text);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            RoundedButton(
              onTap: () async {
                try {
                  await ref
                      .read(blockedControllerProvider)
                      .blockProfile(blockedId: widget.profileId);
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    context.go(AppRoutes.feed);
                  }
                  ref.read(eventsRefreshProvider.notifier).refresh();
                } on FrontendException catch (e) {
                  if (context.mounted) {
                    showErrorSnackBar(
                        context: context, errorText: e.getMessage(context));
                  }
                }
              },
              color: AppConstants.colorDarkGrey,
              child: Text(
                AppLocalizations.of(context)!.reportDialogBlockProfileButton,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.red,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
