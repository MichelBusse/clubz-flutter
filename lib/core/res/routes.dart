import 'package:clubz/features/auth/presentation/pages/sign_in_with_email_page.dart';
import 'package:clubz/features/auth/presentation/pages/sign_up_with_email_page.dart';
import 'package:clubz/features/auth/presentation/pages/reset_password_page.dart';
import 'package:clubz/features/auth/presentation/pages/sign_in_methods_page.dart';
import 'package:clubz/features/auth/presentation/pages/update_password_page.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/data/models/event_location_details.dart';
import 'package:clubz/features/events/presentation/pages/edit_age_policy_page.dart';
import 'package:clubz/features/events/presentation/pages/edit_dress_code_page.dart';
import 'package:clubz/features/events/presentation/pages/edit_event_page.dart';
import 'package:clubz/features/events/presentation/pages/edit_price_policy_page.dart';
import 'package:clubz/features/events/presentation/pages/event_detail_view_page.dart';
import 'package:clubz/features/events/presentation/pages/event_profiles_page.dart';
import 'package:clubz/features/events/presentation/pages/event_location_picker_page.dart';
import 'package:clubz/features/feed/data/models/filter_location_details.dart';
import 'package:clubz/features/feed/presentation/pages/feed_page.dart';
import 'package:clubz/features/feed/presentation/pages/filter_feed_page.dart';
import 'package:clubz/features/feed/presentation/pages/filter_feed_location_picker_page.dart';
import 'package:clubz/features/general/presentation/pages/bad_state_error_page.dart';
import 'package:clubz/features/general/presentation/pages/imprint_page.dart';
import 'package:clubz/features/general/presentation/pages/privacy_policy_page.dart';
import 'package:clubz/features/general/presentation/pages/privacy_policy_data_deletion_page.dart';
import 'package:clubz/features/general/presentation/pages/terms_of_use_page.dart';
import 'package:clubz/features/general/presentation/widgets/scaffold_with_navbar.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/pages/request_following_page.dart';
import 'package:clubz/features/profiles/presentation/pages/followers_page.dart';
import 'package:clubz/features/profiles/presentation/pages/my_profile_page.dart';
import 'package:clubz/features/profiles/presentation/pages/profile_detail_view_page.dart';
import 'package:clubz/features/profiles/presentation/pages/settings_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// Class for all app routes.
class AppRoutes {
  /// Returns a SlideTransition which slides up.
  static Widget _slideUpTransitionBuilder(
      context, animation, secondaryAnimation, child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.ease;
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    final offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  /// Navigator key for outer main navigator.
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  /// Navigator key for inner navigator within every main tab.
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // GoRouter paths for routing and deep linking.
  static const feed = "/";
  static const filterFeed = "/filterFeed";
  static const filterFeedLocationPicker = "/filterFeedLocationPicker";
  static const myProfile = "/myProfile";
  static const followers = "/followers";
  static const requestFollowing = "/requestFollowing";
  static const eventDetailView = "/event";
  static const eventProfiles = "/eventProfiles";
  static const editEvent = "/editEvent";
  static const editDressCode = "/editDressCode";
  static const editAgePolicy = "/editAgePolicy";
  static const editPricePolicy = "/editPricePolicy";
  static const eventLocationPicker = "/eventLocationPicker";
  static const profileDetailView = "/profile";
  static const settingsProfile = "/settingsProfile";
  static const signInMethods = "/signInMethods";
  static const signInWithEmail = "/signInWithEmail";
  static const signUpWithEmail = "/signUpWithEmail";
  static const resetPassword = "/resetPassword";
  static const updatePassword = "/updatePassword";
  static const imprint = "/imprint";
  static const privacyPolicy = "/privacyPolicy";
  static const privacyPolicyDataDeletion = "/privacyPolicyDataDeletion";
  static const termsOfUse = "/termsOfUse";

  /// Routing information for all pages of the app.
  static final router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      // ShellRoute for inner routing within tabs.
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) {
          return NoTransitionPage(
            child: ScaffoldWithNavBar(
              navigator: _shellNavigatorKey,
              location: state.uri.toString(),
              child: child,
            ),
          );
        },
        routes: [
          GoRoute(
            path: feed,
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: FeedPage(
                  rootNavigatorKey: _rootNavigatorKey,
                ),
              );
            },
          ),
          GoRoute(
            path: filterFeed,
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) {
              return const CupertinoPage(
                child: FilterFeedPage(),
              );
            },
          ),
          GoRoute(
            path: filterFeedLocationPicker,
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) {
              return const CupertinoPage<FilterLocationDetails>(
                child: FilterFeedLocationPickerPage(),
              );
            },
          ),
          GoRoute(
            path: myProfile,
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: MyProfilePage(
                  rootNavigatorKey: _rootNavigatorKey,
                ),
              );
            },
          ),
          GoRoute(
            path: followers,
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) {
              return const CupertinoPage(
                child: FollowersPage(),
              );
            },
          ),
          GoRoute(
            path: requestFollowing,
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) {
              return const CupertinoPage(
                child: RequestFollowingPage(),
              );
            },
          ),
          GoRoute(
            path: '$eventDetailView/:eventId',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) {
              // Check type of state.extra.
              if (state.extra is! Event?) {
                return const CupertinoPage(
                  child: BadStateErrorPage(),
                );
              }

              return CupertinoPage(
                child: EventDetailViewPage(
                  eventId: state.pathParameters['eventId'],
                  event: state.extra as Event?,
                  rootNavigatorKey: _rootNavigatorKey,
                ),
              );
            },
          ),
          GoRoute(
            path: eventProfiles,
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) {
              // Check type of state.extra.
              if (state.extra is! EventProfilesPageArgs) {
                return const CupertinoPage(
                  child: BadStateErrorPage(),
                );
              }

              return CupertinoPage(
                child: EventProfilesPage(
                  args: (state.extra as EventProfilesPageArgs),
                ),
              );
            },
          ),
          GoRoute(
            path: '$profileDetailView/:profileId',
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) {
              // Check type of state.extra.
              if (state.extra is! Profile?) {
                return const CupertinoPage(
                  child: BadStateErrorPage(),
                );
              }

              return CupertinoPage(
                child: ProfileDetailViewPage(
                  rootNavigatorKey: _rootNavigatorKey,
                  profileId: state.pathParameters['profileId'],
                  profile: state.extra as Profile?,
                ),
              );
            },
          ),
          GoRoute(
            path: settingsProfile,
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) {
              // Check type of state.extra.
              if (state.extra is! SettingsProfilePageArgs?) {
                return const CupertinoPage(
                  child: BadStateErrorPage(),
                );
              }

              return CupertinoPage(
                child: SettingsProfilePage(
                    args: state.extra as SettingsProfilePageArgs?),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: editEvent,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          // Check type of state.extra.
          if (state.extra is! Event?) {
            return const CupertinoPage(
              child: BadStateErrorPage(),
            );
          }

          return CustomTransitionPage(
            child: EditEventPage(
              event: (state.extra as Event?),
            ),
            transitionsBuilder: _slideUpTransitionBuilder,
          );
        },
      ),
      GoRoute(
        path: editDressCode,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          // Check type of state.extra.
          if (state.extra is! DressCode) {
            return const CupertinoPage(
              child: BadStateErrorPage(),
            );
          }

          return CupertinoPage<DressCode>(
            child: EditDressCodePage(
              dressCode: state.extra as DressCode,
            ),
          );
        },
      ),
      GoRoute(
        path: editAgePolicy,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          // Check type of state.extra.
          if (state.extra is! AgePolicy) {
            return const CupertinoPage(
              child: BadStateErrorPage(),
            );
          }

          return CupertinoPage<AgePolicy>(
            child: EditAgePolicyPage(
              agePolicy: state.extra as AgePolicy,
            ),
          );
        },
      ),
      GoRoute(
        path: editPricePolicy,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          // Check type of state.extra.
          if (state.extra is! PricePolicy) {
            return const CupertinoPage(
              child: BadStateErrorPage(),
            );
          }

          return CupertinoPage<PricePolicy>(
            child: EditPricePolicyPage(
              pricePolicy: state.extra as PricePolicy,
            ),
          );
        },
      ),
      GoRoute(
        path: eventLocationPicker,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const CupertinoPage<EventLocationDetails>(
            child: EventLocationPickerPage(),
          );
        },
      ),
      GoRoute(
        path: signInMethods,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          // Check type of state.extra.
          if (state.extra is! SignInMethodsPageArgs?) {
            return const CupertinoPage(
              child: BadStateErrorPage(),
            );
          }

          return CupertinoPage(
            child: SignInMethodsPage(
              args: state.extra as SignInMethodsPageArgs?,
            ),
          );
        },
      ),
      GoRoute(
        path: signInWithEmail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          // Check type of state.extra.
          if (state.extra is! SignInWithEmailPageArgs?) {
            return const CupertinoPage(
              child: BadStateErrorPage(),
            );
          }

          return CupertinoPage(
            child: SignInWithEmailPage(
              args: state.extra as SignInWithEmailPageArgs?,
            ),
          );
        },
      ),
      GoRoute(
        path: signUpWithEmail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          // Check type of state.extra.
          if (state.extra is! SignUpWithEmailPageArgs?) {
            return const CupertinoPage(
              child: BadStateErrorPage(),
            );
          }

          return CupertinoPage(
            child: SignUpWithEmailPage(
              args: state.extra as SignUpWithEmailPageArgs?,
            ),
          );
        },
      ),
      GoRoute(
        path: resetPassword,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: ResetPasswordPage(),
          );
        },
      ),
      GoRoute(
        path: updatePassword,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: UpdatePasswordPage(),
          );
        },
      ),
      GoRoute(
        path: privacyPolicy,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: PrivacyPolicyPage(),
          );
        },
      ),
      GoRoute(
        path: privacyPolicyDataDeletion,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: PrivacyPolicyDataDeletionPage(),
          );
        },
      ),
      GoRoute(
        path: imprint,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: ImprintPage(),
          );
        },
      ),
      GoRoute(
        path: termsOfUse,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: TermsOfUsePage(),
          );
        },
      ),
    ],
  );
}
