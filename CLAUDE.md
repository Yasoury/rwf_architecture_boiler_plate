# CLAUDE.md

This file provides comprehensive guidance to Claude Code when working with code in this repository. It is the single source of truth for all architectural patterns, conventions, and implementation rules.

## Project Overview

This is a Flutter project based on "Real-World Flutter by Tutorials" book principles. It implements Clean Architecture with a modular, multi-package monorepo structure. The app (WonderWords) is an insightful quotes archive using the FavQs API.

**Key Technologies:** Flutter, Dart, flutter_bloc (Cubits & Blocs), Isar (local database), GoRouter (navigation), Formz (form validation), Firebase (analytics, crashlytics), storybook_flutter (component catalog).

---

## Build Commands

Use the Makefile for ALL development tasks. Never run `flutter pub get` or `flutter test` directly — always use `make` commands to ensure all packages are handled.

| Command | Purpose |
|---------|---------|
| `make get` | Install dependencies for ALL packages |
| `make upgrade` | Upgrade dependencies (minor versions) |
| `make upgrade-major` | Upgrade to major versions |
| `make clean` | Clean all packages |
| `make testing` | Run tests for ALL packages |
| `make test-coverage` | Run tests with coverage reports |
| `make format` | Format code in all packages |
| `make lint` | Run flutter analyze |
| `make build-runner` | Run code generation (Isar schemas, JSON serialization) |
| `make gen-l10n` | Generate localization files for all packages |
| `make outdated` | Check for outdated dependencies |
| `make pods-clean` | Clean iOS pods |

---

## Project Structure

```
lib/
├── main.dart                    # App entry point, DI, error handling setup
├── routing_table.dart           # Centralized route definitions
├── tab_container_screen.dart    # Tab navigation container
├── screen_view_observer.dart    # Analytics screen tracking
└── l10n/                        # Main app localizations

packages/
├── features/                    # Feature packages (package-by-feature)
│   ├── quote_list/              # Bloc: paginated list with search, filters, favorites
│   ├── quote_details/           # Cubit: single quote view with vote/favorite
│   ├── sign_in/                 # Cubit: email/password sign-in form
│   ├── sign_up/                 # Cubit: registration form
│   ├── forgot_my_password/      # Cubit: password reset dialog
│   ├── profile_menu/            # Bloc: user profile with dark mode toggle
│   ├── update_profile/          # Cubit: edit profile form
│   └── user_preferences/        # Cubit: settings management
│
├── component_library/           # Shared UI components + theme system + storybook
├── domain_models/               # Domain entities and domain exceptions
├── key_value_storage/           # Isar database wrapper (singleton)
├── monitoring/                  # Firebase Analytics, Crashlytics, Remote Config
├── fav_qs_api/                  # REST API client (Dio-based)
├── quote_repository/            # Quote data access (cache + network)
├── user_repository/             # User/auth data access (secure + cache + network)
└── form_fields/                 # Formz-based field validation (Email, Password, Username)
```

---

## Package Architecture Rules

These are the four commandments governing package distribution. Follow them strictly.

### Rule 1: Features Get Their Own Package

A feature is either:
- A screen
- A dialog that executes I/O calls (e.g., `forgot_my_password`)

Each feature is a separate package under `packages/features/`. Dummy UI components shared between screens go in `component_library`, NOT in a feature package.

### Rule 2: Features Do NOT Know About Each Other

Feature packages NEVER import other feature packages. When screen A needs to open screen B, screen A receives a callback (e.g., `VoidCallback onSignUpTap`) in its constructor. The main app's `routing_table.dart` connects the wires.

```dart
// CORRECT: Feature uses callbacks
class SignInScreen extends StatelessWidget {
  const SignInScreen({
    required this.userRepository,
    required this.onSignInSuccess,
    this.onSignUpTap,
    super.key,
  });
  final VoidCallback onSignInSuccess;
  final VoidCallback? onSignUpTap;
  final UserRepository userRepository;
}

// WRONG: Feature imports another feature
import 'package:sign_up/sign_up.dart'; // NEVER DO THIS
```

### Rule 3: Repositories Get Their Own Package

Each repository is a separate package (e.g., `quote_repository`, `user_repository`) because repositories are used by multiple features.

### Rule 4: No Common Package

NEVER create a "common" package. When code needs sharing between packages, create a specialized package:
- `component_library` — reusable UI components
- `fav_qs_api` — shared API client
- `key_value_storage` — shared local storage wrapper
- `domain_models` — shared domain models and exceptions
- `form_fields` — shared form validation logic

---

## Barrel File Pattern

Every package uses an `src/` folder for private files and a barrel file directly under `lib/` to expose public API.

**Rules:**
1. Create all implementation files under `lib/src/`
2. Create a barrel file at `lib/<package_name>.dart` that exports public files
3. Features export ONLY their screen widget and localization class — Cubits/Blocs are PRIVATE
4. Repositories export ONLY the repository class — local storage classes are PRIVATE

```dart
// packages/features/sign_in/lib/sign_in.dart (barrel file)
export 'src/l10n/sign_in_localizations.dart';
export 'src/sign_in_screen.dart';
// NOTE: sign_in_cubit.dart is NOT exported — it's an internal detail

// packages/quote_repository/lib/quote_repository.dart (barrel file)
export 'src/quote_repository.dart';
// NOTE: quote_local_storage.dart is NOT exported
```

---

## Three-Layer Model Architecture

Every data entity exists in three forms. NEVER leak one layer's model into another layer.

### Model Types

| Type | Suffix | Location | Annotations | Purpose |
|------|--------|----------|-------------|---------|
| Domain Model | (none) | `domain_models` | Equatable | Neutral business entity |
| Cache Model | `CM` | `key_value_storage` | `@collection` (Isar) | Local database entity |
| Remote Model | `RM` | `fav_qs_api` | `@JsonSerializable` | API request/response entity |

### Mapper Extensions

Create extension methods on each model for conversion. Always create both single-item and list mappers.

**Naming Convention:**
- `RemoteModelToDomain` — Remote → Domain
- `DomainModelToCM` — Domain → Cache
- `CacheModelToDomain` — Cache → Domain

```dart
// Remote to Domain
extension SignInResponseToDomain on SignInResponseRM {
  User toDomainModel() => User(
    accessToken: idToken,    // Property names may differ between layers
    email: email,
    displayName: displayName,
    userId: localId,
  );
}

// Domain to Cache
extension UserSettingsToCM on UserSettings {
  UserSettingsCM toCacheModel() => UserSettingsCM(
    language: language,
    passedOnBoarding: passedOnBoarding,
    darkModePreference: darkModePreference?.toCM(),
  );
}

// Cache to Domain
extension UserSettingsCMToDomain on UserSettingsCM {
  UserSettings toDomainModel() => UserSettings(
    language: language,
    passedOnBoarding: passedOnBoarding,
    darkModePreference: darkModePreference.toDomain(),
  );
}

// List mapper
extension QuoteListCMToDomain on List<QuoteCM> {
  List<Quote> toDomainModel() => map((item) => item.toDomainModel()).toList();
}
```

### Where Mappers Live

Mappers live in the repository package that uses them, under a `mappers/` directory:
```
packages/user_repository/lib/src/
├── user_repository.dart
├── user_local_storage.dart
├── user_secure_storage.dart
└── mappers/
    ├── remote_to_domain.dart
    ├── domain_to_cache.dart
    └── cache_to_domain.dart
```

---

## Isar Database (Local Storage)

The project uses Isar (via `isar_community` package) for local database operations. Isar replaces Hive from the original book.

### KeyValueStorage Singleton

```dart
final class KeyValueStorage {
  static final KeyValueStorage _instance = KeyValueStorage._internal();
  factory KeyValueStorage() => _instance;
  KeyValueStorage._internal();

  late Isar _isar;

  // Expose typed collections
  IsarCollection<UserSettingsCM> get userSettingsCollection =>
      _isar.userSettingsCMs;

  // ALL writes MUST go through this wrapper
  Future<void> writeIsarTxn(Function() function) async {
    await _isar.writeTxn(() async {
      await function();
    });
  }

  // Called once in main.dart before runApp
  Future<void> initIsarDB() async {
    final directory = await getApplicationDocumentsDirectory();
    if (!Isar.instanceNames.contains('default')) {
      _isar = await Isar.open(
        [UserSettingsCMSchema],  // Register ALL collection schemas here
        directory: directory.path,
      );
    } else {
      _isar = Isar.getInstance()!;
    }
  }
}
```

### Cache Model Pattern (Isar Collection)

```dart
@collection
class UserSettingsCM {
  Id id = Isar.autoIncrement;

  String? language;
  bool? passedOnBoarding;

  @enumerated
  DarkModePreferenceCM darkModePreference;

  UserSettingsCM({
    this.language,
    this.passedOnBoarding,
    this.darkModePreference = DarkModePreferenceCM.accordingToSystemPreferences,
  });
}
```

### Local Storage Access Pattern

```dart
class UserLocalStorage {
  final KeyValueStorage noSqlStorage;

  Future<void> upsertUserSettings(UserSettingsCM settings) async {
    await noSqlStorage.writeIsarTxn(() async {
      noSqlStorage.userSettingsCollection.clear();
      noSqlStorage.userSettingsCollection.put(settings);
    });
  }

  Future<UserSettingsCM?> getUserSettings() async {
    return await noSqlStorage.userSettingsCollection.where().findFirst();
  }
}
```

### Code Generation

Run `make build-runner` after:
- Adding/modifying `@collection` Isar models
- Adding/modifying `@JsonSerializable` API models
- Any changes to classes with code generation annotations

This generates `*.g.dart` files. NEVER edit generated files manually.

### Barrel File for key_value_storage

```dart
export 'package:isar_community/isar.dart';
export 'src/key_value_storage.dart';
export 'src/models/models.dart';
```

---

## Repository Pattern

Repositories sit between state managers (Cubits/Blocs) and data sources (API, database). They are the single source of truth for data.

### Repository Constructor Rules

**Dependencies from other packages** → require in constructor (allows sharing instances):
```dart
QuoteRepository({
  required KeyValueStorage keyValueStorage,  // From key_value_storage package
  required this.remoteApi,                   // From fav_qs_api package
  @visibleForTesting QuoteLocalStorage? localStorage,  // Internal, optional for testing
}) : _localStorage = localStorage ?? QuoteLocalStorage(keyValueStorage: keyValueStorage);
```

**Dependencies from same package** → instantiate internally (hide implementation details):
- `QuoteLocalStorage` is created inside the constructor, not exposed
- The `@visibleForTesting` optional parameter exists ONLY for injecting mocks in tests

### Fetch Policy Pattern

Use enum-based fetch policies for flexible data loading strategies:

```dart
enum QuoteListPageFetchPolicy {
  cacheAndNetwork,    // Emit cached first, then fresh from network. Use: initial app open
  networkOnly,        // Skip cache entirely. Use: user pull-to-refresh
  networkPreferably,  // Network first, fallback to cache on error. Use: loading next page
  cachePreferably,    // Cache first, skip network if cache exists. Use: clearing search/filter
}
```

### Stream-Based Repository Data Flow

Repositories return `Stream` (not `Future`) when a fetch policy may emit multiple values:

```dart
Stream<QuoteListPage> getQuoteListPage(
  int pageNumber, {
  required QuoteListPageFetchPolicy fetchPolicy,
  Tag? tag,
  String searchTerm = '',
  String? favoritedByUsername,
}) async* {
  final shouldSkipCache = tag != null || searchTerm.isNotEmpty ||
      fetchPolicy == QuoteListPageFetchPolicy.networkOnly;

  if (shouldSkipCache) {
    final freshPage = await _getPageFromNetwork(pageNumber, tag: tag, searchTerm: searchTerm);
    yield freshPage;
  } else {
    // Emit cached page first if policy allows
    final cachedPage = await _localStorage.getPage(pageNumber);
    if (cachedPage != null &&
        (fetchPolicy == QuoteListPageFetchPolicy.cachePreferably ||
         fetchPolicy == QuoteListPageFetchPolicy.cacheAndNetwork)) {
      yield cachedPage.toDomainModel();
      if (fetchPolicy == QuoteListPageFetchPolicy.cachePreferably) return;
    }

    // Then fetch from network
    try {
      final freshPage = await _getPageFromNetwork(pageNumber);
      yield freshPage;
    } catch (_) {
      if (cachedPage != null &&
          fetchPolicy == QuoteListPageFetchPolicy.networkPreferably) {
        yield cachedPage.toDomainModel();
        return;
      }
      rethrow;
    }
  }
}
```

### App State with BehaviorSubject

For cross-screen state (current user, settings), use `BehaviorSubject` from RxDart in repositories:

```dart
class UserRepository {
  final BehaviorSubject<User?> _userSubject = BehaviorSubject();

  Stream<User?> getUser() async* {
    if (!_userSubject.hasValue) {
      // Load persisted state on first subscription
      final stored = await _secureStorage.getUserInfo();
      _userSubject.add(stored?.toDomainModel());
    }
    yield* _userSubject.stream;
  }

  Future<void> signIn(String email, String password) async {
    final apiUser = await remoteApi.signIn(email, password);
    await _secureStorage.upsertUserInfo(/* ... */);
    _userSubject.add(apiUser.toDomainModel());  // Notify all listeners
  }

  Future<void> signOut() async {
    await _secureStorage.deleteAll();
    _userSubject.add(null);  // Notify all listeners
  }
}
```

### Cache Invalidation Rules

- When fetching a fresh first page (`pageNumber == 1`), clear ALL subsequent cached pages to avoid mixing stale and fresh data
- NEVER cache filtered/searched results — only cache the default unfiltered list
- Favorites list uses a separate cache bucket from the main list

---

## Exception Handling (Three-Layer Architecture)

Exceptions flow through three layers. NEVER let API-specific exceptions leak to the UI layer.

### Layer 1: API Exceptions

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

### Layer 2: Domain Exceptions

Defined in `domain_models` package. These are what the rest of the app uses.

```dart
// packages/domain_models/lib/src/exceptions.dart
class EmptySearchResultException implements Exception {}
class UserAuthenticationRequiredException implements Exception {}
class InvalidCredentialsException implements Exception {}
class UsernameAlreadyTakenException implements Exception {}
class EmailAlreadyRegisteredException implements Exception {}
```

### Layer 3: Repository Translation

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

### Layer 4: UI Handling in Cubit/Bloc

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

### Exception Translation with Extension Methods

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

---

## State Management with Cubits & Blocs

### When to Use Cubit vs Bloc

| Use Cubit | Use Bloc |
|-----------|----------|
| Simple screens with direct method calls | Complex screens with many event types |
| Form validation and submission | Pagination with infinite scroll |
| Single-responsibility screens | Screens combining search + filters + refresh |
| Detail views | Screens needing event debouncing/throttling |
| CRUD operations | Screens combining multiple data streams |

### Cubit Implementation Pattern

```dart
class QuoteDetailsCubit extends Cubit<QuoteDetailsState> {
  QuoteDetailsCubit({
    required this.quoteId,
    required this.quoteRepository,
  }) : super(const QuoteDetailsInProgress()) {
    _fetchQuoteDetails();  // Trigger initial load from constructor
  }

  final int quoteId;
  final QuoteRepository quoteRepository;

  Future<void> _fetchQuoteDetails() async {
    try {
      final quote = await quoteRepository.getQuoteDetails(quoteId);
      emit(QuoteDetailsSuccess(quote: quote));
    } catch (error) {
      emit(QuoteDetailsFailure());
    }
  }

  // Side-effect action: Keep success state visible, show error via snackbar
  Future<void> upvoteQuote() async {
    final currentQuote = state is QuoteDetailsSuccess
        ? (state as QuoteDetailsSuccess).quote : null;
    if (currentQuote == null) return;

    try {
      final updatedQuote = await quoteRepository.upvoteQuote(currentQuote.id);
      emit(QuoteDetailsSuccess(quote: updatedQuote));
    } catch (error) {
      emit(QuoteDetailsSuccess(quote: currentQuote)); // Re-emit to trigger listener
    }
  }
}
```

### State Class Patterns

**Option A: Inheritance-based (for loading/success/failure screens)**

Use when a screen has clearly distinct visual states:

```dart
abstract class QuoteDetailsState extends Equatable {
  const QuoteDetailsState();

  @override
  List<Object?> get props => [];
}

class QuoteDetailsInProgress extends QuoteDetailsState {
  const QuoteDetailsInProgress();
}

class QuoteDetailsSuccess extends QuoteDetailsState {
  const QuoteDetailsSuccess({required this.quote});
  final Quote quote;

  @override
  List<Object?> get props => [quote];
}

class QuoteDetailsFailure extends QuoteDetailsState {
  const QuoteDetailsFailure();
}
```

**Option B: Single class with copyWith (for forms and complex states)**

Use when state has many fields that change independently:

```dart
class SignInState extends Equatable {
  const SignInState({
    this.email = const Email.unvalidated(),
    this.password = const Password.unvalidated(),
    this.submissionStatus = SubmissionStatus.idle,
  });

  final Email email;
  final Password password;
  final SubmissionStatus submissionStatus;

  SignInState copyWith({
    Email? email,
    Password? password,
    SubmissionStatus? submissionStatus,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }

  @override
  List<Object?> get props => [email, password, submissionStatus];
}
```

### SubmissionStatus Enum

Always use this enum for tracking form/action submission states:

```dart
enum SubmissionStatus {
  idle,
  inProgress,
  success,
  genericError,
  invalidCredentialsError,  // Feature-specific errors as needed
  emailAlreadyRegisteredError,
  usernameAlreadyTakenError,
}

extension SubmissionStatusX on SubmissionStatus {
  bool get isError => this == SubmissionStatus.genericError ||
      this == SubmissionStatus.invalidCredentialsError ||
      this == SubmissionStatus.emailAlreadyRegisteredError ||
      this == SubmissionStatus.usernameAlreadyTakenError;
}
```

### Bloc Implementation Pattern

```dart
class QuoteListBloc extends Bloc<QuoteListEvent, QuoteListState> {
  QuoteListBloc({
    required this.quoteRepository,
    required this.userRepository,
  }) : super(const QuoteListState()) {
    _registerEventHandlers();
    add(const QuoteListStarted());  // Trigger initial load
  }

  final QuoteRepository quoteRepository;
  final UserRepository userRepository;

  void _registerEventHandlers() {
    on<QuoteListStarted>(_handleStarted);
    on<QuoteListSearchTermChanged>(
      _handleSearchTermChanged,
      transformer: restartable(),  // Cancel previous search on new input
    );
    on<QuoteListNextPageRequested>(_handleNextPageRequested);
    on<QuoteListRefreshed>(_handleRefreshed);
    on<QuoteListTagChanged>(_handleTagChanged);
    on<QuoteListItemFavoriteToggled>(_handleFavoriteToggled);
  }

  Future<void> _handleStarted(
    QuoteListStarted event,
    Emitter<QuoteListState> emit,
  ) async {
    await emit.onEach(
      userRepository.getUser(),
      onData: (user) {
        // React to user changes
        add(QuoteListUsernameObtained(username: user?.username));
      },
    );
  }
}
```

### Event Classes

```dart
abstract class QuoteListEvent extends Equatable {
  const QuoteListEvent();

  @override
  List<Object?> get props => [];
}

class QuoteListStarted extends QuoteListEvent {
  const QuoteListStarted();
}

class QuoteListSearchTermChanged extends QuoteListEvent {
  const QuoteListSearchTermChanged(this.searchTerm);
  final String searchTerm;

  @override
  List<Object?> get props => [searchTerm];
}

class QuoteListNextPageRequested extends QuoteListEvent {
  const QuoteListNextPageRequested({required this.pageNumber});
  final int pageNumber;

  @override
  List<Object?> get props => [pageNumber];
}
```

### Event Transformers

Use event transformers for controlling event processing:

```dart
// Debounce search input (wait for user to stop typing)
on<QuoteListSearchTermChanged>(
  _handleSearchTermChanged,
  transformer: debounce(const Duration(seconds: 1)),
);

// Cancel previous operation when new one arrives (search, filter changes)
on<QuoteListSearchTermChanged>(
  _handleSearchTermChanged,
  transformer: restartable(),
);

// Process events sequentially (pagination)
on<QuoteListNextPageRequested>(
  _handleNextPageRequested,
  transformer: sequential(),
);
```

### UI Integration: BlocProvider, BlocBuilder, BlocConsumer

**BlocProvider** — Provides Cubit/Bloc instance to widget tree:
```dart
BlocProvider<SignInCubit>(
  create: (_) => SignInCubit(userRepository: userRepository),
  child: const SignInView(),
)
```

**BlocBuilder** — Rebuilds UI when state changes:
```dart
BlocBuilder<QuoteDetailsCubit, QuoteDetailsState>(
  builder: (context, state) {
    if (state is QuoteDetailsSuccess) {
      return QuoteView(quote: state.quote);
    } else if (state is QuoteDetailsFailure) {
      return const ExceptionIndicator();
    }
    return const CenteredCircularProgressIndicator();
  },
)
```

**BlocConsumer** — Combines BlocBuilder + BlocListener (use when you need both UI rebuild AND side effects):
```dart
BlocConsumer<SignInCubit, SignInState>(
  listenWhen: (oldState, newState) =>
      oldState.submissionStatus != newState.submissionStatus,
  listener: (context, state) {
    if (state.submissionStatus == SubmissionStatus.success) {
      widget.onSignInSuccess();
    } else if (state.submissionStatus.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        state.submissionStatus == SubmissionStatus.invalidCredentialsError
            ? SnackBar(content: Text(l10n.invalidCredentialsErrorMessage))
            : const GenericErrorSnackBar(),
      );
    }
  },
  builder: (context, state) {
    // Build form UI based on state
  },
)
```

### Error Display Strategy

| Scenario | Pattern |
|----------|---------|
| Data fetch fails (no data to show) | Emit failure state → show `ExceptionIndicator` widget |
| Side-effect fails (data still visible) | Re-emit success state → show SnackBar via `BlocListener` |
| Form submission fails | Emit error submissionStatus → show SnackBar via `BlocListener` |

---

## Form Validation with Formz

### FormzInput Field Pattern

Every form field extends `FormzInput` and has TWO constructors:

```dart
class Email extends FormzInput<String, EmailValidationError> {
  const Email.unvalidated([super.value = '']) : super.pure();   // No errors shown yet
  const Email.validated(super.value) : super.dirty();           // Errors are shown

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    if (!_emailRegex.hasMatch(value)) return EmailValidationError.invalid;
    return null;  // Valid
  }
}

enum EmailValidationError { empty, invalid, alreadyRegistered }
```

### Form Cubit Methods

**Field change handler** — Only validate if the field was previously invalid:
```dart
void onEmailChanged(String newValue) {
  final previousEmail = state.email;
  final shouldValidate = previousEmail.isNotValid && !previousEmail.isPure;

  final newEmail = shouldValidate
      ? Email.validated(newValue)
      : Email.unvalidated(newValue);

  emit(state.copyWith(email: newEmail));
}
```

**Field unfocus handler** — Force validation when user leaves the field:
```dart
void onEmailUnfocused() {
  emit(state.copyWith(email: Email.validated(state.email.value)));
}
```

**Form submission** — Validate ALL fields, submit only if valid:
```dart
void onSubmit() async {
  final email = Email.validated(state.email.value);
  final password = Password.validated(state.password.value);
  final isFormValid = Formz.validate([email, password]);

  emit(state.copyWith(
    email: email,
    password: password,
    submissionStatus: isFormValid ? SubmissionStatus.inProgress : SubmissionStatus.idle,
  ));

  if (!isFormValid) return;

  try {
    await userRepository.signIn(email.value, password.value);
    emit(state.copyWith(submissionStatus: SubmissionStatus.success));
  } catch (error) {
    emit(state.copyWith(
      submissionStatus: error is InvalidCredentialsException
          ? SubmissionStatus.invalidCredentialsError
          : SubmissionStatus.genericError,
    ));
  }
}
```

### Form UI Integration

**FocusNode setup** — Wire unfocus events to Cubit:
```dart
final _emailFocusNode = FocusNode();

@override
void initState() {
  super.initState();
  final cubit = context.read<SignInCubit>();
  _emailFocusNode.addListener(() {
    if (!_emailFocusNode.hasFocus) {
      cubit.onEmailUnfocused();
    }
  });
}

@override
void dispose() {
  _emailFocusNode.dispose();
  super.dispose();
}
```

**TextField with error display:**
```dart
TextField(
  focusNode: _emailFocusNode,
  onChanged: cubit.onEmailChanged,
  decoration: InputDecoration(
    enabled: state.submissionStatus != SubmissionStatus.inProgress,
    labelText: l10n.emailLabel,
    errorText: state.email.isNotValid && !state.email.isPure
        ? _getEmailError(state.email.error, l10n)
        : null,
  ),
)
```

**Error text resolution:**
```dart
String? _getEmailError(EmailValidationError? error, SignInLocalizations l10n) {
  switch (error) {
    case EmailValidationError.empty:
      return l10n.emailEmptyErrorMessage;
    case EmailValidationError.invalid:
      return l10n.emailInvalidErrorMessage;
    default:
      return null;
  }
}
```

---

## Routing & Navigation (GoRouter)

The project uses **GoRouter** for declarative routing with Navigator 2.0. Feature packages NEVER import GoRouter — they use callbacks.

### Routing Table Architecture

All routes are defined in a `buildRoutes()` function in `lib/routing_table.dart` that returns `List<RouteBase>`.

```dart
List<RouteBase> buildRoutes({
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
  required UserRepository userRepository,
}) {
  return [
    // Top-level routes (outside tab container)
    GoRoute(
      path: AppRoutes.splash,
      name: 'Splash-Screen',
      builder: (context, state) => PopScope(
        canPop: false,
        child: SplashScreen(
          userRepository: userRepository,
          navigateToHomeScreen: () => context.go(AppRoutes.homePath),
          navigateToOnBarding: () => context.go(AppRoutes.onboarding),
          navigateAuthIntro: () => context.go(AppRoutes.signIn),
        ),
      ),
    ),

    GoRoute(
      path: AppRoutes.signIn,
      name: 'sign-in',
      builder: (context, state) => PopScope(
        canPop: false,
        child: Builder(
          builder: (context) => SignInScreen(
            userRepository: userRepository,
            onSignInSuccess: () => context.pop(),
            onSignUpTap: () => context.push(AppRoutes.signUp),
            onForgotMyPasswordTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => ForgotMyPasswordDialog(
                  userRepository: userRepository,
                  onCancelTap: () => Navigator.of(dialogContext).pop(),
                  onEmailRequestSuccess: () => Navigator.of(dialogContext).pop(),
                ),
              );
            },
          ),
        ),
      ),
    ),

    // Tab Container with StatefulShellRoute
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state, navigationShell) => PopScope(
        canPop: false,
        child: TabContainerScreen(navigationShell: navigationShell),
      ),
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.homePath,
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.profileMenuPath,
              name: 'profile-menu',
              builder: (context, state) => ProfileMenuScreen(
                userRepository: userRepository,
                onSignInTap: () => context.push(AppRoutes.signIn),
                onUpdateProfileTap: () => context.push(AppRoutes.updateProfile),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.userPreferencesPath,
              name: 'user-preferences',
              builder: (context, state) => UserPreferencesScreen(
                userRepository: userRepository,
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}
```

### Navigator Keys

```dart
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');
final GlobalKey<NavigatorState> _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');
```

### AppRoutes Path Constants

```dart
class AppRoutes {
  const AppRoutes._();

  // Root paths (outside tabs)
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String updateProfile = '/update-profile';

  // Tab container base
  static const String tabContainer = '/app';

  // Tab branch paths
  static String get homePath => '$tabContainer/home';
  static String get profileMenuPath => '$tabContainer/profile';
  static String get userPreferencesPath => '$tabContainer/settings';

  // Parameterized routes (example)
  static String quoteDetailsPath(int id) => '$homePath/quote/$id';
}
```

### Navigation Rules

1. Only the main app package (`lib/`) imports `go_router`
2. Feature packages use `VoidCallback` or typed callbacks for navigation — NEVER GoRouter directly
3. Use `context.go()` for full replacement navigation (e.g., splash → home)
4. Use `context.push()` for pushing on the navigation stack
5. Use `context.pop()` to go back
6. Use `PopScope(canPop: false)` to prevent back navigation on root screens
7. Use `GoRoute(name: 'screen-name')` to enable analytics screen tracking
8. Tab navigation uses `StatefulShellRoute.indexedStack` with `StatefulShellBranch` per tab
9. For dialogs within routes, use `showDialog()` with `Navigator.of(dialogContext).pop()` (not GoRouter)

### Tab Container Screen

```dart
class TabContainerScreen extends StatelessWidget {
  const TabContainerScreen({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [/* tab items */],
      ),
    );
  }
}
```

### Router Setup in Main App

```dart
late final GoRouter _router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  observers: [
    ScreenViewObserver(analyticsService: _analyticsService),
  ],
  routes: buildRoutes(
    userRepository: _userRepository,
    remoteValueService: widget.remoteValueService,
    dynamicLinkService: _dynamicLinkService,
  ),
);

// In build()
MaterialApp.router(
  routerConfig: _router,
)
```

### Screen View Observer (GoRouter-compatible)

```dart
class ScreenViewObserver extends NavigatorObserver {
  ScreenViewObserver({required this.analyticsService});
  final AnalyticsService analyticsService;

  void _sendScreenView(PageRoute<dynamic> route) {
    final screenName = route.settings.name;
    if (screenName != null) {
      analyticsService.setCurrentScreen(screenName);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) _sendScreenView(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
```

---

## Dependency Injection

Dependencies are created and wired manually in the main app's State class. No DI framework is used.

### Initialization Order in main.dart

```dart
void main() async {
  late final errorReportingService = ErrorReportingService();

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize database
    final keyValueStorage = KeyValueStorage();
    await keyValueStorage.initIsarDB();

    // 2. Initialize Firebase
    await initializeMonitoringPackage();

    // 3. Load remote config
    final remoteValueService = RemoteValueService();
    await remoteValueService.load();

    // 4. Setup error handlers
    FlutterError.onError = errorReportingService.recordFlutterError;
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await errorReportingService.recordError(
        errorAndStacktrace.first, errorAndStacktrace.last,
      );
    }).sendPort);

    // 5. Run app
    runApp(MyApp(remoteValueService: remoteValueService));
  }, (error, stack) => errorReportingService.recordError(error, stack, fatal: true));
}
```

### Dependency Graph in App State

```dart
class _MyAppState extends State<MyApp> {
  // Layer 1: Storage & Services (no dependencies)
  final _keyValueStorage = KeyValueStorage();
  final _analyticsService = AnalyticsService();

  // Layer 2: API (depends on user repository for token)
  late final _favQsApi = FavQsApi(
    userTokenSupplier: () => _userRepository.getUserToken(),
  );

  // Layer 3: Repositories (depends on API + storage)
  late final _userRepository = UserRepository(
    remoteApi: _favQsApi,
    noSqlStorage: _keyValueStorage,
  );
  late final _quoteRepository = QuoteRepository(
    remoteApi: _favQsApi,
    keyValueStorage: _keyValueStorage,
  );

  // Layer 4: Router (depends on repositories)
  late final GoRouter _router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    observers: [ScreenViewObserver(analyticsService: _analyticsService)],
    routes: buildRoutes(
      userRepository: _userRepository,
      remoteValueService: widget.remoteValueService,
      dynamicLinkService: _dynamicLinkService,
    ),
  );
}
```

### Dependency Rules

- Dependencies from OTHER packages → require in constructor (share instances)
- Dependencies from SAME package → instantiate internally (hide details)
- Use `@visibleForTesting` optional parameter for injecting mocks in tests
- The main app package creates ALL shared instances and passes them down via constructors

---

## Localization (i18n)

### Per-Feature Localization

Each feature package manages its own translations independently.

**Required files per feature:**

```
packages/features/sign_in/
├── l10n.yaml                          # Generation config
└── lib/src/l10n/
    ├── messages_en.arb                # English translations
    ├── messages_ar.arb                # Arabic translations
    └── sign_in_localizations.dart     # Generated (DO NOT EDIT)
```

### l10n.yaml Configuration

```yaml
arb-dir: lib/src/l10n
template-arb-file: messages_en.arb
output-localization-file: sign_in_localizations.dart
output-class: SignInLocalizations
nullable-getter: false
synthetic-package: false    # REQUIRED for multi-package projects
```

### ARB File Format

```json
{
  "appBarTitle": "Sign In",
  "emailTextFieldLabel": "Email",
  "emailTextFieldEmptyErrorMessage": "Your email can't be empty.",
  "emailTextFieldInvalidErrorMessage": "This email is not valid.",
  "signInButtonLabel": "Sign In",
  "signedInUserGreeting": "Hi, {username}!",
  "@signedInUserGreeting": {
    "placeholders": {
      "username": {"type": "String"}
    }
  }
}
```

### Key Naming Rules

- Use camelCase starting with lowercase
- Name keys after WHERE they appear, not what they contain: `signInButtonLabel` (not `signIn`)
- Error messages follow pattern: `fieldNameErrorTypeMessage` (e.g., `emailTextFieldEmptyErrorMessage`)
- Same logical text used in different contexts SHOULD have separate keys (allows different translations)

### Usage in Views

```dart
@override
Widget build(BuildContext context) {
  final l10n = SignInLocalizations.of(context);

  return Scaffold(
    appBar: AppBar(title: Text(l10n.appBarTitle)),
    body: TextField(
      decoration: InputDecoration(labelText: l10n.emailTextFieldLabel),
    ),
  );
}
```

### Registering Delegates in Main App

Every feature's localization delegate must be registered in `MaterialApp`:

```dart
MaterialApp.router(
  supportedLocales: const [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ],
  localizationsDelegates: const [
    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    AppLocalizations.delegate,
    ComponentLibraryLocalizations.delegate,
    SignInLocalizations.delegate,
    SignUpLocalizations.delegate,
    ProfileMenuLocalizations.delegate,
    QuoteListLocalizations.delegate,
    // ... all feature delegates
  ],
)
```

### Generation

Run `make gen-l10n` after modifying any ARB file. This generates Dart localization classes for all packages.

---

## Theme System

### InheritedWidget-Based Theming

The theme system uses a custom `WonderTheme` InheritedWidget wrapping both light and dark theme data.

### WonderThemeData Abstract Class

```dart
abstract class WonderThemeData {
  ThemeData get materialThemeData;

  // Colors
  Color get primaryColor;
  Color get secondaryColor;
  Color get accentColor;
  Color get lightAccentColor;
  Color get lightTextColor;
  Color get quoteSvgColor;
  Color get roundedChoiceChipBackgroundColor;
  Color get roundedChoiceChipSelectedBackgroundColor;
  Color get roundedChoiceChipLabelColor;
  Color get roundedChoiceChipSelectedLabelColor;

  // Typography
  TextStyle quoteTextStyle = const TextStyle(
    fontFamily: 'Fondamento',
    package: 'component_library',
  );

  // Layout
  double get screenMargin;
  double get gridSpacing;
}
```

### Light and Dark Implementations

```dart
class LightWonderThemeData extends WonderThemeData {
  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.black.toMaterialColor(),
    useMaterial3: false,
  );

  @override
  Color get accentColor => const Color(0xff6c63ff);
  // ... light colors
}

class DarkWonderThemeData extends WonderThemeData {
  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.white.toMaterialColor(),
    useMaterial3: false,
  );

  @override
  Color get accentColor => const Color(0xffBB86FC);  // Lighter for dark backgrounds
  // ... dark colors
}
```

### WonderTheme InheritedWidget

```dart
class WonderTheme extends InheritedWidget {
  const WonderTheme({
    required super.child,
    required this.lightTheme,
    required this.darkTheme,
    super.key,
  });

  final WonderThemeData lightTheme;
  final WonderThemeData darkTheme;

  static WonderThemeData of(BuildContext context) {
    final inheritedTheme = context.dependOnInheritedWidgetOfExactType<WonderTheme>();
    assert(inheritedTheme != null, 'No WonderTheme found in context');

    final currentBrightness = Theme.of(context).brightness;
    return currentBrightness == Brightness.dark
        ? inheritedTheme!.darkTheme
        : inheritedTheme!.lightTheme;
  }

  @override
  bool updateShouldNotify(WonderTheme oldWidget) =>
      oldWidget.lightTheme != lightTheme || oldWidget.darkTheme != darkTheme;
}
```

### Theme Setup in Main App

```dart
WonderTheme(
  lightTheme: _lightTheme,
  darkTheme: _darkTheme,
  child: MaterialApp.router(
    theme: _lightTheme.materialThemeData,
    darkTheme: _darkTheme.materialThemeData,
    themeMode: darkModePreference?.toThemeMode(),
  ),
)
```

### Dark Mode Preference Persistence

```dart
enum DarkModePreference { useSystemSettings, alwaysLight, alwaysDark }

extension DarkModePreferenceToThemeMode on DarkModePreference {
  ThemeMode toThemeMode() {
    switch (this) {
      case DarkModePreference.useSystemSettings: return ThemeMode.system;
      case DarkModePreference.alwaysLight: return ThemeMode.light;
      case DarkModePreference.alwaysDark: return ThemeMode.dark;
    }
  }
}
```

User preference is persisted via `UserRepository.upsertDarkModePreference()` → Isar, and the main app listens via `StreamBuilder<DarkModePreference>`.

### Using Theme in Widgets

```dart
final theme = WonderTheme.of(context);
Container(
  color: theme.primaryColor,
  padding: EdgeInsets.all(theme.screenMargin),
  child: Text('Hello', style: theme.quoteTextStyle),
)
```

### Spacing & Typography Constants

```dart
class Spacing {
  static const double extraSmall = 4;
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double mediumLarge = 24;
  static const double extraLarge = 32;
  static const double xxLarge = 48;
}

class FontSize {
  static const double extraSmall = 10;
  static const double small = 12;
  static const double medium = 14;
  static const double large = 16;
  static const double extraLarge = 18;
  static const double xxLarge = 24;
}
```

---

## Component Library & Storybook

### Component Library Structure

```
packages/component_library/
├── lib/
│   ├── component_library.dart    # Barrel file
│   └── src/
│       ├── theme/                # WonderTheme, WonderThemeData, Spacing, FontSize
│       ├── expanded_elevated_button.dart
│       ├── favorite_icon_button.dart
│       ├── upvote_icon_button.dart
│       ├── quote_card.dart
│       ├── exception_indicator.dart
│       ├── generic_error_snack_bar.dart
│       ├── rounded_choice_chip.dart
│       ├── custom_search_bar.dart
│       └── l10n/                 # Component-level localizations
│
└── example/                      # Storybook standalone app
    └── lib/
        ├── main.dart
        ├── story_app.dart
        └── stories.dart
```

### Storybook Setup

```dart
// example/lib/story_app.dart
class StoryApp extends StatelessWidget {
  final _lightTheme = LightWonderThemeData();
  final _darkTheme = DarkWonderThemeData();

  @override
  Widget build(BuildContext context) {
    return WonderTheme(
      lightTheme: _lightTheme,
      darkTheme: _darkTheme,
      child: ComponentStorybook(
        lightThemeData: _lightTheme.materialThemeData,
        darkThemeData: _darkTheme.materialThemeData,
      ),
    );
  }
}
```

### Story Definition Pattern

```dart
List<Story> getStories(WonderThemeData theme) {
  return [
    // Simple story (no configuration)
    Story.simple(
      name: 'CenteredCircularProgressIndicator',
      section: 'Indicators',
      child: const CenteredCircularProgressIndicator(),
    ),

    // Configurable story with knobs
    Story(
      name: 'ExpandedElevatedButton',
      section: 'Buttons',
      builder: (context) => ExpandedElevatedButton(
        label: context.knobs.text(label: 'label', initial: 'Press me'),
        onTap: context.knobs.boolean(label: 'enabled', initial: true) ? () {} : null,
        icon: Icon(context.knobs.options(
          label: 'icon',
          initial: Icons.search,
          options: [
            Option('Search', Icons.search),
            Option('Add', Icons.add),
          ],
        )),
      ),
    ),
  ];
}
```

### Component Rules

- Components are reusable UI building blocks shared across features
- Components live in `component_library`, NOT in feature packages
- Components should be theme-aware (use `WonderTheme.of(context)`)
- Components should support localization via `ComponentLibraryLocalizations`
- Every new component should have a corresponding story in the storybook
- Update the storybook whenever modifying a component

---

## Firebase Monitoring (Analytics & Crashlytics)

### Package Structure

```
packages/monitoring/lib/
├── monitoring.dart                  # Public API + initialization
└── src/
    ├── analytics_service.dart       # Firebase Analytics wrapper
    ├── error_reporting_service.dart  # Firebase Crashlytics wrapper
    └── remote_value_service.dart    # Firebase Remote Config wrapper
```

### Initialization

```dart
// monitoring.dart
Future<void> initializeMonitoringPackage() =>
    Firebase.initializeApp().then((val) async {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    });
```

### Analytics Service

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> setCurrentScreen(String screenName) {
    return _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }
}
```

### Screen View Tracking via NavigatorObserver

The `ScreenViewObserver` extends `NavigatorObserver` (not a router-specific observer) and is passed to `GoRouter(observers: [...])`. Screen names come from `GoRoute(name: 'screen-name')` in the routing table. See the Routing & Navigation section for the full implementation.

### Error Reporting (Crashlytics)

```dart
class ErrorReportingService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> recordFlutterError(FlutterErrorDetails details) {
    return _crashlytics.recordFlutterError(details);
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    bool fatal = false,
  }) {
    return _crashlytics.recordError(exception, stack, fatal: fatal);
  }
}
```

### Three Error Capture Points in main.dart

```dart
void main() async {
  late final errorReportingService = ErrorReportingService();

  // 1. Zoned errors (catches async errors not caught elsewhere)
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeMonitoringPackage();

    // 2. Flutter framework errors (widget build errors, layout errors)
    FlutterError.onError = errorReportingService.recordFlutterError;

    // 3. Isolate errors (errors from other isolates)
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await errorReportingService.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);

    runApp(MyApp());
  }, (error, stack) => errorReportingService.recordError(error, stack, fatal: true));
}
```

---

## Automated Testing Patterns

### Test File Organization

```
packages/features/sign_in/
└── test/
    ├── sign_in_cubit_test.dart        # Cubit unit tests
    └── widgets/
        └── sign_in_screen_test.dart   # Widget tests

packages/quote_repository/
└── test/
    ├── quote_repository_test.dart     # Repository unit tests
    ├── mappers_test.dart              # Mapper unit tests
    └── quote_repository_test.mocks.dart  # Generated mocks (DO NOT EDIT)
```

### Cubit/Bloc Testing with bloc_test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('SignInCubit', () {
    blocTest<SignInCubit, SignInState>(
      'emits unvalidated email when email changes for the first time',
      build: () => SignInCubit(userRepository: mockUserRepository),
      act: (cubit) => cubit.onEmailChanged('test@email.com'),
      expect: () => [
        const SignInState(email: Email.unvalidated('test@email.com')),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'emits validated email when email unfocused',
      build: () => SignInCubit(userRepository: mockUserRepository),
      seed: () => const SignInState(email: Email.unvalidated('invalid')),
      act: (cubit) => cubit.onEmailUnfocused(),
      expect: () => [
        const SignInState(email: Email.validated('invalid')),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'emits success when sign in succeeds',
      build: () {
        when(() => mockUserRepository.signIn(any(), any()))
            .thenAnswer((_) async {});
        return SignInCubit(userRepository: mockUserRepository);
      },
      seed: () => const SignInState(
        email: Email.validated('test@email.com'),
        password: Password.validated('12345'),
      ),
      act: (cubit) => cubit.onSubmit(),
      expect: () => [
        isA<SignInState>().having(
          (s) => s.submissionStatus, 'status', SubmissionStatus.inProgress,
        ),
        isA<SignInState>().having(
          (s) => s.submissionStatus, 'status', SubmissionStatus.success,
        ),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'emits invalidCredentialsError when sign in throws InvalidCredentialsException',
      build: () {
        when(() => mockUserRepository.signIn(any(), any()))
            .thenThrow(InvalidCredentialsException());
        return SignInCubit(userRepository: mockUserRepository);
      },
      seed: () => const SignInState(
        email: Email.validated('test@email.com'),
        password: Password.validated('12345'),
      ),
      act: (cubit) => cubit.onSubmit(),
      expect: () => [
        isA<SignInState>().having(
          (s) => s.submissionStatus, 'status', SubmissionStatus.inProgress,
        ),
        isA<SignInState>().having(
          (s) => s.submissionStatus, 'status', SubmissionStatus.invalidCredentialsError,
        ),
      ],
    );
  });
}
```

### Repository Testing

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([FavQsApi, QuoteLocalStorage])
void main() {
  late MockFavQsApi mockApi;
  late MockQuoteLocalStorage mockStorage;
  late QuoteRepository repository;

  setUp(() {
    mockApi = MockFavQsApi();
    mockStorage = MockQuoteLocalStorage();
    repository = QuoteRepository(
      remoteApi: mockApi,
      localStorage: mockStorage,  // Inject mock via @visibleForTesting parameter
    );
  });

  group('getQuoteListPage', () {
    test('returns cached data with cachePreferably when cache exists', () async {
      when(() => mockStorage.getPage(1, false))
          .thenAnswer((_) async => cachedPageCM);

      final result = await repository.getQuoteListPage(
        1,
        fetchPolicy: QuoteListPageFetchPolicy.cachePreferably,
      ).first;

      expect(result, equals(expectedDomainPage));
      verifyNever(() => mockApi.getQuoteListPage(any()));
    });

    test('calls API with networkOnly policy', () async {
      when(() => mockApi.getQuoteListPage(1))
          .thenAnswer((_) async => apiPageRM);
      when(() => mockStorage.upsertPage(any(), any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.getQuoteListPage(
        1,
        fetchPolicy: QuoteListPageFetchPolicy.networkOnly,
      ).first;

      expect(result, equals(expectedDomainPage));
      verify(() => mockApi.getQuoteListPage(1)).called(1);
    });
  });
}
```

### Mapper Testing

```dart
void main() {
  group('QuoteCM to Domain', () {
    test('maps all fields correctly', () {
      final cachModel = QuoteCM(
        id: 1,
        body: 'Test quote',
        author: 'Author',
        isFavorite: true,
      );

      final result = cacheModel.toDomainModel();

      expect(result.id, equals(1));
      expect(result.body, equals('Test quote'));
      expect(result.author, equals('Author'));
      expect(result.isFavorite, isTrue);
    });
  });

  group('DarkModePreferenceCM to Domain', () {
    test('maps alwaysDark correctly', () {
      expect(
        DarkModePreferenceCM.alwaysDark.toDomain(),
        equals(DarkModePreference.alwaysDark),
      );
    });
  });
}
```

### Widget Testing

```dart
void main() {
  testWidgets('SignInScreen renders all form fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          SignInLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: SignInScreen(
          userRepository: MockUserRepository(),
          onSignInSuccess: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));  // Email + Password
    expect(find.byType(ExpandedElevatedButton), findsOneWidget);
  });

  testWidgets('shows error snackbar on invalid credentials', (tester) async {
    // Setup cubit to emit error state
    await tester.pumpWidget(/* ... */);
    await tester.tap(find.byType(ExpandedElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
```

### Mock Generation

Use `@GenerateMocks` annotation and run `make build-runner` to generate mock classes:

```dart
@GenerateMocks([UserRepository, FavQsApi, QuoteLocalStorage])
void main() { /* tests */ }
```

This generates `*.mocks.dart` files. NEVER edit generated mock files manually.

### Running Tests

```bash
make testing          # Run ALL tests across all packages
make test-coverage    # Run tests with coverage reports
```

---

## Authentication Architecture

### Token-Based Auth Flow

1. User submits email + password → API returns user token
2. Token stored in `flutter_secure_storage` (NOT in Isar — tokens are sensitive)
3. Token included in all subsequent API requests via `userTokenSupplier` callback
4. Token persists across app restarts

### Secure vs Regular Storage

| Data | Storage | Package |
|------|---------|---------|
| User token, credentials | `flutter_secure_storage` | user_repository (UserSecureStorage) |
| User settings, preferences | Isar (KeyValueStorage) | key_value_storage |
| Cached quotes, lists | Isar (KeyValueStorage) | key_value_storage |

### Token Supplier Pattern

The API client receives a callback to get the current token, creating a clean dependency:

```dart
// In main app State
late final _favQsApi = FavQsApi(
  userTokenSupplier: () => _userRepository.getUserToken(),
);
```

### Ephemeral vs App State

| Ephemeral State (Cubit/Bloc) | App State (Repository + BehaviorSubject) |
|------------------------------|------------------------------------------|
| Form field values | Current signed-in user |
| Loading indicators | Dark mode preference |
| Submission status | Language preference |
| Focus state | Authentication status |
| Single-screen concerns | Cross-screen concerns |

---

## Pagination

### Data Flow

1. State manager requests page N with a fetch policy
2. Repository returns `Stream<QuoteListPage>` (may emit cached then fresh)
3. `QuoteListPage` contains `quoteList` (items) and `isLastPage` (boolean)
4. State manager appends items for subsequent pages, replaces for refresh
5. UI uses `infinite_scroll_pagination` package for infinite scroll

### Pagination State in Bloc

```dart
class QuoteListState extends Equatable {
  const QuoteListState({
    this.quotes = const [],
    this.nextPage = 1,
    this.filter,
    this.searchTerm = '',
    this.isLoading = false,
    this.error,
  });

  final List<Quote> quotes;
  final int? nextPage;  // null = no more pages
  final Tag? filter;
  final String searchTerm;
  final bool isLoading;
  final dynamic error;
}
```

### Page Loading Rules

- `pageNumber == 1` → clear existing list, show loading indicator
- `pageNumber > 1` → append to existing list, show loading at bottom
- `isLastPage == true` → set `nextPage` to null, stop requesting
- Pull-to-refresh → reset to page 1 with `networkOnly` policy

---

## Creating a New Feature (Step-by-Step)

### Step 1: Use the Feature Generator Script

**IMPORTANT:** Always use the `create_feature.sh` script to scaffold new features. This saves tokens and ensures consistent structure.

```bash
chmod +x create_feature.sh   # First time only
./create_feature.sh my_feature_name   # snake_case name
```

This generates the complete feature package:
```
packages/features/my_feature_name/
├── lib/
│   ├── my_feature_name.dart              # Barrel file (exports screen + l10n)
│   └── src/
│       ├── my_feature_name_screen.dart   # Screen + View widgets with BlocProvider
│       ├── my_feature_name_cubit.dart    # Cubit with InProgress initial state
│       ├── my_feature_name_state.dart    # State classes (InProgress, Loaded, Failure)
│       └── l10n/
│           ├── messages_en.arb           # English translations
│           └── messages_ar.arb           # Arabic translations
├── l10n.yaml                             # Localization config
├── pubspec.yaml                          # Dependencies (component_library, flutter_bloc, equatable)
└── analysis_options.yaml
```

The generated pubspec.yaml already includes:
- `component_library` (path dependency)
- `flutter_bloc`, `equatable`, `intl`
- `flutter_localizations`
- dev: `flutter_test`, `mocktail`, `flutter_lints`

### Step 2: Add Repository Dependencies (if needed)

Edit `packages/features/my_feature_name/pubspec.yaml` to add repository dependencies:

```yaml
dependencies:
  # Add as needed:
  user_repository:
    path: ../../user_repository
  domain_models:
    path: ../../domain_models
```

### Step 3: Add Navigation Callbacks to Screen

Modify the generated screen to accept callbacks and repository:

```dart
class MyFeatureNameScreen extends StatelessWidget {
  const MyFeatureNameScreen({
    required this.userRepository,
    required this.onSuccess,
    this.onNavigateToOther,
    super.key,
  });

  final UserRepository userRepository;
  final VoidCallback onSuccess;
  final VoidCallback? onNavigateToOther;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyFeatureNameCubit(userRepository: userRepository),
      child: const MyFeatureNameView(),
    );
  }
}
```

### Step 4: Add Route in routing_table.dart

```dart
// Add to AppRoutes class
static const String myFeatureName = '/my-feature-name';

// Add to buildRoutes() list
GoRoute(
  path: AppRoutes.myFeatureName,
  name: 'my-feature-name',
  builder: (context, state) => MyFeatureNameScreen(
    userRepository: userRepository,
    onSuccess: () => context.pop(),
  ),
),
```

### Step 5: Register Localization Delegate in main.dart

Add `MyFeatureNameLocalizations.delegate` to the `localizationsDelegates` list.

### Step 6: Write Tests

Create `test/my_feature_name_cubit_test.dart` with `blocTest` for all state transitions.

### Step 7: Run Verification

```bash
make get          # Fetch dependencies for all packages
make gen-l10n     # Generate localization files
make lint         # Check for issues
make testing      # Run all tests
```

---

## Code Style & Conventions

- Use `const` constructors wherever possible
- All state classes extend `Equatable` with proper `props`
- Use `super.key` in widget constructors (not `Key? key`)
- Private fields use underscore prefix (`_localStorage`)
- Use `late final` for lazy initialization of dependencies
- Named parameters with `required` for non-optional dependencies
- Use extension methods for model mapping (not standalone functions)
- Font family: `'IBMPlexSansArabic'` for Arabic support
- Follow existing naming conventions in the codebase
- Keep business logic in Cubits/Blocs, NOT in widgets
- Keep data coordination in repositories, NOT in Cubits/Blocs
