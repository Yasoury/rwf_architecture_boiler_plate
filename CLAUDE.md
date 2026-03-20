# CLAUDE.md

This file provides guidance to Claude Code. Detailed examples and patterns are in `docs/architecture/` — **only read a sub-document when the current task requires that specific topic**.

## Project Overview

Flutter Clean Architecture monorepo (WonderWords app — quotes archive using FavQs API).

**Key Technologies:** Flutter, Dart, flutter_bloc (Cubits & Blocs), Isar (local database via `isar_community`), GoRouter (navigation), Formz (form validation), Firebase (analytics, crashlytics), storybook_flutter.

---

## Build Commands

Use the Makefile for ALL development tasks. Never run `flutter pub get` or `flutter test` directly.

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
├── features/                    # Feature packages (one per screen/dialog)
├── component_library/           # Shared UI components + theme + storybook
├── domain_models/               # Domain entities and exceptions
├── key_value_storage/           # Isar database wrapper (singleton)
├── monitoring/                  # Firebase Analytics, Crashlytics, Remote Config
├── fav_qs_api/                  # REST API client (Dio-based)
├── quote_repository/            # Quote data access (cache + network)
├── user_repository/             # User/auth data access (secure + cache + network)
└── form_fields/                 # Formz-based field validation
```

---

## Package Architecture Rules (STRICT)

### Rule 1: Features Get Their Own Package
A feature = a screen OR a dialog with I/O calls. Each is a separate package under `packages/features/`.

### Rule 2: Features Do NOT Know About Each Other
Feature packages NEVER import other feature packages. Use callbacks (`VoidCallback onSignUpTap`) for navigation. The main app's `routing_table.dart` wires everything.

### Rule 3: Repositories Get Their Own Package
Each repository is a separate package — they're shared across features.

### Rule 4: No Common Package
NEVER create a "common" package. Create specialized packages instead (`component_library`, `domain_models`, `form_fields`, etc.).

---

## Barrel File Pattern

Every package uses `lib/src/` for implementation and a barrel file at `lib/<package_name>.dart` for public API.

- Features export ONLY their screen widget + localization class (Cubits/Blocs are PRIVATE)
- Repositories export ONLY the repository class (local storage is PRIVATE)

---

## Three-Layer Model Architecture

| Type | Suffix | Location | Annotations |
|------|--------|----------|-------------|
| Domain Model | (none) | `domain_models` | Equatable |
| Cache Model | `CM` | `key_value_storage` | `@collection` (Isar) |
| Remote Model | `RM` | `fav_qs_api` | `@JsonSerializable` |

NEVER leak one layer's model into another. Use extension-method mappers (`toDomainModel()`, `toCacheModel()`). Mappers live in the repository's `mappers/` directory.

Run `make build-runner` after modifying `@collection` or `@JsonSerializable` classes.

---

## Code Style & Conventions

- Use `const` constructors wherever possible
- All state classes extend `Equatable` with proper `props`
- Use `super.key` in widget constructors
- Private fields use underscore prefix (`_localStorage`)
- Use `late final` for lazy initialization
- Named parameters with `required` for non-optional dependencies
- Extension methods for model mapping (not standalone functions)
- Font family: `'IBMPlexSansArabic'` for Arabic support
- Business logic in Cubits/Blocs, NOT in widgets
- Data coordination in repositories, NOT in Cubits/Blocs
- Dependencies from OTHER packages → require in constructor
- Dependencies from SAME package → instantiate internally
- Use `@visibleForTesting` optional parameter for test mocks

---

## New Feature Shortcut

Always use `./create_feature.sh my_feature_name` to scaffold new features. See full guide below.

---

## Detailed Architecture Guides

Read these **only when working on the related topic**:

| Topic | Document | Read when... |
|-------|----------|-------------|
| Cubits, Blocs, events, state patterns, UI integration | [state-management.md](docs/architecture/state-management.md) | Building or modifying screen logic |
| Formz fields, form cubits, focus/unfocus, submission | [forms-and-validation.md](docs/architecture/forms-and-validation.md) | Working on form/input features |
| GoRouter, callbacks, tabs, AppRoutes, navigation rules | [routing-and-navigation.md](docs/architecture/routing-and-navigation.md) | Adding routes or navigation |
| Models, mappers, Isar, repositories, fetch policies, caching | [data-layer.md](docs/architecture/data-layer.md) | Working on data access or storage |
| API → Domain exception translation, error display | [exception-handling.md](docs/architecture/exception-handling.md) | Adding error handling |
| WonderTheme, dark mode, Spacing, FontSize | [theming.md](docs/architecture/theming.md) | Modifying theme or styling |
| Per-feature i18n, ARB files, l10n.yaml, delegates | [localization.md](docs/architecture/localization.md) | Adding/modifying translations |
| bloc_test, repository tests, widget tests, mocks | [testing.md](docs/architecture/testing.md) | Writing or modifying tests |
| Storybook, component rules, story patterns | [component-library.md](docs/architecture/component-library.md) | Adding shared UI components |
| Firebase analytics, crashlytics, remote config | [monitoring.md](docs/architecture/monitoring.md) | Working on monitoring/analytics |
| Token flow, secure storage, DI setup | [authentication.md](docs/architecture/authentication.md) | Working on auth or DI |
| Infinite scroll, fetch policies, page state | [pagination.md](docs/architecture/pagination.md) | Building paginated lists |
| Step-by-step feature creation guide | [new-feature-guide.md](docs/architecture/new-feature-guide.md) | Creating a new feature package |
