# Authentication Architecture

## Token-Based Auth Flow

1. User submits email + password → API returns user token
2. Token stored in `flutter_secure_storage` (NOT in Isar — tokens are sensitive)
3. Token included in all subsequent API requests via `userTokenSupplier` callback
4. Token persists across app restarts

## Secure vs Regular Storage

| Data | Storage | Package |
|------|---------|---------|
| User token, credentials | `flutter_secure_storage` | user_repository (UserSecureStorage) |
| User settings, preferences | Isar (KeyValueStorage) | key_value_storage |
| Cached quotes, lists | Isar (KeyValueStorage) | key_value_storage |

## Token Supplier Pattern

The API client receives a callback to get the current token, creating a clean dependency:

```dart
// In main app State
late final _favQsApi = FavQsApi(
  userTokenSupplier: () => _userRepository.getUserToken(),
);
```

## Dependency Injection Setup

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
}
```

## Dependency Rules

- Dependencies from OTHER packages → require in constructor (share instances)
- Dependencies from SAME package → instantiate internally (hide details)
- Use `@visibleForTesting` optional parameter for injecting mocks in tests
- The main app package creates ALL shared instances and passes them down via constructors

## Ephemeral vs App State

| Ephemeral State (Cubit/Bloc) | App State (Repository + BehaviorSubject) |
|------------------------------|------------------------------------------|
| Form field values | Current signed-in user |
| Loading indicators | Dark mode preference |
| Submission status | Language preference |
| Focus state | Authentication status |
| Single-screen concerns | Cross-screen concerns |
