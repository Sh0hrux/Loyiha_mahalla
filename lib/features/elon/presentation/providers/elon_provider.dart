import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/elon_model.dart';
import '../../data/repositories/elon_repository.dart';

// Repository Provider
final elonRepositoryProvider = Provider<ElonRepository>((ref) {
  return ElonRepository();
});

// Active Elonlar Stream Provider (for users)
final activeElonlarProvider = StreamProvider<List<ElonModel>>((ref) {
  final repository = ref.watch(elonRepositoryProvider);
  return repository.getActiveElonlar();
});

// All Elonlar Stream Provider (Admin)
final allElonlarProvider = StreamProvider<List<ElonModel>>((ref) {
  final repository = ref.watch(elonRepositoryProvider);
  return repository.getAllElonlar();
});

// Single Elon Provider
final elonDetailProvider =
    FutureProvider.family<ElonModel, String>((ref, elonId) async {
  final repository = ref.watch(elonRepositoryProvider);
  return repository.getElonById(elonId);
});

// Create Elon Provider (Admin)
final createElonProvider =
    StateNotifierProvider<CreateElonNotifier, AsyncValue<String?>>((ref) {
  final repository = ref.watch(elonRepositoryProvider);
  return CreateElonNotifier(repository);
});

class CreateElonNotifier extends StateNotifier<AsyncValue<String?>> {
  final ElonRepository _repository;

  CreateElonNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createElon(ElonModel elon) async {
    state = const AsyncValue.loading();
    try {
      final elonId = await _repository.createElon(elon);
      state = AsyncValue.data(elonId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Update Elon Provider (Admin)
final updateElonProvider =
    StateNotifierProvider<UpdateElonNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(elonRepositoryProvider);
  return UpdateElonNotifier(repository);
});

class UpdateElonNotifier extends StateNotifier<AsyncValue<void>> {
  final ElonRepository _repository;

  UpdateElonNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> updateElon(String elonId, ElonModel elon) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateElon(elonId, elon);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleStatus(String elonId, bool isActive) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleElonStatus(elonId, isActive);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteElon(String elonId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteElon(elonId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
