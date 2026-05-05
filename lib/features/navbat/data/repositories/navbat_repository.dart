import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/navbat_model.dart';

class NavbatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'navbatlar';

  // Create navbat
  Future<String> createNavbat(NavbatModel navbat) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            navbat.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Navbat band qilishda xatolik: $e');
    }
  }

  // Get user navbatlar
  Stream<List<NavbatModel>> getUserNavbatlar(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final navbatlar = snapshot.docs
          .map((doc) => NavbatModel.fromFirestore(doc))
          .toList();
      // Sort by appointment date
      navbatlar.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
      return navbatlar;
    });
  }

  // Get all navbatlar (Admin)
  Stream<List<NavbatModel>> getAllNavbatlar() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      final navbatlar = snapshot.docs
          .map((doc) => NavbatModel.fromFirestore(doc))
          .toList();
      // Sort by appointment date
      navbatlar.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
      return navbatlar;
    });
  }

  // Get navbatlar by date (for checking availability)
  Future<List<NavbatModel>> getNavbatlarByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Get all navbatlar for the date
      final snapshot = await _firestore
          .collection(_collection)
          .where('appointmentDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('appointmentDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      // Filter in memory to avoid index requirement
      final navbatlar = snapshot.docs
          .map((doc) => NavbatModel.fromFirestore(doc))
          .where((navbat) =>
              navbat.status == 'kutilmoqda' || navbat.status == 'tasdiqlandi')
          .toList();

      return navbatlar;
    } catch (e) {
      throw Exception('Navbatlarni olishda xatolik: $e');
    }
  }

  // Get navbat by ID
  Future<NavbatModel> getNavbatById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw Exception('Navbat topilmadi');
      }
      return NavbatModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Navbat ma\'lumotlarini olishda xatolik: $e');
    }
  }

  // Update navbat status (Admin)
  Future<void> updateNavbatStatus({
    required String navbatId,
    required String status,
    String? adminNote,
    String? adminId,
  }) async {
    try {
      await _firestore.collection(_collection).doc(navbatId).update({
        'status': status,
        'adminNote': adminNote,
        'adminId': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Navbat holatini yangilashda xatolik: $e');
    }
  }

  // Cancel navbat (User)
  Future<void> cancelNavbat(String navbatId) async {
    try {
      await _firestore.collection(_collection).doc(navbatId).update({
        'status': 'bekor_qilindi',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Navbatni bekor qilishda xatolik: $e');
    }
  }

  // Delete navbat
  Future<void> deleteNavbat(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Navbatni o\'chirishda xatolik: $e');
    }
  }
}
