import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'circular_loading.dart';
import '../services/auth_service.dart';
import '../widgets/custom_notification.dart';

class LogoutProfileAction extends StatefulWidget {
  const LogoutProfileAction({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LogoutProfileAction> createState() => _LogoutProfileActionState();
}

class _LogoutProfileActionState extends State<LogoutProfileAction> {
  bool _showLogout = false;

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName;

    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName;
    }

    final email = user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Profile';
  }

  @override
  Widget build(BuildContext context) {
    final userName = _getUserName();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.topRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _showLogout = !_showLogout),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blueAccent.withOpacity(0.15),
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      userName,
                      key: ValueKey(_showLogout),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _showLogout
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ClipRect(
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                offset: _showLogout ? Offset.zero : const Offset(1.0, 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showLogout ? 1 : 0,
                  child: _showLogout
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          height: 40,
                          child: TextButton.icon(
                            onPressed: () async {
                              setState(() => _showLogout = false);
                              try {
                                final loading = await Navigator.of(context)
                                    .push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CircularLoadingPage(
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
                              } catch (e) {
                                if (!mounted) return;
                                CustomNotification.show(
                                  context,
                                  message: 'Logout failed: $e',
                                  isError: true,
                                );
                              }
                            },

                            icon: const Icon(
                              Icons.logout,
                              color: Colors.black87,
                            ),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
