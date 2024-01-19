import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/auth/presentation/pages/sign_in_methods_page.dart';
import 'package:clubz/features/general/presentation/widgets/icon_indicator.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/pages/settings_profile_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// A scaffold for the shell route of the app.
class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final String location;
  final Widget child;
  final GlobalKey navigator;

  const ScaffoldWithNavBar(
      {Key? key,
      required this.child,
      required this.location,
      required this.navigator})
      : super(key: key);

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppTrackingTransparency.requestTrackingAuthorization();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _displayInstallAppPrompt();
    });
  }

  /// Displays the prompt to install the app through app store on the web.
  _displayInstallAppPrompt() {
    // Only show if user access app through web, but has android or ios device.
    if (kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)) {
      showModalBottomSheet(
        elevation: 0,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) => Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 20,
            bottom: 50,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: SvgPicture.asset(
                  'assets/icons/clubz_icon.svg',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                AppLocalizations.of(context)!.installPromptHeadline,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              RoundedButton(
                padding: const EdgeInsets.all(10),
                onTap: () {
                  if (defaultTargetPlatform == TargetPlatform.iOS) {
                    launchUrlString(
                      dotenv.get("APP_STORE_URL"));
                  } else if (defaultTargetPlatform == TargetPlatform.android) {
                    launchUrlString(
                        dotenv.get("PLAY_STORE_URL"));
                  }

                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.installPromptOpenButton,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.black),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              RoundedButton(
                padding: const EdgeInsets.all(10),
                onTap: () {
                  Navigator.of(context).pop();
                },
                color: Colors.black,
                child: Text(
                  AppLocalizations.of(context)!.installPromptDismissButton,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black, Color(0xbb000000), Colors.transparent],
          ),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.transparent,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          onTap: (int index) {
            _openTab(context, index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(
                Icons.explore,
                size: 32,
              ),
              label: AppLocalizations.of(context)!.homePageMenuFeed,
            ),
            BottomNavigationBarItem(
              icon: const Icon(
                Icons.add_circle_rounded,
                size: 32,
              ),
              label: AppLocalizations.of(context)!.homePageMenuCreate,
            ),
            BottomNavigationBarItem(
              icon: IndicatorBadgeContainer(
                active: (ref
                        .watch(profileStateProvider)
                        ?.follower
                        .any((element) => !element.accepted) ??
                    false),
                child: const Icon(
                  Icons.account_circle_rounded,
                  size: 32,
                ),
              ),
              label: AppLocalizations.of(context)!.homePageMenuProfile,
            ),
          ],
        ),
      ),
    );
  }

  /// Opens a main tab of the app.
  void _openTab(BuildContext context, int index) {
    switch (index) {
      case 2: // Own Profile page.
        _handleNavigationIfProfileIsNotReady(
          context,
          () {
            if (widget.navigator.currentContext != null) {
              Navigator.of(widget.navigator.currentContext!)
                  .popUntil((route) => route.isFirst);
            }
            context.go(AppRoutes.myProfile);
          },
        );
        break;
      case 1: // Edit event page.
        _handleNavigationIfProfileIsNotReady(
          context,
          () {
            context.push(AppRoutes.editEvent);
          },
        );
        break;
      default: // Feed page.
        if (widget.navigator.currentContext != null) {
          Navigator.of(widget.navigator.currentContext!)
              .popUntil((route) => route.isFirst);
        }
        context.go(AppRoutes.feed);
        break;
    }
  }

  /// Checks whether the current profile is signed in and initialized and navigates accordingly.
  void _handleNavigationIfProfileIsNotReady(
      BuildContext context, void Function() doIfReady) {
    Profile? profile = ref.read(profileStateProvider);

    if (profile == null) {
      // Open sign in if no profile is signed in.
      context.push(
        AppRoutes.signInMethods,
        extra: SignInMethodsPageArgs(
          // Call desired function if sign in is finished.
          callback: (success) {
            doIfReady.call();
          },
        ),
      );
    } else if (!profile.isInitialized()) {
      // Open settings for profile if current profile is not initialized.
      context.push(
        AppRoutes.settingsProfile,
        extra: SettingsProfilePageArgs(
          // Call desired function if initialization is finished.
          callback: (success) {
            doIfReady.call();
          },
        ),
      );
    } else {
      // Navigate to desired page if current profile is correct.
      doIfReady.call();
    }
  }
}
