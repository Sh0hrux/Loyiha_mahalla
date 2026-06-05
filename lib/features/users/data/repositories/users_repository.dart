import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/models/user_model.dart';

class UsersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all users stream
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      // Sort by createdAt in memory instead of Firestore
      final users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    });
  }

  // Get user by ID
  Future<UserModel> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('Foydalanuvchi topilmadi');
    }
    return UserModel.fromFirestore(doc);
  }

  // Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({
      'role': newRole,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats(String userId) async {
    final arizalarSnapshot = await _firestore
        .collection('arizalar')
        .where('userId', isEqualTo: userId)
        .get();

    final muammolarSnapshot = await _firestore
        .collection('muammolar')
        .where('userId', isEqualTo: userId)
        .get();

    final navbatlarSnapshot = await _firestore
        .collection('navbatlar')
        .where('userId', isEqualTo: userId)
        .get();

    return {
      'arizalar': arizalarSnapshot.docs.length,
      'muammolar': muammolarSnapshot.docs.length,
      'navbatlar': navbatlarSnapshot.docs.length,
    };
  }

  // Search users by name
  Future<List<UserModel>> searchUsers(String query) async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('fullName')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // Get users count by role
  Future<Map<String, int>> getUsersCountByRole() async {
    final allUsersSnapshot = await _firestore.collection('users').get();
    
    int adminCount = 0;
    int fuqaroCount = 0;

    for (var doc in allUsersSnapshot.docs) {
      final role = doc.data()['role'] as String?;
      if (role == 'admin') {
        adminCount++;
      } else {
        fuqaroCount++;
      }
    }

    return {
      'total': allUsersSnapshot.docs.length,
      'admin': adminCount,
      'fuqaro': fuqaroCount,
    };
  }

  // Get new users count (last 7 days)
  Future<int> getNewUsersCount() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final snapshot = await _firestore
        .collection('users')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .get();

    return snapshot.docs.length;
  }
}
