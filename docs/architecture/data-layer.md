# Data Layer: Models, Mappers, Isar & Repositories

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

The project uses Isar (via `isar_community` package) for local database operations.

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
