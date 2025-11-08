# Exception Handling Guide for WonderWords Flutter App

## Overview

This document explains how the WonderWords Flutter application handles exceptions in a clean, maintainable, and scalable way using a **multi-layered exception handling architecture**. This pattern is based on the Repository Pattern and follows clean architecture principles.

## Table of Contents

1. [Core Philosophy](#core-philosophy)
2. [The Three Exception Layers](#the-three-exception-layers)
3. [Exception Flow Through the Architecture](#exception-flow-through-the-architecture)
4. [Layer-by-Layer Breakdown](#layer-by-layer-breakdown)
5. [UI Exception Presentation](#ui-exception-presentation)
6. [Best Practices](#best-practices)
7. [Real-World Examples](#real-world-examples)

---

## Core Philosophy

The WonderWords app follows a **layered exception handling approach** where:

- **Each layer has its own set of exceptions** (API exceptions, Domain exceptions)
- **Exceptions are transformed as they cross layer boundaries** to maintain separation of concerns
- **Higher layers are insulated from lower-level implementation details**
- **Domain exceptions act as the contract** between the data layer and presentation layer

### Why This Approach?

1. **Separation of Concerns**: The UI layer doesn't need to know about API-specific errors
2. **Maintainability**: If you switch from one API to another, only the API layer changes
3. **Testability**: Each layer can be tested independently with its own exception types
4. **Type Safety**: Compile-time guarantees that all exceptions are handled appropriately

---

## The Three Exception Layers

### 1. **API/Remote Layer Exceptions** (`fav_qs_api` package)

These exceptions are specific to the FavQs API implementation.

**Location**: `/packages/fav_qs_api/lib/src/models/exceptions.dart`

**Examples**:
```dart
class EmptySearchResultFavQsException implements Exception {}
class UserAuthRequiredFavQsException implements Exception {}
class InvalidCredentialsFavQsException implements Exception {}
class UsernameAlreadyTakenFavQsException implements Exception {}
class EmailAlreadyRegisteredFavQsException implements Exception {}
```

**Characteristics**:
- Thrown by the `FavQsApi` class when the API returns specific error codes
- Named with `FavQs` suffix to indicate their API-specific nature
- Never exposed outside the repository layer

### 2. **Domain Layer Exceptions** (`domain_models` package)

These are neutral, implementation-agnostic exceptions that represent business logic errors.

**Location**: `/packages/domain_models/lib/src/exceptions.dart`

**Examples**:
```dart
class EmptySearchResultException implements Exception {}
class UserAuthenticationRequiredException implements Exception {}
class InvalidCredentialsException implements Exception {}
class UsernameAlreadyTakenException implements Exception {}
class EmailAlreadyRegisteredException implements Exception {}
```

**Characteristics**:
- No suffix (e.g., just `InvalidCredentialsException`, not `InvalidCredentialsFavQsException`)
- Act as the **contract** between repositories and state managers (BLoCs/Cubits)
- Shared across all repositories and features
- Represent business-level errors, not technical implementation details

### 3. **Presentation Layer Handling** (Features packages)

The presentation layer catches domain exceptions and translates them into user-facing messages or UI states.

**Characteristics**:
- BLoCs/Cubits catch domain exceptions using `try-catch` blocks
- Map exceptions to UI states or trigger snackbar displays
- Never reference API-specific exceptions

---

## Exception Flow Through the Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI LAYER (Features)                      │
│  - Catches: Domain Exceptions                                    │
│  - Displays: Error messages, snackbars, error indicators         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Throws Domain Exceptions
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                    REPOSITORY LAYER                              │
│  - Catches: API Exceptions                                       │
│  - Throws: Domain Exceptions (after transformation)              │
│  - Handles: Exception translation between layers                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Throws API-Specific Exceptions
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                      API LAYER (fav_qs_api)                      │
│  - Inspects: HTTP responses and error codes                      │
│  - Throws: API-specific exceptions                               │
└──────────────────────────────────────────────────────────────────┘
```

---

## Layer-by-Layer Breakdown

### Layer 1: API Layer - Where Exceptions Originate

The API layer is responsible for:
1. Making HTTP requests
2. Parsing responses
3. **Inspecting error codes and throwing appropriate API-specific exceptions**

**Example from** `fav_qs_api.dart:86-96`:

```dart
Future<QuoteRM> _updateQuote(String url) async {
  final response = await _dio.put(url);
  final jsonObject = response.data;
  try {
    final quote = QuoteRM.fromJson(jsonObject);
    return quote;
  } catch (error) {
    final int errorCode = jsonObject[_errorCodeJsonKey];
    if (errorCode == 20) {
      throw UserAuthRequiredFavQsException(); // API-specific exception
    }
    rethrow;
  }
}
```

**Key Points**:
- Error code `20` from the API means authentication is required
- The API layer throws `UserAuthRequiredFavQsException`
- If there's an unexpected error, `rethrow` ensures it propagates up

### Layer 2: Repository Layer - Exception Translation

The repository layer is the **translation point** where API exceptions are caught and converted to domain exceptions.

**Example from** `quote_repository.dart:185-211`:

```dart
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
        throw UserAuthenticationRequiredException(); // Domain exception
      }
      rethrow;
    }
  }
}
```

**Key Points**:
- Catches `UserAuthRequiredFavQsException` (API-specific)
- Throws `UserAuthenticationRequiredException` (domain exception)
- Other exceptions are re-thrown to propagate unexpected errors

**Another example from** `user_repository.dart:48-69`:

```dart
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
    throw InvalidCredentialsException(); // Translation happens here
  }
}
```

### Layer 3: State Management Layer - Exception Handling

BLoCs and Cubits catch domain exceptions and translate them into UI states.

**Example from** `sign_in_cubit.dart:86-122`:

```dart
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

**Key Points**:
- Catches domain exceptions (not API exceptions)
- Maps specific exceptions (`InvalidCredentialsException`) to specific states
- Falls back to generic error handling for unexpected exceptions

**Example from** `quote_list_bloc.dart:229-284`:

```dart
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
      // Refresh the entire list when filtering by favorites
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
    // Attach error to state for UI to display
    emitter(state.copyWithFavoriteToggleError(error));
  }
}
```

---

## UI Exception Presentation

The UI layer listens to state changes and presents errors to users in three main ways:

### 1. **SnackBars** for Transient Errors

Used for errors that don't block the entire screen, such as failed operations.

**Example from** `sign_in_screen.dart:128-154`:

```dart
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
  // ... builder
)
```

**Example from** `quote_list_screen.dart:104-132`:

```dart
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
  // ... child
)
```

### 2. **Exception Indicator Widget** for Full-Screen Errors

When an error prevents displaying the main content, use the `ExceptionIndicator` widget.

**Component**: `exception_indicator.dart`

```dart
class ExceptionIndicator extends StatelessWidget {
  const ExceptionIndicator({
    this.title,
    this.message,
    this.onTryAgain,
    Key? key,
  }) : super(key: key);

  final String? title;
  final String? message;
  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = ComponentLibraryLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48),
            const SizedBox(height: Spacing.xxLarge),
            Text(
              title ?? l10n.exceptionIndicatorGenericTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: FontSize.mediumLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? l10n.exceptionIndicatorGenericMessage,
              textAlign: TextAlign.center,
            ),
            if (onTryAgain != null) const SizedBox(height: Spacing.xxxLarge),
            if (onTryAgain != null)
              ExpandedElevatedButton(
                onTap: onTryAgain,
                icon: const Icon(Icons.refresh),
                label: l10n.exceptionIndicatorTryAgainButton,
              ),
          ],
        ),
      ),
    );
  }
}
```

### 3. **Pre-built SnackBar Widgets**

The component library provides reusable snackbar widgets:

**`GenericErrorSnackBar`** - For unexpected errors:
```dart
class GenericErrorSnackBar extends SnackBar {
  const GenericErrorSnackBar({Key? key})
      : super(
          key: key,
          content: const _GenericErrorSnackBarMessage(),
        );
}
```

**`AuthenticationRequiredErrorSnackBar`** - For auth errors:
```dart
class AuthenticationRequiredErrorSnackBar extends SnackBar {
  const AuthenticationRequiredErrorSnackBar({Key? key})
      : super(
          key: key,
          content: const _AuthenticationRequiredErrorSnackBarMessage(),
        );
}
```

---

## Best Practices

### 1. **Always Catch and Transform API Exceptions in Repositories**

❌ **Bad** - Letting API exceptions leak to the presentation layer:
```dart
Future<Quote> favoriteQuote(int id) async {
  // API exception will leak to BLoC!
  final quote = await remoteApi.favoriteQuote(id);
  return quote.toDomainModel();
}
```

✅ **Good** - Catching and transforming:
```dart
Future<Quote> favoriteQuote(int id) async {
  try {
    final quote = await remoteApi.favoriteQuote(id);
    return quote.toDomainModel();
  } on UserAuthRequiredFavQsException catch (_) {
    throw UserAuthenticationRequiredException();
  }
}
```

### 2. **Use Specific Exception Types When Possible**

❌ **Bad** - Generic catch-all:
```dart
} catch (error) {
  emit(state.copyWith(status: Status.error));
}
```

✅ **Good** - Specific handling with fallback:
```dart
} catch (error) {
  if (error is InvalidCredentialsException) {
    emit(state.copyWith(status: Status.invalidCredentials));
  } else if (error is UserAuthenticationRequiredException) {
    emit(state.copyWith(status: Status.authRequired));
  } else {
    emit(state.copyWith(status: Status.genericError));
  }
}
```

### 3. **Rethrow Unexpected Exceptions**

Always use `rethrow` when you don't handle an exception:

```dart
} catch (error) {
  if (error is EmptySearchResultFavQsException) {
    throw EmptySearchResultException();
  }
  rethrow; // Important! Don't swallow unexpected exceptions
}
```

### 4. **Define Domain Exceptions in the `domain_models` Package**

This ensures they're accessible to all repositories and features:

```
packages/
  domain_models/
    lib/
      src/
        exceptions.dart    ← Domain exceptions here
```

### 5. **Name Exceptions Clearly**

- **API exceptions**: Include the API name (e.g., `InvalidCredentialsFavQsException`)
- **Domain exceptions**: Use clear, business-focused names (e.g., `InvalidCredentialsException`)
- **No prefix/suffix**: Domain exceptions should be clean (not `DomainInvalidCredentialsException`)

### 6. **Don't Catch Exceptions Just to Log Them**

❌ **Bad**:
```dart
} catch (error) {
  print('Error occurred: $error');
  rethrow;
}
```

✅ **Good** - Let exceptions bubble up naturally; use monitoring tools for logging:
```dart
// No unnecessary catch blocks
final result = await repository.getData();
```

---

## Real-World Examples

### Example 1: Sign-In Flow

**Step 1**: User enters invalid credentials

**Step 2**: API returns error code 21
```dart
// In fav_qs_api.dart
} catch (error) {
  final int errorCode = jsonObject[_errorCodeJsonKey];
  if (errorCode == 21) {
    throw InvalidCredentialsFavQsException(); // API exception
  }
  rethrow;
}
```

**Step 3**: Repository catches and transforms
```dart
// In user_repository.dart
} on InvalidCredentialsFavQsException catch (_) {
  throw InvalidCredentialsException(); // Domain exception
}
```

**Step 4**: Cubit catches and updates state
```dart
// In sign_in_cubit.dart
} catch (error) {
  final newState = state.copyWith(
    submissionStatus: error is InvalidCredentialsException
        ? SubmissionStatus.invalidCredentialsError
        : SubmissionStatus.genericError,
  );
  emit(newState);
}
```

**Step 5**: UI displays snackbar
```dart
// In sign_in_screen.dart
if (hasSubmissionError) {
  ScaffoldMessenger.of(context).showSnackBar(
    state.submissionStatus == SubmissionStatus.invalidCredentialsError
        ? SnackBar(content: Text(l10n.invalidCredentialsErrorMessage))
        : const GenericErrorSnackBar(),
  );
}
```

### Example 2: Favoriting a Quote (Auth Required)

**Step 1**: User tries to favorite a quote without being signed in

**Step 2**: API returns error code 20
```dart
// In fav_qs_api.dart
if (errorCode == 20) {
  throw UserAuthRequiredFavQsException();
}
```

**Step 3**: Repository transforms exception
```dart
// In quote_repository.dart
} catch (error) {
  if (error is UserAuthRequiredFavQsException) {
    throw UserAuthenticationRequiredException();
  }
  rethrow;
}
```

**Step 4**: BLoC attaches error to state
```dart
// In quote_list_bloc.dart
} catch (error) {
  emitter(state.copyWithFavoriteToggleError(error));
}
```

**Step 5**: UI shows authentication error and navigates
```dart
// In quote_list_screen.dart
if (state.favoriteToggleError is UserAuthenticationRequiredException) {
  ScaffoldMessenger.of(context).showSnackBar(
    const AuthenticationRequiredErrorSnackBar()
  );
  widget.onAuthenticationError(context);
}
```

---

## Summary

The WonderWords exception handling pattern provides:

✅ **Clean separation of concerns** - Each layer only knows about its own exception types
✅ **Maintainability** - Changing the API doesn't affect the UI layer
✅ **Testability** - Mock different exception scenarios easily
✅ **Type safety** - Compile-time guarantees for exception handling
✅ **User-friendly** - Consistent error messaging across the app

By following this pattern, your Flutter applications will have robust, maintainable exception handling that scales with your app's complexity.
