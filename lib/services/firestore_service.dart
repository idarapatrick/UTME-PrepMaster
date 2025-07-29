import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_profile_model.dart';
import '../models/study_partner.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  /// Create a new user profile document only if it doesn't exist
  static Future<void> createUserProfile(User user) async {
    final doc = _db.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
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
    await _db.collection('users').doc(userId).collection('test_results').add({
      'testId': testId,
      'score': score,
      'answers': answers,
      'takenAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save quiz result
  static Future<void> saveQuizResult({
    required String userId,
    required String subject,
    required int correct,
    required int attempted,
    required double score,
  }) async {
    await _db.collection('users').doc(userId).collection('quizzes').add({
      'subject': subject,
      'correct': correct,
      'attempted': attempted,
      'score': score,
      'takenAt': FieldValue.serverTimestamp(),
    });
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
    final ref = FirebaseStorage.instance.ref().child(
      'users/$userId/$path/$fileName',
    );
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
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final query = await _db
        .collectionGroup('mock_tests')
        .where('takenAt', isGreaterThan: Timestamp.fromDate(twoWeeksAgo))
        .orderBy('totalScore', descending: true)
        .limit(20)
        .get();
    return query.docs.map((d) => d.data()).toList();
  }
  /// Fetch user badges
  static Future<List<Map<String, dynamic>>> fetchUserBadges(
    String userId,
  ) async {
    final query = await _db
        .collection('users')
        .doc(userId)
        .collection('badges')
        .get();
    return query.docs.map((d) => d.data()).toList();
  }

  /// Static Nigerian Institutions List
  static List<String> nigerianInstitutions() => [
    'University of Lagos',
    'Obafemi Awolowo University',
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
 
 /// Get matched partners for a specific user

 final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<StudyPartner>> getMatchedPartners(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('study_partners')
          .where('matchedUserIds', arrayContains: userId)
          .get();

      return snapshot.docs.map((doc) {
        return StudyPartner.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching matched partners: $e');
      return [];
    }
  }


