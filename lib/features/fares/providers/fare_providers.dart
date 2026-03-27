import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagme/features/fares/data/models/fare_entry.dart';
import 'package:tagme/features/fares/data/repositories/fare_repository.dart';
import 'package:tagme/features/profile/data/models/student.dart';
import 'package:tagme/features/profile/data/repositories/profile_repository.dart';

part 'fare_providers.g.dart';

/// Fetches net balances per co-rider for the current user.
///
/// Returns a map of co-rider student IDs to net amounts:
/// positive = they owe you, negative = you owe them.
@riverpod
Future<Map<String, int>> fareBalances(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  final studentId = prefs.getString('local_profile_id');
  if (studentId == null) return {};

  final repo = ref.watch(fareRepositoryProvider);
  return repo.getBalances(studentId);
}

/// Fetches fare history entries for the current user, sorted by date desc.
@riverpod
Future<List<FareEntry>> fareHistory(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  final studentId = prefs.getString('local_profile_id');
  if (studentId == null) return [];

  final repo = ref.watch(fareRepositoryProvider);
  return repo.getEntriesForStudent(studentId);
}

/// Fetches a co-rider's profile by student ID.
@riverpod
Future<Student?> coRiderProfile(Ref ref, String studentId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile(studentId);
}
