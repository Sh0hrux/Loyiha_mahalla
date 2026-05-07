import 'package:cloud_firestore/cloud_firestore.dart';

class ArizaModel {
  final String id;
  final String userId;
  final String userFullName;
  final String userPhone;
  final String category;
  final String description;
  final String status; // yuborildi, ko'rilmoqda, bajarildi, rad_etildi
  final List<String> imageUrls;
  final String? adminResponse;
  final String? adminId;
  final String? mahallaId; // Mahalla ID
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  ArizaModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.userPhone,
    required this.category,
    required this.description,
    required this.status,
    this.imageUrls = const [],
    this.adminResponse,
    this.adminId,
    this.mahallaId,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  // From Firestore
  factory ArizaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArizaModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userFullName: data['userFullName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'yuborildi',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      adminResponse: data['adminResponse'],
      adminId: data['adminId'],
      mahallaId: data['mahallaId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
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
      'status': status,
      'imageUrls': imageUrls,
      'adminResponse': adminResponse,
      'adminId': adminId,
      'mahallaId': mahallaId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  // CopyWith
  ArizaModel copyWith({
    String? id,
    String? userId,
    String? userFullName,
    String? userPhone,
    String? category,
    String? description,
    String? status,
    List<String>? imageUrls,
    String? adminResponse,
    String? adminId,
    String? mahallaId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return ArizaModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      userPhone: userPhone ?? this.userPhone,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      imageUrls: imageUrls ?? this.imageUrls,
      adminResponse: adminResponse ?? this.adminResponse,
      adminId: adminId ?? this.adminId,
      mahallaId: mahallaId ?? this.mahallaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Status helpers
  bool get isYuborildi => status == 'yuborildi';
  bool get isKorilmoqda => status == 'ko\'rilmoqda';
  bool get isBajarildi => status == 'bajarildi';
  bool get isRad => status == 'rad_etildi';

  // Status color
  String get statusText {
    switch (status) {
      case 'yuborildi':
        return 'Yuborildi';
      case 'ko\'rilmoqda':
        return 'Ko\'rib chiqilmoqda';
      case 'bajarildi':
        return 'Bajarildi';
      case 'rad_etildi':
        return 'Rad etildi';
      default:
        return status;
    }
  }
}
