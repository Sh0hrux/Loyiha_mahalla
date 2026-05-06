import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/xodim_model.dart';
import '../../data/repositories/xodim_repository.dart';

// Repository Provider
final xodimRepositoryProvider = Provider<XodimRepository>((ref) {
  return XodimRepository();
});

// Active Xodimlar Stream Provider
final activeXodimlarProvider = StreamProvider<List<XodimModel>>((ref) {
  final repository = ref.watch(xodimRepositoryProvider);
  return repository.getActiveXodimlar();
});

// All Xodimlar Stream Provider (Admin)
final allXodimlarProvider = StreamProvider<List<XodimModel>>((ref) {
  final repository = ref.watch(xodimRepositoryProvider);
  return repository.getAllXodimlar();
});

// Create Xodim Provider
final createXodimProvider =
    StateNotifierProvider<CreateXodimNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(xodimRepositoryProvider);
  return CreateXodimNotifier(repository);
});

class CreateXodimNotifier extends StateNotifier<AsyncValue<void>> {
  final XodimRepository _repository;

  CreateXodimNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createXodim(XodimModel xodim) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createXodim(xodim);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Update Xodim Provider
final updateXodimProvider =
    StateNotifierProvider<UpdateXodimNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(xodimRepositoryProvider);
  return UpdateXodimNotifier(repository);
});

class UpdateXodimNotifier extends StateNotifier<AsyncValue<void>> {
  final XodimRepository _repository;

  UpdateXodimNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> updateXodim(String xodimId, XodimModel xodim) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateXodim(xodimId, xodim);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Delete Xodim Provider
final deleteXodimProvider =
    StateNotifierProvider<DeleteXodimNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(xodimRepositoryProvider);
  return DeleteXodimNotifier(repository);
});

class DeleteXodimNotifier extends StateNotifier<AsyncValue<void>> {
  final XodimRepository _repository;

  DeleteXodimNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> deleteXodim(String xodimId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteXodim(xodimId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
