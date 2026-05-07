import 'package:cloud_firestore/cloud_firestore.dart';

class MahallaModel {
  final String id;
  final String name;
  final String region;
  final String district;
  final DateTime createdAt;

  MahallaModel({
    required this.id,
    required this.name,
    required this.region,
    required this.district,
    required this.createdAt,
  });

  // From Firestore
  factory MahallaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MahallaModel(
      id: doc.id,
      name: data['name'] ?? '',
      region: data['region'] ?? '',
      district: data['district'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'region': region,
      'district': district,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
