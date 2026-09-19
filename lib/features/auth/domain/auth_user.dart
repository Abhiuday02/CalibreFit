/// Domain model representing an authenticated user.
///
/// Intentionally lean for Phase 1. Additional fields (displayName, avatarUrl,
/// onboardingCompleted, etc.) will be added when those features are built.
class AuthUser {
  const AuthUser({required this.id, required this.email, this.displayName});

  final String id;
  final String email;
  final String? displayName;

  @override
  String toString() => 'AuthUser(id: $id, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
