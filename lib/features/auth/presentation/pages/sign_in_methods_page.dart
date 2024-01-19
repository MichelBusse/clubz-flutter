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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:go_router/go_router.dart';

/// A data model for the arguments of [SignInMethodsPage].
class SignInMethodsPageArgs {
  final Function(bool)? callback;

  const SignInMethodsPageArgs({this.callback});
}

/// A page to show available sign in methods.
class SignInMethodsPage extends ConsumerStatefulWidget {
  const SignInMethodsPage({Key? key, this.args}) : super(key: key);

  final SignInMethodsPageArgs? args;

  @override
  ConsumerState<SignInMethodsPage> createState() => _SignInMethodsPageState();
}

class _SignInMethodsPageState extends ConsumerState<SignInMethodsPage> {
  bool redirecting = false;

  @override
  Widget build(BuildContext context) {
    // Listen for changes of profileStateProvider.
    ref.listen<Profile?>(profileStateProvider, (previous, next) async {
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
                  RoundedButton(
                    color: const Color(0xFFFF3C3C),
                    onTap: () async {
                      try {
                        await ref
                            .read(authStateProvider.notifier)
                            .signInWithOAuth2(
                                provider: supabase.OAuthProvider.google);
                      } on FrontendException catch (e) {
                        if (context.mounted) {
                          showErrorSnackBar(
                              context: context,
                              errorText: e.getMessage(context));
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .signInMethodsPageOptionGoogle,
                          style: Theme.of(context).textTheme.displaySmall,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  RoundedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .signInMethodsPageOptionApple,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.black,
                              ),
                        )
                      ],
                    ),
                    onTap: () async {
                      try {
                        await ref
                            .read(authStateProvider.notifier)
                            .signInWithOAuth2(
                                provider: supabase.OAuthProvider.apple);
                      } on FrontendException catch (e) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context: context,
                            errorText: e.getMessage(context),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  RoundedButton(
                    color: const Color(0xFF4267B2),
                    onTap: () async {
                      try {
                        await ref
                            .read(authStateProvider.notifier)
                            .signInWithOAuth2(
                                provider: supabase.OAuthProvider.facebook);
                      } on FrontendException catch (e) {
                        if (context.mounted) {
                          showErrorSnackBar(
                            context: context,
                            errorText: e.getMessage(context),
                          );
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .signInMethodsPageOptionFacebook,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                              ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  RoundedButton(
                    color: const Color(0xFF333333),
                    onTap: () {
                      context.push(
                        AppRoutes.signInWithEmail,
                        extra: SignInWithEmailPageArgs(
                          callback: widget.args?.callback,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .signInMethodsPageOptionEmail,
                          style: Theme.of(context).textTheme.displaySmall!,
                        )
                      ],
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
