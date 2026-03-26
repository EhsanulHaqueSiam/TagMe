import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagme/features/profile/data/models/student.dart';

part 'profile_repository.g.dart';

/// Key used to persist the local profile document ID.
const _profileIdKey = 'local_profile_id';

/// Repository handling Firestore CRUD for student profiles.
@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(firestore: FirebaseFirestore.instance);
}

class ProfileRepository {
  ProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _studentsCollection =>
      _firestore.collection('students');

  /// Saves a student profile to Firestore.
  ///
  /// If the student has no ID, creates a new document with auto-generated ID.
  /// If the student has an existing ID, overwrites the document.
  /// Returns the document ID of the saved profile.
  Future<String> saveProfile(Student student) async {
    final data = student.toJson();

    // Always set updatedAt
    data['updatedAt'] = FieldValue.serverTimestamp();

    if (student.id == null) {
      // New profile -- add createdAt and auto-generate ID
      data['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await _studentsCollection.add(data);
      return docRef.id;
    } else {
      // Existing profile -- update in place
      await _studentsCollection
          .doc(student.id)
          .set(data, SetOptions(merge: true));
      return student.id!;
    }
  }

  /// Reads a single student profile from Firestore by document ID.
  Future<Student?> getProfile(String id) async {
    final doc = await _studentsCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return Student.fromJson(data);
  }

  /// Reads the locally persisted profile document ID.
  Future<String?> getLocalProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileIdKey);
  }

  /// Persists the profile document ID locally so the app knows "who am I".
  Future<void> saveLocalProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileIdKey, id);
  }
}
