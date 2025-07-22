import 'package:flutter/material.dart';
import '../../../data/nigerian_universities.dart';

class UniversitySelectionScreen extends StatefulWidget {
  const UniversitySelectionScreen({super.key});

  @override
  State<UniversitySelectionScreen> createState() =>
      _UniversitySelectionScreenState();
}

class _UniversitySelectionScreenState extends State<UniversitySelectionScreen> {
  String? _selectedUniversity;
  List<String> _filteredUniversities = nigerianUniversities;
  final TextEditingController _searchController = TextEditingController();

  void _filterUniversities(String query) {
    setState(() {
      _filteredUniversities = nigerianUniversities
          .where((uni) => uni.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _handleNext() {
    if (_selectedUniversity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your university.")),
      );
    } else {
      Navigator.pushNamed(context, '/subjects-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select University')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Search and select your university:"),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: _filterUniversities,
              decoration: const InputDecoration(
                hintText: 'Search universities...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredUniversities.isEmpty
                  ? const Center(child: Text("No universities found."))
                  : ListView.builder(
                      itemCount: _filteredUniversities.length,
                      itemBuilder: (context, index) {
                        final university = _filteredUniversities[index];
                        return RadioListTile<String>(
                          value: university,
                          title: Text(university),
                          groupValue: _selectedUniversity,
                          onChanged: (value) {
                            setState(() => _selectedUniversity = value);
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleNext,
                child: const Text("Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
