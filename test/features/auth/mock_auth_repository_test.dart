import 'package:calibrefit/features/auth/data/mock_auth_repository.dart';
import 'package:calibrefit/features/auth/domain/auth_failure.dart';
import 'package:calibrefit/features/auth/domain/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  tearDown(() {
    repo.dispose();
  });

  // ---------------------------------------------------------------------------
  // signIn
  // ---------------------------------------------------------------------------

  group('MockAuthRepository.signIn', () {
    test('succeeds with demo credentials', () async {
      final user = await repo.signIn(
        email: 'demo@calibrefit.app',
        password: 'Password1',
      );
      expect(user, isA<AuthUser>());
      expect(user.email, 'demo@calibrefit.app');
    });

    test('fails with wrong password', () async {
      expect(
        () => repo.signIn(email: 'demo@calibrefit.app', password: 'WrongPass1'),
        throwsA(isA<InvalidCredentialsFailure>()),
      );
    });

    test('fails with unknown email', () async {
      expect(
        () =>
            repo.signIn(email: 'nobody@calibrefit.app', password: 'Password1'),
        throwsA(isA<InvalidCredentialsFailure>()),
      );
    });

    test('fails with invalid email format', () async {
      expect(
        () => repo.signIn(email: 'not-an-email', password: 'Password1'),
        throwsA(isA<InvalidEmailFailure>()),
      );
    });

    test('fails with short password', () async {
      expect(
        () => repo.signIn(email: 'demo@calibrefit.app', password: 'short'),
        throwsA(isA<WeakPasswordFailure>()),
      );
    });

    test('updates currentUser on success', () async {
      expect(repo.currentUser, isNull);
      await repo.signIn(email: 'demo@calibrefit.app', password: 'Password1');
      expect(repo.currentUser, isNotNull);
      expect(repo.currentUser!.email, 'demo@calibrefit.app');
    });

    test('emits user on auth stream after sign in', () async {
      expect(repo.authStateChanges, emits(isA<AuthUser>()));
      await repo.signIn(email: 'demo@calibrefit.app', password: 'Password1');
    });
  });

  // ---------------------------------------------------------------------------
  // register
  // ---------------------------------------------------------------------------

  group('MockAuthRepository.register', () {
    const testEmail = 'new@calibrefit.app';
    const testPassword = 'NewPass12';

    test('creates a new account successfully', () async {
      final user = await repo.register(
        email: testEmail,
        password: testPassword,
        displayName: 'New User',
      );
      expect(user.email, testEmail);
      expect(user.displayName, 'New User');
    });

    test('normalises email to lowercase', () async {
      final user = await repo.register(
        email: 'UPPER@CALIBREFIT.APP',
        password: testPassword,
      );
      expect(user.email, 'upper@calibrefit.app');
    });

    test('fails when email already exists', () async {
      await repo.register(email: testEmail, password: testPassword);
      expect(
        () => repo.register(email: testEmail, password: testPassword),
        throwsA(isA<EmailAlreadyInUseFailure>()),
      );
    });

    test('fails with invalid email format', () async {
      expect(
        () => repo.register(email: 'bad-email', password: testPassword),
        throwsA(isA<InvalidEmailFailure>()),
      );
    });

    test('fails with short password', () async {
      expect(
        () => repo.register(email: testEmail, password: 'short'),
        throwsA(isA<WeakPasswordFailure>()),
      );
    });

    test('sets currentUser after registration', () async {
      await repo.register(email: testEmail, password: testPassword);
      expect(repo.currentUser, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // signOut
  // ---------------------------------------------------------------------------

  group('MockAuthRepository.signOut', () {
    test('clears currentUser', () async {
      await repo.signIn(email: 'demo@calibrefit.app', password: 'Password1');
      expect(repo.currentUser, isNotNull);

      await repo.signOut();
      expect(repo.currentUser, isNull);
    });

    test('emits null on auth stream after sign out', () async {
      await repo.signIn(email: 'demo@calibrefit.app', password: 'Password1');
      expect(repo.authStateChanges, emits(isNull));
      await repo.signOut();
    });
  });
}
