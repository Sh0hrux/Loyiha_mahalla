import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/mahalla_data.dart';
import '../models/mahalla_model.dart';

class MahallaSetupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Setup initial mahallas in Firebase
  Future<void> setupMahallas() async {
    try {
      debugPrint('🟢 Setting up mahallas...');

      // Toshkent shahri, Yunusobod tumani mahallalari
      final mahallas = MahallaData.getMahallas('Yunusobod tumani');

      for (final mahallaName in mahallas) {
        // Check if mahalla already exists
        final querySnapshot = await _firestore
            .collection('mahallalar')
            .where('name', isEqualTo: mahallaName)
            .where('district', isEqualTo: 'Yunusobod tumani')
            .get();

        if (querySnapshot.docs.isEmpty) {
          // Create new mahalla
          final mahalla = MahallaModel(
            id: '',
            name: mahallaName,
            region: 'Toshkent shahri',
            district: 'Yunusobod tumani',
            createdAt: DateTime.now(),
          );

          final docRef = await _firestore
              .collection('mahallalar')
              .add(mahalla.toFirestore());

          debugPrint('✅ Created mahalla: $mahallaName (${docRef.id})');
        } else {
          debugPrint('⚠️ Mahalla already exists: $mahallaName');
        }
      }

      debugPrint('🎉 Mahalla setup completed!');
    } catch (e) {
      debugPrint('❌ Error setting up mahallas: $e');
      rethrow;
    }
  }

  // Get all mahallas
  Future<List<MahallaModel>> getAllMahallas() async {
    try {
      final querySnapshot =
          await _firestore.collection('mahallalar').orderBy('name').get();

      return querySnapshot.docs
          .map((doc) => MahallaModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting mahallas: $e');
      return [];
    }
  }

  // Get mahalla by ID
  Future<MahallaModel?> getMahallaById(String mahallaId) async {
    try {
      final doc =
          await _firestore.collection('mahallalar').doc(mahallaId).get();

      if (doc.exists) {
        return MahallaModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting mahalla: $e');
      return null;
    }
  }

  // Get mahallas by district
  Future<List<MahallaModel>> getMahallasByDistrict(String district) async {
    try {
      final querySnapshot = await _firestore
          .collection('mahallalar')
          .where('district', isEqualTo: district)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => MahallaModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting mahallas by district: $e');
      return [];
    }
  }
}
