import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/firebase_service.dart';
import '../models/ariza_model.dart';

class ArizaRepository {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Create Ariza
  Future<String> createAriza(ArizaModel ariza) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.arizalarCollection)
          .add(ariza.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Ariza yuborishda xatolik: ${e.toString()}');
    }
  }

  // Get User Arizalar
  Stream<List<ArizaModel>> getUserArizalar(String userId) {
    return _firestore
        .collection(AppConstants.arizalarCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final arizalar = snapshot.docs
          .map((doc) => ArizaModel.fromFirestore(doc))
          .toList();
      // Sort in memory instead of Firestore
      arizalar.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return arizalar;
    });
  }

  // Get All Arizalar (Admin)
  Stream<List<ArizaModel>> getAllArizalar() {
    return _firestore
        .collection(AppConstants.arizalarCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ArizaModel.fromFirestore(doc)).toList());
  }

  // Get Ariza by ID
  Future<ArizaModel> getArizaById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.arizalarCollection)
          .doc(id)
          .get();
      
      if (!doc.exists) {
        throw Exception('Ariza topilmadi');
      }
      
      return ArizaModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Ariza olishda xatolik: ${e.toString()}');
    }
  }

  // Update Ariza Status (Admin)
  Future<void> updateArizaStatus({
    required String arizaId,
    required String status,
    String? adminResponse,
    String? adminId,
  }) async {
    try {
      final data = {
        'status': status,
        'updatedAt': Timestamp.now(),
      };

      if (adminResponse != null) {
        data['adminResponse'] = adminResponse;
      }

      if (adminId != null) {
        data['adminId'] = adminId;
      }

      if (status == AppConstants.arizaStatusBajarildi) {
        data['completedAt'] = Timestamp.now();
      }

      await _firestore
          .collection(AppConstants.arizalarCollection)
          .doc(arizaId)
          .update(data);
    } catch (e) {
      throw Exception('Ariza holatini yangilashda xatolik: ${e.toString()}');
    }
  }

  // Delete Ariza
  Future<void> deleteAriza(String arizaId) async {
    try {
      await _firestore
          .collection(AppConstants.arizalarCollection)
          .doc(arizaId)
          .delete();
    } catch (e) {
      throw Exception('Ariza o\'chirishda xatolik: ${e.toString()}');
    }
  }
}
