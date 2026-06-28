import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note/screens/register_screen.dart';
import 'package:note/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_notification.dart';
import '../constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      CustomNotification.show(
        context,
        message: 'Please fill all fields',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockKey = 'block_until_$email';
      final attemptsKey = 'login_attempts_$email';

      final blockUntilStr = prefs.getString(blockKey);
      if (blockUntilStr != null) {
        if (blockUntilStr == 'permanent') {
          if (!mounted) return;
          CustomNotification.show(
            context,
            message: 'Account locked permanently. Too many wrong passwords.',
            isError: true,
          );
          setState(() => _isLoading = false);
          return;
        }

        final blockUntil = DateTime.parse(blockUntilStr);
        if (DateTime.now().isBefore(blockUntil)) {
          final diff = blockUntil.difference(DateTime.now()).inMinutes;
          if (!mounted) return;
          CustomNotification.show(
            context,
            message: 'Account locked. Please wait ${diff + 1} minutes.',
            isError: true,
          );
          setState(() => _isLoading = false);
          return;
        } else {
          await prefs.remove(blockKey);
        }
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await prefs.remove(blockKey);
      await prefs.remove(attemptsKey);

      if (!mounted) return;
      CustomNotification.show(
        context,
        message: 'Login successful',
        isError: false,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        final prefs = await SharedPreferences.getInstance();
        final email = _emailController.text.trim();
        final blockKey = 'block_until_$email';
        final attemptsKey = 'login_attempts_$email';

        int attempts = (prefs.getInt(attemptsKey) ?? 0) + 1;
        await prefs.setInt(attemptsKey, attempts);

        if (attempts >= 6) {
          await prefs.setString(blockKey, 'permanent');
          if (!mounted) return;
          CustomNotification.show(
            context,
            message: 'Account locked permanently. Too many wrong passwords.',
            isError: true,
          );
        } else if (attempts == 5) {
          await prefs.setString(
            blockKey,
            DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
          );
          if (!mounted) return;
          CustomNotification.show(
            context,
            message: 'Incorrect password 5 times. Please wait 15 minutes.',
            isError: true,
          );
        } else if (attempts == 3) {
          await prefs.setString(
            blockKey,
            DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
          );
          if (!mounted) return;
          CustomNotification.show(
            context,
            message: 'Invalid email or password. $attempts of 3 attempts used.',
            isError: true,
          );
        } else {
          if (!mounted) return;
          CustomNotification.show(
            context,
            message: 'Invalid email or password. $attempts of 6 attempts used.',
            isError: true,
          );
        }
      } else {
        if (!mounted) return;
        CustomNotification.show(
          context,
          message: e.message ?? 'Login failed',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      CustomNotification.show(
        context,
        message: 'An unexpected error occurred: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/notelogo.png",
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Log in to your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const RegisterScreen(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  final fade = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  );
                                  return FadeTransition(
                                    opacity: fade,
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Register",
                        style: TextStyle(color: AppColors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: AppColors.primaryText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.mutedText),
        prefixIcon: Icon(icon, color: AppColors.mutedText),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue, width: 1),
        ),
      ),
    );
  }
}
