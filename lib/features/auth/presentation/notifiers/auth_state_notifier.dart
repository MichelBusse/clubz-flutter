import 'dart:async';

import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/data/service/auth_api.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:get_it/get_it.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


/// A [StateNotifier] for notification of changes of [Session].
class AuthStateNotifier extends riverpod.StateNotifier<Session?> {
  late final StreamSubscription<AuthState> _authStateSubscription;
  final _authApi = GetIt.instance.get<AuthApi>();
  bool oneSignalInitialized = false;

  /// Initializes notifier with current [Session] and subscribes to auth state changes.
  AuthStateNotifier() : super(Supabase.instance.client.auth.currentSession) {
    // Initialize OneSignal on load.
    _initializeOneSignal();

    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
          // Update notifier state and OneSignal subscription if login state changes.
      if ((state?.user != null && data.session?.user == null) ||
          (state?.user == null && data.session?.user != null)) {
        state = data.session;
        _updateOneSignalSubscription();
        await closeInAppWebView();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _authStateSubscription.cancel();
  }

  /// Initializes OneSignal and requests permission if necessary.
  void _initializeOneSignal() {
    if (oneSignalInitialized) {
      return;
    }
    oneSignalInitialized = true;

    OneSignal.initialize(dotenv.get("ONE_SIGNAL_APP_ID"));

    OneSignal.Notifications.requestPermission(true);
  }

  /// Updates OneSignal subscription for current user.
  void _updateOneSignalSubscription() async {
    if(state != null) {
      await OneSignal.login(state!.user.id);
    }else{
      OneSignal.logout();
    }
  }

  /// Signs user up with [email] and [password].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.forcedDelay] if rate limit is exceeded.
  /// Throws [FrontendException] with [FrontendExceptionType.signup] if sign up fails.
  Future<bool> signUpWithEmail(
      {required String email, required String password}) async {
    try {
      await _authApi.signup(email: email, password: password);
    } on AuthException catch (e) {
      if (e.statusCode == "429") {
        throw FrontendException(type: FrontendExceptionType.forcedDelay);
      } else {
        throw FrontendException(type: FrontendExceptionType.signUpWithEmail);
      }
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.signUpWithEmail);
    }
    return true;
  }

  /// Signs user in with [email] and [password].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.loginWrongCredentials] if sign in fails.
  Future<bool> signInWithEmail(
      {required String email, required String password}) async {
    try {
      await _authApi.signInWithEmail(email: email, password: password);
    } catch (e) {
      throw (FrontendException(
          type: FrontendExceptionType.signInWithEmail));
    }
    return true;
  }

  /// Signs user in with OAuth2 for the [provider].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.loginWithOAuth2] if sign in fails.
  Future<bool> signInWithOAuth2({required OAuthProvider provider}) async {
    try {
      await _authApi.signInWithOAuth2(provider: provider);
    } catch (e) {
      if (e.runtimeType != PlatformException) {
        throw FrontendException(type: FrontendExceptionType.signInWithOAuth2);
      }
    }
    return true;
  }

  /// Sends password reset link to [email].
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.resetPassword] if password reset fails.
  Future<bool> resetPassword({required String email}) async {
    try {
      await _authApi.resetPassword(email: email);
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.resetPassword);
    }
    return true;
  }

  /// Updates [password] of current user.
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.updatePassword] if password update fails.
  Future<bool> updatePassword({required String password}) async {
    try {
      await _authApi.updatePassword(password: password);
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.updatePassword);
    }
    return true;
  }

  /// Signs user out.
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.logout] if sign out fails.
  Future<bool> signOut() async {
    try {
      await _authApi.signOut();
      state = null;
      _updateOneSignalSubscription();
    } catch (_) {
      throw FrontendException(type: FrontendExceptionType.signOut);
    }

    return true;
  }

  /// Deletes current user.
  ///
  /// Throws [FrontendException] with [FrontendExceptionType.deleteUser] if user deletion fails.
  Future<bool> deleteUser() async {
    try {
      await _authApi.deleteUser();
      state = null;
      _updateOneSignalSubscription();
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.deleteUser);
    }
    return true;
  }
}
