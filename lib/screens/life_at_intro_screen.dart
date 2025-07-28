// lib/screens/life_at/life_at_intro_screen.dart

import 'package:flutter/material.dart';
import 'life_at_browser_screen.dart';

class LifeAtIntroScreen extends StatelessWidget {
  const LifeAtIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to LifeAt!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Focus, study and stay productive with LifeAt.\n\nFeatures:\n• Pomodoro Timer\n• Virtual Study Rooms\n• Music Playlists\n• Customizable Backgrounds\n\nTap below to explore the platform!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LifeAtBrowserScreen()),
                );
              },
              icon: const Icon(Icons.explore),
              label: const Text('Launch LifeAt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
