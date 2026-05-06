import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get overall statistics
  Future<Map<String, dynamic>> getOverallStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Get all collections counts
    final arizalarSnapshot = await _firestore.collection('arizalar').get();
    final muammolarSnapshot = await _firestore.collection('muammolar').get();
    final navbatlarSnapshot = await _firestore.collection('navbatlar').get();
    final elonlarSnapshot = await _firestore.collection('elonlar').get();
    final usersSnapshot = await _firestore.collection('users').get();

    // Get this month's data
    final arizalarThisMonth = await _firestore
        .collection('arizalar')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();

    final muammolarThisMonth = await _firestore
        .collection('muammolar')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();

    // Get this week's data
    final arizalarThisWeek = await _firestore
        .collection('arizalar')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .get();

    final muammolarThisWeek = await _firestore
        .collection('muammolar')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .get();

    return {
      'total': {
        'arizalar': arizalarSnapshot.docs.length,
        'muammolar': muammolarSnapshot.docs.length,
        'navbatlar': navbatlarSnapshot.docs.length,
        'elonlar': elonlarSnapshot.docs.length,
        'users': usersSnapshot.docs.length,
      },
      'thisMonth': {
        'arizalar': arizalarThisMonth.docs.length,
        'muammolar': muammolarThisMonth.docs.length,
      },
      'thisWeek': {
        'arizalar': arizalarThisWeek.docs.length,
        'muammolar': muammolarThisWeek.docs.length,
      },
    };
  }

  // Get arizalar statistics by status
  Future<Map<String, int>> getArizalarByStatus() async {
    final snapshot = await _firestore.collection('arizalar').get();
    
    final stats = <String, int>{
      'yuborildi': 0,
      'ko\'rilmoqda': 0,
      'bajarildi': 0,
      'rad_etildi': 0,
    };

    for (var doc in snapshot.docs) {
      final status = doc.data()['status'] as String?;
      if (status != null && stats.containsKey(status)) {
        stats[status] = stats[status]! + 1;
      }
    }

    return stats;
  }

  // Get muammolar statistics by status
  Future<Map<String, int>> getMuammolarByStatus() async {
    final snapshot = await _firestore.collection('muammolar').get();
    
    final stats = <String, int>{
      'yuborildi': 0,
      'ko\'rilmoqda': 0,
      'hal_qilindi': 0,
      'rad_etildi': 0,
    };

    for (var doc in snapshot.docs) {
      final status = doc.data()['status'] as String?;
      if (status != null && stats.containsKey(status)) {
        stats[status] = stats[status]! + 1;
      }
    }

    return stats;
  }

  // Get navbatlar statistics by status
  Future<Map<String, int>> getNavbatlarByStatus() async {
    final snapshot = await _firestore.collection('navbatlar').get();
    
    final stats = <String, int>{
      'kutilmoqda': 0,
      'tasdiqlandi': 0,
      'tugallandi': 0,
      'bekor_qilindi': 0,
    };

    for (var doc in snapshot.docs) {
      final status = doc.data()['status'] as String?;
      if (status != null && stats.containsKey(status)) {
        stats[status] = stats[status]! + 1;
      }
    }

    return stats;
  }

  // Get arizalar by category
  Future<Map<String, int>> getArizalarByCategory() async {
    final snapshot = await _firestore.collection('arizalar').get();
    
    final stats = <String, int>{};

    for (var doc in snapshot.docs) {
      final category = doc.data()['category'] as String?;
      if (category != null) {
        stats[category] = (stats[category] ?? 0) + 1;
      }
    }

    return stats;
  }

  // Get muammolar by category
  Future<Map<String, int>> getMuammolarByCategory() async {
    final snapshot = await _firestore.collection('muammolar').get();
    
    final stats = <String, int>{};

    for (var doc in snapshot.docs) {
      final category = doc.data()['category'] as String?;
      if (category != null) {
        stats[category] = (stats[category] ?? 0) + 1;
      }
    }

    return stats;
  }

  // Get daily statistics for last 7 days
  Future<List<Map<String, dynamic>>> getDailyStats() async {
    final now = DateTime.now();
    final stats = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final arizalarCount = await _firestore
          .collection('arizalar')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      final muammolarCount = await _firestore
          .collection('muammolar')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      stats.add({
        'date': startOfDay,
        'arizalar': arizalarCount.docs.length,
        'muammolar': muammolarCount.docs.length,
      });
    }

    return stats;
  }

  // Get most active users
  Future<List<Map<String, dynamic>>> getMostActiveUsers({int limit = 5}) async {
    final usersSnapshot = await _firestore.collection('users').get();
    final userStats = <Map<String, dynamic>>[];

    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      final userData = userDoc.data();

      final arizalarCount = await _firestore
          .collection('arizalar')
          .where('userId', isEqualTo: userId)
          .get();

      final muammolarCount = await _firestore
          .collection('muammolar')
          .where('userId', isEqualTo: userId)
          .get();

      final navbatlarCount = await _firestore
          .collection('navbatlar')
          .where('userId', isEqualTo: userId)
          .get();

      final totalActivity = arizalarCount.docs.length + 
                           muammolarCount.docs.length + 
                           navbatlarCount.docs.length;

      if (totalActivity > 0) {
        userStats.add({
          'userId': userId,
          'fullName': userData['fullName'] ?? 'Noma\'lum',
          'phoneNumber': userData['phoneNumber'] ?? '',
          'arizalar': arizalarCount.docs.length,
          'muammolar': muammolarCount.docs.length,
          'navbatlar': navbatlarCount.docs.length,
          'total': totalActivity,
        });
      }
    }

    // Sort by total activity
    userStats.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));

    return userStats.take(limit).toList();
  }
}
