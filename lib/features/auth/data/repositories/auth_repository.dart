import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/firebase_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Sign In with Email/Password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Kirish xatosi: ${e.toString()}');
    }
  }

  // Sign Up with Email/Password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Ro\'yxatdan o\'tish xatosi: ${e.toString()}');
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Parolni tiklash xatosi: ${e.toString()}');
    }
  }

  // Get or Create User
  Future<UserModel> getOrCreateUser({
    required String uid,
    required String email,
  }) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (docSnapshot.exists) {
        return UserModel.fromFirestore(docSnapshot);
      } else {
        // Create new user
        final newUser = UserModel(
          id: uid,
          phoneNumber: email, // Email ni phoneNumber maydoniga saqlaymiz
          fullName: '',
          role: AppConstants.roleFuqaro,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .set(newUser.toFirestore());

        return newUser;
      }
    } on FirebaseException catch (e) {
      print('Firebase xatosi: ${e.code} - ${e.message}');
      throw Exception('Firebase xatosi: ${e.message}');
    } catch (e) {
      print('Xatolik: $e');
      throw Exception('Foydalanuvchi yaratishda xatolik: ${e.toString()}');
    }
  }

  // Update User Profile
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(data);
    } catch (e) {
      throw Exception('Profilni yangilashda xatolik');
    }
  }

  // Get Current User
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        return UserModel.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      throw Exception('Foydalanuvchi ma\'lumotlarini olishda xatolik');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Chiqishda xatolik');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  // Save login state
  Future<void> saveLoginState({
    required String userId,
    required String userRole,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserId, userId);
    await prefs.setString(AppConstants.keyUserRole, userRole);
  }
}
