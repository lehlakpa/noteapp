import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note/screens/register_screen.dart';

import 'circular_loading.dart';
import '../widgets/custom_notification.dart';

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
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
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
      final loading = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const CircularLoadingPage(
            delay: Duration(seconds: 1),
            message: 'Signing you in...',
            autoSuccess: true,
          ),
        ),
      );

      // If loading page returns false (shouldn't normally happen), treat as error.
      if (loading == false) {
        if (!mounted) return;
        CustomNotification.show(
          context,
          message: 'Login cancelled',
          isError: true,
        );
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      CustomNotification.show(
        context,
        message: 'Login successful',
        isError: false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      CustomNotification.show(
        context,
        message: e.message ?? 'Login failed',
        isError: true,
      );
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

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      if (!mounted) return;
      CustomNotification.show(
        context,
        message:
            'Please enter your email in the field above to reset password.',
        isError: true,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      CustomNotification.show(
        context,
        message: 'Password reset link sent to your email.',
        isError: false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      CustomNotification.show(
        context,
        message: e.message ?? 'Failed to send reset email.',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      CustomNotification.show(
        context,
        message: 'An unexpected error occurred: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                size: 80,
                color: Color(0xFF2ECC71),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Log in to your account',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 48),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularLoadingIndicator(
                        size: 20,
                        strokeWidth: 2,
                        color: Colors.white,
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                          (context, animation, secondaryAnimation, child) {
                            final fade = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            );
                            return FadeTransition(opacity: fade, child: child);
                          },
                    ),
                  );
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: Color(0xFF2ECC71)),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 1),
        ),
      ),
    );
  }
}
