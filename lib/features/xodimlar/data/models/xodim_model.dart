import 'package:cloud_firestore/cloud_firestore.dart';

class XodimModel {
  final String id;
  final String fullName;
  final String position; // Lavozim
  final String phone;
  final String? email;
  final String? photoUrl;
  final String? description;
  final int order; // Display order
  final bool isActive;
  final DateTime createdAt;

  XodimModel({
    required this.id,
    required this.fullName,
    required this.position,
    required this.phone,
    this.email,
    this.photoUrl,
    this.description,
    required this.order,
    required this.isActive,
    required this.createdAt,
  });

  // From Firestore
  factory XodimModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return XodimModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      position: data['position'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      photoUrl: data['photoUrl'],
      description: data['description'],
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'position': position,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'description': description,
      'order': order,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
