# Real-World Flutter Template

A production-ready Flutter template based on the "Real-World Flutter by Tutorials" book, featuring clean architecture with feature packages, state management with BLoC, and modern development practices.

## ✨ Features

- **Multi-Package Architecture**: Organized feature packages for better scalability
- **State Management**: BLoC pattern with Cubits and Blocs
- **Navigation**: Routemaster for declarative routing
- **Local Database**: Isar for high-performance local storage
- **Firebase Integration**: Authentication, Analytics, Crashlytics, and Remote Config
- **Internationalization**: Built-in i18n support with ARB files
- **Testing**: Unit, widget, and integration test examples
- **CI/CD**: GitHub Actions workflow for automated testing and deployment
- **Code Generation**: Feature scaffolding scripts for rapid development

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.0.5 or higher
- Dart SDK 3.0.5 or higher
- Firebase account (for backend services)
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/flutter-template.git
cd flutter-template
```

### 2. Install Dependencies

**⚠️ Important**: Use the provided Makefile commands instead of standard Flutter commands:

```bash
# Install all dependencies for all packages
make get

# Instead of: flutter pub get
```

### 3. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add your Android/iOS apps to the project
3. Download configuration files:
   - `google-services.json` for Android → place in `android/app/`
   - `GoogleService-Info.plist` for iOS → add via Xcode to `ios/Runner/`

### 4. Environment Configuration

Create your environment variables for API keys:

```bash
# Run with your API configuration
flutter run --dart-define=api-key=YOUR_API_KEY
```

Or configure in your IDE:
- **Android Studio**: Run → Edit Configurations → Additional run args
- **VS Code**: Create `.vscode/launch.json` with dart-define arguments

### 5. Run the App

```bash
# Clean and run (recommended for first run)
make clean && make get
flutter run
```

## 🏗️ Project Structure

```
├── lib/                          # Main app entry point
├── packages/
│   ├── component_library/        # Reusable UI components
│   ├── domain_models/            # Shared domain models
│   ├── features/                 # Feature packages
│   │   ├── home/
│   │   ├── profile/
│   │   └── ...
│   ├── monitoring/               # Firebase services
│   └── repositories/             # Data repositories
├── .github/workflows/            # CI/CD configuration
└── scripts/                      # Development scripts
```

## 🎯 Creating New Features

This template includes powerful code generation scripts to create new features instantly:

### For macOS/Linux:

```bash
# Make the script executable (first time only)
chmod +x create_feature.sh

# Create a new feature
./create_feature.sh my_new_feature
```

### For Windows:

```batch
# Create a new feature
create_feature.bat my_new_feature
```

### What Gets Generated:

Each feature includes:
- ✅ **Cubit**: State management with predefined states (InProgress, Loaded, Failure)
- ✅ **Screen**: Complete screen with BlocProvider and BlocBuilder
- ✅ **Internationalization**: ARB files for English and Arabic
- ✅ **Package Configuration**: pubspec.yaml with all necessary dependencies
- ✅ **Export Files**: Proper barrel exports

Example generated structure:
```
packages/features/my_new_feature/
├── lib/
│   ├── src/
│   │   ├── l10n/
│   │   │   ├── messages_en.arb
│   │   │   └── messages_ar.arb
│   │   ├── my_new_feature_cubit.dart
│   │   ├── my_new_feature_state.dart
│   │   └── my_new_feature_screen.dart
│   └── my_new_feature.dart
├── l10n.yaml
├── pubspec.yaml
└── analysis_options.yaml
```

## 🛠️ Development Commands

**Always use these Makefile commands instead of direct Flutter commands:**

```bash
# Get dependencies for all packages
make get

# Clean all packages
make clean

# Run tests for all packages
make testing

# Format code
make format

# Analyze code
make analyze

# Run build runner for code generation
make build_runner
```

## 🔧 Available Make Commands

| Command | Description | Replaces |
|---------|-------------|----------|
| `make get` | Install dependencies for all packages | `flutter pub get` |
| `make clean` | Clean all packages | `flutter clean` |
| `make testing` | Run tests for all packages | `flutter test` |
| `make format` | Format code in all packages | `flutter format` |
| `make analyze` | Analyze code in all packages | `flutter analyze` |
| `make build_runner` | Run code generation | `flutter packages pub run build_runner build` |

## 🌐 Internationalization

### Adding New Languages

1. Create new ARB file in your feature's `l10n` folder:
```bash
# Example: packages/features/home/lib/src/l10n/messages_es.arb
{
  "greeting": "Hola"
}
```

2. Generate localizations:
```bash
cd packages/features/your_feature
flutter gen-l10n
```

### Using Translations

```dart
// In your widget
final l10n = HomeLocalizations.of(context);
Text(l10n.greeting)
```

## 🗄️ Database (Isar)

This template uses Isar instead of Hive for better performance:

```dart
// Define your model
@Collection()
class User {
  Id id = Isar.autoIncrement;
  late String name;
  late String email;
}

// Use in repository
class UserRepository {
  Future<void> saveUser(User user) async {
    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
  }
}
```

## 🧪 Testing

### Run All Tests
```bash
make testing
```

### Test Types Included
- **Unit Tests**: Business logic and repositories
- **Widget Tests**: UI components
- **Integration Tests**: End-to-end workflows

### Example Test Structure
```dart
// Unit test example
test('should return user when repository call is successful', () async {
  // arrange
  when(mockRepository.getUser()).thenAnswer((_) async => testUser);
  
  // act
  final result = await useCase.getUser();
  
  // assert
  expect(result, equals(testUser));
});
```

## 🚀 CI/CD

The template includes GitHub Actions workflow:

1. **Push your code** to trigger the pipeline
2. **Automated testing** runs on all packages
3. **Build generation** for Android/iOS
4. **Firebase App Distribution** for beta testing

### Setup CI/CD

1. Add secrets to your GitHub repository:
   - `FIREBASE_CLI_TOKEN`
   - `FIREBASE_APP_ID_ANDROID`
   - `FIREBASE_APP_ID_IOS`

2. Push to `develop` branch to trigger the workflow

## 📱 Firebase Services

### Analytics
Track screen views and custom events automatically.

### Crashlytics
Crash reporting is set up and ready to use.

### Remote Config
Feature flags and A/B testing support.

### Authentication
Firebase Auth integration with the repository pattern.

## 🔍 Code Generation

### For Isar Models
```bash
# After creating/modifying Isar models
make build_runner
```

### For Localizations
```bash
# In feature package directory
flutter gen-l10n
```

## 📝 Best Practices

1. **Always use `make` commands** instead of direct Flutter commands
2. **Create features using the generation scripts** for consistency
3. **Follow the package-by-feature structure** for new features
4. **Use Cubits for simple state**, Blocs for complex state with events
5. **Write tests** for your business logic and repositories
6. **Use the repository pattern** for data access
7. **Implement proper error handling** with domain exceptions

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-feature`
3. Use the provided scripts to generate new features
4. Run tests: `make testing`
5. Commit your changes: `git commit -am 'Add some feature'`
6. Push to the branch: `git push origin feature/my-feature`
7. Submit a pull request

## 📚 Architecture Overview

This template follows the principles from "Real-World Flutter by Tutorials":

- **Feature Packages**: Each feature is a separate package
- **Repository Pattern**: Data access abstraction
- **BLoC Pattern**: Predictable state management
- **Clean Architecture**: Separation of concerns
- **Dependency Injection**: Proper dependency management

## 🆘 Troubleshooting

### Common Issues

**Build Errors After Cloning:**
```bash
# Clean and reinstall everything
make clean
make get
```

**Localization Not Working:**
```bash
# Generate localizations
cd packages/features/your_feature
flutter gen-l10n
```

**Firebase Configuration Issues:**
- Ensure configuration files are in the correct locations
- Check that bundle IDs match your Firebase project
- Verify API keys are properly set

**Package Dependencies:**
```bash
# If you get dependency conflicts
make clean
flutter pub deps
make get
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Based on "Real-World Flutter by Tutorials" by Ray Wenderlich
- Uses modern Flutter best practices and patterns
- Includes production-ready architecture and tooling

---

**Happy coding! 🚀**

For questions and support, please open an issue in the repository.
