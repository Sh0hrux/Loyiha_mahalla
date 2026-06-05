import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/firebase_service.dart';
import '../models/user_model.dart';

/// Foydalanuvchiga ko'rsatish uchun toza (tushunarli) xato xabari.
/// toString() faqat xabarni qaytaradi ("Exception:" prefiksisiz).
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// Firebase Auth xato kodlarini tushunarli o'zbekcha xabarga o'giradi.
String _mapAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
    case 'INVALID_LOGIN_CREDENTIALS':
      return 'Email yoki parol noto\'g\'ri';
    case 'invalid-email':
      return 'Email manzili noto\'g\'ri kiritilgan';
    case 'user-disabled':
      return 'Bu hisob bloklangan. Admin bilan bog\'laning';
    case 'too-many-requests':
      return 'Juda ko\'p urinish bo\'ldi. Birozdan keyin qayta urinib ko\'ring';
    case 'network-request-failed':
      return 'Internet aloqasi yo\'q. Tarmoqni tekshiring';
    case 'email-already-in-use':
      return 'Bu email allaqachon ro\'yxatdan o\'tgan';
    case 'weak-password':
      return 'Parol juda oddiy. Kamida 6 ta belgidan iborat kuchli parol tanlang';
    case 'operation-not-allowed':
      return 'Bu kirish usuli yoqilmagan. Admin bilan bog\'laning';
    default:
      return 'Xatolik yuz berdi. Qaytadan urinib ko\'ring';
  }
}

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
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    } catch (e) {
      throw AuthException(
          'Kirishda xatolik yuz berdi. Qaytadan urinib ko\'ring');
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
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    } catch (e) {
      throw AuthException(
          'Ro\'yxatdan o\'tishda xatolik yuz berdi. Qaytadan urinib ko\'ring');
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    } catch (e) {
      throw AuthException(
          'Parolni tiklashda xatolik yuz berdi. Qaytadan urinib ko\'ring');
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
      debugPrint('Firebase xatosi: ${e.code} - ${e.message}');
      throw Exception('Firebase xatosi: ${e.message}');
    } catch (e) {
      debugPrint('Xatolik: $e');
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
