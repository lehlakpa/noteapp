import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note/screens/home_screen.dart';
import 'package:note/screens/login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Widget? _screen;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final token = await user.getIdToken(false);

        if (token != null && token.isNotEmpty) {
          // Show logo for 1 second
          await Future.delayed(const Duration(seconds: 1));

          if (!mounted) return;

          setState(() {
            _screen = const HomeScreen();
          });

          return;
        }
      }

      if (!mounted) return;

      setState(() {
        _screen = const LoginScreen();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _screen = const LoginScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_screen == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset("assets/images/pookie.png", width: 150),
        ),
      );
    }

    return _screen!;
  }
}
