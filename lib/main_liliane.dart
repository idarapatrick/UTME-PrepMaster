import 'package:flutter/material.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/personal_info_screen.dart';

void main() {
  runApp(const LilianeApp());
}

class LilianeApp extends StatelessWidget {
  const LilianeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTME Test App',
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/personal-info': (context) => const PersonalInfoScreen(),
        // You can add more screens later
      },
    );
  }
}
