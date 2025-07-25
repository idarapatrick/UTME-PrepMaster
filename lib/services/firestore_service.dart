import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:utme_prep_master/widgets/achievement_badge.dart';
import '../models/user_profile_model.dart';


class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;


  static Future<void> createUserProfile(User user) async {
    final doc = _db.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {

      await doc.set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'isAnonymous': user.isAnonymous,
        'xp': 0, // Initialize XP
        'cbtHighScore': 0, // Initialize CBT score
        'displayName': user.displayName ?? 'User${user.uid.substring(0, 6)}',
      });
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
      await doc.set(profile.toMap());
    }
  }

  /// Load full user profile as model
  static Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!, doc.id);
  }

  /// Update profile from model
  static Future<void> updateUserProfileFromModel(UserProfile profile) async {
    await _db
        .collection('users')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  /// Update profile with partial data

  static Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {

    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }


    await _db
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  /// Save or overwrite full user profile from map

  static Future<void> saveFullUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {

    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }

  // TEST & QUIZ METHODS

    await _db
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  /// Save user test result

  static Future<void> saveTestResult({
    required String userId,
    required String testId,
    required double score,
    required List<Map<String, dynamic>> answers,
  }) async {
    final batch = _db.batch();
    
    // Save test result
    final testRef = _db.collection('users').doc(userId).collection('test_results').doc();
    batch.set(testRef, {
      'testId': testId,
      'score': score,
      'answers': answers,
      'takenAt': FieldValue.serverTimestamp(),
    });

    // Add XP for completing test
    final xpAmount = (score * 10).toInt(); // 10 XP per percentage point
    batch.update(_db.collection('users').doc(userId), {
      'xp': FieldValue.increment(xpAmount),
    });

    // Record XP event
    final xpEventRef = _db.collection('users').doc(userId).collection('xp_events').doc();
    batch.set(xpEventRef, {
      'amount': xpAmount,
      'reason': 'Completed test $testId',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Update high score if this is a CBT test
    if (testId.startsWith('cbt_')) {
      await updateCbtHighScore(userId: userId, newScore: score);
    }

    // Check for achievements
    await _checkAchievements(userId);
  }

  static Future<void> saveMockTestResult({
    required String userId,
    required List<Map<String, dynamic>> subjectResults,
    required double totalScore,
  }) async {
    final batch = _db.batch();
    
    // Save mock test result
    final mockTestRef = _db.collection('users').doc(userId).collection('mock_tests').doc();
    batch.set(mockTestRef, {
      'subjectResults': subjectResults,
      'totalScore': totalScore,
      'takenAt': FieldValue.serverTimestamp(),
    });

    // Add XP for completing mock test
    final xpAmount = (totalScore * 0.2).toInt(); // 0.2 XP per mark
    batch.update(_db.collection('users').doc(userId), {
      'xp': FieldValue.increment(xpAmount),
    });

    // Record XP event
    final xpEventRef = _db.collection('users').doc(userId).collection('xp_events').doc();
    batch.set(xpEventRef, {
      'amount': xpAmount,
      'reason': 'Completed mock test',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Update CBT high score
    await updateCbtHighScore(userId: userId, newScore: totalScore);
  }

  /// Save quiz result
  static Future<void> saveQuizResult({
    required String userId,
    required String subject,
    required int correct,
    required int attempted,
    required double score,
  }) async {

    final batch = _db.batch();
    
    // Save quiz result
    final quizRef = _db.collection('users').doc(userId).collection('quizzes').doc();
    batch.set(quizRef, {
    await _db.collection('users').doc(userId).collection('quizzes').add({
      'subject': subject,
      'correct': correct,
      'attempted': attempted,
      'score': score,
      'takenAt': FieldValue.serverTimestamp(),
    });

    // Add XP for completing quiz
    final xpAmount = (correct * 5); // 5 XP per correct answer
    batch.update(_db.collection('users').doc(userId), {
      'xp': FieldValue.increment(xpAmount),
    });

    // Record XP event
    final xpEventRef = _db.collection('users').doc(userId).collection('xp_events').doc();
    batch.set(xpEventRef, {
      'amount': xpAmount,
      'reason': 'Completed quiz in $subject',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    await _checkAchievements(userId);
  }

  // SUBJECT METHODS
  }

  /// Save selected subjects
  static Future<void> saveUserSubjects(
    String userId,
    List<String> subjects,
  ) async {
    await _db.collection('users').doc(userId).update({'subjects': subjects});
  }

  /// Load selected subjects
  static Future<List<String>> loadUserSubjects(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    final data = doc.data();
    if (data != null && data['subjects'] != null) {
      return List<String>.from(data['subjects']);
    }
    return [];
  }

  /// Save progress on a subject
  static Future<void> saveSubjectProgress({
    required String userId,
    required String subject,
    required int attempted,
    required int correct,
    required double bestScore,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('subject_progress')
        .doc(subject)
        .set({
          'attempted': attempted,
          'correct': correct,
          'bestScore': bestScore,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Load subject progress
  static Future<Map<String, dynamic>?> loadSubjectProgress(
    String userId,
    String subject,
  ) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('subject_progress')
        .doc(subject)
        .get();
    return doc.exists ? doc.data() : null;
  }

  // LIBRARY METHODS
  /// Save full mock test result
  static Future<void> saveMockTestResult({
    required String userId,
    required List<Map<String, dynamic>> subjectResults,
    required double totalScore,
  }) async {
    await _db.collection('users').doc(userId).collection('mock_tests').add({
      'subjectResults': subjectResults,
      'totalScore': totalScore,
      'takenAt': FieldValue.serverTimestamp(),
    });
  }

  /// Upload file to Firebase Storage
  static Future<String> uploadFile(
    String userId,
    String path,
    String fileName,
    Uint8List bytes,
  ) async {
    final ref = _storage.ref().child('users/$userId/$path/$fileName');
    final uploadTask = await ref.putData(bytes);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Save PDF metadata
  static Future<void> savePdf(
    String userId,
    String fileName,
    String url,
  ) async {
    await _db.collection('users').doc(userId).collection('library_pdfs').add({
      'fileName': fileName,
      'url': url,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save user note
  static Future<void> saveNote(String userId, String note) async {
    await _db.collection('users').doc(userId).collection('library_notes').add({
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save a useful link
  static Future<void> saveLink(
    String userId,
    String link, {
    String? title,
  }) async {
    await _db.collection('users').doc(userId).collection('library_links').add({
      'link': link,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // LEADERBOARD & ACHIEVEMENT METHODS
  static Future<List<Map<String, dynamic>>> fetchXpLeaderboard(String period) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final DateTimeRange dateRange = _getDateRange(period);
      
      final query = await _db
          .collection('users')
          .orderBy('xp', descending: true)
          .limit(100)
          .get();

      final List<Map<String, dynamic>> leaderboard = [];
      
      for (final doc in query.docs) {
        final xpEvents = await _db
            .collection('users/${doc.id}/xp_events')
            .where('timestamp', isGreaterThanOrEqualTo: dateRange.start)
            .where('timestamp', isLessThanOrEqualTo: dateRange.end)
            .get();

        final totalXp = xpEvents.docs.fold(0, (sum, event) => sum + (event.data()['amount'] as int));

        if (totalXp > 0) {
          leaderboard.add({
            'userId': doc.id,
            'displayName': doc.data()['displayName'] ?? 'Anonymous',
            'xp': totalXp,
            'isCurrentUser': doc.id == userId,
            'achievements': await _getUserAchievementIds(doc.id),
            'avatarUrl': doc.data()['avatarUrl'],
          });
        }
      }

      leaderboard.sort((a, b) => b['xp'].compareTo(a['xp']));
      return leaderboard;
    } catch (e) {
      developer.log('Error fetching XP leaderboard: $e', error: e);
      return [];
    }

    /// Fetch top XP leaderboard

  static Future<List<Map<String, dynamic>>> fetchXpLeaderboard(
    String period,
  ) async {
    final query = await _db
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(20)
        .get();
    return query.docs.map((d) => d.data()).toList();
  }

  /// Fetch top CBT scores in last 2 weeks
  static Future<List<Map<String, dynamic>>> fetchCbtLeaderboard() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final query = await _db
          .collection('users')
          .orderBy('cbtHighScore', descending: true)
          .limit(100)
          .get();

      return query.docs.map((doc) {
        return {
          'userId': doc.id,
          'displayName': doc.data()['displayName'] ?? 'Anonymous',
          'totalScore': doc.data()['cbtHighScore'] ?? 0,
          'isCurrentUser': doc.id == userId,
          'achievements': doc.data()['achievements'] ?? [],
          'avatarUrl': doc.data()['avatarUrl'],
        };
      }).toList();
    } catch (e) {
      developer.log('Error fetching CBT leaderboard: $e', error: e);
      return [];
    }
  }

  static Future<void> updateCbtHighScore({
    required String userId,
    required double newScore,
  }) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    final currentHighScore = (userDoc.data()?['cbtHighScore'] as num?)?.toDouble() ?? 0;
    
    if (newScore > currentHighScore) {
      await _db.collection('users').doc(userId).update({
        'cbtHighScore': newScore,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _checkAchievements(userId);
    }
  }

  static Future<void> addUserXp({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    final batch = _db.batch();
    
    // Update total XP
    final userRef = _db.collection('users').doc(userId);
    batch.update(userRef, {
      'xp': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Record XP event
    final xpEventRef = userRef.collection('xp_events').doc();
    batch.set(xpEventRef, {
      'amount': amount,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    await batch.commit();
    await _checkAchievements(userId);
  }

  static Future<void> _checkAchievements(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};
    
    final xp = userData['xp'] as int? ?? 0;
    final cbtHighScore = userData['cbtHighScore'] as double? ?? 0;
    
    // XP-based achievements
    if (xp >= 10000 && !await _hasAchievement(userId, 'top-1')) {
      await _grantAchievement(userId, 'top-1');
    }
    if (xp >= 5000 && !await _hasAchievement(userId, 'fast-learner')) {
      await _grantAchievement(userId, 'fast-learner');
    }
    if (xp >= 1000 && !await _hasAchievement(userId, 'dedicated-learner')) {
      await _grantAchievement(userId, 'dedicated-learner');
    }
    
    // CBT-based achievements
    if (cbtHighScore >= 90 && !await _hasAchievement(userId, 'perfect-score')) {
      await _grantAchievement(userId, 'perfect-score');
    }
    if (cbtHighScore >= 75 && !await _hasAchievement(userId, 'high-achiever')) {
      await _grantAchievement(userId, 'high-achiever');
    }
  }

  static Future<bool> _hasAchievement(String userId, String achievementId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
      
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final query = await _db
        .collectionGroup('mock_tests')
        .where('takenAt', isGreaterThan: Timestamp.fromDate(twoWeeksAgo))
        .orderBy('totalScore', descending: true)
        .limit(20)

        .get();
    return doc.exists;
  }


  static Future<void> _grantAchievement(String userId, String achievementId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .set({
          'unlockedAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<List<String>> _getUserAchievementIds(String userId) async {
    try {
      final snapshot = await _db
          .collection('users/$userId/achievements')
          .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      developer.log('Error fetching achievements: $e', error: e);
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUserBadges(String userId) async {
  try {
    final snapshot = await _db

  /// Fetch user badges
  static Future<List<Map<String, dynamic>>> fetchUserBadges(
    String userId,
  ) async {
    final query = await _db

        .collection('users')
        .doc(userId)
        .collection('achievements')
        .get();
    
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc.id.replaceAll('-', ' ').toTitleCase(),
        'unlockedAt': doc.data()['unlockedAt'],
        // Add other fields you need from the achievement documents
      };
    }).toList();
  } catch (e) {
    developer.log('Error fetching user badges: $e', error: e);
    return [];
  }
}

  static DateTimeRange _getDateRange(String period) {
    final now = DateTime.now();
    switch (period.toLowerCase()) {
      case '24h':
        return DateTimeRange(
          start: now.subtract(const Duration(days: 1)),
          end: now,
        );
      case 'weekly':
        return DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      case 'monthly':
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, now.day),
          end: now,
        );
      default:
        return DateTimeRange(
          start: DateTime(0),
          end: now,
        );
    }
  }

  /// Static Nigerian Institutions List
  static List<String> nigerianInstitutions() => [
    'University of Lagos',
    'Obafemi Awolowo University',
    'Afe Babalola University',
    'Wigwe University',
    'Ahmadu Bello University',
    'University of Ibadan',
    'Covenant University',
    'Yaba College of Technology',
    'Federal Polytechnic Bida',
    'Nigerian Army University',
    'Federal College of Education Zaria',
    'Lagos State Polytechnic',
    'Babcock University',
    'Nile University',
    'Auchi Polytechnic',
    'Federal University of Technology Akure',
    'Nnamdi Azikiwe University',
    'Federal University of Agriculture Abeokuta',
    'Kaduna Polytechnic',
    'National Open University of Nigeria',
    'University of Benin',
    'University of Port Harcourt',
    'University of Calabar',
    'University of Jos',
    'University of Maiduguri',
    'University of Ilorin',
    'University of Uyo',
    'Federal University of Petroleum Resources Effurun',
    'Federal University of Technology Minna',
    'Federal University of Technology Owerri',
    'Federal University Dutse',
    'Federal University Dutsin-Ma',
    'Federal University Gashua',
    'Federal University Gusau',
    'Federal University Kashere',
    'Federal University Lafia',
    'Federal University Lokoja',
    'Federal University Ndifu-Alike',
    'Federal University Otuoke',
    'Federal University Oye-Ekiti',
    'Federal University Wukari',
    'Federal University Birnin Kebbi',
    'Federal University Gombe',
    'Federal University of Health Sciences Otukpo',
    'Lagos State University',
    'Rivers State University',
    'Delta State University',
    'Ambrose Alli University',
    'Ekiti State University',
    'Enugu State University of Science and Technology',
    'Imo State University',
    'Abia State University',
    'Olabisi Onabanjo University',
    'Osun State University',
    'Kwara State University',
    'Benue State University',
    'Bayero University Kano',
    'Usmanu Danfodiyo University',
    'Nasarawa State University',
    'Kogi State University',
    'Taraba State University',
    'Adamawa State University',
    'Gombe State University',
    'Sokoto State University',
    'Kebbi State University',
    'Yobe State University',
    'Zamfara State University',
    'Plateau State University',
    'Niger State Polytechnic',
    'Federal Polytechnic Ado-Ekiti',
    'Federal Polytechnic Ede',
    'Federal Polytechnic Idah',
    'Federal Polytechnic Ilaro',
    'Federal Polytechnic Kaura Namoda',
    'Federal Polytechnic Mubi',
    'Federal Polytechnic Nasarawa',
    'Federal Polytechnic Nekede',
    'Federal Polytechnic Offa',
    'Federal Polytechnic Oko',
    'Federal Polytechnic Damaturu',
    'Federal Polytechnic Bali',
    'Federal Polytechnic Ekowe',
    'Federal Polytechnic Ukana',
    'Federal Polytechnic Ile-Oluji',
    'Federal Polytechnic Kaltungo',
    'Federal Polytechnic Monguno',
    'Federal Polytechnic Wannune',
    'Federal College of Agriculture Akure',
    'Federal College of Animal Health and Production Technology Ibadan',
    'Federal College of Education Abeokuta',
    'Federal College of Education Kano',
    'Federal College of Education Katsina',
    'Federal College of Education Kontagora',
    'Federal College of Education Okene',
    'Federal College of Education Omoku',
    'Federal College of Education Pankshin',
    'Federal College of Education Potiskum',
    'Federal College of Education Technical Akoka',
    'Federal College of Education Technical Asaba',
    'Federal College of Education Technical Bichi',
    'Federal College of Education Technical Gombe',
    'Federal College of Education Technical Gusau',
    'Federal College of Education Technical Omoku',
    'Federal College of Education Technical Potiskum',
    'Federal College of Education Technical Umunze',
    'Federal College of Education Yola',
    'Nigerian Defence Academy',
    'Nigerian Police Academy',
    'Nigerian Maritime University',
    'Nigerian College of Aviation Technology',
    'Nigerian Institute of Journalism',
    'Nigerian Law School',
    'Nigerian Institute of Transport Technology',
    'Nigerian Institute of Leather and Science Technology',
    'Nigerian Institute of Mining and Geosciences',
    'Nigerian Institute of Oceanography and Marine Research',
    'Nigerian Institute of Social and Economic Research',
    'Nigerian Institute of Medical Research',
    'Nigerian Institute of Science Laboratory Technology',
    'Nigerian Institute of Public Relations',
    'Nigerian Institute of Management',
    'Nigerian Institute of Advanced Legal Studies',
    'Nigerian Institute of International Affairs',
    'Nigerian Institute of Policy and Strategic Studies',
    'Nigerian Institute of Safety Professionals',
    'Nigerian Institute of Welding',
    'Nigerian Institute of Building',
    'Nigerian Institute of Architects',
    'Nigerian Institute of Quantity Surveyors',
    'Nigerian Institute of Town Planners',
    'Nigerian Institute of Estate Surveyors and Valuers',
    'Nigerian Institute of Chartered Accountants',
    'Nigerian Institute of Bankers',
    'Nigerian Institute of Marketing',
    'Nigerian Institute of Management Consultants',
    'Nigerian Institute of Public Administrators',
    'Nigerian Institute of Purchasing and Supply Management',
    'Nigerian Institute of Transport Administration',
    'Nigerian Institute of Training and Development',
    'Nigerian Institute of Urban and Regional Planners',
    'Nigerian Institute of Water Engineers',
    'Nigerian Institute of Welding and Fabrication',
    'Nigerian Institute of Wood Technology',
    'Nigerian Institute of Youth Development',
    'Others...',
  ];
}
