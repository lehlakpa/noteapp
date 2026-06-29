import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'circular_loading.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../widgets/custom_notification.dart';
import '../constants/app_colors.dart';

class LogoutProfileAction extends StatefulWidget {
  const LogoutProfileAction({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LogoutProfileAction> createState() => _LogoutProfileActionState();
}

class _LogoutProfileActionState extends State<LogoutProfileAction> {
  Future<void> _performLogout() async {
    try {
      final loading = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const CircularLoadingPage(
            delay: Duration(seconds: 1),
            message: 'Logging out...',
            autoSuccess: true,
          ),
        ),
      );

      if (loading == false) {
        if (!mounted) return;
        CustomNotification.show(
          context,
          message: 'Logout cancelled',
          isError: true,
        );
        return;
      }

      await widget.authService.logout();

      if (!mounted) return;
      CustomNotification.show(
        context,
        message: 'Logged out successfully',
        isError: false,
      );

      // Redirect to LoginScreen and clear all routes
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      CustomNotification.show(
        context,
        message: 'Logout failed: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName;
    final email = user?.email ?? 'No email';
    
    final nameToDisplay = (displayName != null && displayName.trim().isNotEmpty) 
        ? displayName 
        : (email.contains('@') ? email.split('@').first : 'User');

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.white,
          child: const Icon(Icons.person, color: AppColors.primaryYellow),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nameToDisplay,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: AppColors.primaryText, size: 20),
              SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(color: AppColors.primaryText),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          _performLogout();
        }
      },
    );
  }
}

