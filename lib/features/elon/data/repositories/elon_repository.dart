import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/elon_model.dart';

class ElonRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'elonlar';

  // Create elon (Admin only)
  Future<String> createElon(ElonModel elon) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            elon.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('E\'lon yaratishda xatolik: $e');
    }
  }

  // Get active elonlar (for users)
  Stream<List<ElonModel>> getActiveElonlar() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final elonlar = snapshot.docs
          .map((doc) => ElonModel.fromFirestore(doc))
          .where((elon) => !elon.isExpired) // Filter expired
          .toList();
      // Sort by created date
      elonlar.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return elonlar;
    });
  }

  // Get all elonlar (Admin)
  Stream<List<ElonModel>> getAllElonlar() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final elonlar = snapshot.docs
          .map((doc) => ElonModel.fromFirestore(doc))
          .toList();
      // Sort by created date
      elonlar.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return elonlar;
    });
  }

  // Get elon by ID
  Future<ElonModel> getElonById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw Exception('E\'lon topilmadi');
      }
      return ElonModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('E\'lon ma\'lumotlarini olishda xatolik: $e');
    }
  }

  // Update elon (Admin)
  Future<void> updateElon(String elonId, ElonModel elon) async {
    try {
      await _firestore.collection(_collection).doc(elonId).update(
            elon.toFirestore(),
          );
    } catch (e) {
      throw Exception('E\'lonni yangilashda xatolik: $e');
    }
  }

  // Toggle elon active status (Admin)
  Future<void> toggleElonStatus(String elonId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(elonId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('E\'lon holatini o\'zgartirishda xatolik: $e');
    }
  }

  // Delete elon (Admin)
  Future<void> deleteElon(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('E\'lonni o\'chirishda xatolik: $e');
    }
  }
}
