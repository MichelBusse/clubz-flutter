import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// A page to update the password.
class UpdatePasswordPage extends ConsumerStatefulWidget {
  const UpdatePasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UpdatePasswordPage> createState() =>
      _UpdatePasswordPageState();
}

class _UpdatePasswordPageState
    extends ConsumerState<UpdatePasswordPage> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  late FocusNode _passwordConfirmFocus;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _passwordConfirmFocus = FocusNode();
  }

  void _submit() async {
    final password = _password.text;
    final confirm = _passwordConfirm.text;

    // Password and confirmed password have to match.
    if (password != confirm) {
      showErrorSnackBar(
          context: context,
          errorText: AppLocalizations.of(context)!
              .updatePasswordPagePasswordsDoNotMatch);

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      if (await ref
          .read(authStateProvider.notifier)
          .updatePassword(password: password)) {
        if (context.mounted) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            context.go(AppRoutes.myProfile);
          }
        }
      }
    } on FrontendException catch (e) {
      if (context.mounted) {
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
                        .updatePasswordPageHeadline,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _password,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .updatePasswordPagePasswordHint),
                    obscureText: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                    onSubmitted: (_) => _passwordConfirmFocus.requestFocus(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordConfirm,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .updatePasswordPagePasswordConfirmHint),
                    obscureText: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                    focusNode: _passwordConfirmFocus,
                    onSubmitted: (_) => !_loading ? _submit() : null,
                  ),
                  const SizedBox(height: 20),
                  RoundedButton(
                    onTap: !_loading ? _submit : null,
                    child: !_loading
                        ? Text(
                            AppLocalizations.of(context)!
                                .updatePasswordPageSubmitButton,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  color: Colors.black,
                                ),
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
