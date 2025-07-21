import 'package:flutter/material.dart';
import 'screens/onboarding/welcome_screen.dart';

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
        '/personal-info': (context) =>
            const Placeholder(), // we'll build this next
      },
    );
  }
}
