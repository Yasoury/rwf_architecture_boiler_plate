# Routing & Navigation Guide for WonderWords Flutter App

## Overview

This document explains how the WonderWords Flutter application implements routing and navigation using **Navigator 2.0 with the Routemaster package**. This modern routing approach provides excellent deep linking support, tab-based navigation, and maintains clean separation between feature packages.

## Table of Contents

1. [Core Philosophy](#core-philosophy)
2. [Why Navigator 2.0?](#why-navigator-20)
3. [Architecture Overview](#architecture-overview)
4. [Path Management Strategy](#path-management-strategy)
5. [Routing Table Pattern](#routing-table-pattern)
6. [Tab-Based Navigation](#tab-based-navigation)
7. [Navigation Patterns](#navigation-patterns)
8. [Deep Linking](#deep-linking)
9. [Analytics Integration](#analytics-integration)
10. [Best Practices](#best-practices)
11. [Real-World Examples](#real-world-examples)

---

## Core Philosophy

The WonderWords routing architecture follows these principles:

- **Declarative Routing**: Routes are declared as a map, making it easy to see all app routes at a glance
- **Deep Link First**: Built on Navigator 2.0, which was designed from the ground up for deep linking
- **Feature Decoupling**: Feature packages never import routing libraries; navigation is handled via callbacks
- **Centralized Control**: All routing logic lives in one place (the main app package)
- **Type Safety**: Path parameters and navigation results are properly typed
- **Analytics Ready**: Built-in support for screen view tracking

### Why This Approach?

1. **Deep Linking Support**: Essential for sharing content, notifications, and web integration
2. **Maintainability**: All routes defined in one place, easy to update
3. **Testability**: Feature packages can be tested without navigation dependencies
4. **Scalability**: Adding new routes is straightforward and doesn't affect existing code
5. **Clean Architecture**: Clear separation between features and navigation infrastructure

---

## Why Navigator 2.0?

### Navigator 1.0 Limitations

Flutter's original Navigator (Nav 1) had three main approaches:

1. **Anonymous Routes**: `MaterialApp(home: MyScreen())`
   - ❌ Hard to reuse navigation code
   - ✅ Simple to learn

2. **Simple Named Routes**: `MaterialApp(routes: {...})`
   - ✅ Code reuse possible
   - ❌ Can't parse route parameters from URLs
   - ❌ Poor deep linking support

3. **Advanced Named Routes**: `MaterialApp(onGenerateRoute: ...)`
   - ✅ Can parse route parameters
   - ❌ Complex to implement
   - ❌ Still has deep linking limitations

### Navigator 2.0 Advantages

Navigator 2.0 was built to solve the deep linking problem:

✅ **Full deep link support** - Can push/pop multiple pages at once
✅ **URL parameter parsing** - Extract IDs and parameters from paths
✅ **Web-ready** - Works seamlessly with browser navigation
✅ **Declarative** - Routes declared as configuration, not imperative code

❌ **Complexity** - Requires `RouterDelegate` and `RouteInformationParser`

### The Routemaster Solution

**Routemaster** makes Navigator 2.0 as simple as named routes:

```dart
// Without Routemaster (Navigator 2.0 raw)
class MyRouterDelegate extends RouterDelegate {...}  // 100+ lines
class MyRouteInformationParser extends RouteInformationParser {...}  // 50+ lines

// With Routemaster
final routerDelegate = RoutemasterDelegate(
  routesBuilder: (context) => RouteMap(
    routes: {
      '/': (_) => MaterialPage(child: HomeScreen()),
      '/details/:id': (info) => MaterialPage(child: DetailsScreen(id: info.pathParameters['id'])),
    },
  ),
);
```

✅ `RouteInformationParser` provided out-of-the-box
✅ `RouterDelegate` mostly implemented (just provide routes)
✅ Simple map-based route definition like Nav 1
✅ Full Navigator 2.0 power under the hood

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Main App Package                         │
│  - Owns RouterDelegate                                           │
│  - Defines all routes in routing_table.dart                      │
│  - Handles deep links                                            │
│  - Integrates all features via callbacks                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Navigation via callbacks
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                      Feature Packages                            │
│  - Quote List, Profile Menu, Sign In, etc.                       │
│  - Accept navigation callbacks as parameters                     │
│  - Never import routing libraries                                │
│  - Trigger navigation via callback invocation                    │
└──────────────────────────────────────────────────────────────────┘
```

### File Structure

```
lib/
├── main.dart                      # App entry, RouterDelegate setup
├── routing_table.dart             # All route definitions
├── tab_container_screen.dart      # Tab navigation UI
└── screen_view_observer.dart      # Analytics tracking

packages/
├── quote_list/                    # Feature package
│   └── Does NOT import routemaster
├── profile_menu/                  # Feature package
│   └── Does NOT import routemaster
└── monitoring/
    └── src/
        └── dynamic_link_service.dart  # Deep link handling
```

**Key Point**: Only `main.dart` and `routing_table.dart` import Routemaster!

---

## Path Management Strategy

### Centralized Path Constants

All paths are defined in a single private class: `_PathConstants`

**Location**: `lib/routing_table.dart`

```dart
class _PathConstants {
  const _PathConstants._();  // Private constructor prevents instantiation

  // Root path
  static String get tabContainerPath => '/';

  // Tab paths
  static String get quoteListPath => '${tabContainerPath}quotes';
  static String get profileMenuPath => '${tabContainerPath}user';

  // Nested paths
  static String get updateProfilePath => '$profileMenuPath/update-profile';
  static String get signInPath => '${tabContainerPath}sign-in';
  static String get signUpPath => '${tabContainerPath}sign-up';

  // Path parameters
  static String get idPathParameter => 'id';

  // Dynamic paths (dual purpose method)
  static String quoteDetailsPath({int? quoteId}) =>
      '$quoteListPath/${quoteId ?? ':$idPathParameter'}';
}
```

### Path Composition Benefits

1. **Hierarchical Structure**: Paths built from parent paths
   - `/user/update-profile` naturally extends from `/user`
   - Changes to parent paths automatically propagate

2. **Type Safety**: Compile-time errors if you reference a non-existent path

3. **Single Source of Truth**: Change path once, updates everywhere

4. **Self-Documenting**: Path structure reveals app hierarchy

### Dual-Purpose Dynamic Paths

The `quoteDetailsPath()` method serves two purposes:

```dart
static String quoteDetailsPath({int? quoteId}) =>
    '$quoteListPath/${quoteId ?? ':$idPathParameter'}';
```

**Purpose 1: Route Declaration** (no parameter)
```dart
_PathConstants.quoteDetailsPath(): (info) => MaterialPage(...),
// Generates: '/quotes/:id'
```

**Purpose 2: Navigation** (with parameter)
```dart
routerDelegate.push(_PathConstants.quoteDetailsPath(quoteId: 42));
// Generates: '/quotes/42'
```

---

## Routing Table Pattern

### The `buildRoutingTable` Function

All routes are defined in a single function that returns `Map<String, PageBuilder>`.

**Location**: `lib/routing_table.dart`

```dart
Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required UserRepository userRepository,
  required QuoteRepository quoteRepository,
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
}) {
  return {
    // Route definitions...
  };
}
```

### Key Design Decisions

#### 1. Dependency Injection via Parameters

All dependencies are passed as function parameters:

✅ **Benefits**:
- Clear visibility of all app dependencies
- Easy to test (can pass mocks)
- No global state or service locators
- Explicit dependency graph

```dart
// In main.dart
routes: buildRoutingTable(
  routerDelegate: _routerDelegate,
  userRepository: _userRepository,
  quoteRepository: _quoteRepository,
  remoteValueService: widget.remoteValueService,
  dynamicLinkService: _dynamicLinkService,
),
```

#### 2. RouterDelegate Access

The function receives its own `RouterDelegate`:

**Why?** Routes need to trigger navigation (push/pop) from within screens.

```dart
Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,  // ← Self-reference
  // ...
}) {
  return {
    _PathConstants.signInPath: (_) => MaterialPage(
      child: SignInScreen(
        onSignUpTap: () {
          routerDelegate.push(_PathConstants.signUpPath);  // ← Used here
        },
      ),
    ),
  };
}
```

#### 3. Navigation Callbacks Pattern

Feature packages receive callbacks instead of the router:

```dart
_PathConstants.profileMenuPath: (_) => MaterialPage(
  child: ProfileMenuScreen(
    onSignInTap: () {                              // ← Callback
      routerDelegate.push(_PathConstants.signInPath);  // ← Handled in routing table
    },
    onSignUpTap: () {                              // ← Callback
      routerDelegate.push(_PathConstants.signUpPath);  // ← Handled in routing table
    },
  ),
),
```

**Benefits**:
- Feature packages remain navigation-agnostic
- Can test features without routing infrastructure
- Easy to change navigation behavior without touching features
- Clear contract between app and features

---

## Tab-Based Navigation

### CupertinoTabPage for Nested Routes

WonderWords uses Routemaster's `CupertinoTabPage` for tab navigation.

```dart
_PathConstants.tabContainerPath: (_) => CupertinoTabPage(
  child: const TabContainerScreen(),
  paths: [
    _PathConstants.quoteListPath,    // Tab 1: Quotes
    _PathConstants.profileMenuPath,  // Tab 2: Profile
  ],
),
```

### How It Works

1. **Tab Container Route**: The root path (`/`) is a `CupertinoTabPage`
2. **Tab Paths**: Each tab is a separate route (`/quotes`, `/user`)
3. **Nested Navigation**: Each tab has its own navigation stack
4. **Persistent Bottom Bar**: Tab bar stays visible when navigating within tabs

### Tab Container Screen

**Location**: `lib/tab_container_screen.dart`

```dart
class TabContainerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);  // ← Provided by Routemaster

    return CupertinoTabScaffold(
      controller: tabState.controller,  // ← Controls which tab is active
      tabBuilder: tabState.tabBuilder,  // ← Builds the content for each tab
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

### Tab Navigation Flow

```
User taps "Quotes" tab:
  → URL becomes: /quotes
  → Quote list screen displays
  → Bottom bar shows "Quotes" selected

User taps a quote:
  → URL becomes: /quotes/42
  → Quote details screen displays
  → Bottom bar remains visible (nested navigation)

User taps "Profile" tab:
  → URL becomes: /user
  → Profile screen displays
  → Bottom bar shows "Profile" selected
```

---

## Navigation Patterns

### Pattern 1: Simple Push Navigation

**Use Case**: Navigate to a new screen

```dart
_PathConstants.signInPath: (_) => MaterialPage(
  name: 'sign-in',
  child: SignInScreen(
    onSignUpTap: () {
      routerDelegate.push(_PathConstants.signUpPath);  // ← Simple push
    },
  ),
),
```

### Pattern 2: Pop After Success

**Use Case**: Close screen after completing an action

```dart
_PathConstants.signInPath: (_) => MaterialPage(
  child: SignInScreen(
    onSignInSuccess: () {
      routerDelegate.pop();  // ← Close sign-in screen
    },
  ),
),
```

### Pattern 3: Navigation with Result

**Use Case**: Navigate to screen, wait for result, return it

```dart
_PathConstants.quoteListPath: (route) => MaterialPage(
  child: QuoteListScreen(
    onQuoteSelected: (id) {
      final navigation = routerDelegate.push<Quote?>(  // ← Typed result
        _PathConstants.quoteDetailsPath(quoteId: id),
      );
      return navigation.result;  // ← Return Future<Quote?>
    },
  ),
),
```

**How the result is set** (in quote details screen):
```dart
Navigator.of(context).pop(updatedQuote);  // Returns Quote? to caller
```

### Pattern 4: Fullscreen Dialog

**Use Case**: Modal screens that should cover everything

```dart
_PathConstants.signInPath: (_) => MaterialPage(
  name: 'sign-in',
  fullscreenDialog: true,  // ← iOS-style modal presentation
  child: SignInScreen(...),
),
```

### Pattern 5: Show Dialog (Not a Route)

**Use Case**: Temporary overlays that shouldn't affect navigation stack

```dart
onForgotMyPasswordTap: () {
  showDialog(  // ← Regular Flutter dialog, not a route
    context: context,
    builder: (context) => ForgotMyPasswordDialog(
      onCancelTap: () => Navigator.of(context).pop(),  // ← Use Navigator, not routerDelegate
    ),
  );
},
```

**Key Difference**:
- `routerDelegate.push()` → Adds to URL, affects back button, deep linkable
- `showDialog()` → Temporary overlay, doesn't change URL, not deep linkable

### Pattern 6: Path Parameters

**Use Case**: Dynamic routes with IDs

```dart
_PathConstants.quoteDetailsPath(): (info) => MaterialPage(
  child: QuoteDetailsScreen(
    quoteId: int.parse(
      info.pathParameters[_PathConstants.idPathParameter] ?? '',  // ← Extract 'id' from /quotes/:id
    ),
  ),
),
```

**URL Examples**:
- `/quotes/42` → `quoteId = 42`
- `/quotes/123` → `quoteId = 123`

### Pattern 7: Authentication-Required Navigation

**Use Case**: Redirect to sign-in when authentication is needed

```dart
_PathConstants.quoteListPath: (route) => MaterialPage(
  child: QuoteListScreen(
    onAuthenticationError: (context) {
      routerDelegate.push(_PathConstants.signInPath);  // ← Redirect to sign-in
    },
  ),
),
```

---

## Deep Linking

### What Are Deep Links?

Deep links allow users to open specific content in your app via a URL:

```
User taps: https://wonderwords1.page.link/quotes/42
  ↓
App launches and navigates to: /quotes/42
  ↓
User sees: Quote details screen for quote #42
```

### Deep Link Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  Firebase Dynamic Links                                           │
│  - Generates short links: https://wonderwords1.page.link/xyz      │
│  - Handles iOS/Android app store fallback                         │
│  - Provides social meta tags for rich previews                    │
└───────────────────────────┬──────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  DynamicLinkService (packages/monitoring)                         │
│  - Generates dynamic link URLs                                    │
│  - Listens for incoming links (app already open)                  │
│  - Extracts initial link (app opened by link)                     │
└───────────────────────────┬──────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  RoutemasterDelegate (main.dart)                                  │
│  - Receives path from DynamicLinkService                          │
│  - Pushes path to navigation stack                                │
│  - Navigator 2.0 handles the rest                                 │
└──────────────────────────────────────────────────────────────────┘
```

### Generating Deep Links

**Location**: `lib/routing_table.dart`

```dart
_PathConstants.quoteDetailsPath(): (info) => MaterialPage(
  child: QuoteDetailsScreen(
    shareableLinkGenerator: (quote) {
      return dynamicLinkService.generateDynamicLinkUrl(
        path: _PathConstants.quoteDetailsPath(quoteId: quote.id),  // ← Path in app
        socialMetaTagParameters: SocialMetaTagParameters(
          title: quote.body,      // ← Preview title
          description: quote.author,  // ← Preview description
        ),
      );
    },
  ),
),
```

**What this does**:
1. Takes the quote ID (e.g., 42)
2. Generates path: `/quotes/42`
3. Creates Firebase Dynamic Link: `https://wonderwords1.page.link/xyz`
4. Adds social meta tags for rich link previews
5. Returns URL to share via Share Sheet

### Handling Incoming Deep Links

**Location**: `lib/main.dart`

```dart
class WonderWordsState extends State<WonderWords> {
  late final RoutemasterDelegate _routerDelegate = RoutemasterDelegate(...);
  late StreamSubscription _incomingDynamicLinksSubscription;

  @override
  void initState() {
    super.initState();

    // Handle deep link that opened the app
    _openInitialDynamicLinkIfAny();

    // Listen for deep links while app is running
    _incomingDynamicLinksSubscription =
        _dynamicLinkService.onNewDynamicLinkPath().listen(
          _routerDelegate.push,  // ← Automatically navigate to new link
        );
  }

  Future<void> _openInitialDynamicLinkIfAny() async {
    final path = await _dynamicLinkService.getInitialDynamicLinkPath();
    if (path != null) {
      _routerDelegate.push(path);  // ← Navigate to initial deep link
    }
  }
}
```

**Two scenarios handled**:

1. **App Launched by Deep Link**:
   - `getInitialDynamicLinkPath()` retrieves the link
   - Push the path to router

2. **Deep Link Received While App Running**:
   - `onNewDynamicLinkPath()` stream emits new links
   - Automatically push to router via `.listen()`

### DynamicLinkService Implementation

**Location**: `packages/monitoring/lib/src/dynamic_link_service.dart`

```dart
class DynamicLinkService {
  static const _domainUriPrefix = 'https://wonderwords1.page.link';
  static const _iOSBundleId = 'com.raywenderlich.wonderWords';
  static const _androidPackageName = 'com.example.rwf_architecture_boiler_plate';

  // Generate a shareable deep link
  Future<String> generateDynamicLinkUrl({
    required String path,
    SocialMetaTagParameters? socialMetaTagParameters,
  }) async {
    final parameters = DynamicLinkParameters(
      uriPrefix: _domainUriPrefix,
      link: Uri.parse('$_domainUriPrefix$path'),  // ← Full URL with path
      androidParameters: const AndroidParameters(packageName: _androidPackageName),
      iosParameters: const IOSParameters(bundleId: _iOSBundleId),
      socialMetaTagParameters: socialMetaTagParameters,
    );

    final shortLink = await _dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl.toString();  // ← Returns short link
  }

  // Get the link that opened the app (if any)
  Future<String?> getInitialDynamicLinkPath() async {
    final data = await _dynamicLinks.getInitialLink();
    final link = data?.link;
    return link?.path;  // ← Returns just the path part (e.g., /quotes/42)
  }

  // Stream of new links received while app is running
  Stream<String> onNewDynamicLinkPath() {
    return _dynamicLinks.onLink.map((data) => data.link.path);
  }
}
```

---

## Analytics Integration

### Screen View Tracking

WonderWords automatically tracks screen views using `RoutemasterObserver`.

**Location**: `lib/screen_view_observer.dart`

```dart
class ScreenViewObserver extends RoutemasterObserver {
  ScreenViewObserver({required this.analyticsService});

  final AnalyticsService analyticsService;

  void _sendScreenView(PageRoute<dynamic> route) {
    final String? screenName = route.settings.name;  // ← Page name from MaterialPage
    if (screenName != null) {
      analyticsService.setCurrentScreen(screenName);  // ← Send to Firebase Analytics
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);  // ← Track when new screen is pushed
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);  // ← Track when returning to previous screen
    }
  }
}
```

### Registering the Observer

**Location**: `lib/main.dart`

```dart
late final RoutemasterDelegate _routerDelegate = RoutemasterDelegate(
  observers: [
    ScreenViewObserver(
      analyticsService: _analyticsService,  // ← Register observer
    ),
  ],
  routesBuilder: (context) => RouteMap(...),
);
```

### Naming Pages for Analytics

Every page should have a `name` for proper tracking:

```dart
_PathConstants.quoteListPath: (route) => MaterialPage(
  name: 'quotes-list',  // ← This name appears in analytics
  child: QuoteListScreen(...),
),
```

**Analytics Event**:
```
screen_view {
  firebase_screen: "quotes-list",
  firebase_screen_class: "QuoteListScreen"
}
```

---

## Best Practices

### 1. Never Import Routemaster in Feature Packages

❌ **Bad** - Feature depends on routing library:
```dart
// In packages/quote_list/lib/src/quote_list_screen.dart
import 'package:routemaster/routemaster.dart';  // ❌ Don't do this!

class QuoteListScreen extends StatelessWidget {
  void navigateToDetails(int id) {
    Routemaster.of(context).push('/quotes/$id');  // ❌ Feature knows about routing
  }
}
```

✅ **Good** - Feature uses callback:
```dart
// In packages/quote_list/lib/src/quote_list_screen.dart
class QuoteListScreen extends StatelessWidget {
  const QuoteListScreen({
    required this.onQuoteSelected,  // ✅ Callback parameter
  });

  final Future<Quote?> Function(int id) onQuoteSelected;

  void handleQuoteTap(int id) {
    onQuoteSelected(id);  // ✅ Just calls callback
  }
}
```

### 2. Use Path Constants, Never Hardcode Paths

❌ **Bad** - Hardcoded paths:
```dart
routerDelegate.push('/sign-in');  // ❌ Typo-prone, hard to refactor
routerDelegate.push('/quotes/' + id.toString());  // ❌ Error-prone string concatenation
```

✅ **Good** - Path constants:
```dart
routerDelegate.push(_PathConstants.signInPath);  // ✅ Type-safe, autocomplete
routerDelegate.push(_PathConstants.quoteDetailsPath(quoteId: id));  // ✅ Validated parameters
```

### 3. Always Name Your Pages

❌ **Bad** - No name:
```dart
MaterialPage(
  child: MyScreen(),  // ❌ Won't show in analytics
)
```

✅ **Good** - Named page:
```dart
MaterialPage(
  name: 'my-screen',  // ✅ Appears in analytics
  child: MyScreen(),
)
```

**Naming Convention**: Use kebab-case (lowercase with dashes)

### 4. Separate Dialog Navigation from Route Navigation

❌ **Bad** - Dialog as a route:
```dart
// Don't create routes for temporary overlays
_PathConstants.forgotPasswordPath: (_) => MaterialPage(
  child: ForgotPasswordDialog(),  // ❌ Overkill
),
```

✅ **Good** - Dialog via showDialog:
```dart
onForgotPasswordTap: () {
  showDialog(  // ✅ Temporary overlay
    context: context,
    builder: (context) => ForgotPasswordDialog(),
  );
},
```

**Rule of Thumb**:
- If it should be **deep linkable** → Route
- If it's a **temporary overlay** → Dialog/BottomSheet

### 5. Use Typed Navigation Results

❌ **Bad** - Untyped results:
```dart
final result = await routerDelegate.push(path);  // ❌ result is dynamic
if (result != null) {
  final quote = result as Quote;  // ❌ Runtime cast
}
```

✅ **Good** - Typed results:
```dart
final result = await routerDelegate.push<Quote?>(path);  // ✅ Typed
if (result != null) {
  // result is Quote, no cast needed
  updateQuote(result);
}
```

### 6. Compose Paths Hierarchically

❌ **Bad** - Flat, duplicated paths:
```dart
static String get profileMenuPath => '/user';
static String get updateProfilePath => '/user/update-profile';  // ❌ Duplication
static String get settingsPath => '/user/settings';  // ❌ Must remember parent
```

✅ **Good** - Hierarchical composition:
```dart
static String get profileMenuPath => '/user';
static String get updateProfilePath => '$profileMenuPath/update-profile';  // ✅ Builds on parent
static String get settingsPath => '$profileMenuPath/settings';  // ✅ Automatic consistency
```

**Benefits**: Change parent path once, all children update automatically

### 7. Handle Authentication Redirects Consistently

✅ **Good** - Consistent pattern across features:
```dart
_PathConstants.quoteListPath: (route) => MaterialPage(
  child: QuoteListScreen(
    onAuthenticationError: (context) {
      routerDelegate.push(_PathConstants.signInPath);  // ✅ Redirect to sign-in
    },
  ),
),

_PathConstants.quoteDetailsPath(): (info) => MaterialPage(
  child: QuoteDetailsScreen(
    onAuthenticationError: () {
      routerDelegate.push(_PathConstants.signInPath);  // ✅ Same pattern
    },
  ),
),
```

---

## Real-World Examples

### Example 1: Complete User Sign-In Flow

**Scenario**: User taps "Sign In" → Signs in successfully → Returns to previous screen

**Step 1**: User taps sign-in button in profile menu

```dart
// In routing_table.dart
_PathConstants.profileMenuPath: (_) => MaterialPage(
  child: ProfileMenuScreen(
    onSignInTap: () {
      routerDelegate.push(_PathConstants.signInPath);  // Navigate to sign-in
    },
  ),
),
```

**Step 2**: Sign-in screen appears

```dart
_PathConstants.signInPath: (_) => MaterialPage(
  name: 'sign-in',
  fullscreenDialog: true,  // Modal presentation
  child: SignInScreen(
    userRepository: userRepository,
    onSignInSuccess: () {
      routerDelegate.pop();  // Close sign-in screen on success
    },
  ),
),
```

**Step 3**: User enters credentials and submits

**Step 4**: Sign-in succeeds, `onSignInSuccess` callback fires

**Step 5**: `routerDelegate.pop()` closes sign-in screen

**Step 6**: User returns to profile menu (now signed in)

**URL Changes**:
```
/user → /user/sign-in → /user
```

### Example 2: Quote Details with Navigation Result

**Scenario**: User favorites a quote → Updated quote returns to list → List updates

**Step 1**: User taps a quote in the list

```dart
_PathConstants.quoteListPath: (route) => MaterialPage(
  child: QuoteListScreen(
    onQuoteSelected: (id) {
      final navigation = routerDelegate.push<Quote?>(
        _PathConstants.quoteDetailsPath(quoteId: id),
      );
      return navigation.result;  // Return Future<Quote?>
    },
  ),
),
```

**Step 2**: Quote details screen opens

```dart
_PathConstants.quoteDetailsPath(): (info) => MaterialPage(
  child: QuoteDetailsScreen(
    quoteId: int.parse(info.pathParameters['id'] ?? ''),
    quoteRepository: quoteRepository,
  ),
),
```

**Step 3**: User taps the favorite button

**Step 4**: Quote details screen updates the quote in repository

**Step 5**: User presses back button

```dart
// In QuoteDetailsScreen
Navigator.of(context).pop(updatedQuote);  // Return updated quote
```

**Step 6**: Quote list screen receives `updatedQuote` from `navigation.result`

**Step 7**: Quote list updates the item in the list

**URL Changes**:
```
/quotes → /quotes/42 → /quotes
```

### Example 3: Deep Link Opens Specific Quote

**Scenario**: User receives link → Taps it → App opens to quote details

**Step 1**: Another user shares a quote

```dart
// In QuoteDetailsScreen, user taps share button
final link = await shareableLinkGenerator(quote);
// Generates: https://wonderwords1.page.link/abc123
Share.share(link);
```

**Step 2**: Recipient receives link and taps it

**Step 3**: Firebase Dynamic Links opens the app

**Step 4**: DynamicLinkService extracts path

```dart
// In DynamicLinkService
Future<String?> getInitialDynamicLinkPath() async {
  final data = await _dynamicLinks.getInitialLink();
  return data?.link.path;  // Returns: "/quotes/42"
}
```

**Step 5**: Main app pushes the path

```dart
// In main.dart
Future<void> _openInitialDynamicLinkIfAny() async {
  final path = await _dynamicLinkService.getInitialDynamicLinkPath();
  if (path != null) {
    _routerDelegate.push(path);  // Pushes "/quotes/42"
  }
}
```

**Step 6**: Routemaster finds matching route

```dart
_PathConstants.quoteDetailsPath(): (info) => MaterialPage(
  child: QuoteDetailsScreen(
    quoteId: int.parse(info.pathParameters['id'] ?? ''),  // Extracts 42
  ),
),
```

**Step 7**: App displays quote #42

**URL Flow**:
```
https://wonderwords1.page.link/abc123
  ↓ Firebase resolves to
https://wonderwords1.page.link/quotes/42
  ↓ App extracts path
/quotes/42
  ↓ Routemaster matches
QuoteDetailsScreen(quoteId: 42)
```

### Example 4: Tab Navigation with Nested Routes

**Scenario**: User switches tabs while on nested screens

**Step 1**: User is on quote details screen

```
Current URL: /quotes/42
Navigation stack: [TabContainer, QuoteList, QuoteDetails]
```

**Step 2**: User taps "Profile" tab

```
New URL: /user
Navigation stack: [TabContainer, ProfileMenu]
Quote tab stack preserved: [QuoteList, QuoteDetails] ← Saved
```

**Step 3**: User navigates in profile tab

```
Current URL: /user/update-profile
Navigation stack: [TabContainer, ProfileMenu, UpdateProfile]
```

**Step 4**: User switches back to "Quotes" tab

```
New URL: /quotes/42
Navigation stack: [TabContainer, QuoteList, QuoteDetails] ← Restored!
```

**How it works**:
- `CupertinoTabPage` maintains separate navigation stacks per tab
- Switching tabs doesn't destroy the other tab's stack
- Tab state is preserved

---

## Summary

The WonderWords routing architecture provides:

✅ **Deep Link Support** - Built on Navigator 2.0, perfect for sharing and notifications
✅ **Clean Architecture** - Features don't depend on routing, easy to test
✅ **Type Safety** - Path parameters and results are properly typed
✅ **Maintainability** - All routes in one place, easy to update
✅ **Analytics Ready** - Automatic screen view tracking
✅ **Tab Navigation** - Nested routes with persistent bottom bar
✅ **Scalability** - Adding routes is simple and doesn't affect existing code

By following the patterns in this guide, you can build a routing system that:
- Scales with your app's complexity
- Maintains clean separation of concerns
- Provides excellent deep linking support
- Integrates seamlessly with analytics
- Remains testable and maintainable
