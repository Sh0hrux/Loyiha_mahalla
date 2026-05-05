import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Current User Provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>((ref) {
  return CurrentUserNotifier(ref.read(authRepositoryProvider));
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _authRepository;

  CurrentUserNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await _loadCurrentUser();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      await _authRepository.updateUserProfile(
        uid: currentUser.id,
        data: data,
      );
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.read(authRepositoryProvider));
});

enum AuthStatus {
  initial,
  loading,
  authenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user;

  AuthState({
    required this.status,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    UserModel? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthStateNotifier(this._authRepository)
      : super(AuthState(status: AuthStatus.initial));

  // Sign In
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    print('🟢 signIn called: $email'); // DEBUG
    state = state.copyWith(status: AuthStatus.loading);
    print('🟢 State set to loading'); // DEBUG

    try {
      print('🟢 Calling Firebase signIn...'); // DEBUG
      final userCredential = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      print('🟢 Firebase signIn success: ${userCredential.user?.uid}'); // DEBUG

      final user = await _authRepository.getOrCreateUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
      );
      print('🟢 User created/fetched: ${user.id}, role: ${user.role}'); // DEBUG

      await _authRepository.saveLoginState(
        userId: user.id,
        userRole: user.role,
      );
      print('🟢 Login state saved'); // DEBUG

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      print('🟢 State set to authenticated, redirecting...'); // DEBUG
    } catch (e) {
      print('🔴 Error in signIn: $e'); // DEBUG
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Sign Up
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final userCredential = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
      );

      final user = await _authRepository.getOrCreateUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
      );

      await _authRepository.saveLoginState(
        userId: user.id,
        userRole: user.role,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _authRepository.resetPassword(email);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = AuthState(status: AuthStatus.initial);
  }
}
