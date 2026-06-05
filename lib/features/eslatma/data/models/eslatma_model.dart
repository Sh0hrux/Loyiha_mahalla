import 'package:cloud_firestore/cloud_firestore.dart';

/// Eslatma turlari
enum EslatmaType {
  soliq('Soliq to\'lovi', '💰'),
  kommunal('Kommunal to\'lovlar', '🏘️'),
  tadbir('Tadbir va tadbirlar', '🎉'),
  yigilish('Mahalla yig\'ilishi', '👥'),
  xizmat('Mahalla xizmati', '🏛️'),
  umumiy('Umumiy xabar', '📢'),
  muhim('Muhim eslatma', '⚠️');

  final String label;
  final String emoji;
  const EslatmaType(this.label, this.emoji);

  static EslatmaType fromString(String value) {
    return EslatmaType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => EslatmaType.umumiy,
    );
  }
}

/// Eslatma (Bildirishnoma) Model
class EslatmaModel {
  final String id;
  final String userId; // Qaysi foydalanuvchiga yuborilgan
  final String adminId; // Kim yuborgan (admin)
  final String adminName; // Admin ismi
  final EslatmaType type; // Eslatma turi
  final String title; // Sarlavha
  final String message; // Xabar matni
  final bool isRead; // O'qilganmi?
  final DateTime createdAt; // Yaratilgan vaqt
  final DateTime? expiresAt; // Amal qilish muddati (ixtiyoriy)
  final bool isUrgent; // Shoshilinch eslatma
  final Map<String, dynamic>? metadata; // Qo'shimcha ma'lumotlar

  EslatmaModel({
    required this.id,
    required this.userId,
    required this.adminId,
    required this.adminName,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.expiresAt,
    this.isUrgent = false,
    this.metadata,
  });

  /// Firestore'dan Model'ga
  factory EslatmaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return EslatmaModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      adminId: data['adminId'] ?? '',
      adminName: data['adminName'] ?? 'Admin',
      type: EslatmaType.fromString(data['type'] ?? 'umumiy'),
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      isUrgent: data['isUrgent'] ?? false,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Model'dan Firestore'ga
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'adminId': adminId,
      'adminName': adminName,
      'type': type.name,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isUrgent': isUrgent,
      'metadata': metadata,
    };
  }

  /// Copy with
  EslatmaModel copyWith({
    String? id,
    String? userId,
    String? adminId,
    String? adminName,
    EslatmaType? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isUrgent,
    Map<String, dynamic>? metadata,
  }) {
    return EslatmaModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isUrgent: isUrgent ?? this.isUrgent,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Eslatma muddati o'tganmi?
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Eslatma yangi (24 soat ichida)
  bool get isNew {
    return DateTime.now().difference(createdAt).inHours < 24;
  }

  /// Eslatma rangi (turi bo'yicha)
  String get typeColor {
    switch (type) {
      case EslatmaType.soliq:
        return '#10B981'; // Green
      case EslatmaType.kommunal:
        return '#3B82F6'; // Blue
      case EslatmaType.tadbir:
        return '#F59E0B'; // Amber
      case EslatmaType.yigilish:
        return '#8B5CF6'; // Violet
      case EslatmaType.xizmat:
        return '#EC4899'; // Pink
      case EslatmaType.muhim:
        return '#EF4444'; // Red
      default:
        return '#6366F1'; // Indigo
    }
  }
}
