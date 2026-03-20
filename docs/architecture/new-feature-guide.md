# Creating a New Feature (Step-by-Step)

## Step 1: Use the Feature Generator Script

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

## Step 2: Add Repository Dependencies (if needed)

Edit `packages/features/my_feature_name/pubspec.yaml` to add repository dependencies:

```yaml
dependencies:
  # Add as needed:
  user_repository:
    path: ../../user_repository
  domain_models:
    path: ../../domain_models
```

## Step 3: Add Navigation Callbacks to Screen

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

## Step 4: Add Route in routing_table.dart

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

## Step 5: Register Localization Delegate in main.dart

Add `MyFeatureNameLocalizations.delegate` to the `localizationsDelegates` list.

## Step 6: Write Tests

Create `test/my_feature_name_cubit_test.dart` with `blocTest` for all state transitions.

## Step 7: Run Verification

```bash
make get          # Fetch dependencies for all packages
make gen-l10n     # Generate localization files
make lint         # Check for issues
make testing      # Run all tests
```
