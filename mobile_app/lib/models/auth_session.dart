class AuthSession {
  final String name;
  final String email;
  final String accessToken;
  final String refreshToken;

  const AuthSession({
    required this.name,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });
}
