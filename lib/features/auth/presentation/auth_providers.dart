import 'package:calibrefit/features/auth/data/mock_auth_repository.dart';
import 'package:calibrefit/features/auth/domain/auth_repository.dart';
import 'package:calibrefit/features/auth/domain/auth_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

/// Provides the [AuthRepository] implementation.
///
/// Swap [MockAuthRepository] for the real backend implementation in Phase 14
/// without touching anything in the presentation or application layers.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = MockAuthRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

/// Represents the possible states of authentication.
sealed class AuthState {
  const AuthState();
}

/// Auth check not yet completed (used during splash).
final class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

/// A user is signed in.
final class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated(this.user);
  final AuthUser user;
}

/// No user is signed in.
final class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

// ---------------------------------------------------------------------------
// AuthNotifier
// ---------------------------------------------------------------------------

/// Manages the global authentication state and exposes sign-in / register /
/// sign-out operations to the presentation layer.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final repo = ref.watch(authRepositoryProvider);

    // Listen to repository auth stream and update state reactively.
    final subscription = repo.authStateChanges.listen((user) {
      state = user != null
          ? AuthStateAuthenticated(user)
          : const AuthStateUnauthenticated();
    });

    ref.onDispose(subscription.cancel);

    // Initialise from current session (e.g. restored from secure storage later).
    final current = repo.currentUser;
    return current != null
        ? AuthStateAuthenticated(current)
        : const AuthStateUnauthenticated();
  }

  // ---------------------------------------------------------------------------
  // Public operations
  // ---------------------------------------------------------------------------

  /// Signs the user in. Returns the error message string on failure, or null
  /// on success. The auth stream automatically updates [state].
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.signIn(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString().replaceFirst(RegExp(r'^.*Exception: '), '');
    }
  }

  /// Registers a new account. Returns the error message string on failure,
  /// or null on success.
  Future<String?> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst(RegExp(r'^.*Exception: '), '');
    }
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
  }
}

/// Global provider for [AuthNotifier].
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// ---------------------------------------------------------------------------
// Auth state stream provider (for GoRouter redirect listenable)
// ---------------------------------------------------------------------------

/// Exposes the raw [authStateChanges] stream so GoRouter can listen to it
/// and trigger a redirect evaluation after every auth state change.
final authStateChangesProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
