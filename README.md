# Flutter Clean Architecture Boilerplate

A production-ready Flutter boilerplate template implementing **Real-World Flutter** architecture patterns with clean architecture, feature-based packages, and comprehensive state management. This template provides a solid foundation for building scalable Flutter applications with authentication, onboarding, and user profile management.

**Based on**: "Real-World Flutter by Tutorials" by Ray Wenderlich - extracted from the full application as a clean starting point for new projects.

## 📱 What This Template Provides

This is a **ready-to-use authentication boilerplate** featuring:

- 🔐 **Authentication Flow** - Sign in, sign up, password recovery
- 🎯 **Onboarding** - First-time user experience
- 👤 **User Profile** - Profile menu and profile update screens
- ⚙️ **User Preferences** - Settings and preferences management
- 🚀 **Splash Screen** - App initialization
- 🎨 **Theme System** - Light and dark mode support
- 🌐 **Internationalization** - English and Arabic localization
- 🔥 **Firebase Integration** - Analytics, Crashlytics, Remote Config
- 🗄️ **Isar Database** - High-performance local storage
- 🧭 **Navigator 2.0** - Declarative routing with Routemaster

**Purpose**: Clone this template and add your own feature packages (e.g., tasks, posts, products) following the established clean architecture patterns.

---

## ✨ Key Features & Patterns

### Architecture Patterns
- **Clean Architecture** with presentation, domain, and data layers
- **Package-by-Feature** for features (sign_in, profile_menu, etc.)
- **Package-by-Layer** for infrastructure (repositories, API, storage)
- **Repository Pattern** for data access abstraction
- **BLoC/Cubit** for predictable state management
- **3-Layer Exception Handling** (API → Domain → UI)

### Technical Highlights
- **Navigator 2.0** with Routemaster for declarative routing
- **Isar Database** for high-performance local caching
- **Firebase Services** (Analytics, Crashlytics, Remote Config)
- **Barrel File Pattern** for clean package exports
- **Form Validation** with Formz
- **Modular Package Structure** - Easy to add new features

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
- Firebase account (for Analytics, Crashlytics, Remote Config)
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
│   │   ├── sign_in/                        # User sign in
│   │   ├── sign_up/                        # User registration
│   │   ├── forgot_my_password/             # Password recovery
│   │   ├── on_boarding/                    # First-time user flow
│   │   ├── splash/                         # App initialization
│   │   ├── profile_menu/                   # User profile and settings
│   │   ├── update_profile/                 # Edit user information
│   │   └── user_preferences/               # App preferences
│   │
│   ├── user_repository/                    # User/auth management
│   │
│   ├── firebase_api/                       # Firebase API client
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
packages/features/sign_in/
├── lib/
│   ├── sign_in.dart                  # Barrel file (public API)
│   └── src/                          # Private implementation
│       ├── sign_in_screen.dart       # UI
│       ├── sign_in_cubit.dart        # State management
│       ├── sign_in_state.dart        # State classes
│       └── l10n/                     # Feature localization
│           ├── messages_en.arb
│           └── messages_ar.arb
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
├── user_repository/         # User authentication and profile data
├── firebase_api/            # Firebase authentication client
├── key_value_storage/       # Local preferences wrapper
├── domain_models/           # Shared business entities (User, etc.)
├── component_library/       # Reusable UI widgets
├── form_fields/             # Shared form validation
└── monitoring/              # Analytics, crashlytics, remote config
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
- Used for caching user data and app state

### Networking
- **dio** (^5.4.1) - HTTP client for API communication
- **json_serializable** (^6.7.1) - JSON serialization

### Firebase
- **firebase_core** (^2.27.0) - Firebase initialization
- **firebase_analytics** (^10.8.9) - User analytics
- **firebase_crashlytics** (^3.4.18) - Crash reporting
- **firebase_auth** - User authentication
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
│  - Domain Models (User, etc.)                   │
│  - Domain Exceptions                             │
│  - Business Logic Interfaces                     │
└────────────────┬────────────────────────────────┘
                 │
                 ├─> Implements
                 │
┌────────────────▼────────────────────────────────┐
│             Data Layer                           │
│  - Repositories (User Repository)                │
│  - API Clients (Firebase API)                   │
│  - Local Storage (Isar)                         │
│  - Cache Models (CM suffix)                     │
│  - Remote Models (RM suffix)                    │
└──────────────────────────────────────────────────┘
```

### 2. Exception Handling (3 Layers)

```
API Layer Exceptions (e.g., FirebaseException)
    ↓ Caught by Repository
Domain Exceptions (e.g., InvalidCredentialsException)
    ↓ Caught by BLoC/Cubit
UI States (SnackBar, Error Messages)
```

**Example Flow**:
1. API throws Firebase authentication error
2. Repository catches and throws `InvalidCredentialsException`
3. Cubit catches and updates state with `SubmissionStatus.invalidCredentialsError`
4. UI displays localized error message in SnackBar

**See**: [Exception Handling Guide](docs/EXCEPTION_HANDLING_GUIDE_HUMAN.md) for complete flow.

### 3. Repository Pattern

Repositories coordinate between API and local storage:

```dart
class UserRepository {
  UserRepository({
    required this.remoteApi,        // Firebase API client
    required this.keyValueStorage,  // Isar database
  });

  // Authentication
  Future<User> signIn(String email, String password) async {
    try {
      final response = await remoteApi.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cache user data
      await _localStorage.upsertUser(response.user.toCacheModel());

      return response.user.toDomainModel();
    } on InvalidCredentialsFirebaseException {
      throw InvalidCredentialsException();
    } catch (error) {
      rethrow;
    }
  }
}
```

**Key Responsibilities**:
- Transform API exceptions to domain exceptions
- Coordinate between remote API and local cache
- Provide clean domain models to presentation layer

### 4. Model Architecture

**Three model types** for clean separation:

```dart
// Domain Model (no suffix) - Business logic layer
class User {
  final String id;
  final String email;
  final String username;
  final String? profilePictureUrl;
}

// Cache Model (CM suffix) - Isar database
@Collection()
class UserCM {
  Id id = Isar.autoIncrement;
  late String userId;
  late String email;
  late String username;
  String? profilePictureUrl;
}

// Remote Model (RM suffix) - API responses
@JsonSerializable()
class UserRM {
  final String id;
  final String email;
  final String username;
  @JsonKey(name: 'profile_picture') final String? profilePictureUrl;
}
```

**Mappers** convert between model types:
```dart
extension UserRMToDomain on UserRM {
  User toDomainModel() => User(
    id: id,
    email: email,
    username: username,
    profilePictureUrl: profilePictureUrl,
  );
}

extension UserRMToCM on UserRM {
  UserCM toCacheModel() => UserCM()
    ..userId = id
    ..email = email
    ..username = username
    ..profilePictureUrl = profilePictureUrl;
}
```

### 5. State Management with BLoC/Cubit

**Use Cubit** for simple state:
- Form validation and submission
- Direct state changes
- Single-responsibility screens
- Examples: `sign_in`, `sign_up`, `update_profile`

**Use BLoC** for complex state:
- Event-driven architecture
- Stream transformations
- Multiple concurrent operations
- Examples: `profile_menu`, user session management

**Example Cubit**:
```dart
class SignInCubit extends Cubit<SignInState> {
  SignInCubit({required this.userRepository})
    : super(const SignInState());

  final UserRepository userRepository;

  void onEmailChanged(String value) {
    final previousState = state;
    final previousEmailState = previousState.email;

    final shouldValidate = previousEmailState.isNotValid &&
                          !previousEmailState.isPure;

    final newEmailState = shouldValidate
        ? Email.validated(value)
        : Email.unvalidated(value);

    emit(state.copyWith(email: newEmailState));
  }

  void onEmailUnfocused() {
    final previousEmailValue = state.email.value;
    final newEmailState = Email.validated(previousEmailValue);
    emit(state.copyWith(email: newEmailState));
  }

  void onSubmit() async {
    final email = Email.validated(state.email.value);
    final password = Password.validated(state.password.value);

    final isFormValid = Formz.validate([email, password]);

    final newState = state.copyWith(
      email: email,
      password: password,
      submissionStatus: isFormValid
          ? SubmissionStatus.inProgress
          : null,
    );

    emit(newState);

    if (isFormValid) {
      try {
        await userRepository.signIn(
          email.value,
          password.value,
        );
        emit(state.copyWith(submissionStatus: SubmissionStatus.success));
      } catch (error) {
        final status = error is InvalidCredentialsException
            ? SubmissionStatus.invalidCredentialsError
            : SubmissionStatus.genericError;
        emit(state.copyWith(submissionStatus: status));
      }
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
packages/features/sign_in/lib/src/l10n/
├── messages_en.arb    # English translations
└── messages_ar.arb    # Arabic translations
```

**Example ARB file**:
```json
{
  "signInTitle": "Sign In",
  "emailLabel": "Email",
  "passwordLabel": "Password",
  "signInButton": "Sign In",
  "invalidCredentialsError": "Invalid email or password"
}
```

### Using Translations

```dart
// In your widget
@override
Widget build(BuildContext context) {
  final l10n = SignInLocalizations.of(context);

  return Text(l10n.signInTitle);  // "Sign In"
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
class UserCM {
  Id id = Isar.autoIncrement;

  late String userId;
  late String email;
  late String username;

  String? profilePictureUrl;

  @Index()
  late String userIdIndex;  // Index for fast lookups
}
```

### Writing to Isar

**Always use the transaction wrapper**:

```dart
class UserLocalStorage {
  final Isar _isar;

  Future<void> writeIsarTxn(Future<void> Function() function) async {
    await _isar.writeTxn(function);
  }

  Future<void> saveUser(UserCM user) async {
    await writeIsarTxn(() async {
      await _isar.userCMs.put(user);
    });
  }
}
```

**Note**: The `writeIsarTxn` wrapper adds negligible overhead but provides a centralized place for error handling and logging.

### Reading from Isar

```dart
// Get by ID
Future<UserCM?> getUser(String userId) async {
  return await _isar.userCMs
      .where()
      .userIdIndexEqualTo(userId)
      .findFirst();
}

// Get current user
Future<UserCM?> getCurrentUser() async {
  return await _isar.userCMs
      .where()
      .findFirst();
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
packages/features/sign_in/
└── test/
    ├── sign_in_cubit_test.dart        # Cubit tests
    └── widgets/
        └── email_field_test.dart       # Widget tests

packages/user_repository/
└── test/
    └── user_repository_test.dart       # Repository tests
```

### Example: Cubit Test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('SignInCubit', () {
    late UserRepository userRepository;

    setUp(() {
      userRepository = MockUserRepository();
    });

    blocTest<SignInCubit, SignInState>(
      'emits success when sign in succeeds',
      build: () => SignInCubit(userRepository: userRepository),
      act: (cubit) {
        when(() => userRepository.signIn(any(), any()))
            .thenAnswer((_) async => testUser);
        cubit.onSubmit();
      },
      expect: () => [
        SignInState(
          email: Email.validated('test@example.com'),
          password: Password.validated('password123'),
          submissionStatus: SubmissionStatus.inProgress,
        ),
        SignInState(
          email: Email.validated('test@example.com'),
          password: Password.validated('password123'),
          submissionStatus: SubmissionStatus.success,
        ),
      ],
    );
  });
}
```

### Example: Repository Test

```dart
void main() {
  group('UserRepository', () {
    late FirebaseApi mockApi;
    late UserLocalStorage mockStorage;
    late UserRepository repository;

    setUp(() {
      mockApi = MockFirebaseApi();
      mockStorage = MockUserLocalStorage();
      repository = UserRepository(
        remoteApi: mockApi,
        localStorage: mockStorage,
      );
    });

    test('should sign in user successfully', () async {
      // Arrange
      when(() => mockApi.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => signInResponse);

      when(() => mockStorage.upsertUser(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.signIn(
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result, equals(expectedUser));
      verify(() => mockStorage.upsertUser(any())).called(1);
    });
  });
}
```

---

## 📱 Navigation with Routemaster

### Path Constants

All routes defined in `lib/routing_table.dart`:

```dart
class _PathConstants {
  const _PathConstants._();

  static String get tabContainerPath => '/';
  static String get signInPath => '${tabContainerPath}sign-in';
  static String get signUpPath => '${tabContainerPath}sign-up';
  static String get profileMenuPath => '${tabContainerPath}profile';
  static String get updateProfilePath => '${profileMenuPath}/update';
}
```

### Route Definitions

```dart
Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required UserRepository userRepository,
}) {
  return {
    // Tab container (requires auth)
    _PathConstants.tabContainerPath: (_) => CupertinoTabPage(
      child: const TabContainerScreen(),
      paths: [
        _PathConstants.profileMenuPath,
      ],
    ),

    // Sign in
    _PathConstants.signInPath: (_) => MaterialPage(
      name: 'sign-in',
      fullscreenDialog: true,
      child: SignInScreen(
        userRepository: userRepository,
        onSignInSuccess: () => routerDelegate.pop(),
        onSignUpTap: () => routerDelegate.push(_PathConstants.signUpPath),
      ),
    ),

    // Profile menu
    _PathConstants.profileMenuPath: (_) => MaterialPage(
      name: 'profile-menu',
      child: ProfileMenuScreen(
        userRepository: userRepository,
        onUpdateProfileTap: () => routerDelegate.push(
          _PathConstants.updateProfilePath,
        ),
      ),
    ),
  };
}
```

### Feature Navigation (No Routemaster Import!)

Features **never import Routemaster** - they use callbacks:

```dart
// ✅ CORRECT - Feature uses callbacks
class SignInScreen extends StatelessWidget {
  const SignInScreen({
    required this.onSignInSuccess,
    required this.onSignUpTap,
  });

  final VoidCallback onSignInSuccess;
  final VoidCallback onSignUpTap;

  void _handleSignInSuccess() {
    onSignInSuccess();  // Trigger callback
  }
}
```

**See**: [Routing Guide](docs/ROUTING_GUIDE_HUMAN.md) for complete navigation patterns.

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
cd packages/features/sign_in
flutter gen-l10n
```

### Firebase Configuration

**Android**:
- Verify `google-services.json` is in `android/app/`
- Check `applicationId` in `android/app/build.gradle` matches Firebase
- Ensure Firebase Authentication is enabled in console

**iOS**:
- Ensure `GoogleService-Info.plist` is added via Xcode (not just copied)
- Verify bundle ID in Xcode matches Firebase
- Check signing configuration
- Enable Firebase Authentication in console

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
12. ✅ **Cache user data** - Store authenticated user info locally
13. ✅ **Use Isar transactions** - Wrap writes in `writeIsarTxn`

### Development Workflow
14. ✅ **Always use Makefile commands** - Never use `flutter pub get` directly
15. ✅ **Run tests before committing** - `make testing`
16. ✅ **Generate code after model changes** - `make build-runner`
17. ✅ **Keep localization updated** - `make gen-l10n` after ARB changes

---

## 🚀 Building Your App on This Template

### Adding New Features

1. **Create a new feature package**:
   ```bash
   cd packages/features
   mkdir my_feature
   cd my_feature
   flutter create . --template=package
   ```

2. **Structure your feature**:
   ```
   packages/features/my_feature/
   ├── lib/
   │   ├── my_feature.dart           # Barrel file
   │   └── src/
   │       ├── my_feature_screen.dart
   │       ├── my_feature_cubit.dart
   │       ├── my_feature_state.dart
   │       └── l10n/
   └── pubspec.yaml
   ```

3. **Add dependencies** in `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_bloc: ^8.1.5
     component_library:
       path: ../../component_library
     domain_models:
       path: ../../domain_models
   ```

4. **Register route** in `routing_table.dart`:
   ```dart
   static String get myFeaturePath => '${tabContainerPath}my-feature';

   // In buildRoutingTable:
   _PathConstants.myFeaturePath: (_) => MaterialPage(
     child: MyFeatureScreen(...),
   ),
   ```

5. **Run code generation**:
   ```bash
   make get
   make build-runner
   make gen-l10n
   ```

### Adding a Repository

1. **Create repository package**:
   ```bash
   cd packages
   mkdir my_repository
   ```

2. **Implement repository** following the pattern:
   - Create domain models in `domain_models/`
   - Create cache models with `CM` suffix
   - Create remote models with `RM` suffix
   - Implement repository coordinating API + cache
   - Transform exceptions (API → Domain)

3. **Add tests**:
   ```bash
   mkdir my_repository/test
   # Write repository tests with mocked dependencies
   ```

### Customizing the Template

- **Replace Firebase Auth** with your own backend
- **Add more locales** in ARB files
- **Customize theme** in `component_library/`
- **Add analytics events** in `monitoring/`
- **Extend user model** with additional fields

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
- **Firebase**: Authentication, Analytics, Crashlytics

---

## 📞 Support

- 📖 **Architecture Guides**: See `docs/` folder
- 🤖 **AI Development**: Check `CLAUDE.md`
- 🐛 **Issues**: [GitHub Issues](https://github.com/Yasoury/rwf_architecture_boiler_plate/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/Yasoury/rwf_architecture_boiler_plate/discussions)

---

**Happy coding! 🚀**

This template is designed as a **clean starting point** for Flutter apps requiring authentication. Clone it, add your features, and build amazing applications following clean architecture patterns!
