import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/repositories/users_repository.dart';

// Repository Provider
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

// All Users Stream Provider
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final repository = ref.watch(usersRepositoryProvider);
  return repository.getAllUsers();
});

// Users by Role Stream Provider
final usersByRoleProvider = StreamProvider.family<List<UserModel>, String>((ref, role) {
  final repository = ref.watch(usersRepositoryProvider);
  return repository.getUsersByRole(role);
});

// User Statistics Provider
final userStatsProvider = FutureProvider.family<Map<String, int>, String>((ref, userId) async {
  final repository = ref.watch(usersRepositoryProvider);
  return repository.getUserStats(userId);
});

// Users Count by Role Provider
final usersCountByRoleProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(usersRepositoryProvider);
  return repository.getUsersCountByRole();
});

// New Users Count Provider
final newUsersCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(usersRepositoryProvider);
  return repository.getNewUsersCount();
});

// Update User Role Provider
final updateUserRoleProvider = StateNotifierProvider<UpdateUserRoleNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(usersRepositoryProvider);
  return UpdateUserRoleNotifier(repository);
});

class UpdateUserRoleNotifier extends StateNotifier<AsyncValue<void>> {
  final UsersRepository _repository;

  UpdateUserRoleNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> updateRole(String userId, String newRole) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateUserRole(userId, newRole);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
