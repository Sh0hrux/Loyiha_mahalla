import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/muammo_model.dart';

class MuammoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'muammolar';

  // Create muammo
  Future<String> createMuammo(MuammoModel muammo) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            muammo.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Muammo yuborishda xatolik: $e');
    }
  }

  // Get user muammolar
  Stream<List<MuammoModel>> getUserMuammolar(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final muammolar = snapshot.docs
          .map((doc) => MuammoModel.fromFirestore(doc))
          .toList();
      // Sort in memory instead of Firestore
      muammolar.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return muammolar;
    });
  }

  // Get all muammolar (Admin)
  Stream<List<MuammoModel>> getAllMuammolar() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MuammoModel.fromFirestore(doc))
            .toList());
  }

  // Get muammo by ID
  Future<MuammoModel> getMuammoById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw Exception('Muammo topilmadi');
      }
      return MuammoModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Muammo ma\'lumotlarini olishda xatolik: $e');
    }
  }

  // Update muammo status (Admin)
  Future<void> updateMuammoStatus({
    required String muammoId,
    required String status,
    String? adminResponse,
  }) async {
    try {
      await _firestore.collection(_collection).doc(muammoId).update({
        'status': status,
        'adminResponse': adminResponse,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Muammo holatini yangilashda xatolik: $e');
    }
  }

  // Delete muammo
  Future<void> deleteMuammo(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Muammoni o\'chirishda xatolik: $e');
    }
  }
}
