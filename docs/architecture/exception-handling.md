# Exception Handling (Three-Layer Architecture)

Exceptions flow through three layers. NEVER let API-specific exceptions leak to the UI layer.

## Layer 1: API Exceptions

Defined in the API package. Thrown when API calls fail.

```dart
// packages/fav_qs_api/lib/src/models/exceptions.dart
class EmptySearchResultFavQsException implements Exception {}
class UserAuthRequiredFavQsException implements Exception {}
class InvalidCredentialsFavQsException implements Exception {}
class UsernameAlreadyTakenFavQsException implements Exception {}
class EmailAlreadyRegisteredFavQsException implements Exception {}
```

Thrown in API client based on HTTP status codes:
```dart
Future<ResponseRM> signIn(String email, String password) async {
  try {
    final response = await _dio.post(url, data: body);
    return ResponseRM.fromJson(response.data);
  } on DioException catch (dioError) {
    if (dioError.response?.statusCode == 400) {
      throw InvalidCredentialsFavQsException();
    }
    rethrow;
  }
}
```

## Layer 2: Domain Exceptions

Defined in `domain_models` package. These are what the rest of the app uses.

```dart
// packages/domain_models/lib/src/exceptions.dart
class EmptySearchResultException implements Exception {}
class UserAuthenticationRequiredException implements Exception {}
class InvalidCredentialsException implements Exception {}
class UsernameAlreadyTakenException implements Exception {}
class EmailAlreadyRegisteredException implements Exception {}
```

## Layer 3: Repository Translation

Repositories catch API exceptions and rethrow as domain exceptions:

```dart
// In repository
Future<void> signIn(String email, String password) async {
  try {
    final apiUser = await remoteApi.signIn(email, password);
    // ... store and propagate
  } on InvalidCredentialsFavQsException catch (_) {
    throw InvalidCredentialsException();  // Translate to domain exception
  } catch (e) {
    throw UnknownException();  // Generic fallback
  }
}
```

## Layer 4: UI Handling in Cubit/Bloc

State managers catch domain exceptions and map to submission status or error states:

```dart
// In Cubit
try {
  await userRepository.signIn(email, password);
  emit(state.copyWith(submissionStatus: SubmissionStatus.success));
} catch (error) {
  emit(state.copyWith(
    submissionStatus: error is InvalidCredentialsException
        ? SubmissionStatus.invalidCredentialsError
        : SubmissionStatus.genericError,
  ));
}
```

## Exception Translation with Extension Methods

For repetitive translation patterns, use private extensions:

```dart
extension on Future<QuoteRM> {
  Future<Quote> toCacheUpdateFuture(QuoteLocalStorage storage) async {
    try {
      final result = await this;
      final cacheModel = result.toCacheModel();
      await storage.update(cacheModel);
      return result.toDomainModel();
    } on UserAuthRequiredFavQsException {
      throw UserAuthenticationRequiredException();
    }
  }
}
```
