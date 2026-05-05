import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ariza_model.dart';
import '../../data/repositories/ariza_repository.dart';

// Repository Provider
final arizaRepositoryProvider = Provider<ArizaRepository>((ref) {
  return ArizaRepository();
});

// User Arizalar Stream Provider
final userArizalarProvider = StreamProvider.family<List<ArizaModel>, String>((ref, userId) {
  final repository = ref.watch(arizaRepositoryProvider);
  return repository.getUserArizalar(userId);
});

// All Arizalar Stream Provider (Admin)
final allArizalarProvider = StreamProvider<List<ArizaModel>>((ref) {
  final repository = ref.watch(arizaRepositoryProvider);
  return repository.getAllArizalar();
});

// Create Ariza State Provider
final createArizaProvider = StateNotifierProvider<CreateArizaNotifier, AsyncValue<String?>>((ref) {
  return CreateArizaNotifier(ref.read(arizaRepositoryProvider));
});

class CreateArizaNotifier extends StateNotifier<AsyncValue<String?>> {
  final ArizaRepository _repository;

  CreateArizaNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createAriza(ArizaModel ariza) async {
    state = const AsyncValue.loading();
    try {
      final arizaId = await _repository.createAriza(ariza);
      state = AsyncValue.data(arizaId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
