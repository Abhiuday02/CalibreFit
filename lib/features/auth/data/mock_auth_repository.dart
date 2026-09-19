import 'dart:async';

import 'package:calibrefit/features/auth/domain/auth_failure.dart';
import 'package:calibrefit/features/auth/domain/auth_repository.dart';
import 'package:calibrefit/features/auth/domain/auth_user.dart';

/// In-memory mock implementation of [AuthRepository].
///
/// Simulates the full auth lifecycle without any network or backend dependency.
/// Behaviour:
///   - A pre-seeded demo account (demo@calibrefit.app / Password1) always works.
///   - Any new registration creates an account for the lifetime of the session.
///   - A 600 ms artificial delay mimics real network latency.
///   - Validation mirrors what the backend will enforce in Phase 14.
///
/// Replace this class with a real implementation (e.g. backed by FastAPI JWT)
/// in Phase 14 without changing any other code — the repository interface
/// and provider are the only contract consumers depend on.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    // Seed a demo account so reviewers can log in immediately.
    _accounts[_demoEmail] = _AccountRecord(
      user: AuthUser(
        id: 'demo-user-001',
        email: _demoEmail,
        displayName: 'Demo User',
      ),
      passwordHash: _demoEmail.hashCode ^ _demoPassword.hashCode,
    );
  }

  static const _demoEmail = 'demo@calibrefit.app';
  static const _demoPassword = 'Password1';
  static const _networkDelay = Duration(milliseconds: 600);

  // In-memory store: email → account record.
  final Map<String, _AccountRecord> _accounts = {};

  // Current session.
  AuthUser? _currentUser;

  // Auth state broadcast stream.
  final _authController = StreamController<AuthUser?>.broadcast();

  // ---------------------------------------------------------------------------
  // AuthRepository implementation
  // ---------------------------------------------------------------------------

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _authController.stream;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_networkDelay);

    _validateEmail(email);
    _validatePasswordLength(password);

    final record = _accounts[email.toLowerCase()];
    if (record == null ||
        record.passwordHash != (email.hashCode ^ password.hashCode)) {
      throw const InvalidCredentialsFailure();
    }

    _currentUser = record.user;
    _authController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future<void>.delayed(_networkDelay);

    _validateEmail(email);
    _validatePasswordLength(password);

    final normalised = email.toLowerCase();

    if (_accounts.containsKey(normalised)) {
      throw const EmailAlreadyInUseFailure();
    }

    final user = AuthUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: normalised,
      displayName: displayName,
    );

    _accounts[normalised] = _AccountRecord(
      user: user,
      passwordHash: email.hashCode ^ password.hashCode,
    );

    _currentUser = user;
    _authController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _authController.add(null);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) throw const InvalidEmailFailure();
  }

  void _validatePasswordLength(String password) {
    if (password.length < 8) throw const WeakPasswordFailure();
  }

  void dispose() {
    _authController.close();
  }
}

// ---------------------------------------------------------------------------
// Internal record type
// ---------------------------------------------------------------------------

class _AccountRecord {
  const _AccountRecord({required this.user, required this.passwordHash});

  final AuthUser user;
  final int passwordHash;
}
