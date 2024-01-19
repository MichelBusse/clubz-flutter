import 'package:clubz/core/res/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A class to hold all API functions for user authentication.
class AuthApi {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Signs user up with [email] and [password].
  Future signup({required String email, required String password}) {
    return supabase.auth.signUp(
      password: password,
      email: email,
      emailRedirectTo: dotenv.get("WEBSITE_URL") + AppRoutes.settingsProfile,
    );
  }

  /// Sends password reset link to [email].
  Future resetPassword({
    required String email,
  }) {
    return supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: dotenv.get("WEBSITE_URL") + AppRoutes.updatePassword,
    );
  }

  /// Updates [password] of current user.
  Future updatePassword({required String password}) {
    return supabase.auth.updateUser(
      UserAttributes(
        password: password,
      ),
    );
  }

  /// Signs user in with [email] and [password].
  Future signInWithEmail({required String email, required String password}) {
    return supabase.auth.signInWithPassword(email: email, password: password);
  }

  /// Signs user in with OAuth2 of [provider].
  Future signInWithOAuth2({required OAuthProvider provider}) {
    // Specify redirectUrl for linking back to app (Necessary for Google). Leave null for web.
    String? redirectUrl = "one.clubz://login-callback/";
    if (kIsWeb) {
      redirectUrl = null;
    }
    return supabase.auth.signInWithOAuth(provider, redirectTo: redirectUrl);
  }

  /// Signs user out.
  Future signOut() {
    return supabase.auth.signOut();
  }

  /// Deletes current user.
  Future deleteUser() {
    return supabase.rpc('delete_user');
  }

  /// Returns current user.
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
