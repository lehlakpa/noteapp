import 'package:flutter/material.dart';
import 'package:note/screens/practise.dart';
import 'package:note/screens/rockgame.dart';
import 'package:note/screens/profile1.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note/screens/profile.dart';
import 'firebase_options.dart';
import 'authProvider/auth_wrapper.dart';
import 'constants/app_colors.dart';

// void main() async {
//   runApp(MaterialApp(home: Practise()));
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.creamBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryYellow,
          primary: AppColors.primaryYellow,
          surface: AppColors.creamBackground,
        ),
        fontFamily:
            'Roboto', // Fallback, flutter defaults to Roboto/San Francisco
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryYellow,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 2,
          ),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.white,
          elevation: 4,
          shadowColor: AppColors.shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
