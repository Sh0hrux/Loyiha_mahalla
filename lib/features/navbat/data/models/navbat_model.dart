import 'package:cloud_firestore/cloud_firestore.dart';

class NavbatModel {
  final String id;
  final String userId;
  final String userFullName;
  final String userPhone;
  final String purpose; // Maqsad
  final DateTime appointmentDate; // Navbat sanasi
  final String timeSlot; // Vaqt oralig'i (09:00-09:30)
  final String status; // kutilmoqda, tasdiqlandi, bekor_qilindi, tugallandi
  final String? adminNote; // Admin izohi
  final String? adminId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NavbatModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.userPhone,
    required this.purpose,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    this.adminNote,
    this.adminId,
    required this.createdAt,
    this.updatedAt,
  });

  // Status text
  String get statusText {
    switch (status) {
      case 'kutilmoqda':
        return 'Kutilmoqda';
      case 'tasdiqlandi':
        return 'Tasdiqlandi';
      case 'bekor_qilindi':
        return 'Bekor qilindi';
      case 'tugallandi':
        return 'Tugallandi';
      default:
        return 'Noma\'lum';
    }
  }

  // From Firestore
  factory NavbatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NavbatModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userFullName: data['userFullName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      purpose: data['purpose'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      status: data['status'] ?? 'kutilmoqda',
      adminNote: data['adminNote'],
      adminId: data['adminId'],
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
      'purpose': purpose,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'status': status,
      'adminNote': adminNote,
      'adminId': adminId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Copy with
  NavbatModel copyWith({
    String? id,
    String? userId,
    String? userFullName,
    String? userPhone,
    String? purpose,
    DateTime? appointmentDate,
    String? timeSlot,
    String? status,
    String? adminNote,
    String? adminId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NavbatModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      userPhone: userPhone ?? this.userPhone,
      purpose: purpose ?? this.purpose,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
