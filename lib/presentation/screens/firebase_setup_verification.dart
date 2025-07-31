import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/offline_cache_service.dart';
import '../../data/services/user_data_service.dart';

class FirebaseSetupVerification extends StatefulWidget {
  const FirebaseSetupVerification({super.key});

  @override
  State<FirebaseSetupVerification> createState() => _FirebaseSetupVerificationState();
}

class _FirebaseSetupVerificationState extends State<FirebaseSetupVerification> {
  List<Map<String, dynamic>> _testResults = [];
  bool _isRunning = false;

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    final tests = [
      {'name': 'Firebase Initialization', 'test': _testFirebaseInit},
      {'name': 'Firestore Settings', 'test': _testFirestoreSettings},
      {'name': 'Offline Cache Service', 'test': _testOfflineCache},
      {'name': 'User Data Service', 'test': _testUserDataService},
      {'name': 'Firestore Rules', 'test': _testFirestoreRules},
    ];

    for (final test in tests) {
      try {
        final testFunction = test['test'] as Future<void> Function();
        await testFunction();
        _addResult(test['name'] as String, true, 'Passed');
      } catch (e) {
        _addResult(test['name'] as String, false, e.toString());
      }
    }

    setState(() {
      _isRunning = false;
    });
  }

  void _addResult(String testName, bool passed, String message) {
    setState(() {
      _testResults.add({
        'name': testName,
        'passed': passed,
        'message': message,
      });
    });
  }

  Future<void> _testFirebaseInit() async {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase not initialized');
    }
  }

  Future<void> _testFirestoreSettings() async {
    final settings = FirebaseFirestore.instance.settings;
    if (settings.persistenceEnabled != true) {
      throw Exception('Firestore persistence not enabled');
    }
  }

  Future<void> _testOfflineCache() async {
    await OfflineCacheService.initialize();
    final status = await OfflineCacheService.getCacheStatus();
    if (status.isEmpty) {
      throw Exception('Offline cache service not working');
    }
  }

  Future<void> _testUserDataService() async {
    // Test if UserDataService methods are accessible
    try {
      await UserDataService.getLeaderboardData();
    } catch (e) {
      // This might fail if no user is authenticated, which is ok for this test
      if (!e.toString().contains('permission') && !e.toString().contains('auth')) {
        rethrow;
      }
    }
  }

  Future<void> _testFirestoreRules() async {
    try {
      // Try to access a protected collection without auth (should fail)
      await FirebaseFirestore.instance.collection('admin').limit(1).get();
      throw Exception('Admin collection should be protected');
    } catch (e) {
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        // Good! Rules are working
        return;
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Setup Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase & Firestore Setup Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will verify that all services are properly initialized and configured.',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isRunning ? null : _runTests,
                        child: _isRunning
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Running Tests...'),
                                ],
                              )
                            : const Text('Run Verification Tests'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _testResults.length,
                itemBuilder: (context, index) {
                  final result = _testResults[index];
                  return Card(
                    color: result['passed'] ? Colors.green[50] : Colors.red[50],
                    child: ListTile(
                      leading: Icon(
                        result['passed'] ? Icons.check_circle : Icons.error,
                        color: result['passed'] ? Colors.green : Colors.red,
                      ),
                      title: Text(result['name']),
                      subtitle: Text(result['message']),
                      trailing: Text(
                        result['passed'] ? 'PASS' : 'FAIL',
                        style: TextStyle(
                          color: result['passed'] ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_testResults.isNotEmpty && !_isRunning) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary: ${_testResults.where((r) => r['passed']).length}/${_testResults.length} tests passed',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_testResults.every((r) => r['passed'])) ...[
                        const Text(
                          '✅ All systems are properly configured!',
                          style: TextStyle(color: Colors.green),
                        ),
                        const Text(
                          'Your Firebase and Firestore setup is ready for production.',
                        ),
                      ] else ...[
                        const Text(
                          '⚠️ Some tests failed. Check the errors above and refer to the setup guides.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
