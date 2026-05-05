import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth
  static FirebaseAuth get auth => _auth;
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;

  // Firestore
  static FirebaseFirestore get firestore => _firestore;
  
  // Storage
  static FirebaseStorage get storage => _storage;

  // Phone Authentication - Send OTP
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(e.message ?? 'Xatolik yuz berdi');
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Verify OTP Code
  static Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Upload Image to Storage
  static Future<String> uploadImage({
    required File imageFile,
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Delete Image from Storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }

  // Generic Firestore Operations
  
  // Create Document
  static Future<DocumentReference> createDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    return await _firestore.collection(collection).add(data);
  }

  // Create Document with ID
  static Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    await _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: merge));
  }

  // Get Document
  static Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  // Update Document
  static Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // Delete Document
  static Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // Get Collection Stream
  static Stream<QuerySnapshot> getCollectionStream({
    required String collection,
    Query Function(Query query)? queryBuilder,
  }) {
    Query query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  // Get Collection
  static Future<QuerySnapshot> getCollection({
    required String collection,
    Query Function(Query query)? queryBuilder,
  }) async {
    Query query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return await query.get();
  }

  // Batch Write
  static WriteBatch batch() {
    return _firestore.batch();
  }

  // Transaction
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    return await _firestore.runTransaction(updateFunction);
  }
}
