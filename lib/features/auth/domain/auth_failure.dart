import 'package:calibrefit/core/error/failures.dart';

/// Auth-specific failures, extending the sealed [AppFailure] hierarchy.
final class InvalidCredentialsFailure extends AppFailure {
  const InvalidCredentialsFailure()
    : super(message: 'Invalid email or password.');
}

final class EmailAlreadyInUseFailure extends AppFailure {
  const EmailAlreadyInUseFailure()
    : super(message: 'An account with this email already exists.');
}

final class WeakPasswordFailure extends AppFailure {
  const WeakPasswordFailure()
    : super(message: 'Password must be at least 8 characters.');
}

final class InvalidEmailFailure extends AppFailure {
  const InvalidEmailFailure()
    : super(message: 'Please enter a valid email address.');
}
