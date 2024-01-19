import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// A page to request a password reset.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState
    extends ConsumerState<ResetPasswordPage> {
  final TextEditingController _email = TextEditingController();
  bool _loading = false;

  void _submit() async {
    // Email field should not be empty.
    if (_email.text.isEmpty) {
      showErrorSnackBar(
          context: context,
          errorText: AppLocalizations.of(context)!
              .resetPasswordPageEmailRequired);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await ref
          .read(authStateProvider.notifier)
          .resetPassword(email: _email.text);

      if(context.mounted) {
        context.go(AppRoutes.feed);
      }
    } on FrontendException catch (e) {
      if(context.mounted) {
        showErrorSnackBar(context: context, errorText: e.getMessage(context));
      }
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(),
      body: Builder(
        builder: (context) => Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: AppConstants.paddingMainBodyContainer,
                left: AppConstants.paddingMainBodyContainer,
                right: AppConstants.paddingMainBodyContainer,
                bottom: (Scaffold.of(context).appBarMaxHeight ?? 0) +
                    AppConstants.paddingMainBodyContainer,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!
                        .resetPasswordPageHeadline,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _email,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .resetPasswordPageEmailHint),
                    onSubmitted: (_) => !_loading ? _submit() : null,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  RoundedButton(
                    onTap: !_loading ? _submit : null,
                    child: !_loading
                        ? Text(
                            AppLocalizations.of(context)!
                                .resetPasswordPageSubmitButton,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(color: Colors.black),
                          )
                        : const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
