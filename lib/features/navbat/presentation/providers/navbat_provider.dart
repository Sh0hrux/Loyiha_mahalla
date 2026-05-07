import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/navbat_model.dart';
import '../../data/repositories/navbat_repository.dart';

// Repository Provider
final navbatRepositoryProvider = Provider<NavbatRepository>((ref) {
  return NavbatRepository();
});

// User Navbatlar Stream Provider
final userNavbatlarProvider =
    StreamProvider.family<List<NavbatModel>, String>((ref, userId) {
  final repository = ref.watch(navbatRepositoryProvider);
  return repository.getUserNavbatlar(userId);
});

// All Navbatlar Stream Provider (Admin) - with mahalla filter
final allNavbatlarProvider = StreamProvider.family<List<NavbatModel>, String?>((ref, mahallaId) {
  final repository = ref.watch(navbatRepositoryProvider);
  return repository.getAllNavbatlar(mahallaId: mahallaId);
});

// Single Navbat Provider
final navbatDetailProvider =
    FutureProvider.family<NavbatModel, String>((ref, navbatId) async {
  final repository = ref.watch(navbatRepositoryProvider);
  return repository.getNavbatById(navbatId);
});

// Get Navbatlar by Date Provider
final navbatlarByDateProvider =
    FutureProvider.family<List<NavbatModel>, DateTime>((ref, date) async {
  final repository = ref.watch(navbatRepositoryProvider);
  return repository.getNavbatlarByDate(date);
});

// Create Navbat Provider
final createNavbatProvider =
    StateNotifierProvider<CreateNavbatNotifier, AsyncValue<String?>>((ref) {
  final repository = ref.watch(navbatRepositoryProvider);
  return CreateNavbatNotifier(repository);
});

class CreateNavbatNotifier extends StateNotifier<AsyncValue<String?>> {
  final NavbatRepository _repository;

  CreateNavbatNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createNavbat(NavbatModel navbat) async {
    state = const AsyncValue.loading();
    try {
      final navbatId = await _repository.createNavbat(navbat);
      state = AsyncValue.data(navbatId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Update Navbat Status Provider (Admin)
final updateNavbatStatusProvider =
    StateNotifierProvider<UpdateNavbatStatusNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(navbatRepositoryProvider);
  return UpdateNavbatStatusNotifier(repository);
});

class UpdateNavbatStatusNotifier extends StateNotifier<AsyncValue<void>> {
  final NavbatRepository _repository;

  UpdateNavbatStatusNotifier(this._repository)
      : super(const AsyncValue.data(null));

  Future<void> updateStatus({
    required String navbatId,
    required String status,
    String? adminNote,
    String? adminId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateNavbatStatus(
        navbatId: navbatId,
        status: status,
        adminNote: adminNote,
        adminId: adminId,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancelNavbat(String navbatId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.cancelNavbat(navbatId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
