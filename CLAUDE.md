# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter template project based on "Real-World Flutter by Tutorials" book principles, implementing Clean Architecture with presentation, domain, and data layers. The project follows a modular package-based structure with features and shared components.

## Architecture Principles

- **Clean Architecture**: Maintain strict separation between presentation, domain, and data layers
- **State Management**: Use Bloc/Cubit for state management
- **Local Storage**: Isar for database operations, key_value_storage for user settings
- **Modular Design**: Feature-based packages in `packages/features/`
- **Repository Pattern**: Implement repositories for data access abstraction

## Build Commands

Use the Makefile for all development tasks:

- `make get` - Install dependencies for all packages
- `make upgrade` - Upgrade dependencies for all packages
- `make upgrade-major` - Upgrade to major versions
- `make lint` - Run Flutter analyze
- `make format` - Format code
- `make testing` - Run tests for all packages
- `make test-coverage` - Run tests with coverage
- `make clean` - Clean all packages
- `make build-runner` - Run build_runner for code generation
- `make gen-l10n` - Generate localization files
- `make outdated` - Check for outdated dependencies
- `make pods-clean` - Clean iOS pods

## Project Structure

```
packages/
├── features/           # Feature modules (sign_in, sign_up, profile_menu, etc.)
├── component_library/  # Shared UI components
├── domain_models/      # Domain entities and business logic
├── key_value_storage/  # Local storage abstraction
├── monitoring/         # Analytics, error reporting, remote config
├── fav_qs_api/        # API client and remote models
├── quote_repository/   # Quote data access
├── user_repository/    # User data access
└── form_fields/       # Form validation utilities
```

## Model Architecture

### Model Types:
- **Domain Models**: Core business entities (suffix: no suffix)
- **Cache Models**: Local storage entities (suffix: `CM`)
- **Remote Models**: API response/request entities (suffix: `RM`)

### Model Mappers
When creating model mappers, generate extensions for both individual models and lists:

```dart
extension ModelNameToCM on ModelName {
  ModelNameCM toCacheModel() { ... }
}

extension ModelNameListToCM on List<ModelName> {
  List<ModelNameCM> toCacheModel() { ... }
}
```

## Localization Guidelines

- Generate l10n files using `make gen-l10n`
- Provide translations in English and Arabic
- Use camelCase keys starting with lowercase
- Implement l10n in views like: `final l10n = ViewNameLocalizations.of(context);`
- Store localization files in each feature's `lib/src/l10n/` directory

### Translation JSON Format:
```json
{
  "keyName": "Translation text",
  "anotherKey": "More text"
}
```

## Theme System

- Use `WonderThemeData` abstract class for theme definitions
- Implement both `LightWonderThemeData` and `DarkWonderThemeData`
- Access theme via `WonderTheme.of(context)`
- Font family: 'IBMPlexSansArabic'

## Code Generation

Run `make build-runner` after:
- Adding new cache models with Isar annotations
- Modifying API models with json_serializable
- Changes to any `@JsonSerializable` or Isar collection classes

## Dependencies Management

- **Always** use `make get` instead of `flutter pub get`
- **Always** use `make upgrade` instead of `flutter pub upgrade`
- These commands handle dependencies for all packages in the monorepo

## Testing

- Run `make testing` to test all packages
- Use `make test-coverage` for coverage reports
- Follow the testing patterns established in existing test files
- Mock dependencies using mockito for repository and service tests

## Package Dependencies

Core packages used across the template:
- `flutter_bloc` - State management
- `isar` - Local database
- `routemaster` - Navigation
- `equatable` - Value equality
- `json_serializable` - JSON serialization
- `build_runner` - Code generation

## Key Services

- **KeyValueStorage**: User preferences and simple data storage
- **Monitoring**: Analytics, error reporting, remote configuration
- **Repositories**: Data access abstraction following repository pattern
- **API Clients**: RESTful API communication with proper error handling

## Bloc/Cubit State Management Patterns

### When to Use Bloc vs Cubit

- **Use Cubit** for simple state management with direct method calls:
  - Form validation and submission
  - Simple data transformations
  - Single-responsibility screens
  
- **Use Bloc** for complex state management with events:
  - Reactive state that depends on multiple streams
  - Complex business logic requiring event-driven architecture
  - Managing multiple concurrent operations

### Cubit Implementation Pattern

```dart
class FeatureCubit extends Cubit<FeatureState> {
  FeatureCubit({
    required this.repository,
  }) : super(const FeatureState());

  final Repository repository;

  void onMethodName(String value) {
    final previousState = state;
    final newState = previousState.copyWith(
      field: processValue(value),
    );
    emit(newState);
  }

  void onSubmit() async {
    emit(state.copyWith(submissionStatus: SubmissionStatus.inProgress));
    
    try {
      await repository.performAction(state.data);
      emit(state.copyWith(submissionStatus: SubmissionStatus.success));
    } catch (error) {
      emit(state.copyWith(submissionStatus: SubmissionStatus.genericError));
    }
  }
}
```

### State Class Pattern

All state classes must extend `Equatable` and follow this structure:

```dart
class FeatureState extends Equatable {
  const FeatureState({
    this.field = const DefaultValue(),
    this.submissionStatus = SubmissionStatus.idle,
  });

  final FieldType field;
  final SubmissionStatus submissionStatus;

  FeatureState copyWith({
    FieldType? field,
    SubmissionStatus? submissionStatus,
  }) {
    return FeatureState(
      field: field ?? this.field,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }

  @override
  List<Object?> get props => [field, submissionStatus];
}
```

### Bloc Implementation Pattern

```dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  FeatureBloc({
    required this.repository,
  }) : super(const FeatureInProgress()) {
    
    on<FeatureStarted>((_, emit) async {
      await emit.onEach(
        repository.getDataStream(),
        onData: (data) => FeatureLoaded(data: data),
      );
    });

    on<FeatureActionRequested>((event, emit) async {
      // Handle specific events
      await repository.performAction(event.data);
    });

    add(const FeatureStarted());
  }

  final Repository repository;
}
```

## Form Field Validation Patterns

### Form Field Structure

All form fields extend `FormzInput` and follow this pattern:

```dart
class FieldName extends FormzInput<String, FieldValidationError> with EquatableMixin {
  const FieldName.unvalidated([super.value = '']) : super.pure();
  const FieldName.validated(super.value) : super.dirty();

  @override
  FieldValidationError? validator(String value) {
    if (value.isEmpty) return FieldValidationError.empty;
    if (/* custom validation */) return FieldValidationError.invalid;
    return null;
  }

  @override
  List<Object?> get props => [value, isPure];
}

enum FieldValidationError { empty, invalid }
```

### Form State Management in Cubits

**Field Change Handling:**
```dart
void onFieldChanged(String newValue) {
  final previousState = state;
  final previousFieldState = previousState.field;
  
  // Only validate if field was previously invalid and not pure
  final shouldValidate = previousFieldState.isNotValid && !previousFieldState.isPure;
  
  final newFieldState = shouldValidate
      ? FieldName.validated(newValue)
      : FieldName.unvalidated(newValue);

  emit(state.copyWith(field: newFieldState));
}
```

**Field Unfocus Handling:**
```dart
void onFieldUnfocused() {
  final previousFieldValue = state.field.value;
  final newFieldState = FieldName.validated(previousFieldValue);
  emit(state.copyWith(field: newFieldState));
}
```

**Form Submission:**
```dart
void onSubmit() async {
  // Validate all fields
  final field1 = Field1.validated(state.field1.value);
  final field2 = Field2.validated(state.field2.value);
  
  final isFormValid = Formz.validate([field1, field2]);
  
  final newState = state.copyWith(
    field1: field1,
    field2: field2,
    submissionStatus: isFormValid ? SubmissionStatus.inProgress : null,
  );
  
  emit(newState);
  
  if (isFormValid) {
    try {
      await repository.submitData(field1.value, field2.value);
      emit(state.copyWith(submissionStatus: SubmissionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        submissionStatus: error is SpecificException 
            ? SubmissionStatus.specificError 
            : SubmissionStatus.genericError,
      ));
    }
  }
}
```

### UI Integration with Forms

**BlocProvider Setup:**
```dart
BlocProvider<FeatureCubit>(
  create: (_) => FeatureCubit(repository: repository),
  child: FeatureView(),
)
```

**Form Field Integration:**
```dart
final _fieldFocusNode = FocusNode();

@override
void initState() {
  super.initState();
  final cubit = context.read<FeatureCubit>();
  _fieldFocusNode.addListener(() {
    if (!_fieldFocusNode.hasFocus) {
      cubit.onFieldUnfocused();
    }
  });
}

// In build method
TextField(
  focusNode: _fieldFocusNode,
  onChanged: cubit.onFieldChanged,
  decoration: InputDecoration(
    enabled: !isSubmissionInProgress,
    labelText: l10n.fieldLabel,
    errorText: fieldError == null ? null : getErrorMessage(fieldError),
  ),
)
```

**BlocConsumer for State Management:**
```dart
BlocConsumer<FeatureCubit, FeatureState>(
  listenWhen: (oldState, newState) =>
      oldState.submissionStatus != newState.submissionStatus,
  listener: (context, state) {
    if (state.submissionStatus == SubmissionStatus.success) {
      onSuccess();
    } else if (state.submissionStatus.isError) {
      showErrorSnackBar(context, state.submissionStatus);
    }
  },
  builder: (context, state) {
    final fieldError = state.field.isValid || state.field.isPure 
        ? null 
        : state.field.error;
    // Build UI based on state
  },
)
```

### SubmissionStatus Pattern

Always use this enum for form submission states:

```dart
enum SubmissionStatus {
  idle,           // Form not submitted yet
  inProgress,     // Show loading state
  success,        // Navigate or show success
  genericError,   // Show generic error snackbar
  specificError,  // Show specific error message
}
```

## Navigation and Routing Patterns

### Routemaster Implementation

The project uses **Routemaster** for declarative routing. Navigation is centralized in `routing_table.dart`:

**Routing Table Structure:**
```dart
Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required UserRepository userRepository,
  required QuoteRepository quoteRepository,
  // ... other dependencies
}) {
  return {
    _PathConstants.signInPath: (_) => MaterialPage(
      name: 'sign-in',
      fullscreenDialog: true,
      child: SignInScreen(
        userRepository: userRepository,
        onSignInSuccess: () => routerDelegate.pop(),
        onSignUpTap: () => routerDelegate.push(_PathConstants.signUpPath),
      ),
    ),
  };
}
```

**Path Constants Pattern:**
```dart
class _PathConstants {
  const _PathConstants._();
  
  static String get tabContainerPath => '/';
  static String get signInPath => '${tabContainerPath}sign-in';
  
  // Parameterized routes
  static String quoteDetailsPath({int? quoteId}) =>
      '$quoteListPath/${quoteId ?? ':$idPathParameter'}';
}
```

**Tab-Based Navigation:**
- Use `CupertinoTabPage` for tab container screens
- Define tab paths in routing table
- Tab state managed by Routemaster automatically

**Navigation Callbacks:**
- Always use callbacks (`onSuccess`, `onTap`) instead of direct navigation in screens
- Pass `routerDelegate` reference for navigation actions
- Use `routerDelegate.push()` for forward navigation
- Use `routerDelegate.pop()` to go back

## Repository and Data Layer Patterns

### Repository Architecture

Repositories act as the single source of truth, managing both local cache and remote API:

**Repository Structure:**
```dart
class DataRepository {
  DataRepository({
    required KeyValueStorage keyValueStorage,
    required this.remoteApi,
    @visibleForTesting DataLocalStorage? localStorage,
  }) : _localStorage = localStorage ?? DataLocalStorage(keyValueStorage: keyValueStorage);

  final RemoteApi remoteApi;
  final DataLocalStorage _localStorage;
  
  // Implementation follows cache-first or network-first strategies
}
```

### Fetch Policy Pattern

Use enum-based fetch policies for flexible data loading:

```dart
enum DataFetchPolicy {
  cacheAndNetwork,    // Show cache first, then network
  networkOnly,        // Skip cache entirely
  networkPreferably,  // Network first, fallback to cache
  cachePreferably,    // Cache first, no network call
}
```

**Stream-Based Data Flow:**
```dart
Stream<DataModel> getData(FetchPolicy policy) async* {
  if (shouldCheckCache) {
    final cached = await _localStorage.getData();
    if (cached != null) yield cached.toDomainModel();
  }
  
  try {
    final fresh = await remoteApi.getData();
    await _localStorage.upsertData(fresh.toCacheModel());
    yield fresh.toDomainModel();
  } catch (error) {
    if (hasCachedFallback) yield cachedData.toDomainModel();
    rethrow;
  }
}
```

### Model Mapping Extensions

**Consistent Extension Naming:**
- `RemoteModelToDomain` - Remote to Domain
- `DomainModelToCM` - Domain to Cache
- `CacheModelToDomain` - Cache to Domain
- `DomainModelToRemote` - Domain to Remote

**List Mapping Extensions:**
```dart
extension DataModelListToDomain on List<DataModelCM> {
  List<DataModel> toDomainModel() {
    return map((item) => item.toDomainModel()).toList();
  }
}
```

## Error Handling and Exception Patterns

### Custom Exception Hierarchy

All domain exceptions are simple classes implementing `Exception`:

```dart
class SpecificException implements Exception {}
class UserAuthenticationRequiredException implements Exception {}
class InvalidCredentialsException implements Exception {}
```

### Exception Translation Pattern

Repositories translate API exceptions to domain exceptions:

```dart
try {
  await remoteApi.performAction();
} on ApiSpecificException {
  throw DomainSpecificException();
} catch (error) {
  rethrow; // Let generic errors pass through
}
```

**Extension Pattern for Exception Handling:**
```dart
extension on Future<RemoteModel> {
  Future<CacheModel> toCacheUpdateFuture(LocalStorage storage) async {
    try {
      final result = await this;
      await storage.update(result.toCacheModel());
      return result.toCacheModel();
    } catch (error) {
      if (error is SpecificApiException) {
        throw SpecificDomainException();
      }
      rethrow;
    }
  }
}
```

## Localization Implementation Patterns

### Feature-Level Localization

Each feature package has its own localization:
- `l10n.yaml` configuration file
- `lib/src/l10n/` directory with ARB files
- Generated localizations class per feature

**l10n.yaml Configuration:**
```yaml
arb-dir: lib/src/l10n
template-arb-file: messages_en.arb
output-localization-file: feature_localizations.dart
output-class: FeatureLocalizations
```

**ARB File Structure (English/Arabic):**
- Keys use camelCase starting with lowercase
- Consistent key naming across features
- Error messages follow pattern: `fieldNameErrorMessage`

**Usage Pattern in Views:**
```dart
@override
Widget build(BuildContext context) {
  final l10n = FeatureLocalizations.of(context);
  
  return Text(l10n.welcomeMessage);
}
```

## Testing Patterns

### Cubit/Bloc Testing

Use `bloc_test` package for state management testing:

```dart
blocTest<FeatureCubit, FeatureState>(
  'Description of behavior being tested',
  build: () => FeatureCubit(repository: MockRepository()),
  act: (cubit) => cubit.onAction('input'),
  expect: () => [
    const FeatureState(field: ExpectedValue()),
  ],
);
```

### Repository Testing

Use `mockito` with generated mocks:

```dart
@GenerateMocks([RemoteApi, LocalStorage])
void main() {
  final mockApi = MockRemoteApi();
  final mockStorage = MockLocalStorage();
  
  test('should return cached data when available', () async {
    when(mockStorage.getData()).thenAnswer((_) async => cachedData);
    
    final result = await repository.getData();
    
    expect(result, expectedData);
    verify(mockStorage.getData()).called(1);
  });
}
```

## Dependency Injection Pattern

### Manual DI in Main Widget State

Dependencies are created and managed in the main widget state:

```dart
class AppWidgetState extends State<AppWidget> {
  final _keyValueStorage = KeyValueStorage();
  final _analyticsService = AnalyticsService();
  
  late final _remoteApi = RemoteApi(
    userTokenSupplier: () => _userRepository.getUserToken(),
  );
  
  late final _userRepository = UserRepository(
    remoteApi: _remoteApi,
    noSqlStorage: _keyValueStorage,
  );
  
  // Dependencies passed down through constructors
}
```

### Service Initialization

**Monitoring Services Setup:**
```dart
void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeMonitoringPackage();
    
    final errorReportingService = ErrorReportingService();
    FlutterError.onError = errorReportingService.recordFlutterError;
    
    runApp(MainApp());
  }, (error, stack) => errorReportingService.recordError(error, stack));
}
```

## Code Style

- Use clean architecture principles from the book
- Maintain strict layer separation
- Follow established naming conventions in existing code
- Implement proper error handling with custom exceptions
- Use extension methods for model mapping
- Keep business logic in domain layer, UI logic in presentation layer