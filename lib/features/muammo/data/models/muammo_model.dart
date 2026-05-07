import 'package:cloud_firestore/cloud_firestore.dart';

class MuammoModel {
  final String id;
  final String userId;
  final String userFullName;
  final String userPhone;
  final String category;
  final String description;
  final String location;
  final List<String> imageUrls;
  final String status; // yuborildi, ko'rilmoqda, hal_qilindi, rad_etildi
  final String? adminResponse;
  final String? mahallaId; // Mahalla ID
  final DateTime createdAt;
  final DateTime? updatedAt;

  MuammoModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.userPhone,
    required this.category,
    required this.description,
    required this.location,
    required this.imageUrls,
    required this.status,
    this.adminResponse,
    this.mahallaId,
    required this.createdAt,
    this.updatedAt,
  });

  // Status text
  String get statusText {
    switch (status) {
      case 'yuborildi':
        return 'Yuborildi';
      case 'ko\'rilmoqda':
        return 'Ko\'rilmoqda';
      case 'hal_qilindi':
        return 'Hal qilindi';
      case 'rad_etildi':
        return 'Rad etildi';
      default:
        return 'Noma\'lum';
    }
  }

  // From Firestore
  factory MuammoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MuammoModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userFullName: data['userFullName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      status: data['status'] ?? 'yuborildi',
      adminResponse: data['adminResponse'],
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
      'userId': userId,
      'userFullName': userFullName,
      'userPhone': userPhone,
      'category': category,
      'description': description,
      'location': location,
      'imageUrls': imageUrls,
      'status': status,
      'adminResponse': adminResponse,
      'mahallaId': mahallaId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Copy with
  MuammoModel copyWith({
    String? id,
    String? userId,
    String? userFullName,
    String? userPhone,
    String? category,
    String? description,
    String? location,
    List<String>? imageUrls,
    String? status,
    String? adminResponse,
    String? mahallaId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MuammoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      userPhone: userPhone ?? this.userPhone,
      category: category ?? this.category,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      mahallaId: mahallaId ?? this.mahallaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
