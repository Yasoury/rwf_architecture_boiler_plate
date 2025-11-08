# Exception Handling Pattern - AI Agent Implementation Guide

## Purpose

This document provides precise rules and patterns for AI agents to implement exception handling in the WonderWords Flutter application. Follow these rules strictly to maintain architectural consistency.

---

## Architecture Overview

```
API Layer → Repository Layer → State Management → UI Layer
   ↓              ↓                  ↓              ↓
API Exceptions  Transforms to    Catches Domain   Displays to
               Domain Exceptions   Exceptions       User
```

---

## Rule Set

### RULE 1: Exception Layer Separation

**ALWAYS maintain three distinct exception layers:**

1. **API Layer Exceptions** - Suffixed with API name (e.g., `InvalidCredentialsFavQsException`)
   - Location: `/packages/fav_qs_api/lib/src/models/exceptions.dart`
   - Visibility: Package-private, never exposed outside repositories

2. **Domain Layer Exceptions** - No suffix (e.g., `InvalidCredentialsException`)
   - Location: `/packages/domain_models/lib/src/exceptions.dart`
   - Visibility: Public, shared across all features and repositories

3. **UI Layer** - No custom exceptions, only catches domain exceptions

### RULE 2: Exception Naming Convention

**API Layer Pattern:**
```dart
class [ErrorDescription][ApiName]Exception implements Exception {}
```

**Examples:**
```dart
class UserAuthRequiredFavQsException implements Exception {}
class InvalidCredentialsFavQsException implements Exception {}
class EmailAlreadyRegisteredFavQsException implements Exception {}
```

**Domain Layer Pattern:**
```dart
class [ErrorDescription]Exception implements Exception {}
```

**Examples:**
```dart
class UserAuthenticationRequiredException implements Exception {}
class InvalidCredentialsException implements Exception {}
class EmailAlreadyRegisteredException implements Exception {}
```

### RULE 3: API Layer Exception Throwing

**When to throw in API layer:**
- HTTP error responses with specific error codes
- Parsing failures that indicate specific business errors
- API-specific validation failures

**Template:**
```dart
Future<ModelRM> apiMethod() async {
  final response = await _dio.method(url);
  final jsonObject = response.data;

  try {
    final model = ModelRM.fromJson(jsonObject);
    return model;
  } catch (error) {
    // Check for specific error codes
    final int? errorCode = jsonObject[_errorCodeJsonKey];

    if (errorCode == [SPECIFIC_CODE]) {
      throw [Specific]FavQsException();
    }

    // For multiple error codes
    if (errorCode == [CODE_1]) {
      final String errorMessage = jsonObject[_errorMessageJsonKey];
      if (errorMessage.toLowerCase().contains('[keyword]')) {
        throw [Specific1]FavQsException();
      } else {
        throw [Specific2]FavQsException();
      }
    }

    rethrow; // ALWAYS rethrow unhandled exceptions
  }
}
```

**Real Example:**
```dart
// From fav_qs_api.dart:98-121
Future<UserRM> signIn(String email, String password) async {
  final url = _urlBuilder.buildSignInUrl();
  final requestJsonBody = SignInRequestRM(
    credentials: UserCredentialsRM(
      email: email,
      password: password,
    ),
  ).toJson();

  final response = await _dio.post(url, data: requestJsonBody);
  final jsonObject = response.data;

  try {
    final user = UserRM.fromJson(jsonObject);
    return user;
  } catch (error) {
    final int errorCode = jsonObject[_errorCodeJsonKey];
    if (errorCode == 21) {
      throw InvalidCredentialsFavQsException();
    }
    rethrow;
  }
}
```

### RULE 4: Repository Layer Exception Translation

**ALWAYS catch API exceptions and throw domain exceptions in repositories.**

**Template:**
```dart
Future<DomainModel> repositoryMethod() async {
  try {
    final apiModel = await remoteApi.method();
    // Additional processing (caching, transformation, etc.)
    return apiModel.toDomainModel();
  } on [Specific]ApiException catch (_) {
    throw [Specific]Exception(); // Domain exception
  }
}
```

**For multiple possible exceptions:**
```dart
Future<DomainModel> repositoryMethod() async {
  try {
    final apiModel = await remoteApi.method();
    return apiModel.toDomainModel();
  } catch (error) {
    if (error is [Specific1]ApiException) {
      throw [Specific1]Exception();
    } else if (error is [Specific2]ApiException) {
      throw [Specific2]Exception();
    }
    rethrow;
  }
}
```

**Real Example:**
```dart
// From user_repository.dart:48-69
Future<void> signIn(String email, String password) async {
  try {
    final apiUser = await remoteApi.signIn(email, password);

    await _secureStorage.upsertUserInfo(
      username: apiUser.username,
      email: apiUser.email,
      token: apiUser.token,
    );

    final domainUser = apiUser.toDomainModel();
    _userSubject.add(domainUser);
  } on InvalidCredentialsFavQsException catch (_) {
    throw InvalidCredentialsException();
  }
}
```

**Another pattern using extension:**
```dart
// From quote_repository.dart:185-211
extension on Future<QuoteRM> {
  Future<QuoteCM> toCacheUpdateFuture(
    QuoteLocalStorage localStorage, {
    bool shouldInvalidateFavoritesCache = false,
  }) async {
    try {
      final updatedApiQuote = await this;
      final updatedCacheQuote = updatedApiQuote.toCacheModel();
      await Future.wait([
        localStorage.updateQuote(
          updatedCacheQuote,
          !shouldInvalidateFavoritesCache,
        ),
        if (shouldInvalidateFavoritesCache)
          localStorage.clearQuoteListPageList(true),
      ]);
      return updatedCacheQuote;
    } catch (error) {
      if (error is UserAuthRequiredFavQsException) {
        throw UserAuthenticationRequiredException();
      }
      rethrow;
    }
  }
}
```

### RULE 5: State Management Exception Handling

**BLoCs and Cubits must:**
1. Catch domain exceptions (never API exceptions)
2. Map exceptions to UI states
3. Always have a fallback for unexpected exceptions

**Cubit Pattern:**
```dart
void onSubmit() async {
  // Validation and pre-processing

  emit(state.copyWith(status: Status.loading));

  if (isValid) {
    try {
      await repository.method();
      emit(state.copyWith(status: Status.success));
    } catch (error) {
      final status = error is [Specific]Exception
          ? Status.specificError
          : Status.genericError;
      emit(state.copyWith(status: status));
    }
  }
}
```

**BLoC Pattern with Streams:**
```dart
Stream<State> _handleEvent(Emitter emitter, Event event) async* {
  try {
    await for (final data in repository.streamMethod()) {
      yield State.success(data: data);
    }
  } catch (error) {
    if (error is [Specific]Exception) {
      yield State.specificError();
    } else {
      yield State.genericError();
    }
  }
}
```

**Real Example (Cubit):**
```dart
// From sign_in_cubit.dart:86-122
void onSubmit() async {
  final email = Email.validated(state.email.value);
  final password = Password.validated(state.password.value);

  final isFormValid = Formz.validate([email, password]);

  final newState = state.copyWith(
    email: email,
    password: password,
    submissionStatus: isFormValid ? SubmissionStatus.inProgress : null,
  );

  emit(newState);

  if (isFormValid) {
    try {
      await userRepository.signIn(email.value, password.value);
      final newState = state.copyWith(
        submissionStatus: SubmissionStatus.success,
      );
      emit(newState);
    } catch (error) {
      final newState = state.copyWith(
        submissionStatus: error is InvalidCredentialsException
            ? SubmissionStatus.invalidCredentialsError
            : SubmissionStatus.genericError,
      );
      emit(newState);
    }
  }
}
```

**Real Example (BLoC):**
```dart
// From quote_list_bloc.dart:229-284
Future<void> _handleQuoteListItemFavoriteToggled(
  Emitter emitter,
  QuoteListItemFavoriteToggled event,
) async {
  try {
    final updatedQuote = await (event is QuoteListItemFavorited
        ? _quoteRepository.favoriteQuote(event.id)
        : _quoteRepository.unfavoriteQuote(event.id));

    final isFilteringByFavorites = state.filter is QuoteListFilterByFavorites;

    if (!isFilteringByFavorites) {
      emitter(state.copyWithUpdatedQuote(updatedQuote));
    } else {
      emitter(QuoteListState(filter: state.filter));

      final firstPageFetchStream = _fetchQuotePage(
        1,
        fetchPolicy: QuoteListPageFetchPolicy.networkOnly,
      );

      await emitter.onEach<QuoteListState>(
        firstPageFetchStream,
        onData: emitter.call,
      );
    }
  } catch (error) {
    emitter(state.copyWithFavoriteToggleError(error));
  }
}
```

### RULE 6: UI Layer Exception Display

**Three standard ways to display exceptions:**

#### Pattern 1: SnackBar for Transient Errors

**Use when:**
- Operation failed but UI remains functional
- User should be notified but can continue using the app

**Template:**
```dart
BlocListener<YourBloc, YourState>(
  listener: (context, state) {
    if (state.error != null) {
      final snackBar = state.error is [Specific]Exception
          ? [Specific]ErrorSnackBar()
          : const GenericErrorSnackBar();

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  },
  child: // ... your UI
)
```

**Real Example:**
```dart
// From quote_list_screen.dart:104-132
BlocListener<QuoteListBloc, QuoteListState>(
  listener: (context, state) {
    if (state.refreshError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.quoteListRefreshErrorMessage),
        ),
      );
    } else if (state.favoriteToggleError != null) {
      final snackBar =
          state.favoriteToggleError is UserAuthenticationRequiredException
              ? const AuthenticationRequiredErrorSnackBar()
              : const GenericErrorSnackBar();

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);

      widget.onAuthenticationError(context);
    }

    _pagingController.value = state.toPagingState();
  },
  child: // ... your UI
)
```

#### Pattern 2: ExceptionIndicator for Full-Screen Errors

**Use when:**
- Initial data load fails
- Screen cannot display meaningful content without the data

**Template:**
```dart
BlocBuilder<YourBloc, YourState>(
  builder: (context, state) {
    if (state.status == Status.loading) {
      return const CenteredCircularProgressIndicator();
    }

    if (state.status == Status.error) {
      return ExceptionIndicator(
        title: state.error is [Specific]Exception
            ? l10n.specificErrorTitle
            : null,
        message: state.error is [Specific]Exception
            ? l10n.specificErrorMessage
            : null,
        onTryAgain: () => bloc.add(RetryEvent()),
      );
    }

    return // ... your successful UI
  },
)
```

#### Pattern 3: Status-Based SnackBar in BlocConsumer

**Use when:**
- Form submissions
- Actions that should show success or failure

**Template:**
```dart
BlocConsumer<YourCubit, YourState>(
  listenWhen: (oldState, newState) =>
      oldState.submissionStatus != newState.submissionStatus,
  listener: (context, state) {
    if (state.submissionStatus == SubmissionStatus.success) {
      // Handle success
      return;
    }

    final hasError = state.submissionStatus == SubmissionStatus.specificError ||
        state.submissionStatus == SubmissionStatus.genericError;

    if (hasError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          state.submissionStatus == SubmissionStatus.specificError
              ? SnackBar(content: Text(l10n.specificErrorMessage))
              : const GenericErrorSnackBar(),
        );
    }
  },
  builder: (context, state) {
    // ... your form UI
  },
)
```

**Real Example:**
```dart
// From sign_in_screen.dart:128-154
BlocConsumer<SignInCubit, SignInState>(
  listenWhen: (oldState, newState) =>
      oldState.submissionStatus != newState.submissionStatus,
  listener: (context, state) {
    if (state.submissionStatus == SubmissionStatus.success) {
      widget.onSignInSuccess();
      return;
    }

    final hasSubmissionError =
        state.submissionStatus == SubmissionStatus.genericError ||
        state.submissionStatus == SubmissionStatus.invalidCredentialsError;

    if (hasSubmissionError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          state.submissionStatus == SubmissionStatus.invalidCredentialsError
              ? SnackBar(
                  content: Text(l10n.invalidCredentialsErrorMessage),
                )
              : const GenericErrorSnackBar(),
        );
    }
  },
  builder: (context, state) {
    // ... form UI
  },
)
```

### RULE 7: Creating Reusable Error SnackBars

**When creating custom error snackbars:**

**Location:** `/packages/component_library/lib/src/[name]_error_snack_bar.dart`

**Template:**
```dart
import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';

class [Name]ErrorSnackBar extends SnackBar {
  const [Name]ErrorSnackBar({Key? key})
      : super(
          key: key,
          content: const _[Name]ErrorSnackBarMessage(),
        );
}

class _[Name]ErrorSnackBarMessage extends StatelessWidget {
  const _[Name]ErrorSnackBarMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = ComponentLibraryLocalizations.of(context);
    return Text(l10n.[name]ErrorSnackbarMessage);
  }
}
```

**Real Examples:**

```dart
// generic_error_snack_bar.dart
class GenericErrorSnackBar extends SnackBar {
  const GenericErrorSnackBar({Key? key})
      : super(
          key: key,
          content: const _GenericErrorSnackBarMessage(),
        );
}

// authentication_required_error_snack_bar.dart
class AuthenticationRequiredErrorSnackBar extends SnackBar {
  const AuthenticationRequiredErrorSnackBar({Key? key})
      : super(
          key: key,
          content: const _AuthenticationRequiredErrorSnackBarMessage(),
        );
}
```

### RULE 8: Exception Declaration

**All exceptions must implement `Exception` and be marker classes (no fields).**

**Template:**
```dart
class [Name]Exception implements Exception {}
```

**✅ Correct:**
```dart
class InvalidCredentialsException implements Exception {}
class UserAuthenticationRequiredException implements Exception {}
class EmptySearchResultException implements Exception {}
```

**❌ Incorrect:**
```dart
class InvalidCredentialsException extends Exception {} // Don't extend
class InvalidCredentialsException {} // Must implement Exception
class InvalidCredentialsException implements Exception {
  final String message; // No fields in marker exceptions
  InvalidCredentialsException(this.message);
}
```

### RULE 9: Always Use `rethrow`

**When catching an exception you don't handle, ALWAYS use `rethrow`.**

**❌ Incorrect:**
```dart
} catch (error) {
  if (error is SpecificApiException) {
    throw SpecificException();
  }
  throw error; // Wrong! Use rethrow instead
}
```

**✅ Correct:**
```dart
} catch (error) {
  if (error is SpecificApiException) {
    throw SpecificException();
  }
  rethrow; // Preserves stack trace
}
```

### RULE 10: Error Code Mapping Reference

**Based on FavQs API error codes (from codebase analysis):**

| Error Code | API Exception | Domain Exception | Meaning |
|------------|---------------|------------------|---------|
| 20 | `UserAuthRequiredFavQsException` | `UserAuthenticationRequiredException` | User must be authenticated |
| 21 | `InvalidCredentialsFavQsException` | `InvalidCredentialsException` | Sign-in credentials are wrong |
| 32 | `UsernameAlreadyTakenFavQsException` or `EmailAlreadyRegisteredFavQsException` | `UsernameAlreadyTakenException` or `EmailAlreadyRegisteredException` | Duplicate username or email |
| Special | `EmptySearchResultFavQsException` | `EmptySearchResultException` | Search returned no results (detected by id == 0) |

**Pattern for code 32:**
```dart
if (errorCode == 32) {
  final String errorMessage = jsonObject[_errorMessageJsonKey];
  if (errorMessage.toLowerCase().contains('email')) {
    throw EmailAlreadyRegisteredFavQsException();
  } else {
    throw UsernameAlreadyTakenFavQsException();
  }
}
```

**Pattern for empty search:**
```dart
final firstItem = quoteListPage.quoteList.first;
if (firstItem.id == 0) {
  throw EmptySearchResultFavQsException();
}
```

---

## Implementation Checklist

When implementing new exception handling:

- [ ] Define API exception in `/packages/fav_qs_api/lib/src/models/exceptions.dart`
- [ ] Name API exception with `[Name]FavQsException` pattern
- [ ] Define corresponding domain exception in `/packages/domain_models/lib/src/exceptions.dart`
- [ ] Name domain exception with `[Name]Exception` pattern (no suffix)
- [ ] Throw API exception in API layer when specific error code is detected
- [ ] Use `rethrow` for unhandled exceptions in API layer
- [ ] Catch API exception in repository layer
- [ ] Throw domain exception from repository layer
- [ ] Use `rethrow` for unhandled exceptions in repository layer
- [ ] Catch domain exception in BLoC/Cubit
- [ ] Map exception to UI state or error property
- [ ] Have fallback for unexpected exceptions
- [ ] Display exception to user via SnackBar, ExceptionIndicator, or inline message
- [ ] Create custom SnackBar widget in component library if needed
- [ ] Add localized error messages

---

## Complete Flow Example

**Scenario: User tries to favorite a quote while not authenticated**

### Step 1: API Layer
```dart
// File: /packages/fav_qs_api/lib/src/fav_qs_api.dart

Future<QuoteRM> _updateQuote(String url) async {
  final response = await _dio.put(url);
  final jsonObject = response.data;
  try {
    final quote = QuoteRM.fromJson(jsonObject);
    return quote;
  } catch (error) {
    final int errorCode = jsonObject[_errorCodeJsonKey];
    if (errorCode == 20) {
      throw UserAuthRequiredFavQsException(); // STEP 1: API throws
    }
    rethrow;
  }
}
```

### Step 2: Repository Layer
```dart
// File: /packages/quote_repository/lib/src/quote_repository.dart

extension on Future<QuoteRM> {
  Future<QuoteCM> toCacheUpdateFuture(
    QuoteLocalStorage localStorage, {
    bool shouldInvalidateFavoritesCache = false,
  }) async {
    try {
      final updatedApiQuote = await this;
      final updatedCacheQuote = updatedApiQuote.toCacheModel();
      await localStorage.updateQuote(updatedCacheQuote, true);
      return updatedCacheQuote;
    } catch (error) {
      if (error is UserAuthRequiredFavQsException) {
        throw UserAuthenticationRequiredException(); // STEP 2: Transform
      }
      rethrow;
    }
  }
}

Future<Quote> favoriteQuote(int id) async {
  final updatedCacheQuote = await remoteApi
      .favoriteQuote(id)
      .toCacheUpdateFuture(_localStorage);
  return updatedCacheQuote.toDomainModel();
}
```

### Step 3: BLoC Layer
```dart
// File: /packages/features/quote_list/lib/src/quote_list_bloc.dart

Future<void> _handleQuoteListItemFavoriteToggled(
  Emitter emitter,
  QuoteListItemFavoriteToggled event,
) async {
  try {
    final updatedQuote = await _quoteRepository.favoriteQuote(event.id);
    emitter(state.copyWithUpdatedQuote(updatedQuote));
  } catch (error) {
    emitter(
      state.copyWithFavoriteToggleError(error), // STEP 3: Attach to state
    );
  }
}
```

### Step 4: UI Layer
```dart
// File: /packages/features/quote_list/lib/src/quote_list_screen.dart

BlocListener<QuoteListBloc, QuoteListState>(
  listener: (context, state) {
    if (state.favoriteToggleError != null) {
      final snackBar = state.favoriteToggleError
          is UserAuthenticationRequiredException
              ? const AuthenticationRequiredErrorSnackBar() // STEP 4: Display
              : const GenericErrorSnackBar();

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);

      widget.onAuthenticationError(context); // STEP 5: Navigate if needed
    }
  },
  child: // ... UI
)
```

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Letting API Exceptions Leak
```dart
// In repository
Future<Quote> getQuote(int id) async {
  return (await remoteApi.getQuote(id)).toDomainModel(); // API exception leaks!
}
```

### ❌ Anti-Pattern 2: Using API Exceptions in BLoCs
```dart
// In BLoC
} catch (error) {
  if (error is InvalidCredentialsFavQsException) { // Wrong layer!
    emit(state.copyWith(status: Status.error));
  }
}
```

### ❌ Anti-Pattern 3: Swallowing Exceptions
```dart
} catch (error) {
  // Silently fails - bad!
}
```

### ❌ Anti-Pattern 4: Creating Exception with Messages
```dart
class InvalidCredentialsException implements Exception {
  final String message; // Don't do this! Keep them as markers
  InvalidCredentialsException(this.message);
}
```

### ❌ Anti-Pattern 5: Not Handling Specific Exceptions
```dart
} catch (error) {
  emit(state.copyWith(status: Status.error)); // Too generic!
}
```

---

## Quick Reference

### Exception Suffixes by Layer
- **API Layer**: `[Name]FavQsException`
- **Domain Layer**: `[Name]Exception` (no suffix)
- **UI Layer**: No custom exceptions

### File Locations
- **API Exceptions**: `/packages/fav_qs_api/lib/src/models/exceptions.dart`
- **Domain Exceptions**: `/packages/domain_models/lib/src/exceptions.dart`
- **SnackBar Widgets**: `/packages/component_library/lib/src/[name]_error_snack_bar.dart`

### Import Statements
```dart
// In API layer
import 'package:fav_qs_api/src/models/exceptions.dart';

// In Repository layer
import 'package:domain_models/domain_models.dart';
import 'package:fav_qs_api/fav_qs_api.dart';

// In BLoC/Cubit
import 'package:domain_models/domain_models.dart';

// In UI (for specific checks)
import 'package:domain_models/domain_models.dart';
```

---

## Validation Rules for AI Agents

Before submitting code, verify:

1. ✅ API exceptions are only thrown in API layer
2. ✅ API exceptions are only caught in repository layer
3. ✅ Domain exceptions are thrown from repository layer
4. ✅ Domain exceptions are caught in state management layer
5. ✅ All unhandled exceptions use `rethrow`
6. ✅ All exceptions are marker classes (no fields)
7. ✅ Naming conventions are followed exactly
8. ✅ UI displays errors via SnackBar, ExceptionIndicator, or inline
9. ✅ Generic error fallback exists for unexpected exceptions
10. ✅ No layer references exceptions from lower layers

---

## Summary

Follow these rules precisely to implement exception handling that:
- Maintains clean architecture boundaries
- Provides type-safe error handling
- Enables easy testing and maintenance
- Delivers clear user feedback
- Scales with application complexity

When in doubt, refer to the real examples provided in this document.
