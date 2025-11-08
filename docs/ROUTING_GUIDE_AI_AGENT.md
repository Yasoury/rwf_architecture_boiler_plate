# Routing & Navigation Pattern - AI Agent Implementation Guide

## Purpose

This document provides precise rules and patterns for AI agents to implement routing and navigation in the WonderWords Flutter application. Follow these rules strictly to maintain architectural consistency.

---

## Architecture Overview

```
Main App Package (lib/)
  ├── main.dart                    → RouterDelegate setup
  ├── routing_table.dart           → All route definitions
  ├── tab_container_screen.dart    → Tab navigation UI
  └── screen_view_observer.dart    → Analytics observer

Feature Packages (packages/*/)
  ├── quote_list/                  → NEVER imports routemaster
  ├── profile_menu/                → NEVER imports routemaster
  └── sign_in/                     → NEVER imports routemaster

Navigation Flow:
  Feature → Callback → Routing Table → RoutemasterDelegate → Screen
```

---

## Rule Set

### RULE 1: Package Import Restrictions

**ONLY these files may import Routemaster:**
- `lib/main.dart`
- `lib/routing_table.dart`
- `lib/tab_container_screen.dart`
- `lib/screen_view_observer.dart`

**NEVER import Routemaster in:**
- Any file in `packages/` directory
- Any feature package
- Any repository
- Any BLoC/Cubit

**Correct import statement** (only in allowed files):
```dart
import 'package:routemaster/routemaster.dart';
```

### RULE 2: Path Constants Structure

**ALL paths MUST be defined in the `_PathConstants` class.**

**Location**: `lib/routing_table.dart`

**Template**:
```dart
class _PathConstants {
  const _PathConstants._();  // ALWAYS private constructor

  // Root path - ALWAYS '/'
  static String get tabContainerPath => '/';

  // Tab paths - build from parent
  static String get [name]Path => '${tabContainerPath}[segment]';

  // Nested paths - build from parent
  static String get [nested]Path => '$[parent]Path/[segment]';

  // Path parameters
  static String get [param]PathParameter => '[param]';

  // Dynamic paths - dual purpose method
  static String [name]Path({[Type]? [param]}) =>
      '$[parent]Path/${[param] ?? ':[param]PathParameter'}';
}
```

**Real Example**:
```dart
class _PathConstants {
  const _PathConstants._();

  static String get tabContainerPath => '/';
  static String get quoteListPath => '${tabContainerPath}quotes';
  static String get profileMenuPath => '${tabContainerPath}user';
  static String get updateProfilePath => '$profileMenuPath/update-profile';
  static String get signInPath => '${tabContainerPath}sign-in';
  static String get signUpPath => '${tabContainerPath}sign-up';
  static String get idPathParameter => 'id';

  static String quoteDetailsPath({int? quoteId}) =>
      '$quoteListPath/${quoteId ?? ':$idPathParameter'}';
}
```

**Validation Rules**:
- ✅ Class MUST be private (`_PathConstants`)
- ✅ Constructor MUST be private (`const _PathConstants._()`)
- ✅ All members MUST be `static`
- ✅ Use getters for fixed paths
- ✅ Use methods for dynamic paths
- ✅ Build paths from parent paths (composition)
- ✅ Root path MUST be `'/'`

### RULE 3: Routing Table Function Signature

**The routing table MUST follow this exact signature.**

**Template**:
```dart
Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required UserRepository userRepository,
  required QuoteRepository quoteRepository,
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
  // Add other dependencies as required parameters
}) {
  return {
    // Route definitions
  };
}
```

**Rules**:
- ✅ Return type MUST be `Map<String, PageBuilder>`
- ✅ Function name MUST be `buildRoutingTable`
- ✅ RouterDelegate MUST be first parameter
- ✅ All parameters MUST be `required`
- ✅ All dependencies MUST be passed as parameters (no global state)
- ✅ Use named parameters only

### RULE 4: Route Definition Patterns

#### Pattern 1: Simple Static Route

**Use when**: Route has no parameters, no navigation callbacks

**Template**:
```dart
_PathConstants.[name]Path: (_) => MaterialPage(
  name: '[kebab-case-name]',
  child: [ScreenWidget](
    repository: repository,
  ),
),
```

**Real Example**:
```dart
_PathConstants.updateProfilePath: (_) => MaterialPage(
  name: 'update-profile',
  child: UpdateProfileScreen(
    userRepository: userRepository,
    onUpdateProfileSuccess: () {
      routerDelegate.pop();
    },
  ),
),
```

#### Pattern 2: Route with Simple Callback

**Use when**: Screen needs to navigate elsewhere

**Template**:
```dart
_PathConstants.[name]Path: (_) => MaterialPage(
  name: '[kebab-case-name]',
  child: [ScreenWidget](
    on[Action]Tap: () {
      routerDelegate.push(_PathConstants.[target]Path);
    },
  ),
),
```

**Real Example**:
```dart
_PathConstants.profileMenuPath: (_) => MaterialPage(
  name: 'profile-menu',
  child: ProfileMenuScreen(
    quoteRepository: quoteRepository,
    userRepository: userRepository,
    onSignInTap: () {
      routerDelegate.push(_PathConstants.signInPath);
    },
    onSignUpTap: () {
      routerDelegate.push(_PathConstants.signUpPath);
    },
    onUpdateProfileTap: () {
      routerDelegate.push(_PathConstants.updateProfilePath);
    },
  ),
),
```

#### Pattern 3: Route with Navigation Result

**Use when**: Screen returns a result to the caller

**Template**:
```dart
_PathConstants.[name]Path: (route) => MaterialPage(
  name: '[kebab-case-name]',
  child: [ScreenWidget](
    on[Item]Selected: (id) {
      final navigation = routerDelegate.push<[ResultType]?>(
        _PathConstants.[target]Path([param]: id),
      );
      return navigation.result;
    },
  ),
),
```

**Real Example**:
```dart
_PathConstants.quoteListPath: (route) => MaterialPage(
  name: 'quotes-list',
  child: QuoteListScreen(
    quoteRepository: quoteRepository,
    userRepository: userRepository,
    onAuthenticationError: (context) {
      routerDelegate.push(_PathConstants.signInPath);
    },
    onQuoteSelected: (id) {
      final navigation = routerDelegate.push<Quote?>(
        _PathConstants.quoteDetailsPath(quoteId: id),
      );
      return navigation.result;
    },
    remoteValueService: remoteValueService,
  ),
),
```

#### Pattern 4: Route with Path Parameters

**Use when**: Route needs to extract parameters from URL

**Template**:
```dart
_PathConstants.[name]Path(): (info) => MaterialPage(
  name: '[kebab-case-name]',
  child: [ScreenWidget](
    [param]: [Type].parse(
      info.pathParameters[_PathConstants.[param]PathParameter] ?? '',
    ),
  ),
),
```

**Real Example**:
```dart
_PathConstants.quoteDetailsPath(): (info) => MaterialPage(
  name: 'quote-details',
  child: QuoteDetailsScreen(
    quoteRepository: quoteRepository,
    quoteId: int.parse(
      info.pathParameters[_PathConstants.idPathParameter] ?? '',
    ),
    onAuthenticationError: () {
      routerDelegate.push(_PathConstants.signInPath);
    },
    shareableLinkGenerator: (quote) {
      return dynamicLinkService.generateDynamicLinkUrl(
        path: _PathConstants.quoteDetailsPath(quoteId: quote.id),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: quote.body,
          description: quote.author,
        ),
      );
    },
  ),
),
```

**Key Points**:
- ✅ Use `()` after path method: `quoteDetailsPath()`
- ✅ Parameter is `info`, not `_`
- ✅ Extract with `info.pathParameters['param']`
- ✅ Always provide fallback: `?? ''` or `?? '0'`

#### Pattern 5: Fullscreen Dialog Route

**Use when**: Route should present as modal (iOS-style)

**Template**:
```dart
_PathConstants.[name]Path: (_) => MaterialPage(
  name: '[kebab-case-name]',
  fullscreenDialog: true,
  child: [ScreenWidget](...),
),
```

**Real Example**:
```dart
_PathConstants.signInPath: (_) => MaterialPage(
  name: 'sign-in',
  fullscreenDialog: true,
  child: Builder(
    builder: (context) {
      return SignInScreen(
        userRepository: userRepository,
        onSignInSuccess: () {
          routerDelegate.pop();
        },
        onSignUpTap: () {
          routerDelegate.push(_PathConstants.signUpPath);
        },
        onForgotMyPasswordTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return ForgotMyPasswordDialog(
                userRepository: userRepository,
                onCancelTap: () {
                  Navigator.of(context).pop();
                },
                onEmailRequestSuccess: () {
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      );
    },
  ),
),
```

#### Pattern 6: Tab Container Route

**Use when**: Creating root route with tabs

**Template**:
```dart
_PathConstants.tabContainerPath: (_) => CupertinoTabPage(
  child: const [TabContainerWidget](),
  paths: [
    _PathConstants.[tab1]Path,
    _PathConstants.[tab2]Path,
  ],
),
```

**Real Example**:
```dart
_PathConstants.tabContainerPath: (_) => CupertinoTabPage(
  child: const TabContainerScreen(),
  paths: [
    _PathConstants.quoteListPath,
    _PathConstants.profileMenuPath,
  ],
),
```

**Rules**:
- ✅ MUST use `CupertinoTabPage`, not `MaterialPage`
- ✅ `child` is the tab bar UI
- ✅ `paths` are the routes for each tab
- ✅ Order of `paths` determines tab order

### RULE 5: RouterDelegate Setup

**The RouterDelegate MUST be set up in `main.dart` following this pattern.**

**Template**:
```dart
class [AppName]State extends State<[AppName]> {
  // Dependencies
  late final [Dependency] _dependency = [Dependency]();

  // RouterDelegate - MUST be late final
  late final RoutemasterDelegate _routerDelegate = RoutemasterDelegate(
    observers: [
      ScreenViewObserver(
        analyticsService: _analyticsService,
      ),
    ],
    routesBuilder: (context) {
      return RouteMap(
        routes: buildRoutingTable(
          routerDelegate: _routerDelegate,
          // Pass all dependencies
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _routerDelegate,
      routeInformationParser: const RoutemasterParser(),
      // Other MaterialApp properties
    );
  }
}
```

**Real Example**:
```dart
class WonderWordsState extends State<WonderWords> {
  final _keyValueStorage = KeyValueStorage();
  final _analyticsService = AnalyticsService();
  final _dynamicLinkService = DynamicLinkService();

  late final FavQsApi _favQsApi = FavQsApi(
    userTokenSupplier: () => _userRepository.getUserToken(),
  );

  late final _quoteRepository = QuoteRepository(
    remoteApi: _favQsApi,
    keyValueStorage: _keyValueStorage,
  );

  late final _userRepository = UserRepository(
    remoteApi: _favQsApi,
    noSqlStorage: _keyValueStorage,
  );

  late final RoutemasterDelegate _routerDelegate = RoutemasterDelegate(
    observers: [
      ScreenViewObserver(
        analyticsService: _analyticsService,
      ),
    ],
    routesBuilder: (context) {
      return RouteMap(
        routes: buildRoutingTable(
          routerDelegate: _routerDelegate,
          userRepository: _userRepository,
          quoteRepository: _quoteRepository,
          remoteValueService: widget.remoteValueService,
          dynamicLinkService: _dynamicLinkService,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: _lightTheme.materialThemeData,
      darkTheme: _darkTheme.materialThemeData,
      supportedLocales: const [Locale('en', '')],
      localizationsDelegates: const [...],
      routerDelegate: _routerDelegate,
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
```

**Validation Rules**:
- ✅ `_routerDelegate` MUST be `late final`
- ✅ MUST use `RoutemasterDelegate`
- ✅ MUST include `observers` with `ScreenViewObserver`
- ✅ MUST use `routesBuilder` that returns `RouteMap`
- ✅ MUST pass `_routerDelegate` to `buildRoutingTable`
- ✅ MUST use `MaterialApp.router`, not `MaterialApp`
- ✅ MUST set `routeInformationParser: const RoutemasterParser()`

### RULE 6: Navigation Method Selection

**Choose the correct navigation method based on the scenario.**

#### Scenario 1: Push to New Route

**Use**: `routerDelegate.push()`

```dart
onSignInTap: () {
  routerDelegate.push(_PathConstants.signInPath);
},
```

#### Scenario 2: Pop Current Route

**Use**: `routerDelegate.pop()`

```dart
onSignInSuccess: () {
  routerDelegate.pop();
},
```

#### Scenario 3: Pop with Result

**Use**: `Navigator.of(context).pop(result)`

```dart
// In the screen being popped
final updatedQuote = await repository.updateQuote(id);
Navigator.of(context).pop(updatedQuote);  // Return to previous screen with result
```

#### Scenario 4: Push and Wait for Result

**Use**: `routerDelegate.push<T?>()`

```dart
onQuoteSelected: (id) {
  final navigation = routerDelegate.push<Quote?>(
    _PathConstants.quoteDetailsPath(quoteId: id),
  );
  return navigation.result;  // Returns Future<Quote?>
},
```

#### Scenario 5: Show Temporary Overlay (Dialog/BottomSheet)

**Use**: `showDialog()` or `showModalBottomSheet()`, NOT routes

```dart
onForgotMyPasswordTap: () {
  showDialog(
    context: context,
    builder: (context) => ForgotMyPasswordDialog(
      onCancelTap: () {
        Navigator.of(context).pop();  // Use Navigator, not routerDelegate
      },
    ),
  );
},
```

**Rule**: If it shouldn't be deep linkable, use Flutter widgets, not routes.

### RULE 7: Page Naming Convention

**ALL MaterialPage instances MUST have a name.**

**Template**:
```dart
MaterialPage(
  name: '[feature]-[screen]',  // kebab-case
  child: [ScreenWidget](...),
)
```

**Naming Rules**:
- ✅ Use kebab-case (lowercase with dashes)
- ✅ Be descriptive but concise
- ✅ Match the screen's purpose
- ✅ Examples: `'sign-in'`, `'quotes-list'`, `'quote-details'`, `'profile-menu'`

**Validation**:
```dart
✅ name: 'quotes-list'
✅ name: 'profile-menu'
✅ name: 'update-profile'
❌ name: 'QuotesList'  // Wrong: PascalCase
❌ name: 'quotes_list'  // Wrong: snake_case
❌ name: 'list'  // Wrong: Not descriptive enough
```

### RULE 8: Deep Link Integration

**Deep link handling MUST be set up in `main.dart` `initState`.**

**Template**:
```dart
class [AppName]State extends State<[AppName]> {
  late StreamSubscription _incomingDynamicLinksSubscription;

  @override
  void initState() {
    super.initState();

    // Handle deep link that opened the app
    _openInitialDynamicLinkIfAny();

    // Listen for deep links while app is running
    _incomingDynamicLinksSubscription =
        _dynamicLinkService.onNewDynamicLinkPath().listen(
          _routerDelegate.push,
        );
  }

  Future<void> _openInitialDynamicLinkIfAny() async {
    final path = await _dynamicLinkService.getInitialDynamicLinkPath();
    if (path != null) {
      _routerDelegate.push(path);
    }
  }

  @override
  void dispose() {
    _incomingDynamicLinksSubscription.cancel();
    super.dispose();
  }
}
```

**Real Example**:
```dart
class WonderWordsState extends State<WonderWords> {
  late StreamSubscription _incomingDynamicLinksSubscription;

  @override
  void initState() {
    super.initState();

    _openInitialDynamicLinkIfAny();

    _incomingDynamicLinksSubscription =
        _dynamicLinkService.onNewDynamicLinkPath().listen(
          _routerDelegate.push,
        );
  }

  Future<void> _openInitialDynamicLinkIfAny() async {
    final path = await _dynamicLinkService.getInitialDynamicLinkPath();
    if (path != null) {
      _routerDelegate.push(path);
    }
  }

  @override
  void dispose() {
    _incomingDynamicLinksSubscription.cancel();
    super.dispose();
  }
}
```

**Validation Rules**:
- ✅ Call `_openInitialDynamicLinkIfAny()` in `initState`
- ✅ Subscribe to `onNewDynamicLinkPath()` in `initState`
- ✅ Store subscription in instance variable
- ✅ Cancel subscription in `dispose()`
- ✅ Check for null before pushing initial link

### RULE 9: Deep Link Generation in Routes

**When a screen needs to generate shareable links, provide a generator callback.**

**Template**:
```dart
_PathConstants.[name]Path(): (info) => MaterialPage(
  child: [ScreenWidget](
    shareableLinkGenerator: (item) {
      return dynamicLinkService.generateDynamicLinkUrl(
        path: _PathConstants.[name]Path([param]: item.id),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: item.[titleField],
          description: item.[descriptionField],
        ),
      );
    },
  ),
),
```

**Real Example**:
```dart
_PathConstants.quoteDetailsPath(): (info) => MaterialPage(
  name: 'quote-details',
  child: QuoteDetailsScreen(
    quoteRepository: quoteRepository,
    quoteId: int.parse(
      info.pathParameters[_PathConstants.idPathParameter] ?? '',
    ),
    shareableLinkGenerator: (quote) {
      return dynamicLinkService.generateDynamicLinkUrl(
        path: _PathConstants.quoteDetailsPath(quoteId: quote.id),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: quote.body,
          description: quote.author,
        ),
      );
    },
  ),
),
```

**Validation Rules**:
- ✅ Callback MUST be named `shareableLinkGenerator` or similar
- ✅ MUST call `dynamicLinkService.generateDynamicLinkUrl()`
- ✅ `path` parameter MUST use path constant method
- ✅ Include `socialMetaTagParameters` for rich link previews
- ✅ Return type is `Future<String>`

### RULE 10: Tab Container Screen Implementation

**Tab UI MUST be implemented following this pattern.**

**Location**: `lib/tab_container_screen.dart`

**Template**:
```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:[app]/l10n/app_localizations.dart';

class TabContainerScreen extends StatelessWidget {
  const TabContainerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: tabState.tabBuilder,
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            label: l10n.[tab1]Label,
            icon: const Icon(Icons.[tab1Icon]),
          ),
          BottomNavigationBarItem(
            label: l10n.[tab2]Label,
            icon: const Icon(Icons.[tab2Icon]),
          ),
        ],
      ),
    );
  }
}
```

**Real Example**:
```dart
class TabContainerScreen extends StatelessWidget {
  const TabContainerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: tabState.tabBuilder,
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            label: l10n.quotesBottomNavigationBarItemLabel,
            icon: const Icon(Icons.format_quote),
          ),
          BottomNavigationBarItem(
            label: l10n.profileBottomNavigationBarItemLabel,
            icon: const Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
```

**Validation Rules**:
- ✅ MUST import `package:routemaster/routemaster.dart`
- ✅ MUST call `CupertinoTabPage.of(context)`
- ✅ MUST use `tabState.controller` and `tabState.tabBuilder`
- ✅ Number of items in `CupertinoTabBar` MUST match number of paths in route definition
- ✅ Order of items MUST match order of paths

### RULE 11: Screen View Observer Implementation

**Analytics tracking MUST be implemented via RoutemasterObserver.**

**Location**: `lib/screen_view_observer.dart`

**Template**:
```dart
import 'package:flutter/material.dart';
import 'package:monitoring/monitoring.dart';
import 'package:routemaster/routemaster.dart';

class ScreenViewObserver extends RoutemasterObserver {
  ScreenViewObserver({required this.analyticsService});

  final AnalyticsService analyticsService;

  void _sendScreenView(PageRoute<dynamic> route) {
    final String? screenName = route.settings.name;

    if (screenName != null) {
      analyticsService.setCurrentScreen(screenName);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
```

**Validation Rules**:
- ✅ MUST extend `RoutemasterObserver`
- ✅ MUST accept `AnalyticsService` in constructor
- ✅ MUST override `didPush` and `didPop`
- ✅ MUST extract `route.settings.name`
- ✅ MUST check if route is `PageRoute` before processing
- ✅ In `didPop`, track `previousRoute`, not `route`

---

## Implementation Checklist

When adding a new route:

- [ ] Add path constant to `_PathConstants` class
- [ ] Use parent path composition (e.g., `'$parentPath/segment'`)
- [ ] Add route definition to `buildRoutingTable` function
- [ ] Include `name` parameter in `MaterialPage`
- [ ] Use kebab-case for page name
- [ ] Pass all required dependencies
- [ ] Use callbacks for navigation, not direct router access
- [ ] If route has parameters, use `quoteDetailsPath()` pattern
- [ ] Extract parameters with `info.pathParameters['param']`
- [ ] If screen needs deep linking, add `shareableLinkGenerator`
- [ ] If route is a tab, use `CupertinoTabPage`
- [ ] Test deep linking by navigating directly to path

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Importing Routemaster in Feature Packages

```dart
// In packages/quote_list/lib/src/quote_list_screen.dart
import 'package:routemaster/routemaster.dart';  // ❌ NEVER!

class QuoteListScreen extends StatelessWidget {
  void _navigateToDetails(int id) {
    Routemaster.of(context).push('/quotes/$id');  // ❌ Feature depends on routing
  }
}
```

### ❌ Anti-Pattern 2: Hardcoding Paths

```dart
routerDelegate.push('/sign-in');  // ❌ Typo-prone
routerDelegate.push('/quotes/' + id.toString());  // ❌ Error-prone
```

✅ **Correct**:
```dart
routerDelegate.push(_PathConstants.signInPath);
routerDelegate.push(_PathConstants.quoteDetailsPath(quoteId: id));
```

### ❌ Anti-Pattern 3: Not Naming Pages

```dart
MaterialPage(
  child: MyScreen(),  // ❌ No name, won't appear in analytics
)
```

✅ **Correct**:
```dart
MaterialPage(
  name: 'my-screen',
  child: MyScreen(),
)
```

### ❌ Anti-Pattern 4: Creating Routes for Dialogs

```dart
_PathConstants.confirmDialogPath: (_) => MaterialPage(  // ❌ Dialog as route
  child: ConfirmDialog(),
),
```

✅ **Correct**:
```dart
onDeleteTap: () {
  showDialog(  // ✅ Use showDialog for temporary overlays
    context: context,
    builder: (context) => ConfirmDialog(),
  );
},
```

### ❌ Anti-Pattern 5: Not Using Path Composition

```dart
static String get profileMenuPath => '/user';
static String get updateProfilePath => '/user/update-profile';  // ❌ Duplication
```

✅ **Correct**:
```dart
static String get profileMenuPath => '/user';
static String get updateProfilePath => '$profileMenuPath/update-profile';  // ✅ Composed
```

### ❌ Anti-Pattern 6: Forgetting to Cancel Subscriptions

```dart
@override
void initState() {
  super.initState();
  _dynamicLinkService.onNewDynamicLinkPath().listen(
    _routerDelegate.push,
  );  // ❌ Subscription not stored, can't cancel
}
// No dispose method - memory leak!
```

✅ **Correct**:
```dart
late StreamSubscription _subscription;

@override
void initState() {
  super.initState();
  _subscription = _dynamicLinkService.onNewDynamicLinkPath().listen(
    _routerDelegate.push,
  );
}

@override
void dispose() {
  _subscription.cancel();  // ✅ Proper cleanup
  super.dispose();
}
```

### ❌ Anti-Pattern 7: Not Providing Fallback for Path Parameters

```dart
quoteId: int.parse(info.pathParameters['id']),  // ❌ Throws if null
```

✅ **Correct**:
```dart
quoteId: int.parse(info.pathParameters['id'] ?? '0'),  // ✅ Fallback value
```

---

## Complete Flow Examples

### Example 1: Adding a New Screen with Navigation

**Task**: Add a "Settings" screen accessible from Profile Menu

**Step 1**: Add path constant

```dart
class _PathConstants {
  // ... existing paths

  static String get settingsPath => '$profileMenuPath/settings';
}
```

**Step 2**: Add route definition

```dart
Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required UserRepository userRepository,
  // ... other dependencies
}) {
  return {
    // ... existing routes

    _PathConstants.settingsPath: (_) => MaterialPage(
      name: 'settings',
      child: SettingsScreen(
        userRepository: userRepository,
        onBackTap: () {
          routerDelegate.pop();
        },
      ),
    ),
  };
}
```

**Step 3**: Add navigation callback in profile menu route

```dart
_PathConstants.profileMenuPath: (_) => MaterialPage(
  name: 'profile-menu',
  child: ProfileMenuScreen(
    // ... existing callbacks
    onSettingsTap: () {
      routerDelegate.push(_PathConstants.settingsPath);  // ← New callback
    },
  ),
),
```

**Step 4**: Implement callback in ProfileMenuScreen

```dart
// In packages/profile_menu/lib/src/profile_menu_screen.dart
class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({
    required this.onSettingsTap,  // ← Accept callback
    // ... other parameters
  });

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Settings'),
          onTap: onSettingsTap,  // ← Call callback
        ),
      ],
    );
  }
}
```

### Example 2: Adding a Route with Path Parameters

**Task**: Add a "User Profile" screen showing another user's profile by username

**Step 1**: Add path constant with parameter

```dart
class _PathConstants {
  // ... existing paths

  static String get usernamePathParameter => 'username';

  static String userProfilePath({String? username}) =>
      '$profileMenuPath/${username ?? ':$usernamePathParameter'}';
}
```

**Step 2**: Add route definition

```dart
_PathConstants.userProfilePath(): (info) => MaterialPage(
  name: 'user-profile',
  child: UserProfileScreen(
    username: info.pathParameters[_PathConstants.usernamePathParameter] ?? '',
    quoteRepository: quoteRepository,
  ),
),
```

**Step 3**: Navigate with parameter

```dart
onUserTap: (username) {
  routerDelegate.push(
    _PathConstants.userProfilePath(username: username),
  );
},
```

**URL Examples**:
- Declaration: `/user/:username`
- Navigation: `/user/john_doe`

### Example 3: Adding Deep Link Support to Existing Screen

**Task**: Make user profile screen shareable via deep links

**Step 1**: Add `shareableLinkGenerator` to route

```dart
_PathConstants.userProfilePath(): (info) => MaterialPage(
  name: 'user-profile',
  child: UserProfileScreen(
    username: info.pathParameters[_PathConstants.usernamePathParameter] ?? '',
    quoteRepository: quoteRepository,
    shareableLinkGenerator: (userProfile) {  // ← Add generator
      return dynamicLinkService.generateDynamicLinkUrl(
        path: _PathConstants.userProfilePath(username: userProfile.username),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: userProfile.displayName,
          description: 'View ${userProfile.username}\'s profile',
        ),
      );
    },
  ),
),
```

**Step 2**: Use generator in screen

```dart
// In UserProfileScreen
Future<void> _shareProfile() async {
  final link = await widget.shareableLinkGenerator(currentUser);
  Share.share(link);
}
```

---

## Quick Reference

### File Locations
- **Routing table**: `lib/routing_table.dart`
- **Path constants**: `lib/routing_table.dart` (inside `_PathConstants` class)
- **RouterDelegate setup**: `lib/main.dart`
- **Tab UI**: `lib/tab_container_screen.dart`
- **Analytics observer**: `lib/screen_view_observer.dart`
- **Deep link service**: `packages/monitoring/lib/src/dynamic_link_service.dart`

### Import Statements

**Only in `lib/main.dart`, `lib/routing_table.dart`, `lib/tab_container_screen.dart`, `lib/screen_view_observer.dart`:**
```dart
import 'package:routemaster/routemaster.dart';
```

**Never in feature packages:**
```dart
// ❌ NEVER do this in packages/ directory
import 'package:routemaster/routemaster.dart';
```

### Navigation Methods
- **Push route**: `routerDelegate.push(path)`
- **Push with result**: `routerDelegate.push<T?>(path).result`
- **Pop route**: `routerDelegate.pop()`
- **Pop with result**: `Navigator.of(context).pop(result)`
- **Show dialog**: `showDialog(context: context, builder: ...)`

### Page Types
- **Regular page**: `MaterialPage(...)`
- **Modal page**: `MaterialPage(fullscreenDialog: true, ...)`
- **Tab container**: `CupertinoTabPage(...)`

### Path Parameter Access
```dart
info.pathParameters['paramName'] ?? 'fallback'
```

---

## Validation Rules for AI Agents

Before submitting code, verify:

1. ✅ Routemaster only imported in main app package files
2. ✅ All paths defined in `_PathConstants` class
3. ✅ Path constants use composition (build from parent paths)
4. ✅ `buildRoutingTable` has correct signature
5. ✅ RouterDelegate passed to `buildRoutingTable`
6. ✅ All dependencies passed as required parameters
7. ✅ All MaterialPage instances have `name` parameter
8. ✅ Page names use kebab-case
9. ✅ Features use callbacks, never direct router access
10. ✅ Path parameters extracted with fallback values
11. ✅ Deep link subscription cancelled in `dispose()`
12. ✅ Tab order matches between `CupertinoTabPage` and `CupertinoTabBar`

---

## Summary

Follow these rules precisely to implement routing that:
- Maintains clean architecture boundaries
- Provides excellent deep linking support
- Integrates seamlessly with analytics
- Remains testable and maintainable
- Scales with application complexity

When in doubt, refer to the real examples provided in this document.
