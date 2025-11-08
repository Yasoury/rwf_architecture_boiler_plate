# WonderWords - Flutter Architecture Template

A production-ready Flutter application template demonstrating **Real-World Flutter** architecture patterns with clean architecture, feature packages, and comprehensive state management. Built on the foundations of the FavQs quote browsing app from "Real-World Flutter by Tutorials" by Ray Wenderlich.

## 📱 What This App Does

WonderWords is a fully functional quote browsing and management application featuring:

- 📖 **Browse Quotes** - Paginated quote list with infinite scrolling
- 🔍 **Search & Filter** - Search by keyword, filter by tags or favorites
- ⭐ **Favorites** - Save your favorite quotes (requires authentication)
- 👤 **User Management** - Sign up, sign in, profile management
- 🔗 **Deep Linking** - Share quotes via Firebase Dynamic Links
- 🌙 **Dark Mode** - Full theme support with light and dark modes
- 🌐 **Internationalization** - English and Arabic support
- 📊 **Analytics** - Firebase Analytics integration

**Note**: This is a template for learning clean architecture patterns in Flutter, not a production app ready for deployment.

---

## ✨ Key Features & Patterns

### Architecture Patterns
- **Clean Architecture** with presentation, domain, and data layers
- **Package-by-Feature** for features (quote_list, sign_in, etc.)
- **Package-by-Layer** for infrastructure (repositories, API, storage)
- **Repository Pattern** for data access abstraction
- **BLoC/Cubit** for predictable state management
- **3-Layer Exception Handling** (API → Domain → UI)

### Technical Highlights
- **Navigator 2.0** with Routemaster for declarative routing
- **Isar Database** for high-performance local caching
- **Firebase Services** (Analytics, Crashlytics, Dynamic Links, Remote Config)
- **FavQs API Integration** for quote data
- **Barrel File Pattern** for clean package exports
- **Form Validation** with Formz
- **Deep Linking** with social meta tags

---

## 📚 Comprehensive Architecture Documentation

This project includes **extensive architecture guides** in the `docs/` folder - your complete reference for implementation patterns:

### 🤖 For AI Agents (Claude Code):
Precise rules and validation checklists for AI-assisted development:
- **[Exception Handling Guide](docs/EXCEPTION_HANDLING_GUIDE_AI_AGENT.md)** - Multi-layered exception handling rules
- **[Feature Package Architecture Guide](docs/FEATURE_PACKAGE_ARCHITECTURE_GUIDE_AI_AGENT.md)** - Package organization and dependency rules
- **[Routing & Navigation Guide](docs/ROUTING_GUIDE_AI_AGENT.md)** - Routing table patterns and path management

### 👨‍💻 For Human Developers:
Comprehensive explanations with real-world examples:
- **[Exception Handling Explained](docs/EXCEPTION_HANDLING_GUIDE_HUMAN.md)** - Understanding the exception flow
- **[Package Architecture Patterns](docs/FEATURE_PACKAGE_ARCHITECTURE_GUIDE_HUMAN.md)** - Package-by-feature vs package-by-layer
- **[Navigator 2.0 with Routemaster](docs/ROUTING_GUIDE_HUMAN.md)** - Deep linking and declarative routing

### 🎯 Quick Reference:
See **[CLAUDE.md](CLAUDE.md)** for:
- Project overview and build commands
- Model architecture (Domain, Cache, Remote models)
- BLoC/Cubit state management patterns
- Form field validation patterns
- Localization guidelines
- Theme system usage

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK **3.0.5** or higher
- Dart SDK **3.0.5** or higher
- Firebase account (for Analytics, Crashlytics, Dynamic Links)
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/Yasoury/rwf_architecture_boiler_plate.git
cd rwf_architecture_boiler_plate
```

### 2. Install Dependencies

**⚠️ Important**: Always use Makefile commands instead of standard Flutter commands:

```bash
# Install all dependencies for all packages
make get

# DO NOT use: flutter pub get
# The Makefile handles all packages in the monorepo
```

### 3. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add Android and/or iOS apps to your project
3. Download and place configuration files:
   - **Android**: `google-services.json` → `android/app/`
   - **iOS**: `GoogleService-Info.plist` → `ios/Runner/` (add via Xcode)

4. Enable Firebase services:
   - **Analytics** - User behavior tracking
   - **Crashlytics** - Crash reporting
   - **Dynamic Links** - Deep linking for quote sharing
   - **Remote Config** - Feature flags (optional)

### 4. Run the App

```bash
# Clean and get dependencies (recommended for first run)
make clean
make get

# Run the app
flutter run
```

---

## 🏗️ Project Structure

```
rwf_architecture_boiler_plate/
├── lib/
│   ├── main.dart                           # App entry point
│   ├── routing_table.dart                  # All route definitions
│   ├── tab_container_screen.dart           # Tab navigation UI
│   └── screen_view_observer.dart           # Analytics tracking
│
├── packages/
│   ├── features/                           # Package-by-Feature
│   │   ├── quote_list/                     # Browse and filter quotes
│   │   ├── quote_details/                  # View, favorite, share quote
│   │   ├── sign_in/                        # User authentication
│   │   ├── sign_up/                        # User registration
│   │   ├── profile_menu/                   # User profile and settings
│   │   ├── update_profile/                 # Edit user information
│   │   └── forgot_my_password/             # Password recovery dialog
│   │
│   ├── quote_repository/                   # Quote data management
│   ├── user_repository/                    # User/auth management
│   │
│   ├── fav_qs_api/                         # FavQs API client
│   ├── key_value_storage/                  # Local preferences storage
│   │
│   ├── domain_models/                      # Shared business entities
│   ├── component_library/                  # Reusable UI components
│   ├── form_fields/                        # Form validation utilities
│   └── monitoring/                         # Firebase services
│
├── docs/                                   # Architecture guides
│   ├── EXCEPTION_HANDLING_GUIDE_AI_AGENT.md
│   ├── EXCEPTION_HANDLING_GUIDE_HUMAN.md
│   ├── FEATURE_PACKAGE_ARCHITECTURE_GUIDE_AI_AGENT.md
│   ├── FEATURE_PACKAGE_ARCHITECTURE_GUIDE_HUMAN.md
│   ├── ROUTING_GUIDE_AI_AGENT.md
│   └── ROUTING_GUIDE_HUMAN.md
│
├── CLAUDE.md                               # AI development guide
├── Makefile                                # Development commands
└── README.md                               # This file
```

---

## 🎯 Package Architecture Explained

### Package-by-Feature (Features)
Each screen gets its own package in `packages/features/`:

```
packages/features/quote_list/
├── lib/
│   ├── quote_list.dart              # Barrel file (public API)
│   └── src/                          # Private implementation
│       ├── quote_list_screen.dart    # UI
│       ├── quote_list_bloc.dart      # State management
│       ├── quote_list_state.dart     # State classes
│       ├── quote_list_event.dart     # Event classes
│       └── l10n/                     # Feature localization
├── test/
└── pubspec.yaml
```

**Key Rules**:
- ✅ Features **never import other features**
- ✅ Features communicate via **callbacks** (not direct imports)
- ✅ Each feature exports **only its screen** (BLoCs/Cubits are private)

### Package-by-Layer (Infrastructure)
Shared services and repositories:

```
packages/
├── quote_repository/        # Coordinates API + local storage
├── user_repository/         # User authentication and profile
├── fav_qs_api/             # HTTP client for FavQs API
├── key_value_storage/      # Local preferences wrapper
├── domain_models/          # Shared business entities
├── component_library/      # Reusable UI widgets
├── form_fields/            # Shared form validation
└── monitoring/             # Analytics, crashlytics, deep links
```

**See**: [Feature Package Architecture Guide](docs/FEATURE_PACKAGE_ARCHITECTURE_GUIDE_HUMAN.md) for complete details.

---

## 🛠️ Development Commands

**Always use these Makefile commands** - they handle all packages in the monorepo:

### Essential Commands

```bash
# Install dependencies for ALL packages
make get

# Upgrade dependencies
make upgrade

# Upgrade to major versions
make upgrade-major

# Clean all packages
make clean

# Run tests for ALL packages
make testing

# Run tests with coverage
make test-coverage
```

### Code Quality

```bash
# Format code
make format

# Analyze code
make lint

# Check for outdated dependencies
make outdated
```

### Code Generation

```bash
# Run build_runner (for Isar models, JSON serialization)
make build-runner

# Generate localization files
make gen-l10n

# Clean iOS pods
make pods-clean
```

### Complete Command Reference

| Command | Description | Replaces |
|---------|-------------|----------|
| `make get` | Install dependencies for all packages | `flutter pub get` |
| `make upgrade` | Upgrade dependencies | `flutter pub upgrade` |
| `make upgrade-major` | Upgrade to major versions | Manual upgrades |
| `make clean` | Clean all packages | `flutter clean` |
| `make testing` | Run tests for all packages | `flutter test` |
| `make test-coverage` | Run tests with coverage | `flutter test --coverage` |
| `make format` | Format code in all packages | `flutter format` |
| `make lint` | Analyze code in all packages | `flutter analyze` |
| `make build-runner` | Run code generation | `flutter pub run build_runner build` |
| `make gen-l10n` | Generate localization files | `flutter gen-l10n` |
| `make outdated` | Check for outdated dependencies | `flutter pub outdated` |
| `make pods-clean` | Clean iOS pods | Manual pod cleanup |

---

## 📦 Key Packages & Technologies

### State Management
- **flutter_bloc** (^8.1.5) - BLoC pattern implementation
- **equatable** (^2.0.5) - Value equality for states
- **formz** (^0.7.0) - Form validation

### Navigation
- **routemaster** (^1.0.1) - Declarative routing with Navigator 2.0
- Supports deep linking, tab navigation, and typed route parameters

### Local Storage
- **isar** (^3.1.0+1) - High-performance NoSQL database
- **isar_flutter_libs** (^3.1.0+1) - Flutter bindings
- Used for caching quotes and user data

### Networking
- **dio** (^5.4.1) - HTTP client for FavQs API
- **json_serializable** (^6.7.1) - JSON serialization

### Firebase
- **firebase_core** (^2.27.0) - Firebase initialization
- **firebase_analytics** (^10.8.9) - User analytics
- **firebase_crashlytics** (^3.4.18) - Crash reporting
- **firebase_dynamic_links** (^5.4.17) - Deep linking
- **firebase_remote_config** (^4.3.17) - Feature flags

### Localization
- **intl** (^0.19.0) - Internationalization support
- ARB files for English and Arabic translations

---

## 🏛️ Architecture Patterns

### 1. Clean Architecture Layers

```
┌─────────────────────────────────────────────────┐
│         Presentation Layer (Features)            │
│  - Screens (UI)                                  │
│  - BLoCs/Cubits (State Management)              │
│  - Widgets                                       │
└────────────────┬────────────────────────────────┘
                 │
                 ├─> Uses
                 │
┌────────────────▼────────────────────────────────┐
│            Domain Layer                          │
│  - Domain Models (Quote, User, Tag)             │
│  - Domain Exceptions                             │
│  - Business Logic Interfaces                     │
└────────────────┬────────────────────────────────┘
                 │
                 ├─> Implements
                 │
┌────────────────▼────────────────────────────────┐
│             Data Layer                           │
│  - Repositories (Quote, User)                    │
│  - API Clients (FavQs API)                      │
│  - Local Storage (Isar)                         │
│  - Cache Models (CM suffix)                     │
│  - Remote Models (RM suffix)                    │
└──────────────────────────────────────────────────┘
```

### 2. Exception Handling (3 Layers)

```
API Layer Exceptions (FavQsException suffix)
    ↓ Caught by Repository
Domain Exceptions (No suffix)
    ↓ Caught by BLoC/Cubit
UI States (SnackBar, ExceptionIndicator)
```

**Example Flow**:
1. API throws `InvalidCredentialsFavQsException` (error code 21)
2. Repository catches and throws `InvalidCredentialsException`
3. Cubit catches and updates state with `SubmissionStatus.invalidCredentialsError`
4. UI displays localized error message in SnackBar

**See**: [Exception Handling Guide](docs/EXCEPTION_HANDLING_GUIDE_HUMAN.md) for complete flow.

### 3. Repository Pattern

Repositories coordinate between API and local storage:

```dart
class QuoteRepository {
  QuoteRepository({
    required this.remoteApi,        // FavQs API client
    required this.keyValueStorage,  // Isar database
  });

  // Fetch with caching strategy
  Stream<List<Quote>> getQuotes({
    required QuoteListPageFetchPolicy policy,  // Cache vs network
  }) async* {
    // 1. Check cache (if policy allows)
    // 2. Fetch from API
    // 3. Update cache
    // 4. Transform to domain models
    // 5. Handle exceptions (API → Domain)
  }
}
```

**Fetch Policies**:
- `cacheAndNetwork` - Show cache first, then network
- `networkOnly` - Skip cache entirely
- `networkPreferably` - Try network, fallback to cache
- `cachePreferably` - Use cache, no network call

### 4. Model Architecture

**Three model types** for clean separation:

```dart
// Domain Model (no suffix) - Business logic layer
class Quote {
  final int id;
  final String body;
  final String author;
  final bool isFavorite;
}

// Cache Model (CM suffix) - Isar database
@Collection()
class QuoteCM {
  Id id = Isar.autoIncrement;
  late String body;
  late String author;
  late bool isFavorite;
}

// Remote Model (RM suffix) - API responses
@JsonSerializable()
class QuoteRM {
  final int id;
  final String body;
  final String author;
  @JsonKey(name: 'favorited') final bool isFavorite;
}
```

**Mappers** convert between model types:
```dart
extension QuoteRMToDomain on QuoteRM {
  Quote toDomainModel() => Quote(...);
}

extension QuoteRMToCM on QuoteRM {
  QuoteCM toCacheModel() => QuoteCM()..body = body..author = author;
}
```

### 5. State Management with BLoC/Cubit

**Use Cubit** for simple state:
- Form validation and submission
- Direct state changes
- Single-responsibility screens
- Examples: `sign_in`, `sign_up`, `quote_details`

**Use BLoC** for complex state:
- Event-driven architecture
- Stream transformations
- Multiple concurrent operations
- Examples: `quote_list`, `profile_menu`

**Example Cubit**:
```dart
class SignInCubit extends Cubit<SignInState> {
  SignInCubit({required this.userRepository})
    : super(const SignInState());

  final UserRepository userRepository;

  void onEmailChanged(String value) {
    final email = Email.unvalidated(value);
    emit(state.copyWith(email: email));
  }

  void onSubmit() async {
    emit(state.copyWith(status: SubmissionStatus.inProgress));

    try {
      await userRepository.signIn(
        state.email.value,
        state.password.value,
      );
      emit(state.copyWith(status: SubmissionStatus.success));
    } catch (error) {
      final status = error is InvalidCredentialsException
          ? SubmissionStatus.invalidCredentialsError
          : SubmissionStatus.genericError;
      emit(state.copyWith(status: status));
    }
  }
}
```

---

## 🌐 Internationalization (i18n)

### Supported Languages
- English (en)
- Arabic (ar)

### Adding Translations

Each feature has its own localization files:

```
packages/features/quote_list/lib/src/l10n/
├── messages_en.arb    # English translations
└── messages_ar.arb    # Arabic translations
```

**Example ARB file**:
```json
{
  "quoteListTitle": "Quotes",
  "searchHint": "Search quotes...",
  "favoriteButton": "Favorite"
}
```

### Using Translations

```dart
// In your widget
@override
Widget build(BuildContext context) {
  final l10n = QuoteListLocalizations.of(context);

  return Text(l10n.quoteListTitle);  // "Quotes"
}
```

### Generate Localizations

```bash
# After adding/modifying ARB files
make gen-l10n
```

This runs `flutter gen-l10n` for all features with localization.

---

## 🗄️ Database (Isar)

### Cache Models

All cache models use the `CM` suffix and Isar annotations:

```dart
@Collection()
class QuoteCM {
  Id id = Isar.autoIncrement;

  late String body;
  late String author;
  late bool isFavorite;

  // Lists stored as JSON strings
  late String tagsJson;

  @Index()
  late int favqsId;  // Index for fast lookups
}
```

### Writing to Isar

**Always use the transaction wrapper**:

```dart
class QuoteLocalStorage {
  final Isar _isar;

  Future<void> writeIsarTxn(Future<void> Function() function) async {
    await _isar.writeTxn(function);
  }

  Future<void> saveQuote(QuoteCM quote) async {
    await writeIsarTxn(() async {
      await _isar.quoteCMs.put(quote);
    });
  }
}
```

**Note**: The `writeIsarTxn` wrapper adds negligible overhead but provides a centralized place for error handling and logging.

### Reading from Isar

```dart
// Get by ID
Future<QuoteCM?> getQuote(int favqsId) async {
  return await _isar.quoteCMs
      .where()
      .favqsIdEqualTo(favqsId)
      .findFirst();
}

// Query with filter
Future<List<QuoteCM>> getFavoriteQuotes() async {
  return await _isar.quoteCMs
      .filter()
      .isFavoriteEqualTo(true)
      .findAll();
}
```

### Code Generation

After creating or modifying Isar models:

```bash
make build-runner
```

This generates the `*.g.dart` files required by Isar.

---

## 🧪 Testing

### Run All Tests

```bash
# Test all packages
make testing

# With coverage
make test-coverage
```

### Test Structure

```
packages/features/quote_list/
└── test/
    ├── quote_list_bloc_test.dart      # BLoC tests
    └── widgets/
        └── quote_card_test.dart        # Widget tests

packages/quote_repository/
└── test/
    └── quote_repository_test.dart      # Repository tests
```

### Example: BLoC Test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuoteRepository extends Mock implements QuoteRepository {}

void main() {
  group('QuoteListBloc', () {
    late QuoteRepository quoteRepository;

    setUp(() {
      quoteRepository = MockQuoteRepository();
    });

    blocTest<QuoteListBloc, QuoteListState>(
      'emits loaded state when quotes are fetched successfully',
      build: () => QuoteListBloc(quoteRepository: quoteRepository),
      act: (bloc) {
        when(() => quoteRepository.getQuotePage(any()))
            .thenAnswer((_) async => testQuotes);
        bloc.add(const QuoteListStarted());
      },
      expect: () => [
        const QuoteListInProgress(),
        QuoteListLoaded(quotes: testQuotes),
      ],
    );
  });
}
```

### Example: Repository Test

```dart
void main() {
  group('QuoteRepository', () {
    late FavQsApi mockApi;
    late QuoteLocalStorage mockStorage;
    late QuoteRepository repository;

    setUp(() {
      mockApi = MockFavQsApi();
      mockStorage = MockQuoteLocalStorage();
      repository = QuoteRepository(
        remoteApi: mockApi,
        localStorage: mockStorage,
      );
    });

    test('should return cached quotes when available', () async {
      // Arrange
      when(() => mockStorage.getQuotes())
          .thenAnswer((_) async => cachedQuotes);

      // Act
      final result = await repository
          .getQuotes(policy: QuoteListPageFetchPolicy.cachePreferably)
          .first;

      // Assert
      expect(result, equals(expectedQuotes));
      verify(() => mockStorage.getQuotes()).called(1);
      verifyNever(() => mockApi.getQuotes());
    });
  });
}
```

---

## 🔗 Deep Linking

### Firebase Dynamic Links Setup

1. Create a Dynamic Links prefix in Firebase Console:
   ```
   https://wonderwords1.page.link
   ```

2. Configure domain verification for Android/iOS

3. The app handles two scenarios:
   - **App opened by link**: `getInitialDynamicLinkPath()`
   - **Link received while running**: `onNewDynamicLinkPath()` stream

### Generating Shareable Links

```dart
// In routing_table.dart
_PathConstants.quoteDetailsPath(): (info) => MaterialPage(
  child: QuoteDetailsScreen(
    shareableLinkGenerator: (quote) {
      return dynamicLinkService.generateDynamicLinkUrl(
        path: '/quotes/${quote.id}',
        socialMetaTagParameters: SocialMetaTagParameters(
          title: quote.body,
          description: quote.author,
        ),
      );
    },
  ),
),
```

### Using in UI

```dart
// User taps share button
final link = await widget.shareableLinkGenerator(currentQuote);
// Returns: https://wonderwords1.page.link/xyz123

Share.share(link);  // Opens share sheet
```

**See**: [Routing Guide](docs/ROUTING_GUIDE_HUMAN.md) for complete deep linking implementation.

---

## 📱 Navigation with Routemaster

### Path Constants

All routes defined in `lib/routing_table.dart`:

```dart
class _PathConstants {
  const _PathConstants._();

  static String get tabContainerPath => '/';
  static String get quoteListPath => '${tabContainerPath}quotes';
  static String get profileMenuPath => '${tabContainerPath}user';

  // Dynamic route with parameter
  static String quoteDetailsPath({int? quoteId}) =>
      '$quoteListPath/${quoteId ?? ':id'}';
}
```

### Route Definitions

```dart
Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required QuoteRepository quoteRepository,
  required UserRepository userRepository,
}) {
  return {
    // Tab container
    _PathConstants.tabContainerPath: (_) => CupertinoTabPage(
      child: const TabContainerScreen(),
      paths: [
        _PathConstants.quoteListPath,
        _PathConstants.profileMenuPath,
      ],
    ),

    // Quote list
    _PathConstants.quoteListPath: (route) => MaterialPage(
      name: 'quotes-list',
      child: QuoteListScreen(
        quoteRepository: quoteRepository,
        onQuoteSelected: (id) {
          final navigation = routerDelegate.push<Quote?>(
            _PathConstants.quoteDetailsPath(quoteId: id),
          );
          return navigation.result;
        },
      ),
    ),

    // Quote details with path parameter
    _PathConstants.quoteDetailsPath(): (info) => MaterialPage(
      name: 'quote-details',
      child: QuoteDetailsScreen(
        quoteId: int.parse(info.pathParameters['id'] ?? '0'),
        quoteRepository: quoteRepository,
      ),
    ),
  };
}
```

### Feature Navigation (No Routemaster Import!)

Features **never import Routemaster** - they use callbacks:

```dart
// ✅ CORRECT - Feature uses callbacks
class QuoteListScreen extends StatelessWidget {
  const QuoteListScreen({
    required this.onQuoteSelected,  // Callback, not router
  });

  final Future<Quote?> Function(int id) onQuoteSelected;

  void _handleQuoteTap(Quote quote) {
    onQuoteSelected(quote.id);  // Trigger callback
  }
}
```

---

## 🎨 Theme System

### Light and Dark Themes

```dart
// Access theme
final theme = WonderTheme.of(context);

// Use theme colors
Container(
  color: theme.primaryColor,
  child: Text(
    'Hello',
    style: TextStyle(
      color: theme.onPrimaryColor,
      fontFamily: 'IBMPlexSansArabic',
    ),
  ),
)
```

### Theme Implementation

```dart
// Light theme
class LightWonderThemeData extends WonderThemeData {
  @override
  Color get primaryColor => const Color(0xFF6200EE);

  @override
  Color get onPrimaryColor => Colors.white;

  // ... more colors
}

// Dark theme
class DarkWonderThemeData extends WonderThemeData {
  @override
  Color get primaryColor => const Color(0xFFBB86FC);

  @override
  Color get onPrimaryColor => Colors.black;

  // ... more colors
}
```

---

## 🆘 Troubleshooting

### Build Errors After Cloning

```bash
# Clean and reinstall everything
make clean
make get
```

### Isar Code Generation Issues

```bash
# Regenerate Isar models
make build-runner

# If still failing, delete generated files first
find . -name "*.g.dart" -delete
make build-runner
```

### Localization Not Generated

```bash
# Generate localizations for all features
make gen-l10n

# Or for a specific feature
cd packages/features/quote_list
flutter gen-l10n
```

### Firebase Configuration

**Android**:
- Verify `google-services.json` is in `android/app/`
- Check `applicationId` in `android/app/build.gradle` matches Firebase

**iOS**:
- Ensure `GoogleService-Info.plist` is added via Xcode (not just copied)
- Verify bundle ID in Xcode matches Firebase
- Check signing configuration

### FavQs API Errors

**401 Unauthorized**:
- User not signed in (some endpoints require auth)
- Invalid credentials during sign-in
- Token expired (sign in again)

**Error Code 20**: User authentication required
**Error Code 21**: Invalid credentials
**Error Code 32**: Email or username already taken

### Dependency Conflicts

```bash
# Check dependency tree
flutter pub deps

# Force upgrade
make upgrade

# If problems persist
make clean
rm -rf ~/.pub-cache
make get
```

### iOS Pod Issues

```bash
# Clean pods
make pods-clean

# Or manually
cd ios
rm -rf Pods Podfile.lock
pod install
```

---

## 📝 Best Practices

### Architecture
1. ✅ **Follow clean architecture layers** - Keep presentation, domain, and data separate
2. ✅ **Use repository pattern** - Never call API directly from features
3. ✅ **Transform exceptions** - API exceptions → Domain exceptions → UI states
4. ✅ **Features don't import features** - Use callbacks for navigation

### Code Organization
5. ✅ **Package-by-feature for screens** - Each feature gets its own package
6. ✅ **Barrel files for public API** - Export only what's needed
7. ✅ **Keep state management private** - Don't export BLoCs/Cubits

### State Management
8. ✅ **Use Cubit for simple state** - Forms, simple screens
9. ✅ **Use BLoC for complex state** - Event streams, complex logic
10. ✅ **Always handle errors** - Catch domain exceptions, show user feedback

### Data Management
11. ✅ **Use model suffixes** - Domain (no suffix), Cache (CM), Remote (RM)
12. ✅ **Cache strategically** - Use fetch policies for cache vs network
13. ✅ **Use Isar transactions** - Wrap writes in `writeIsarTxn`

### Development Workflow
14. ✅ **Always use Makefile commands** - Never use `flutter pub get` directly
15. ✅ **Run tests before committing** - `make testing`
16. ✅ **Generate code after model changes** - `make build-runner`
17. ✅ **Keep localization updated** - `make gen-l10n` after ARB changes

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-feature`
3. Follow the architecture patterns documented in `docs/`
4. Write tests for your changes
5. Run tests: `make testing`
6. Format code: `make format`
7. Commit your changes: `git commit -am 'Add some feature'`
8. Push to the branch: `git push origin feature/my-feature`
9. Submit a pull request

### Code Review Checklist

Before submitting PR, verify:
- [ ] All tests pass (`make testing`)
- [ ] Code is formatted (`make format`)
- [ ] No analysis issues (`make lint`)
- [ ] Exception handling follows 3-layer pattern
- [ ] Features use callbacks (no Routemaster imports)
- [ ] Models use correct suffixes (CM, RM)
- [ ] BLoCs/Cubits are not exported
- [ ] Localization files are up to date

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Based on**: "Real-World Flutter by Tutorials" by Ray Wenderlich
- **Architecture**: Clean Architecture principles
- **API**: FavQs API for quote data
- **Firebase**: Analytics, Crashlytics, Dynamic Links

---

## 📞 Support

- 📖 **Architecture Guides**: See `docs/` folder
- 🤖 **AI Development**: Check `CLAUDE.md`
- 🐛 **Issues**: [GitHub Issues](https://github.com/Yasoury/rwf_architecture_boiler_plate/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/Yasoury/rwf_architecture_boiler_plate/discussions)

---

**Happy coding! 🚀**

This template is designed for **learning clean architecture patterns** in Flutter. Study the code, explore the documentation, and build amazing apps!
