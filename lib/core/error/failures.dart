/// Base class for all domain-level failures in CalibreFit.
///
/// Subclass this in each feature's domain layer to create typed failures
/// (e.g. InvalidCredentialsFailure). Using [abstract] instead of [sealed]
/// allows subclasses to live in different libraries while still being
/// strongly typed throughout the codebase.
abstract class AppFailure {
  const AppFailure({required this.message});

  /// Human-readable description of what went wrong.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

// ---------------------------------------------------------------------------
// Concrete failure types
// ---------------------------------------------------------------------------

/// A network request failed (timeout, no connectivity, non-2xx response).
final class NetworkFailure extends AppFailure {
  const NetworkFailure({required super.message, this.statusCode});

  final int? statusCode;
}

/// The requested resource was not found (404 equivalent).
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({required super.message});
}

/// Local storage read/write failed.
final class StorageFailure extends AppFailure {
  const StorageFailure({required super.message});
}

/// Input validation failed before reaching the data layer.
final class ValidationFailure extends AppFailure {
  const ValidationFailure({required super.message});
}

/// An unexpected error that does not fit any known category.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({required super.message});
}
