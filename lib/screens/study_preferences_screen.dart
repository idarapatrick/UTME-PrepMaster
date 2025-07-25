import 'package:flutter/material.dart';

class StudyPreferencesScreen extends StatefulWidget {
  const StudyPreferencesScreen({super.key});

  @override
  State<StudyPreferencesScreen> createState() => _StudyPreferencesScreenState();
}

class _StudyPreferencesScreenState extends State<StudyPreferencesScreen> {
  bool prefersMorning = false;
  bool prefersEvening = false;
  double dailyStudyHours = 1;

  void _submitPreferences() {
    if (!prefersMorning && !prefersEvening) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one preferred study time.'),
        ),
      );
      return;
    }

    // Here you can save preferences to state or backend
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Preferences Saved'),
        content: const Text('Your study preferences have been recorded.'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step 4: Study Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferred Study Time:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text('Morning'),
              value: prefersMorning,
              onChanged: (val) => setState(() => prefersMorning = val!),
            ),
            CheckboxListTile(
              title: const Text('Evening'),
              value: prefersEvening,
              onChanged: (val) => setState(() => prefersEvening = val!),
            ),
            const SizedBox(height: 24),
            const Text(
              'How many hours do you plan to study daily?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: dailyStudyHours,
              min: 1,
              max: 10,
              divisions: 9,
              label: '${dailyStudyHours.round()} hr(s)',
              onChanged: (val) => setState(() => dailyStudyHours = val),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _submitPreferences,
                child: const Text('Finish Onboarding'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
