import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/muammo_model.dart';
import '../../data/repositories/muammo_repository.dart';

// Repository Provider
final muammoRepositoryProvider = Provider<MuammoRepository>((ref) {
  return MuammoRepository();
});

// User Muammolar Stream Provider
final userMuammolarProvider =
    StreamProvider.family<List<MuammoModel>, String>((ref, userId) {
  final repository = ref.watch(muammoRepositoryProvider);
  return repository.getUserMuammolar(userId);
});

// All Muammolar Stream Provider (Admin)
final allMuammolarProvider = StreamProvider<List<MuammoModel>>((ref) {
  final repository = ref.watch(muammoRepositoryProvider);
  return repository.getAllMuammolar();
});

// Single Muammo Provider
final muammoDetailProvider =
    FutureProvider.family<MuammoModel, String>((ref, muammoId) async {
  final repository = ref.watch(muammoRepositoryProvider);
  return repository.getMuammoById(muammoId);
});

// Create Muammo Provider
final createMuammoProvider =
    StateNotifierProvider<CreateMuammoNotifier, AsyncValue<String?>>((ref) {
  final repository = ref.watch(muammoRepositoryProvider);
  return CreateMuammoNotifier(repository);
});

class CreateMuammoNotifier extends StateNotifier<AsyncValue<String?>> {
  final MuammoRepository _repository;

  CreateMuammoNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createMuammo(MuammoModel muammo) async {
    state = const AsyncValue.loading();
    try {
      final muammoId = await _repository.createMuammo(muammo);
      state = AsyncValue.data(muammoId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Update Muammo Status Provider (Admin)
final updateMuammoStatusProvider =
    StateNotifierProvider<UpdateMuammoStatusNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(muammoRepositoryProvider);
  return UpdateMuammoStatusNotifier(repository);
});

class UpdateMuammoStatusNotifier extends StateNotifier<AsyncValue<void>> {
  final MuammoRepository _repository;

  UpdateMuammoStatusNotifier(this._repository)
      : super(const AsyncValue.data(null));

  Future<void> updateStatus({
    required String muammoId,
    required String status,
    String? adminResponse,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateMuammoStatus(
        muammoId: muammoId,
        status: status,
        adminResponse: adminResponse,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
