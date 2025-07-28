import 'package:flutter/material.dart';
import '../../data/utme_subjects.dart'; // Ensure this file exists and exports List<String> utmeSubjects;

class SubjectsSelectionScreen extends StatefulWidget {
  const SubjectsSelectionScreen({super.key});

  @override
  State<SubjectsSelectionScreen> createState() =>
      _SubjectsSelectionScreenState();
}

class _SubjectsSelectionScreenState extends State<SubjectsSelectionScreen> {
  final List<String> _selectedSubjects = [];

  void _toggleSubject(String subject) {
    setState(() {
      if (_selectedSubjects.contains(subject)) {
        _selectedSubjects.remove(subject);
      } else {
        if (_selectedSubjects.length < 4) {
          _selectedSubjects.add(subject);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only select up to 4 subjects.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _continue() {
    if (_selectedSubjects.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select 4 subjects to proceed.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      Navigator.pushNamed(context, '/study-preferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 3: Select UTME Subjects'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select exactly 4 subjects for your UTME exam:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: utmeSubjects.map((subject) {
                  return CheckboxListTile(
                    title: Text(subject),
                    value: _selectedSubjects.contains(subject),
                    onChanged: (_) => _toggleSubject(subject),
                    activeColor: Colors.deepPurple,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
