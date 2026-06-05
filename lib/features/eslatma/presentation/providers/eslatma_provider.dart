import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/eslatma_model.dart';
import '../../data/repositories/eslatma_repository.dart';
import '../../../../services/firebase_service.dart';

// Repository provider
final eslatmaRepositoryProvider = Provider<EslatmaRepository>((ref) {
  return EslatmaRepository();
});

// User's eslatmalar stream provider
final userEslatmalarProvider = StreamProvider.autoDispose<List<EslatmaModel>>((ref) {
  final repository = ref.watch(eslatmaRepositoryProvider);
  final userId = FirebaseService.currentUserId;
  
  if (userId == null) {
    return Stream.value([]);
  }
  
  return repository.getUserEslatmalar(userId);
});

// Unread count provider
final unreadEslatmalarCountProvider = StreamProvider.autoDispose<int>((ref) {
  final repository = ref.watch(eslatmaRepositoryProvider);
  final userId = FirebaseService.currentUserId;
  
  if (userId == null) {
    return Stream.value(0);
  }
  
  return repository.getUnreadCount(userId);
});

// All eslatmalar (admin only)
final allEslatmalarProvider = StreamProvider.autoDispose<List<EslatmaModel>>((ref) {
  final repository = ref.watch(eslatmaRepositoryProvider);
  return repository.getAllEslatmalar();
});

// Eslatma State Notifier for actions
class EslatmaNotifier extends StateNotifier<AsyncValue<void>> {
  final EslatmaRepository _repository;

  EslatmaNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Yangi eslatma yaratish
  Future<String?> createEslatma({
    required String userId,
    required String adminId,
    required String adminName,
    required EslatmaType type,
    required String title,
    required String message,
    DateTime? expiresAt,
    bool isUrgent = false,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final id = await _repository.createEslatma(
        userId: userId,
        adminId: adminId,
        adminName: adminName,
        type: type,
        title: title,
        message: message,
        expiresAt: expiresAt,
        isUrgent: isUrgent,
      );
      
      state = const AsyncValue.data(null);
      return id;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Bulk eslatma yuborish
  Future<bool> createBulkEslatma({
    required List<String> userIds,
    required String adminId,
    required String adminName,
    required EslatmaType type,
    required String title,
    required String message,
    DateTime? expiresAt,
    bool isUrgent = false,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.createBulkEslatma(
        userIds: userIds,
        adminId: adminId,
        adminName: adminName,
        type: type,
        title: title,
        message: message,
        expiresAt: expiresAt,
        isUrgent: isUrgent,
      );
      
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// O'qilgan deb belgilash
  Future<void> markAsRead(String eslatmaId) async {
    try {
      await _repository.markAsRead(eslatmaId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Barcha eslatmalarni o'qilgan deb belgilash
  Future<void> markAllAsRead(String userId) async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.markAllAsRead(userId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// O'chirish
  Future<void> deleteEslatma(String eslatmaId) async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.deleteEslatma(eslatmaId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Eslatma notifier provider
final eslatmaNotifierProvider = StateNotifierProvider<EslatmaNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(eslatmaRepositoryProvider);
  return EslatmaNotifier(repository);
});

// Single eslatma provider
final eslatmaByIdProvider = FutureProvider.autoDispose.family<EslatmaModel?, String>((ref, id) async {
  final repository = ref.watch(eslatmaRepositoryProvider);
  return repository.getEslatmaById(id);
});

// Stats provider (admin only)
final eslatmaStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repository = ref.watch(eslatmaRepositoryProvider);
  return repository.getEslatmaStats();
});
