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
      appBar: AppBar(
        title: const Text('Step 2: University Selection'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Search and select your university",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Search field
              TextField(
                controller: _searchController,
                onChanged: _filterUniversities,
                decoration: InputDecoration(
                  hintText: 'Search universities...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // University list
              Expanded(
                child: _filteredUniversities.isEmpty
                    ? const Center(child: Text("No universities found."))
                    : ListView.builder(
                        itemCount: _filteredUniversities.length,
                        itemBuilder: (context, index) {
                          final university = _filteredUniversities[index];
                          return RadioListTile<String>(
                            title: Text(university),
                            value: university,
                            groupValue: _selectedUniversity,
                            activeColor: Colors.deepPurple,
                            onChanged: (value) {
                              setState(() => _selectedUniversity = value);
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),

              // Next button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
