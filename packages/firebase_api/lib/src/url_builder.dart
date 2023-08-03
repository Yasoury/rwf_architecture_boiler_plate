class UrlBuilder {
  const UrlBuilder({
    String? baseUrl,
  }) : _baseUrl = baseUrl ?? 'https://identitytoolkit.googleapis.com/v1/';

  final String _baseUrl;

  String buildSignInWithPasswordUrl() {
    return '$_baseUrl/accounts:signInWithPassword';
  }

  String buildSignUpUrl() {
    return '$_baseUrl/accounts:signUp';
  }

  String buildUpdateProfileUrl() {
    return '$_baseUrl/accounts:update';
  }

  String buildRequestPasswordResetEmailUrl() {
    return '$_baseUrl/accounts:resetPassword';
  }

  String buildDeleteUserUrl() {
    return '$_baseUrl/accounts:delete';
  }
}
