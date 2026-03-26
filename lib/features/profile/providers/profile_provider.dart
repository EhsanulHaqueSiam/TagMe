import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/profile/data/models/student.dart';
import 'package:tagme/features/profile/data/repositories/profile_repository.dart';

part 'profile_provider.g.dart';

/// Manages async profile state with load and save operations.
///
/// On build, loads the current profile by reading the locally persisted
/// profile ID and fetching the profile from Firestore.
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  FutureOr<Student?> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    final localId = await repo.getLocalProfileId();
    if (localId == null) return null;
    return repo.getProfile(localId);
  }

  /// Saves a student profile to Firestore and persists the document ID locally.
  Future<void> saveProfile(Student student) async {
    state = const AsyncLoading<Student?>();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      final docId = await repo.saveProfile(student);
      await repo.saveLocalProfileId(docId);
      return student.copyWith(id: docId);
    });
  }
}

/// Returns true if a local profile ID exists (i.e., user has set up a profile).
@riverpod
Future<bool> hasProfile(Ref ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  final localId = await repo.getLocalProfileId();
  return localId != null;
}
