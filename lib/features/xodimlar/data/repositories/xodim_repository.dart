import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/xodim_model.dart';

class XodimRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'xodimlar';

  // Get active xodimlar
  Stream<List<XodimModel>> getActiveXodimlar() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final xodimlar = snapshot.docs
          .map((doc) => XodimModel.fromFirestore(doc))
          .toList();
      // Sort by order
      xodimlar.sort((a, b) => a.order.compareTo(b.order));
      return xodimlar;
    });
  }

  // Get all xodimlar (Admin)
  Stream<List<XodimModel>> getAllXodimlar() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final xodimlar = snapshot.docs
          .map((doc) => XodimModel.fromFirestore(doc))
          .toList();
      // Sort by order
      xodimlar.sort((a, b) => a.order.compareTo(b.order));
      return xodimlar;
    });
  }

  // Create xodim (Admin)
  Future<String> createXodim(XodimModel xodim) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            xodim.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Xodim qo\'shishda xatolik: $e');
    }
  }

  // Update xodim (Admin)
  Future<void> updateXodim(String xodimId, XodimModel xodim) async {
    try {
      await _firestore.collection(_collection).doc(xodimId).update(
            xodim.toFirestore(),
          );
    } catch (e) {
      throw Exception('Xodimni yangilashda xatolik: $e');
    }
  }

  // Delete xodim (Admin)
  Future<void> deleteXodim(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Xodimni o\'chirishda xatolik: $e');
    }
  }
}
