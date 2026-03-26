import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

/// Checks whether mock student data has already been seeded.
///
/// Returns `true` if the students collection is empty and seeding should run.
Future<bool> shouldSeed() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('students').limit(1).get();
  return snapshot.docs.isEmpty;
}

/// Seeds 8 mock student profiles into Firestore for development and testing.
///
/// Uses a batch write for efficiency. Each student includes a geo-hashed
/// location field for geoflutterfire_plus queries. Only runs when
/// [shouldSeed] returns true.
Future<void> seedMockStudents() async {
  final mockStudents = <Map<String, dynamic>>[
    {
      'name': 'Rahim Ahmed',
      'university': 'AIUB',
      'gender': 'male',
      'transportType': 'bus',
      'routeOrigin': 'Uttara',
      'routeDestination': 'AIUB Kuratoli',
      'location':
          const GeoFirePoint(GeoPoint(23.8756, 90.3917)).data,
    },
    {
      'name': 'Fatima Khan',
      'university': 'BRACU',
      'gender': 'female',
      'transportType': 'CNG',
      'routeOrigin': 'Mohakhali',
      'routeDestination': 'BRACU Mohakhali',
      'location':
          const GeoFirePoint(GeoPoint(23.7781, 90.4042)).data,
    },
    {
      'name': 'Karim Hasan',
      'university': 'NSU',
      'gender': 'male',
      'transportType': 'rickshaw',
      'routeOrigin': 'Bashundhara',
      'routeDestination': 'NSU Bashundhara',
      'location':
          const GeoFirePoint(GeoPoint(23.8148, 90.4255)).data,
    },
    {
      'name': 'Nusrat Jahan',
      'university': 'DU',
      'gender': 'female',
      'transportType': 'bus',
      'routeOrigin': 'Mirpur',
      'routeDestination': 'DU Campus',
      'location':
          const GeoFirePoint(GeoPoint(23.7335, 90.3925)).data,
    },
    {
      'name': 'Tanvir Islam',
      'university': 'BUET',
      'gender': 'male',
      'transportType': 'bike',
      'routeOrigin': 'Dhanmondi',
      'routeDestination': 'BUET Palashi',
      'location':
          const GeoFirePoint(GeoPoint(23.7267, 90.3887)).data,
    },
    {
      'name': 'Sabrina Akter',
      'university': 'IUB',
      'gender': 'female',
      'transportType': 'car',
      'routeOrigin': 'Gulshan',
      'routeDestination': 'IUB Bashundhara',
      'location':
          const GeoFirePoint(GeoPoint(23.7947, 90.4143)).data,
    },
    {
      'name': 'Arif Rahman',
      'university': 'EWU',
      'gender': 'male',
      'transportType': 'CNG',
      'routeOrigin': 'Rampura',
      'routeDestination': 'EWU Aftabnagar',
      'location':
          const GeoFirePoint(GeoPoint(23.7645, 90.4312)).data,
    },
    {
      'name': 'Maliha Tasnim',
      'university': 'AIUB',
      'gender': 'female',
      'transportType': 'bus',
      'routeOrigin': 'Banani',
      'routeDestination': 'AIUB Kuratoli',
      'location':
          const GeoFirePoint(GeoPoint(23.7940, 90.4023)).data,
    },
  ];

  final batch = FirebaseFirestore.instance.batch();
  for (final student in mockStudents) {
    batch.set(
      FirebaseFirestore.instance.collection('students').doc(),
      {
        ...student,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }
  await batch.commit();
}
