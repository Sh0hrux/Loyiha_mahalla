import 'package:cloud_firestore/cloud_firestore.dart';

class ElonModel {
  final String id;
  final String title;
  final String content;
  final String category; // Muhim, Oddiy, Tadbir
  final String? imageUrl;
  final String authorId;
  final String authorName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt; // E'lon amal qilish muddati

  ElonModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  // Category color
  String get categoryColor {
    switch (category) {
      case 'Muhim':
        return 'red';
      case 'Tadbir':
        return 'purple';
      case 'Oddiy':
      default:
        return 'blue';
    }
  }

  // Is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // From Firestore
  factory ElonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ElonModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? 'Oddiy',
      imageUrl: data['imageUrl'],
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  // Copy with
  ElonModel copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? imageUrl,
    String? authorId,
    String? authorName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return ElonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
