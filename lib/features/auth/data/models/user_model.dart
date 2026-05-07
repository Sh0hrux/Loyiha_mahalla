import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String phoneNumber;
  final String fullName;
  final String role; // 'fuqaro' or 'admin'
  final String? address;
  final String? passportSeries;
  final String? passportNumber;
  final String? photoUrl;
  final String? mahallaId; // Mahalla ID (reference to mahallalar collection)
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.role,
    this.address,
    this.passportSeries,
    this.passportNumber,
    this.photoUrl,
    this.mahallaId,
    required this.createdAt,
    this.updatedAt,
  });

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      phoneNumber: data['phoneNumber'] ?? '',
      fullName: data['fullName'] ?? '',
      role: data['role'] ?? 'fuqaro',
      address: data['address'],
      passportSeries: data['passportSeries'],
      passportNumber: data['passportNumber'],
      photoUrl: data['photoUrl'],
      mahallaId: data['mahallaId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'role': role,
      'address': address,
      'passportSeries': passportSeries,
      'passportNumber': passportNumber,
      'photoUrl': photoUrl,
      'mahallaId': mahallaId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // CopyWith
  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    String? role,
    String? address,
    String? passportSeries,
    String? passportNumber,
    String? photoUrl,
    String? mahallaId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      address: address ?? this.address,
      passportSeries: passportSeries ?? this.passportSeries,
      passportNumber: passportNumber ?? this.passportNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      mahallaId: mahallaId ?? this.mahallaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isFuqaro => role == 'fuqaro';
}
