# Feature Package Architecture Pattern - AI Agent Implementation Guide

## Purpose

This document provides precise rules and patterns for AI agents to implement the feature package architecture in the WonderWords Flutter application. Follow these rules strictly to maintain architectural consistency.

---

## Architecture Overview

```
Main App Package (wonder_words/)
  └── Integrates all packages

packages/
├── features/              → Package-by-feature (screens, state management)
├── [name]_repository/     → Package-by-layer (data coordination)
├── fav_qs_api/           → Package-by-layer (API client)
├── key_value_storage/    → Package-by-layer (local storage)
├── domain_models/        → Shared (business entities)
├── component_library/    → Shared (UI components)
├── form_fields/          → Shared (form validation)
└── monitoring/           → Package-by-layer (observability)
```

---

## The Four Golden Rules

### RULE 1: Features Get Their Own Package

**A feature is**:
1. A screen (e.g., Quote List, Sign In)
2. A dialog performing I/O operations

**Location**: `packages/features/[feature_name]/`

**Validation**:
- ✅ Each screen gets a dedicated package
- ✅ I/O dialogs get packages
- ❌ Simple confirmation dialogs don't need packages
- ❌ Multiple screens in one feature package

### RULE 2: Features Don't Know About Each Other

**Features NEVER import other feature packages.**

**Allowed**:
```dart
// ✅ Import repositories
import 'package:user_repository/user_repository.dart';

// ✅ Import shared packages
import 'package:domain_models/domain_models.dart';
import 'package:component_library/component_library.dart';

// ✅ Import form_fields
import 'package:form_fields/form_fields.dart';
```

**Forbidden**:
```dart
// ❌ NEVER import another feature
import 'package:quote_details/quote_details.dart';
import 'package:sign_in/sign_in.dart';
```

**Communication Pattern**:
Features communicate via **callbacks provided by the main app**:

```dart
class QuoteListScreen extends StatelessWidget {
  const QuoteListScreen({
    required this.onQuoteSelected,  // ← Callback, not direct import
  });

  final Future<Quote?> Function(int id) onQuoteSelected;
}
```

### RULE 3: Repositories Get Their Own Package

**Each repository coordinating data sources gets a package.**

**Location**: `packages/[domain]_repository/`

**Examples**:
- `packages/quote_repository/`
- `packages/user_repository/`

**Validation**:
- ✅ One repository per domain
- ✅ Repository coordinates API + local storage
- ❌ Multiple domains in one repository package

### RULE 4: No Common Package

**NEVER create these package names**:
- ❌ `common`
- ❌ `shared`
- ❌ `utils`
- ❌ `helpers`
- ❌ `core`
- ❌ `base`

**Instead, create specialized packages**:
- ✅ `component_library`
- ✅ `form_fields`
- ✅ `domain_models`
- ✅ `monitoring`

**Decision Process**:
When code needs to be shared:
1. Identify the **domain** of the code
2. Create a **specialized package** named after that domain
3. Move shared code there

---

## Rule Set

### RULE 5: Package Naming Convention

**Template**: `[domain]_[type]` or just `[domain]`

**Valid Names**:
- ✅ `quote_list` (feature)
- ✅ `sign_in` (feature)
- ✅ `user_repository` (repository)
- ✅ `quote_repository` (repository)
- ✅ `component_library` (shared)
- ✅ `form_fields` (shared)

**Invalid Names**:
- ❌ `utils`
- ❌ `common`
- ❌ `helpers`
- ❌ `widgets` (too generic)
- ❌ `QuoteList` (use snake_case)

**Rules**:
- MUST use `snake_case`
- MUST be descriptive
- MUST indicate domain/purpose
- MUST NOT use generic terms

### RULE 6: Package Directory Structure

**Template**:
```
packages/[package_name]/
├── lib/
│   ├── [package_name].dart       # BARREL FILE (required)
│   └── src/                       # PRIVATE (convention)
│       ├── [files].dart
│       └── [subdirs]/
├── test/                          # TEST (required)
│   └── [test_files].dart
└── pubspec.yaml                   # MANIFEST (required)
```

**Validation**:
- ✅ Package name MUST match directory name
- ✅ Barrel file name MUST match package name
- ✅ MUST have `src/` directory
- ✅ MUST have `test/` directory
- ✅ MUST have `pubspec.yaml`

### RULE 7: Barrel File Pattern

**EVERY package MUST have a barrel file.**

**Location**: `lib/[package_name].dart`

**Purpose**: Define public API

**Template**:
```dart
// lib/[package_name].dart

export 'src/[public_file_1].dart';
export 'src/[public_file_2].dart';
export 'src/[subdir]/[public_file_3].dart';

// Do NOT export private implementation files
```

**What to Export**:

**✅ Export**:
- Screens
- Dialogs
- Localization classes
- Public constants
- Public interfaces
- Repository classes
- Domain models
- Reusable components

**❌ Don't Export**:
- State management classes (BLoC, Cubit)
- State/Event classes
- Internal widgets
- Helper functions
- Mappers
- Local storage classes
- Internal utilities

**Examples**:

```dart
// Feature package (sign_in/lib/sign_in.dart)
export 'src/sign_in_screen.dart';
export 'src/l10n/sign_in_localizations.dart';
// sign_in_cubit.dart is NOT exported

// Repository package (quote_repository/lib/quote_repository.dart)
export 'src/quote_repository.dart';
// quote_local_storage.dart is NOT exported
// mappers/ directory is NOT exported

// Shared package (component_library/lib/component_library.dart)
export 'src/exception_indicator.dart';
export 'src/expanded_elevated_button.dart';
export 'src/quote_card.dart';
export 'src/theme/wonder_theme.dart';
// (25+ exports - all reusable components)
```

**Validation**:
- ✅ Barrel file MUST exist
- ✅ Barrel file name MUST match package name
- ✅ MUST only export from `src/`
- ❌ NEVER export implementation details

### RULE 8: Feature Package Structure

**Template**:
```
packages/features/[feature_name]/
├── lib/
│   ├── [feature_name].dart                 # Barrel file
│   └── src/
│       ├── [feature_name]_screen.dart      # Main UI
│       ├── [feature_name]_cubit.dart       # Simple state (OR)
│       ├── [feature_name]_bloc.dart        # Complex state
│       ├── [feature_name]_state.dart       # State class
│       ├── [feature_name]_event.dart       # Event classes (BLoC only)
│       ├── widgets/                         # Feature widgets (optional)
│       │   └── [widget].dart
│       └── l10n/                            # Translations (optional)
│           ├── [feature]_localizations.dart
│           ├── [feature]_localizations_en.dart
│           └── [feature]_localizations_pt.dart
├── test/
│   ├── [feature_name]_cubit_test.dart
│   └── widget_test.dart
└── pubspec.yaml
```

**Naming Convention**:
- Main screen: `[feature_name]_screen.dart`
- State management: `[feature_name]_cubit.dart` OR `[feature_name]_bloc.dart`
- State class: `[feature_name]_state.dart`
- Event class: `[feature_name]_event.dart` (BLoC only)

**Cubit vs BLoC Decision**:
- Use **Cubit** for: Simple forms, direct state changes
- Use **BLoC** for: Complex flows, event streams, debouncing

**Validation**:
- ✅ MUST follow naming convention
- ✅ Screen file MUST end with `_screen.dart`
- ✅ State management MUST be in `src/` (not exported)
- ✅ Barrel file MUST export screen and localizations only

### RULE 9: Package Dependencies Declaration

**Location**: `pubspec.yaml`

**Template**:
```yaml
name: [package_name]
publish_to: none

environment:
  sdk: ">=3.0.5 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # Local packages (relative paths)
  [dependency_1]:
    path: ../../[dependency_1]
  [dependency_2]:
    path: ../../[dependency_2]

  # External packages
  [external_package]: ^[version]

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

**Rules for Local Dependencies**:
- ✅ MUST use relative paths
- ✅ Path MUST be relative to package root
- ✅ MUST specify only needed dependencies
- ❌ NEVER use absolute paths
- ❌ NEVER add "just in case" dependencies

**Feature Package Dependencies**:

**Allowed**:
```yaml
dependencies:
  # Repositories
  user_repository:
    path: ../../user_repository
  quote_repository:
    path: ../../quote_repository

  # Shared packages
  domain_models:
    path: ../../domain_models
  component_library:
    path: ../../component_library
  form_fields:
    path: ../../form_fields

  # State management
  flutter_bloc: ^8.1.5

  # Localization
  intl: ^0.19.0
```

**Forbidden**:
```yaml
dependencies:
  # ❌ NEVER depend on other features
  quote_details:
    path: ../quote_details

  # ❌ NEVER depend on infrastructure
  fav_qs_api:
    path: ../../fav_qs_api
  key_value_storage:
    path: ../../key_value_storage
```

**Repository Package Dependencies**:

**Allowed**:
```yaml
dependencies:
  # Infrastructure
  fav_qs_api:
    path: ../fav_qs_api
  key_value_storage:
    path: ../key_value_storage

  # Shared
  domain_models:
    path: ../domain_models
```

**Forbidden**:
```yaml
dependencies:
  # ❌ NEVER depend on features
  quote_list:
    path: ../features/quote_list

  # ❌ NEVER depend on UI
  component_library:
    path: ../component_library
```

### RULE 10: Import Statements

**ALWAYS use absolute package imports**:

```dart
// ✅ CORRECT - Absolute import
import 'package:domain_models/domain_models.dart';
import 'package:component_library/component_library.dart';

// ❌ WRONG - Relative import
import '../../../domain_models/lib/domain_models.dart';

// ❌ WRONG - Import from src/
import 'package:domain_models/src/quote.dart';
```

**Within the same package, use relative imports**:
```dart
// Within quote_list package
import 'quote_list_state.dart';  // ✅ Same directory
import 'widgets/filter_chip.dart';  // ✅ Subdirectory
```

### RULE 11: Package Categories and Allowed Dependencies

#### Feature Packages

**Location**: `packages/features/[name]/`

**Can depend on**:
- ✅ Repositories (`[domain]_repository`)
- ✅ `domain_models`
- ✅ `component_library`
- ✅ `form_fields`
- ✅ `monitoring` (for analytics)
- ✅ `flutter_bloc`
- ✅ `intl` (localization)

**Cannot depend on**:
- ❌ Other features
- ❌ `fav_qs_api`
- ❌ `key_value_storage`

#### Repository Packages

**Location**: `packages/[domain]_repository/`

**Can depend on**:
- ✅ API packages (`fav_qs_api`)
- ✅ Storage packages (`key_value_storage`)
- ✅ `domain_models`
- ✅ `equatable`

**Cannot depend on**:
- ❌ Features
- ❌ `component_library`
- ❌ `form_fields`

#### Shared Packages

**Location**: `packages/[name]/`

**Can depend on**:
- ✅ Flutter SDK
- ✅ Minimal external packages
- ✅ Other shared packages (carefully)

**Cannot depend on**:
- ❌ Features
- ❌ Repositories
- ❌ Infrastructure packages (with exceptions)

---

## Implementation Patterns

### Pattern 1: Creating a New Feature Package

**Step-by-Step Template**:

**Step 1: Create directory structure**
```bash
mkdir -p packages/features/[feature_name]/lib/src
mkdir -p packages/features/[feature_name]/test
touch packages/features/[feature_name]/pubspec.yaml
```

**Step 2: Create pubspec.yaml**
```yaml
name: [feature_name]
publish_to: none

environment:
  sdk: ">=3.0.5 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.5

  # Add repository dependencies
  [domain]_repository:
    path: ../../[domain]_repository

  # Add shared dependencies
  domain_models:
    path: ../../domain_models
  component_library:
    path: ../../component_library

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.0.3
  flutter_lints: ^4.0.0
```

**Step 3: Create barrel file**
```dart
// lib/[feature_name].dart
export 'src/[feature_name]_screen.dart';
export 'src/l10n/[feature_name]_localizations.dart';
```

**Step 4: Create screen file**
```dart
// lib/src/[feature_name]_screen.dart
import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:[domain]_repository/[domain]_repository.dart';

import '[feature_name]_cubit.dart';

class [FeatureName]Screen extends StatelessWidget {
  const [FeatureName]Screen({
    required this.[domain]Repository,
    this.on[Action]Tap,  // Callback for navigation
    super.key,
  });

  final [Domain]Repository [domain]Repository;
  final VoidCallback? on[Action]Tap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<[FeatureName]Cubit>(
      create: (_) => [FeatureName]Cubit(
        [domain]Repository: [domain]Repository,
      ),
      child: [FeatureName]View(
        on[Action]Tap: on[Action]Tap,
      ),
    );
  }
}

class [FeatureName]View extends StatelessWidget {
  const [FeatureName]View({
    this.on[Action]Tap,
    super.key,
  });

  final VoidCallback? on[Action]Tap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('[Feature Name]')),
      body: BlocBuilder<[FeatureName]Cubit, [FeatureName]State>(
        builder: (context, state) {
          // Build UI based on state
          return Container();
        },
      ),
    );
  }
}
```

**Step 5: Create Cubit**
```dart
// lib/src/[feature_name]_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:[domain]_repository/[domain]_repository.dart';

part '[feature_name]_state.dart';

class [FeatureName]Cubit extends Cubit<[FeatureName]State> {
  [FeatureName]Cubit({
    required this.[domain]Repository,
  }) : super(const [FeatureName]State());

  final [Domain]Repository [domain]Repository;

  Future<void> load() async {
    emit(state.copyWith(status: Status.loading));

    try {
      final data = await [domain]Repository.getData();
      emit(state.copyWith(
        status: Status.success,
        data: data,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: Status.error,
        error: error,
      ));
    }
  }
}
```

**Step 6: Create State**
```dart
// lib/src/[feature_name]_state.dart
part of '[feature_name]_cubit.dart';

class [FeatureName]State extends Equatable {
  const [FeatureName]State({
    this.status = Status.initial,
    this.data,
    this.error,
  });

  final Status status;
  final [DataType]? data;
  final Object? error;

  [FeatureName]State copyWith({
    Status? status,
    [DataType]? data,
    Object? error,
  }) {
    return [FeatureName]State(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}

enum Status { initial, loading, success, error }
```

**Step 7: Add to main app**
```yaml
# Root pubspec.yaml
dependencies:
  [feature_name]:
    path: packages/features/[feature_name]
```

**Step 8: Add route**
```dart
// lib/routing_table.dart
_PathConstants.[feature]Path: (_) => MaterialPage(
  name: '[kebab-case-name]',
  child: [FeatureName]Screen(
    [domain]Repository: [domain]Repository,
    on[Action]Tap: () {
      routerDelegate.push(_PathConstants.[target]Path);
    },
  ),
),
```

### Pattern 2: Creating a Shared Package

**When to create**: When 2+ packages need the same code

**Step 1: Identify domain**
Determine what the shared code represents:
- UI components → `component_library`
- Form validation → `form_fields`
- Business entities → `domain_models`
- Analytics → `monitoring`

**Step 2: Create package structure**
```bash
mkdir -p packages/[domain_name]/lib/src
mkdir -p packages/[domain_name]/test
```

**Step 3: Create pubspec.yaml**
```yaml
name: [domain_name]
publish_to: none

environment:
  sdk: ">=2.13.0 <3.0.0"

dependencies:
  # Minimal dependencies only
  equatable: ^2.0.3  # If needed

dev_dependencies:
  test: ^1.16.8
  lints: ^4.0.0
```

**Step 4: Create barrel file**
```dart
// lib/[domain_name].dart
export 'src/[file1].dart';
export 'src/[file2].dart';
export 'src/[subdirectory]/[file3].dart';
```

**Step 5: Implement files in src/**

**Step 6: Update dependent packages**
```yaml
# In consuming packages
dependencies:
  [domain_name]:
    path: ../../[domain_name]
```

### Pattern 3: Repository Package Structure

**Template**:
```
packages/[domain]_repository/
├── lib/
│   ├── [domain]_repository.dart           # Barrel file
│   └── src/
│       ├── [domain]_repository.dart       # Main repository
│       ├── [domain]_local_storage.dart    # Cache (PRIVATE)
│       └── mappers/                        # Transformations (PRIVATE)
│           ├── [model]_rm_to_dm.dart
│           ├── [model]_rm_to_cm.dart
│           └── [model]_cm_to_dm.dart
├── test/
│   └── [domain]_repository_test.dart
└── pubspec.yaml
```

**Barrel file exports ONLY repository**:
```dart
// lib/[domain]_repository.dart
export 'src/[domain]_repository.dart';
// Local storage is PRIVATE
// Mappers are PRIVATE
```

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Feature Importing Another Feature

```dart
// In quote_list package
import 'package:quote_details/quote_details.dart';  // ❌ NEVER!

void _navigateToDetails() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => QuoteDetailsScreen()),
  );
}
```

✅ **Correct**:
```dart
class QuoteListScreen extends StatelessWidget {
  const QuoteListScreen({
    required this.onQuoteSelected,  // ✅ Use callback
  });

  final VoidCallback onQuoteSelected;

  void _navigateToDetails() {
    onQuoteSelected();  // ✅ Trigger callback
  }
}
```

### ❌ Anti-Pattern 2: Creating Common/Utils Package

```bash
# ❌ NEVER create these
packages/common/
packages/shared/
packages/utils/
packages/helpers/
```

✅ **Correct**:
```bash
# ✅ Create specialized packages
packages/component_library/
packages/form_fields/
packages/domain_models/
```

### ❌ Anti-Pattern 3: Importing from src/

```dart
// ❌ NEVER import from src/
import 'package:quote_repository/src/quote_repository.dart';
import 'package:sign_in/src/sign_in_cubit.dart';
```

✅ **Correct**:
```dart
// ✅ Import barrel file only
import 'package:quote_repository/quote_repository.dart';
import 'package:sign_in/sign_in.dart';
```

### ❌ Anti-Pattern 4: Feature Depending on Infrastructure

```yaml
# In sign_in/pubspec.yaml
dependencies:
  fav_qs_api:  # ❌ Feature shouldn't know about API
    path: ../../fav_qs_api
```

✅ **Correct**:
```yaml
dependencies:
  user_repository:  # ✅ Depend on repository
    path: ../../user_repository
```

### ❌ Anti-Pattern 5: Exporting State Management

```dart
// lib/sign_in.dart
export 'src/sign_in_screen.dart';
export 'src/sign_in_cubit.dart';  // ❌ Don't export implementation
export 'src/sign_in_state.dart';  // ❌ Don't export state
```

✅ **Correct**:
```dart
// lib/sign_in.dart
export 'src/sign_in_screen.dart';  // ✅ Only export screen
export 'src/l10n/sign_in_localizations.dart';  // ✅ And localizations
// Cubit and state are private
```

### ❌ Anti-Pattern 6: Multiple Features in One Package

```
packages/features/user_flows/  # ❌ Too broad
  ├── sign_in_screen.dart
  ├── sign_up_screen.dart
  └── profile_screen.dart
```

✅ **Correct**:
```
packages/features/
  ├── sign_in/  # ✅ One feature per package
  ├── sign_up/
  └── profile_menu/
```

### ❌ Anti-Pattern 7: Repository Depending on Features

```yaml
# In quote_repository/pubspec.yaml
dependencies:
  quote_list:  # ❌ Inverts dependency flow
    path: ../features/quote_list
```

✅ **Correct**:
```yaml
# In quote_list/pubspec.yaml
dependencies:
  quote_repository:  # ✅ Feature depends on repository
    path: ../../quote_repository
```

---

## Validation Checklist

Before submitting code, verify:

### Package Structure
- [ ] Package name uses `snake_case`
- [ ] Package name is descriptive (not generic)
- [ ] Directory structure follows template
- [ ] Has `lib/` directory
- [ ] Has `lib/src/` directory
- [ ] Has `test/` directory
- [ ] Has `pubspec.yaml`

### Barrel File
- [ ] Barrel file exists at `lib/[package_name].dart`
- [ ] Barrel file name matches package name
- [ ] Only exports public API
- [ ] Doesn't export state management (for features)
- [ ] Doesn't export internal utilities

### Dependencies
- [ ] Uses relative paths for local packages
- [ ] Only includes necessary dependencies
- [ ] Follows allowed dependencies for package type
- [ ] No circular dependencies
- [ ] No feature-to-feature dependencies

### Feature Package
- [ ] Located in `packages/features/`
- [ ] Exports only screen and localizations
- [ ] State management in `src/` (not exported)
- [ ] Uses callbacks for navigation
- [ ] Doesn't import other features

### Repository Package
- [ ] Located in `packages/`
- [ ] Exports only repository class
- [ ] Local storage is private
- [ ] Mappers are private
- [ ] Depends on infrastructure packages

### Imports
- [ ] Uses absolute package imports
- [ ] Imports barrel files, not src/
- [ ] No relative imports across packages

---

## Quick Reference

### Package Locations
- **Features**: `packages/features/[name]/`
- **Repositories**: `packages/[domain]_repository/`
- **Infrastructure**: `packages/[name]/` (root level)
- **Shared**: `packages/[name]/` (root level)

### Barrel Files
- **Location**: `lib/[package_name].dart`
- **Purpose**: Define public API
- **Export**: Only public-facing classes

### Allowed Dependencies

**Feature → Repository, domain_models, component_library, form_fields**
**Repository → API, Storage, domain_models**
**Shared → Minimal external packages**
**Feature ❌ Feature**
**Feature ❌ Infrastructure**
**Repository ❌ Features**

### File Naming
- Screen: `[feature]_screen.dart`
- Cubit: `[feature]_cubit.dart`
- BLoC: `[feature]_bloc.dart`
- State: `[feature]_state.dart`
- Event: `[feature]_event.dart`

---

## Complete Example: Adding Bookmarks Feature

### Step 1: Create Package Structure

```bash
mkdir -p packages/features/bookmarks/lib/src
mkdir -p packages/features/bookmarks/test
```

### Step 2: Create pubspec.yaml

```yaml
name: bookmarks
publish_to: none

environment:
  sdk: ">=3.0.5 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.5

  quote_repository:
    path: ../../quote_repository
  domain_models:
    path: ../../domain_models
  component_library:
    path: ../../component_library

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.0.3
  flutter_lints: ^4.0.0
```

### Step 3: Create Files

```dart
// lib/bookmarks.dart (Barrel file)
export 'src/bookmarks_screen.dart';

// lib/src/bookmarks_screen.dart
import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_repository/quote_repository.dart';

import 'bookmarks_cubit.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({
    required this.quoteRepository,
    super.key,
  });

  final QuoteRepository quoteRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookmarksCubit>(
      create: (_) => BookmarksCubit(
        quoteRepository: quoteRepository,
      )..loadBookmarks(),
      child: const BookmarksView(),
    );
  }
}

class BookmarksView extends StatelessWidget {
  const BookmarksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: BlocBuilder<BookmarksCubit, BookmarksState>(
        builder: (context, state) {
          if (state.status == Status.loading) {
            return const CenteredCircularProgressIndicator();
          }

          if (state.status == Status.error) {
            return ExceptionIndicator(
              onTryAgain: () => context.read<BookmarksCubit>().loadBookmarks(),
            );
          }

          return ListView.builder(
            itemCount: state.bookmarks.length,
            itemBuilder: (context, index) {
              final quote = state.bookmarks[index];
              return QuoteCard(quote: quote);
            },
          );
        },
      ),
    );
  }
}

// lib/src/bookmarks_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domain_models/domain_models.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:equatable/equatable.dart';

part 'bookmarks_state.dart';

class BookmarksCubit extends Cubit<BookmarksState> {
  BookmarksCubit({
    required this.quoteRepository,
  }) : super(const BookmarksState());

  final QuoteRepository quoteRepository;

  Future<void> loadBookmarks() async {
    emit(state.copyWith(status: Status.loading));

    try {
      // Implementation
      emit(state.copyWith(
        status: Status.success,
        bookmarks: [],
      ));
    } catch (error) {
      emit(state.copyWith(
        status: Status.error,
        error: error,
      ));
    }
  }
}

// lib/src/bookmarks_state.dart
part of 'bookmarks_cubit.dart';

class BookmarksState extends Equatable {
  const BookmarksState({
    this.status = Status.initial,
    this.bookmarks = const [],
    this.error,
  });

  final Status status;
  final List<Quote> bookmarks;
  final Object? error;

  BookmarksState copyWith({
    Status? status,
    List<Quote>? bookmarks,
    Object? error,
  }) {
    return BookmarksState(
      status: status ?? this.status,
      bookmarks: bookmarks ?? this.bookmarks,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, bookmarks, error];
}

enum Status { initial, loading, success, error }
```

### Step 4: Update Main App

```yaml
# Root pubspec.yaml
dependencies:
  bookmarks:
    path: packages/features/bookmarks
```

### Step 5: Add Route

```dart
// lib/routing_table.dart
_PathConstants.bookmarksPath: (_) => MaterialPage(
  name: 'bookmarks',
  child: BookmarksScreen(
    quoteRepository: quoteRepository,
  ),
),
```

---

## Summary

Follow these rules precisely to implement feature package architecture that:
- Scales with team and product growth
- Maintains clear boundaries and ownership
- Enables independent feature development
- Supports isolated testing
- Provides flexibility for experimentation
- Creates self-documenting code structure

When in doubt, refer to the real examples in the WonderWords codebase.
