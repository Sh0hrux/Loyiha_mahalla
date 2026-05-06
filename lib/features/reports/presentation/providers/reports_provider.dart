import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/reports_repository.dart';

// Repository Provider
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository();
});

// Overall Stats Provider
final overallStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getOverallStats();
});

// Arizalar by Status Provider
final arizalarByStatusProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getArizalarByStatus();
});

// Muammolar by Status Provider
final muammolarByStatusProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getMuammolarByStatus();
});

// Navbatlar by Status Provider
final navbatlarByStatusProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getNavbatlarByStatus();
});

// Arizalar by Category Provider
final arizalarByCategoryProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getArizalarByCategory();
});

// Muammolar by Category Provider
final muammolarByCategoryProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getMuammolarByCategory();
});

// Daily Stats Provider
final dailyStatsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getDailyStats();
});

// Most Active Users Provider
final mostActiveUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getMostActiveUsers(limit: 5);
});
