import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note/screens/home_screen.dart';
import 'package:note/screens/login_screen.dart';
import 'package:note/screens/circular_loading.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  /// Returns a valid ID token string if the user is logged in, null otherwise.
  Future<String?> _getAccessToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      // forceRefresh: false — uses cached token if still valid
      final token = await user.getIdToken(false);
      return token;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getAccessToken(),
      builder: (context, snapshot) {
        // While checking the token — show custom loading screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0A),
            body: CircularLoadingIndicator(
              size: 48,
              strokeWidth: 4,
              color: Color(0xFF2ECC71),
            ),
          );
        }

        // Valid access token found → go to HomeScreen
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // No token → show LoginScreen
        return const LoginScreen();
      },
    );
  }
}
