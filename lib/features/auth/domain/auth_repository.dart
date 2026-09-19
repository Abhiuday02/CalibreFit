import 'package:calibrefit/core/error/failures.dart';
import 'package:calibrefit/features/auth/domain/auth_user.dart';

/// Contract for all authentication operations.
///
/// The concrete implementation in Phase 1 is [MockAuthRepository].
/// A real backend-backed implementation will be added in Phase 14.
///
/// All methods return [({T value})] on success or throw an [AppFailure]
/// subtype on failure so callers can pattern-match exhaustively.
abstract interface class AuthRepository {
  /// Returns the currently signed-in user, or `null` if no session exists.
  AuthUser? get currentUser;

  /// A stream that emits the current [AuthUser] (or `null`) whenever
  /// auth state changes. Useful for auth-gated navigation.
  Stream<AuthUser?> get authStateChanges;

  /// Signs in with [email] and [password].
  ///
  /// Throws an [AppFailure] on error.
  Future<AuthUser> signIn({required String email, required String password});

  /// Creates a new account with [email] and [password].
  ///
  /// Throws an [AppFailure] on error.
  Future<AuthUser> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs the current user out.
  Future<void> signOut();
}
