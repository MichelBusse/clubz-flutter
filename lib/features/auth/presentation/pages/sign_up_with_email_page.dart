import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/auth/presentation/pages/sign_in_with_email_page.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/pages/settings_profile_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// A data model for the arguments of [SignUpWithEmailPage].
class SignUpWithEmailPageArgs {
  final Function(bool)? callback;

  const SignUpWithEmailPageArgs({this.callback});
}

/// A page to sign up with email and password.
class SignUpWithEmailPage extends ConsumerStatefulWidget {
  const SignUpWithEmailPage({Key? key, this.args}) : super(key: key);

  final SignUpWithEmailPageArgs? args;

  @override
  ConsumerState<SignUpWithEmailPage> createState() =>
      _SignUpWithEmailPageState();
}

class _SignUpWithEmailPageState extends ConsumerState<SignUpWithEmailPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  late FocusNode _passwordFocus;
  late FocusNode _passwordConfirmFocus;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _passwordFocus = FocusNode();
    _passwordConfirmFocus = FocusNode();
  }

  void _submit() async {
    final email = _email.text;
    final password = _password.text;
    final confirm = _passwordConfirm.text;

    if (password != confirm) {
      showErrorSnackBar(
          context: context,
          errorText: AppLocalizations.of(context)!
              .signUpWithEmailPagePasswordsDoNotMatch);

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      if (await ref
          .read(authStateProvider.notifier)
          .signUpWithEmail(email: email, password: password)) {
        if (context.mounted) {
          context.pushReplacement(
            AppRoutes.signInWithEmail,
            extra: SignInWithEmailPageArgs(
              callback: widget.args?.callback,
              loginInfoMessage:
                  AppLocalizations.of(context)!.signUpWithEmailPageInfoMessage,
            ),
          );
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
    // Listen for changes of profileStateProvider.
    ref.listen<Profile?>(profileStateProvider, (previous, next) {
      // Do nothing if current profile was already set or if currentProfile is null now.
      if (previous != null || next == null) {
        return;
      }
      if (!next.isInitialized()) {
        // If fullName or username of current profile is null,
        // navigate to SettingsProfilePage to request missing information.
        context.pushReplacement(
          AppRoutes.settingsProfile,
          extra: SettingsProfilePageArgs(
            callback: widget.args?.callback,
          ),
        );
      } else {
        // If fullName and username of current profile is set,
        // navigate to first page and invoke callback method if provided.
        Navigator.of(context).popUntil((route) => route.isFirst);
        widget.args?.callback?.call(true);
      }
    });

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
                    AppLocalizations.of(context)!.signUpWithEmailPageHeadline,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _email,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .signUpWithEmailPageEmailHint),
                    style: Theme.of(context).textTheme.bodyLarge,
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _password,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .signUpWithEmailPagePasswordHint),
                    obscureText: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                    focusNode: _passwordFocus,
                    onSubmitted: (_) => _passwordConfirmFocus.requestFocus(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordConfirm,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .signUpWithEmailPagePasswordConfirmHint),
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
                                .signUpWithEmailPageSubmitButton,
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
                  const SizedBox(height: 10),
                  RoundedButton(
                      onTap: () async {
                        context.push(
                          AppRoutes.signInWithEmail,
                          extra: SignInWithEmailPageArgs(
                              callback: widget.args?.callback),
                        );
                      },
                      color: AppConstants.colorDarkGrey,
                      child: Text(
                        AppLocalizations.of(context)!
                            .signUpWithEmailPageSignInButton,
                        style: Theme.of(context).textTheme.displaySmall,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push(AppRoutes.imprint);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.imprintPageButton,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push(AppRoutes.privacyPolicy);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.privacyPolicyPageButton,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push(AppRoutes.termsOfUse);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.termsOfUsePageButton,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
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
