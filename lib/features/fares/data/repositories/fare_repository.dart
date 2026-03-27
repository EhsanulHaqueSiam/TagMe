import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/fares/data/models/fare_entry.dart';

part 'fare_repository.g.dart';

/// Repository handling Firestore CRUD for fare ledger entries.
@riverpod
FareRepository fareRepository(Ref ref) {
  return FareRepository(firestore: FirebaseFirestore.instance);
}

class FareRepository {
  FareRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _fareLedgerCollection =>
      _firestore.collection('fareLedger');

  /// Creates a new fare ledger entry. Returns the auto-generated doc ID.
  Future<String> createEntry(FareEntry entry) async {
    final data = entry.toJson();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _fareLedgerCollection.add(data);
    return docRef.id;
  }

  /// Gets all fare entries involving [studentId] (as payer or payee).
  ///
  /// Merges two queries (fromStudentId and toStudentId) and sorts by
  /// rideDate descending.
  Future<List<FareEntry>> getEntriesForStudent(String studentId) async {
    final fromSnapshot = await _fareLedgerCollection
        .where('fromStudentId', isEqualTo: studentId)
        .get();
    final toSnapshot = await _fareLedgerCollection
        .where('toStudentId', isEqualTo: studentId)
        .get();

    // Merge and deduplicate by doc ID.
    final docsById = <String, DocumentSnapshot<Map<String, dynamic>>>{};
    for (final doc in fromSnapshot.docs) {
      docsById[doc.id] = doc;
    }
    for (final doc in toSnapshot.docs) {
      docsById[doc.id] = doc;
    }

    final entries = docsById.values.map(_entryFromDoc).toList()
      ..sort((a, b) => b.rideDate.compareTo(a.rideDate));
    return entries;
  }

  /// Computes net balance per co-rider for [studentId].
  ///
  /// Returns a map of co-rider IDs to net amounts:
  /// - Positive = they owe you
  /// - Negative = you owe them
  Future<Map<String, int>> getBalances(String studentId) async {
    final entries = await getEntriesForStudent(studentId);
    final balances = <String, int>{};

    for (final entry in entries) {
      if (entry.settled) continue;

      if (entry.fromStudentId == studentId) {
        // I owe them.
        final coRider = entry.toStudentId;
        balances[coRider] = (balances[coRider] ?? 0) - entry.amount;
      } else if (entry.toStudentId == studentId) {
        // They owe me.
        final coRider = entry.fromStudentId;
        balances[coRider] = (balances[coRider] ?? 0) + entry.amount;
      }
    }

    return balances;
  }

  /// Marks a fare entry as settled.
  Future<void> markSettled(String entryId) async {
    await _fareLedgerCollection.doc(entryId).update({'settled': true});
  }

  FareEntry _entryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    data['id'] = doc.id;

    // Convert Timestamps to DateTime for Freezed.
    if (data['rideDate'] is Timestamp) {
      data['rideDate'] =
          (data['rideDate'] as Timestamp).toDate().toIso8601String();
    }
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }

    return FareEntry.fromJson(data);
  }
}
