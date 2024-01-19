import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/auth/presentation/pages/sign_up_with_email_page.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/pages/settings_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// A data model for the arguments of [SignInWithEmailPage].
class SignInWithEmailPageArgs {
  final Function(bool)? callback;
  final String? loginInfoMessage;

  const SignInWithEmailPageArgs({this.loginInfoMessage, this.callback});
}

/// A page to sign in with email and password.
class SignInWithEmailPage extends ConsumerStatefulWidget {
  const SignInWithEmailPage({
    Key? key,
    this.args,
  }) : super(key: key);

  final SignInWithEmailPageArgs? args;

  @override
  ConsumerState<SignInWithEmailPage> createState() =>
      _SignInWithEmailPageState();
}

class _SignInWithEmailPageState extends ConsumerState<SignInWithEmailPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  late FocusNode _passwordFocus;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _passwordFocus = FocusNode();
  }

  void _submit() async {
    final email = _email.text;
    final password = _password.text;

    setState(() {
      _loading = true;
    });

    try {
      await ref
          .read(authStateProvider.notifier)
          .signInWithEmail(email: email, password: password);
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
                    AppLocalizations.of(context)!.signInWithEmailPageHeadline,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  if (widget.args?.loginInfoMessage != null)
                    Text(
                      widget.args!.loginInfoMessage!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  if (widget.args?.loginInfoMessage != null)
                    const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _email,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .signInWithEmailPageEmailHint),
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _password,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .signInWithEmailPagePasswordHint),
                    obscureText: true,
                    focusNode: _passwordFocus,
                    onSubmitted: (_) => !_loading ? _submit() : null,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  RoundedButton(
                    onTap: !_loading ? _submit : null,
                    child: !_loading
                        ? Text(
                            AppLocalizations.of(context)!
                                .signInWithEmailPageSubmitButton,
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
                        AppRoutes.signUpWithEmail,
                        extra: SignUpWithEmailPageArgs(
                          callback: widget.args?.callback,
                        ),
                      );
                    },
                    color: AppConstants.colorDarkGrey,
                    child: Text(
                      AppLocalizations.of(context)!
                          .signInWithEmailPageSignUpButton,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoundedButton(
                    onTap: () async {
                      context.push(AppRoutes.resetPassword);
                    },
                    color: Colors.transparent,
                    child: Text(
                      AppLocalizations.of(context)!
                          .signInWithEmailPageResetPasswordButton,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
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
