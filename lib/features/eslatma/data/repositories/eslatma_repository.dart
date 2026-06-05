import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firebase_service.dart';
import '../models/eslatma_model.dart';

class EslatmaRepository {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final String _collection = 'eslatmalar';

  /// Yangi eslatma yaratish (faqat admin/xodim)
  Future<String> createEslatma({
    required String userId,
    required String adminId,
    required String adminName,
    required EslatmaType type,
    required String title,
    required String message,
    DateTime? expiresAt,
    bool isUrgent = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final eslatma = EslatmaModel(
        id: '', // Firestore generates
        userId: userId,
        adminId: adminId,
        adminName: adminName,
        type: type,
        title: title,
        message: message,
        isRead: false,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        isUrgent: isUrgent,
        metadata: metadata,
      );

      final docRef = await _firestore
          .collection(_collection)
          .add(eslatma.toFirestore());

      print('✅ Eslatma yaratildi: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Eslatma yaratishda xatolik: $e');
      rethrow;
    }
  }

  /// Bir nechta foydalanuvchilarga eslatma yuborish
  Future<List<String>> createBulkEslatma({
    required List<String> userIds,
    required String adminId,
    required String adminName,
    required EslatmaType type,
    required String title,
    required String message,
    DateTime? expiresAt,
    bool isUrgent = false,
  }) async {
    try {
      final batch = _firestore.batch();
      final docIds = <String>[];

      for (final userId in userIds) {
        final docRef = _firestore.collection(_collection).doc();
        final eslatma = EslatmaModel(
          id: docRef.id,
          userId: userId,
          adminId: adminId,
          adminName: adminName,
          type: type,
          title: title,
          message: message,
          isRead: false,
          createdAt: DateTime.now(),
          expiresAt: expiresAt,
          isUrgent: isUrgent,
        );

        batch.set(docRef, eslatma.toFirestore());
        docIds.add(docRef.id);
      }

      await batch.commit();
      print('✅ ${userIds.length} ta eslatma yuborildi');
      return docIds;
    } catch (e) {
      print('❌ Bulk eslatma yaratishda xatolik: $e');
      rethrow;
    }
  }

  /// Foydalanuvchining eslatmalari (real-time stream)
  Stream<List<EslatmaModel>> getUserEslatmalar(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EslatmaModel.fromFirestore(doc))
          .toList();
    });
  }

  /// O'qilmagan eslatmalar soni (real-time)
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Barcha eslatmalar (admin uchun)
  Stream<List<EslatmaModel>> getAllEslatmalar() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EslatmaModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Eslatmani o'qilgan deb belgilash
  Future<void> markAsRead(String eslatmaId) async {
    try {
      await _firestore.collection(_collection).doc(eslatmaId).update({
        'isRead': true,
      });
      print('✅ Eslatma o\'qildi: $eslatmaId');
    } catch (e) {
      print('❌ Eslatmani o\'qilgan deb belgilashda xatolik: $e');
      rethrow;
    }
  }

  /// Barcha eslatmalarni o'qilgan deb belgilash
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      print('✅ Barcha eslatmalar o\'qildi');
    } catch (e) {
      print('❌ Barcha eslatmalarni o\'qilgan deb belgilashda xatolik: $e');
      rethrow;
    }
  }

  /// Eslatmani o'chirish
  Future<void> deleteEslatma(String eslatmaId) async {
    try {
      await _firestore.collection(_collection).doc(eslatmaId).delete();
      print('✅ Eslatma o\'chirildi: $eslatmaId');
    } catch (e) {
      print('❌ Eslatmani o\'chirishda xatolik: $e');
      rethrow;
    }
  }

  /// Bitta eslatmani olish
  Future<EslatmaModel?> getEslatmaById(String eslatmaId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(eslatmaId).get();
      if (!doc.exists) return null;
      return EslatmaModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Eslatmani olishda xatolik: $e');
      return null;
    }
  }

  /// Eskirgan eslatmalarni o'chirish (30 kundan eski)
  Future<void> deleteExpiredEslatmalar() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final snapshot = await _firestore
          .collection(_collection)
          .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ ${snapshot.docs.length} ta eskirgan eslatma o\'chirildi');
    } catch (e) {
      print('❌ Eskirgan eslatmalarni o\'chirishda xatolik: $e');
      rethrow;
    }
  }

  /// Eslatma statistikasi (admin uchun)
  Future<Map<String, int>> getEslatmaStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      
      int total = snapshot.docs.length;
      int unread = 0;
      int urgent = 0;
      Map<String, int> typeCount = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['isRead'] == false) unread++;
        if (data['isUrgent'] == true) urgent++;
        
        final type = data['type'] as String;
        typeCount[type] = (typeCount[type] ?? 0) + 1;
      }

      return {
        'total': total,
        'unread': unread,
        'urgent': urgent,
        ...typeCount,
      };
    } catch (e) {
      print('❌ Statistika olishda xatolik: $e');
      return {};
    }
  }
}
