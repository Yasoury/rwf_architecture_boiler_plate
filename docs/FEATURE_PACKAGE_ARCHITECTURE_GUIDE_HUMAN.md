# Feature Package Architecture Guide for WonderWords Flutter App

## Overview

This document explains how the WonderWords Flutter application organizes code using a **hybrid package architecture** that combines the best of package-by-feature and package-by-layer approaches. This architecture provides excellent scalability, maintainability, and clear ownership boundaries.

## Table of Contents

1. [Core Philosophy](#core-philosophy)
2. [Package-by-Layer vs Package-by-Feature](#package-by-layer-vs-package-by-feature)
3. [The Hybrid Approach](#the-hybrid-approach)
4. [Package Organization](#package-organization)
5. [The Four Golden Rules](#the-four-golden-rules)
6. [Package Categories](#package-categories)
7. [Dependency Rules](#dependency-rules)
8. [Barrel Files Pattern](#barrel-files-pattern)
9. [Feature Structure](#feature-structure)
10. [Best Practices](#best-practices)
11. [Real-World Examples](#real-world-examples)

---

## Core Philosophy

The WonderWords architecture follows these principles:

- **Package by Convenience**: Use package-by-feature for screens/features, package-by-layer for infrastructure
- **Clear Boundaries**: Each package has a well-defined responsibility
- **No Common Package**: Shared code goes into specialized packages, never a "common" or "utils" package
- **Feature Independence**: Features don't know about each other, only about repositories and shared infrastructure
- **Scalability First**: Structure supports growing teams and codebase

### Why This Approach?

1. **Self-Documenting**: Package structure reveals app features at a glance
2. **Scalable**: Adding features doesn't require restructuring
3. **Team Ownership**: Clear boundaries for different teams/developers
4. **Testability**: Packages can be tested in isolation
5. **Flexibility**: Easy to experiment with different approaches per feature

---

## Package-by-Layer vs Package-by-Feature

### Package-by-Layer

Group files by **technical concerns** (what they do technically).

**Structure Example**:
```
packages/
  ├── ui/                    # All screens, dialogs, widgets
  ├── state_managers/        # All BLoCs, Cubits, Providers
  ├── repositories/          # All repositories
  ├── models/                # All data models
  └── networking/            # All API calls
```

**✅ Advantages**:
- Low learning curve (intuitive organization)
- Encourages code reuse
- Similar structure across projects
- Easy to find files by type

**❌ Disadvantages**:
- Doesn't convey app features
- Everything is public (poor encapsulation)
- Developers jump between distant folders
- Violates Single Responsibility Principle (files that change together aren't together)
- Doesn't scale well with large codebases

### Package-by-Feature

Group files by **domain/business concerns** (what feature they belong to).

**Structure Example**:
```
packages/
  ├── quote_list/           # Screen, BLoC, widgets for quote list
  ├── quote_details/        # Screen, Cubit, widgets for quote details
  ├── sign_in/              # Screen, Cubit, forms for sign in
  ├── profile_menu/         # Screen, BLoC for profile
  └── sign_up/              # Screen, Cubit, forms for sign up
```

**✅ Advantages**:
- Self-documenting structure
- Scales excellently
- Easy to find feature-related files
- Complete visibility control
- Smoother onboarding (focus on one feature)
- Clear team ownership
- Easy to experiment per feature

**❌ Disadvantages**:
- Code reuse requires more thought
- Harder to find shared utilities
- Less intuitive for beginners

---

## The Hybrid Approach

WonderWords uses **both approaches** based on what's convenient:

- **Package-by-Feature**: For screens, dialogs, and feature-specific code
- **Package-by-Layer**: For infrastructure (APIs, storage, shared models)

```
packages/
  ├── features/                   # PACKAGE-BY-FEATURE
  │   ├── quote_list/
  │   ├── quote_details/
  │   ├── sign_in/
  │   ├── sign_up/
  │   ├── profile_menu/
  │   ├── update_profile/
  │   └── forgot_my_password/
  │
  ├── quote_repository/           # PACKAGE-BY-LAYER (Infrastructure)
  ├── user_repository/            # PACKAGE-BY-LAYER (Infrastructure)
  ├── fav_qs_api/                 # PACKAGE-BY-LAYER (Infrastructure)
  ├── key_value_storage/          # PACKAGE-BY-LAYER (Infrastructure)
  ├── domain_models/              # PACKAGE-BY-LAYER (Shared)
  ├── component_library/          # PACKAGE-BY-LAYER (Shared UI)
  ├── form_fields/                # PACKAGE-BY-LAYER (Shared)
  └── monitoring/                 # PACKAGE-BY-LAYER (Infrastructure)
```

**Key Insight**: Use package-by-feature for **feature code** (screens, state managers), and package-by-layer for **infrastructure code** (APIs, databases, shared utilities).

---

## Package Organization

### Complete Package Structure

```
wonder_words/                     # Main application package
├── lib/
│   ├── main.dart
│   ├── routing_table.dart
│   ├── tab_container_screen.dart
│   └── screen_view_observer.dart
└── packages/
    │
    ├── features/                 # Feature packages (7 packages)
    │   ├── quote_list/
    │   │   ├── lib/
    │   │   │   ├── quote_list.dart              # Barrel file
    │   │   │   └── src/
    │   │   │       ├── quote_list_screen.dart
    │   │   │       ├── quote_list_bloc.dart
    │   │   │       ├── quote_list_state.dart
    │   │   │       ├── quote_list_event.dart
    │   │   │       ├── quote_paged_list_view.dart
    │   │   │       ├── filter_horizontal_list.dart
    │   │   │       └── l10n/                    # Feature-specific translations
    │   │   ├── test/
    │   │   └── pubspec.yaml
    │   │
    │   ├── quote_details/
    │   ├── sign_in/
    │   ├── sign_up/
    │   ├── profile_menu/
    │   ├── update_profile/
    │   └── forgot_my_password/
    │
    ├── quote_repository/         # Repository packages (2 packages)
    │   ├── lib/
    │   │   ├── quote_repository.dart            # Barrel file
    │   │   └── src/
    │   │       ├── quote_repository.dart
    │   │       ├── quote_local_storage.dart
    │   │       └── mappers/
    │   ├── test/
    │   └── pubspec.yaml
    │
    ├── user_repository/
    │
    ├── fav_qs_api/               # API layer
    │   ├── lib/
    │   │   ├── fav_qs_api.dart
    │   │   └── src/
    │   │       ├── fav_qs_api.dart
    │   │       ├── models/
    │   │       │   ├── exceptions.dart
    │   │       │   ├── request/
    │   │       │   └── response/
    │   │       └── url_builder.dart
    │   └── pubspec.yaml
    │
    ├── key_value_storage/        # Local storage wrapper
    │
    ├── domain_models/            # Shared domain models
    │   ├── lib/
    │   │   ├── domain_models.dart
    │   │   └── src/
    │   │       ├── quote.dart
    │   │       ├── user.dart
    │   │       ├── tag.dart
    │   │       ├── exceptions.dart
    │   │       └── dark_mode_preference.dart
    │   └── pubspec.yaml
    │
    ├── component_library/        # Shared UI components
    │   ├── lib/
    │   │   ├── component_library.dart
    │   │   └── src/
    │   │       ├── buttons/
    │   │       ├── cards/
    │   │       ├── indicators/
    │   │       ├── theme/
    │   │       └── l10n/
    │   └── pubspec.yaml
    │
    ├── form_fields/              # Shared form validation
    │   ├── lib/
    │   │   ├── form_fields.dart
    │   │   └── src/
    │   │       ├── email.dart
    │   │       ├── password.dart
    │   │       └── username.dart
    │   └── pubspec.yaml
    │
    └── monitoring/               # Analytics, crash reporting, deep links
        ├── lib/
        │   ├── monitoring.dart
        │   └── src/
        │       ├── analytics_service.dart
        │       ├── error_reporting_service.dart
        │       ├── dynamic_link_service.dart
        │       └── remote_value_service.dart
        └── pubspec.yaml
```

---

## The Four Golden Rules

### Rule 1: Features Get Their Own Package

**Definition of a Feature**:
1. A screen (e.g., Quote List Screen, Sign In Screen)
2. A dialog that performs I/O operations (networking, database)

**Examples**:
- ✅ `quote_list` - A screen showing paginated quotes
- ✅ `sign_in` - A screen with form and authentication
- ✅ `forgot_my_password` - A dialog making API calls
- ❌ Confirmation dialog - Just UI, no I/O, doesn't need a package

**Why?**
- Clear ownership
- Easy to locate feature code
- Isolated testing
- Independent versioning

### Rule 2: Features Don't Know About Each Other

Features **never** import other features. They communicate via:
- **Callbacks** (navigation, events)
- **Shared repositories**
- **Shared domain models**

**Example**:
```dart
// ❌ BAD - Feature importing another feature
import 'package:quote_details/quote_details.dart';  // NEVER!

// ✅ GOOD - Feature uses callback
class QuoteListScreen extends StatelessWidget {
  const QuoteListScreen({
    required this.onQuoteSelected,  // Callback for navigation
  });

  final Future<Quote?> Function(int id) onQuoteSelected;
}
```

**Why?**
- Prevents circular dependencies
- Makes features independently deployable
- Easier to refactor/replace features
- Clear dependency graph

### Rule 3: Repositories Get Their Own Package

Each repository coordinating data sources gets a dedicated package:
- `quote_repository` - Manages quote data
- `user_repository` - Manages user/auth data

**Why?**
- Clear data layer separation
- Shared across multiple features
- Independent testing
- Encapsulates data source complexity

### Rule 4: No Common Package

**NEVER** create packages named:
- ❌ `common`
- ❌ `shared`
- ❌ `utils`
- ❌ `helpers`

**Instead**, create **specialized packages**:
- ✅ `component_library` - Shared UI components
- ✅ `form_fields` - Form validation logic
- ✅ `domain_models` - Domain entities
- ✅ `monitoring` - Analytics and error tracking

**Why?**
- Forces thoughtful organization
- Prevents "junk drawer" packages
- Self-documenting purpose
- Clear boundaries

**Origin of Specialized Packages**:
When 2+ packages need the same code:
1. Identify the **domain** of the shared code
2. Create a **specialized package** for that domain
3. Both packages depend on the new package

**Example**:
```
sign_in needs Email validation
sign_up needs Email validation
  ↓
Create form_fields package
  ↓
sign_in → form_fields
sign_up → form_fields
```

---

## Package Categories

### 1. Feature Packages (7 packages)

Located in `packages/features/`

**Purpose**: Implement user-facing features

**Contains**:
- Screens/Dialogs
- State management (BLoCs/Cubits)
- State/Event classes
- Feature-specific widgets
- Feature-specific localization

**Dependencies**:
- ✅ Repositories
- ✅ Domain models
- ✅ Component library
- ✅ Form fields (if needed)
- ❌ Other features
- ❌ API packages
- ❌ Storage packages

**Examples**:
- `quote_list` - Browse and filter quotes
- `quote_details` - View quote details, favorite, share
- `sign_in` - User authentication
- `sign_up` - User registration
- `profile_menu` - User profile and settings
- `update_profile` - Edit user information
- `forgot_my_password` - Password reset

### 2. Repository Packages (2 packages)

Located in `packages/`

**Purpose**: Coordinate data sources (API + local storage)

**Contains**:
- Repository classes
- Local storage interfaces
- Data mappers (Remote ↔ Cache ↔ Domain)
- Fetch policies
- Cache management

**Dependencies**:
- ✅ API packages
- ✅ Storage packages
- ✅ Domain models
- ❌ Features
- ❌ Component library

**Examples**:
- `quote_repository` - Quote data management
- `user_repository` - User/auth data management

### 3. Infrastructure Packages (3 packages)

**Purpose**: Provide low-level services

**Examples**:

**`fav_qs_api`** - Remote API wrapper
- HTTP client setup
- API endpoints
- Remote models
- API exceptions
- URL building

**`key_value_storage`** - Local storage wrapper
- Hive database setup
- Type adapters
- Storage interface

**`monitoring`** - Observability services
- Firebase Analytics
- Crash reporting
- Remote config
- Deep linking

**Dependencies**:
- ✅ External packages (dio, hive, firebase)
- ❌ Application code
- ❌ Features
- ❌ Repositories

### 4. Shared Packages (3 packages)

**Purpose**: Share code across features/repositories

**Examples**:

**`domain_models`** - Business entities
- Quote, User, Tag models
- Domain exceptions
- Enums (DarkModePreference)
- Pure data classes (no UI, no logic)

**`component_library`** - UI components
- Reusable widgets
- Buttons, cards, indicators
- Theme system
- Component localization
- Design system tokens

**`form_fields`** - Form validation
- FormzInput implementations
- Email, Password, Username fields
- Validation rules
- Error enums

**Dependencies**:
- ✅ Flutter SDK
- ✅ Minimal external packages (equatable, formz)
- ❌ Features
- ❌ Repositories
- ❌ Infrastructure (except component_library can use flutter_svg)

---

## Dependency Rules

### The Dependency Graph

```
┌──────────────────────────────────────────────────────────────┐
│                      Main App Package                         │
│                   (Integrates everything)                     │
└──────────────────────────┬───────────────────────────────────┘
                           │
            ┌──────────────┼──────────────┐
            ↓              ↓              ↓
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│   Features    │  │ Repositories  │  │   Monitoring  │
│               │  │               │  │               │
│ quote_list    │  │ quote_repo    │  │ Analytics     │
│ sign_in       │  │ user_repo     │  │ Deep Links    │
│ ...           │  │               │  │               │
└───────┬───────┘  └───────┬───────┘  └───────────────┘
        │                  │
        │   ┌──────────────┼──────────────┐
        │   │              │              │
        ↓   ↓              ↓              ↓
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│ Component Lib │  │ fav_qs_api    │  │ key_value_    │
│               │  │               │  │   storage     │
└───────┬───────┘  └───────┬───────┘  └───────────────┘
        │                  │
        │   ┌──────────────┼──────────────┐
        │   │              │              │
        ↓   ↓              ↓              ↓
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│ Domain Models │  │  Form Fields  │  │   External    │
│               │  │               │  │   Packages    │
└───────────────┘  └───────────────┘  └───────────────┘
```

### Allowed Dependencies

**Features can depend on**:
- ✅ Repositories
- ✅ Domain models
- ✅ Component library
- ✅ Form fields
- ✅ Monitoring (for analytics)
- ❌ Other features
- ❌ API packages
- ❌ Storage packages

**Repositories can depend on**:
- ✅ API packages
- ✅ Storage packages
- ✅ Domain models
- ❌ Features
- ❌ Component library
- ❌ Form fields

**Shared packages can depend on**:
- ✅ External packages (minimal)
- ❌ Features
- ❌ Repositories
- ❌ Infrastructure packages

### Dependency Declaration

All dependencies are declared in `pubspec.yaml` with **relative paths**:

```yaml
# In packages/features/sign_in/pubspec.yaml
dependencies:
  user_repository:
    path: ../../user_repository
  domain_models:
    path: ../../domain_models
  component_library:
    path: ../../component_library
  form_fields:
    path: ../../form_fields
```

**Rules**:
- ✅ Use relative paths for local packages
- ✅ Document why each dependency is needed
- ❌ Don't add "just in case" dependencies
- ❌ Don't create circular dependencies

---

## Barrel Files Pattern

Every package has a **barrel file** that exports only public APIs.

### What is a Barrel File?

A barrel file (named after the package) re-exports selected files from `src/`:

```dart
// packages/sign_in/lib/sign_in.dart (BARREL FILE)
export 'src/sign_in_screen.dart';
export 'src/l10n/sign_in_localizations.dart';

// Note: sign_in_cubit.dart is NOT exported (internal implementation)
```

### Package Structure with Barrel Files

```
packages/sign_in/
├── lib/
│   ├── sign_in.dart              # BARREL FILE (public API)
│   └── src/                       # PRIVATE (convention)
│       ├── sign_in_screen.dart    # Exported (public)
│       ├── sign_in_cubit.dart     # NOT exported (private)
│       ├── sign_in_state.dart     # NOT exported (private)
│       └── l10n/
│           └── sign_in_localizations.dart  # Exported (public)
└── pubspec.yaml
```

### Usage

**Consumers import the barrel file**:
```dart
// ✅ CORRECT - Import barrel file
import 'package:sign_in/sign_in.dart';

// ❌ WRONG - Import from src/
import 'package:sign_in/src/sign_in_screen.dart';
```

### Benefits

1. **Encapsulation**: Internal implementation hidden
2. **Clean API**: Only public classes exposed
3. **Refactoring Freedom**: Change internal files without breaking consumers
4. **Documentation**: Barrel file shows public contract
5. **Dart Convention**: Follows `src/` private convention

### What to Export

**✅ Export**:
- Screens/Dialogs
- Localization classes
- Public constants/enums
- Public interfaces

**❌ Don't Export**:
- State management (BLoCs, Cubits)
- State/Event classes
- Internal widgets
- Helper functions
- Mappers

### Examples from WonderWords

**Quote Repository**:
```dart
// packages/quote_repository/lib/quote_repository.dart
export 'src/quote_repository.dart';
// That's it! Local storage and mappers are private
```

**Component Library**:
```dart
// packages/component_library/lib/component_library.dart
export 'src/chevron_list_tile.dart';
export 'src/exception_indicator.dart';
export 'src/expanded_elevated_button.dart';
export 'src/favorite_icon_button.dart';
export 'src/quote_card.dart';
export 'src/theme/wonder_theme.dart';
export 'src/theme/spacing.dart';
// ... (25 exports total - all reusable components)
```

**Domain Models**:
```dart
// packages/domain_models/lib/domain_models.dart
export 'src/quote.dart';
export 'src/user.dart';
export 'src/tag.dart';
export 'src/exceptions.dart';
export 'src/dark_mode_preference.dart';
export 'src/quote_list_page.dart';
// All models are public (shared across app)
```

---

## Feature Structure

### Standard Feature Package Layout

```
packages/features/[feature_name]/
├── lib/
│   ├── [feature_name].dart              # Barrel file
│   └── src/
│       ├── [feature_name]_screen.dart   # Main UI
│       ├── [feature_name]_cubit.dart    # State management (Cubit)
│       ├── [feature_name]_state.dart    # State class
│       │
│       # OR for complex features:
│       ├── [feature_name]_bloc.dart     # State management (BLoC)
│       ├── [feature_name]_event.dart    # Event classes
│       ├── [feature_name]_state.dart    # State classes
│       │
│       ├── widgets/                      # Feature-specific widgets
│       │   ├── some_widget.dart
│       │   └── another_widget.dart
│       │
│       └── l10n/                         # Feature translations
│           ├── [feature]_localizations.dart
│           ├── [feature]_localizations_en.dart
│           └── [feature]_localizations_pt.dart
│
├── test/
│   ├── [feature_name]_cubit_test.dart
│   └── widget_test.dart
│
└── pubspec.yaml
```

### When to Use Cubit vs BLoC

**Use Cubit when**:
- Simple state changes
- Direct method calls
- Form handling
- No need for streams
- Examples: `sign_in`, `sign_up`, `forgot_my_password`, `quote_details`

**Use BLoC when**:
- Complex state logic
- Event-driven architecture
- Stream transformations
- Debouncing/throttling
- Examples: `quote_list`, `profile_menu`

---

## Best Practices

### 1. Package Naming Conventions

**✅ Good Names**:
- `quote_list` - Clear, descriptive
- `sign_in` - Action-oriented
- `user_repository` - Purpose clear
- `component_library` - Specialized

**❌ Bad Names**:
- `utils` - Too generic
- `common` - Not descriptive
- `helpers` - Vague
- `screen1` - Not meaningful

**Rules**:
- Use `snake_case`
- Be descriptive but concise
- Indicate purpose clearly
- Avoid generic terms

### 2. Feature Independence

**✅ Good - Feature uses callbacks**:
```dart
// In routing_table.dart (main app)
_PathConstants.quoteListPath: (route) => MaterialPage(
  child: QuoteListScreen(
    onQuoteSelected: (id) {
      return routerDelegate.push(_PathConstants.quoteDetailsPath(quoteId: id));
    },
  ),
),
```

**❌ Bad - Feature imports another feature**:
```dart
// In quote_list package
import 'package:quote_details/quote_details.dart';  // NEVER!

Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => QuoteDetailsScreen()),
);
```

### 3. Dependency Minimization

**✅ Good - Minimal dependencies**:
```yaml
# domain_models/pubspec.yaml
dependencies:
  equatable: ^2.0.3  # Only what's needed
```

**❌ Bad - Unnecessary dependencies**:
```yaml
# domain_models/pubspec.yaml
dependencies:
  equatable: ^2.0.3
  dio: ^5.0.0  # Why does a model package need HTTP client?
  flutter_bloc: ^8.0.0  # Models don't need state management!
```

### 4. Keep Packages Focused

Each package should have **one clear responsibility**.

**✅ Good**:
- `quote_list` - Only quote list feature
- `sign_in` - Only sign-in feature
- `form_fields` - Only form validation

**❌ Bad**:
- `user_features` - Sign in, sign up, profile (too broad)
- `quote_stuff` - List, details, favorites (not focused)

### 5. Use Absolute Imports Between Packages

**✅ Good**:
```dart
import 'package:domain_models/domain_models.dart';
import 'package:component_library/component_library.dart';
```

**❌ Bad**:
```dart
import '../../../domain_models/lib/domain_models.dart';  // Fragile!
```

### 6. Localization Per Package

Each feature/component library has its own translations:

```
packages/sign_in/lib/src/l10n/
├── sign_in_localizations.dart
├── sign_in_localizations_en.dart
└── sign_in_localizations_pt.dart
```

**Why?**
- Feature can be translated independently
- Avoids massive centralized translation files
- Easier to maintain

### 7. Testing Per Package

Each package has its own `test/` directory:

```
packages/sign_in/
├── lib/
└── test/
    ├── sign_in_cubit_test.dart
    └── widget_test.dart
```

**Benefits**:
- Tests run independently
- Can test package in isolation
- Faster test execution (run only affected tests)

---

## Real-World Examples

### Example 1: Adding a New Feature

**Scenario**: Add a "Bookmarks" feature for saving favorite quotes

**Step 1**: Create feature package structure

```bash
mkdir -p packages/features/bookmarks/lib/src
mkdir -p packages/features/bookmarks/test
```

**Step 2**: Create pubspec.yaml

```yaml
name: bookmarks
publish_to: none

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
```

**Step 3**: Create files

```
lib/
├── bookmarks.dart                    # Barrel file
└── src/
    ├── bookmarks_screen.dart
    ├── bookmarks_cubit.dart
    ├── bookmarks_state.dart
    └── l10n/
        └── bookmarks_localizations.dart
```

**Step 4**: Implement barrel file

```dart
// lib/bookmarks.dart
export 'src/bookmarks_screen.dart';
export 'src/l10n/bookmarks_localizations.dart';
```

**Step 5**: Add to main app dependencies

```yaml
# Root pubspec.yaml
dependencies:
  bookmarks:
    path: packages/features/bookmarks
```

**Step 6**: Add route in `routing_table.dart`

```dart
_PathConstants.bookmarksPath: (_) => MaterialPage(
  name: 'bookmarks',
  child: BookmarksScreen(
    quoteRepository: quoteRepository,
  ),
),
```

### Example 2: Sharing Code Between Features

**Scenario**: Both `sign_in` and `sign_up` need username validation

**❌ Wrong Approach - Duplicate code**:
```dart
// In sign_in package
class Username { /* validation logic */ }

// In sign_up package
class Username { /* SAME validation logic - duplicated! */ }
```

**❌ Wrong Approach - Create common package**:
```dart
// Create packages/common/  ← BAD!
```

**✅ Right Approach - Create specialized package**:

**Step 1**: Identify the domain → Form validation

**Step 2**: Create `form_fields` package

```
packages/form_fields/
├── lib/
│   ├── form_fields.dart
│   └── src/
│       ├── username.dart
│       ├── email.dart
│       └── password.dart
└── pubspec.yaml
```

**Step 3**: Implement validation

```dart
// lib/src/username.dart
class Username extends FormzInput<String, UsernameValidationError> {
  // Validation logic
}
```

**Step 4**: Export in barrel file

```dart
// lib/form_fields.dart
export 'src/username.dart';
export 'src/email.dart';
export 'src/password.dart';
```

**Step 5**: Use in both features

```yaml
# sign_in/pubspec.yaml
dependencies:
  form_fields:
    path: ../../form_fields

# sign_up/pubspec.yaml
dependencies:
  form_fields:
    path: ../../form_fields
```

### Example 3: Repository Package Structure

**Quote Repository Internals**:

```
packages/quote_repository/
├── lib/
│   ├── quote_repository.dart              # Barrel (only this exported)
│   └── src/
│       ├── quote_repository.dart          # Main repository class
│       ├── quote_local_storage.dart       # Cache layer (PRIVATE)
│       └── mappers/                        # Data transformations (PRIVATE)
│           ├── quote_cm_to_dm.dart
│           ├── quote_rm_to_cm.dart
│           └── quote_rm_to_dm.dart
└── pubspec.yaml
```

**Why are mappers private?**
- Implementation detail
- Can change freely without affecting consumers
- Forces all data access through repository
- Clean abstraction

---

## Summary

The WonderWords Feature Package Architecture provides:

✅ **Scalability** - Easy to add features without restructuring
✅ **Maintainability** - Clear boundaries and responsibilities
✅ **Team Collaboration** - Clear ownership per package
✅ **Testability** - Packages tested in isolation
✅ **Flexibility** - Can experiment per feature
✅ **Self-Documenting** - Structure reveals app features
✅ **Encapsulation** - Private implementation via barrel files
✅ **Independence** - Features don't couple to each other

By following the four golden rules and organizing code by convenience (feature for screens, layer for infrastructure), you create a codebase that scales beautifully with your team and product.
