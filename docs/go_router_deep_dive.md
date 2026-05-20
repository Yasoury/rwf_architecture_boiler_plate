# go_router Deep Dive: From Navigator 2.0 to Production

A step-by-step guide to understanding go_router from the inside out. This is not an API reference — it explains how each piece works under the hood and why.

---

## Table of Contents

1. [Navigator 2.0 Foundation](#step-1-navigator-20-foundation)
2. [The GoRouter Object](#step-2-the-gorouter-object)
3. [GoRoute & Route Matching](#step-3-goroute--route-matching)
4. [Path Parameters, Query Parameters & GoRouterState](#step-4-path-parameters-query-parameters--gorouterstate)
5. [Sub-Routes & The Navigation Stack](#step-5-sub-routes--the-navigation-stack)
6. [go() vs push() vs pushReplacement()](#step-6-go-vs-push-vs-pushreplacement)
7. [ShellRoute](#step-7-shellroute)
8. [StatefulShellRoute](#step-8-statefulshellroute)
9. [Redirect System](#step-9-redirect-system)
10. [Passing Data: extra, State & The Tradeoffs](#step-10-passing-data-extra-state--the-tradeoffs)
11. [Deep Linking & Web](#step-11-deep-linking--web)
12. [Error Handling & Custom Pages](#step-12-error-handling--custom-pages)

---

## Step 1: Navigator 2.0 Foundation

Before go_router, you need to understand what it's wrapping. Flutter has two navigation APIs.

### Navigator 1.0 (Imperative)

The classic API — `Navigator.push()`, `Navigator.pop()`. You tell Flutter **what to do**:

```dart
Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen()));
```

Problem: the framework doesn't own the navigation state. **You** manage it imperatively. This breaks deep linking, browser back buttons, and makes it hard to restore state.

### Navigator 2.0 (Declarative)

Flutter introduced a declarative layer with 4 key pieces. Here's what each one actually does:

```
URL (browser / deep link / system)
        |
        v
+---------------------------+
|  RouteInformationParser    |  <-- Converts raw URL string -> route data object
+-------------+-------------+
              v
+---------------------------+
|     RouterDelegate         |  <-- Takes route data -> builds a List<Page> (the nav stack)
+-------------+-------------+
              v
+---------------------------+
|       Navigator            |  <-- Renders the List<Page> as a widget stack
+---------------------------+
```

**RouteInformationParser** — A translator. The OS hands it a raw string like `/products/42`. The parser turns that into a structured object your app understands. Think of it as URL deserialization.

**RouterDelegate** — The brain. It holds the navigation state (which pages are on the stack). When the parsed route data arrives, the delegate decides what `List<Page>` to build. It also reports state changes back up to the URL bar.

**Navigator** — The renderer. It takes that `List<Page>` and puts actual widgets on screen. It's the same Navigator from 1.0, but now someone else is telling it what to display.

**Router** — The glue widget. It wires the parser and delegate together and sits at the root of your widget tree:

```dart
MaterialApp.router(
  routeInformationParser: myParser,
  routerDelegate: myDelegate,
)
```

### Why This Matters for go_router

When you write `GoRouter(routes: [...])`, here's what actually happens:

- GoRouter creates its **own** `RouteInformationParser` (`GoRouteInformationParser`)
- GoRouter creates its **own** `RouterDelegate` (`GoRouterDelegate`)
- You pass `GoRouter` to `MaterialApp.router()` via `routerConfig`
- GoRouter now owns the full pipeline

**go_router is not a new navigation system.** It's a convenience layer that implements the Navigator 2.0 interfaces so you don't have to write ~300 lines of boilerplate yourself.

### The Key Mental Model

With Navigator 1.0: you push/pop screens — **you** are the state manager.

With Navigator 2.0: you declare what the screen stack should look like based on state — **the framework** manages the stack. The URL and the screen stack are always in sync because they flow through the same pipeline.

This is the same shift as going from imperative `setState` to declarative state management — declare what the state should be, let the framework figure out how to get there.

---

## Step 2: The GoRouter Object

What happens when you create a `GoRouter()` instance.

### The Constructor

At its core, a GoRouter takes a route tree and produces the two Navigator 2.0 pieces from Step 1:

```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
  ],
);
```

Internally, this constructor does 3 things:

**1. Builds a route configuration tree**

Your `routes` list gets parsed into a `RouteConfiguration` object. This is an internal class that validates your route tree at construction time — it checks for duplicate paths, missing leading slashes, and invalid parameter syntax. If your routes are malformed, you get an error immediately, not at runtime when someone navigates.

**2. Creates a GoRouterDelegate (the brain)**

This is the `RouterDelegate` from Step 1. It holds a `GoRouteMatchList` — the current navigation state. When you call `go('/products/42')`, the delegate:
- Runs the path through the route matcher
- Produces a new `GoRouteMatchList`
- Calls `notifyListeners()` which triggers Navigator to rebuild with the new `List<Page>`

**3. Creates a GoRouteInformationParser (the translator)**

This is the `RouteInformationParser` from Step 1. It handles the bidirectional conversion:
- **Inbound**: OS gives a URL string -> parser creates a `RouteMatchList`
- **Outbound**: navigation state changes -> parser converts back to a URL string for the browser/system

### Wiring to MaterialApp

GoRouter implements `RouterConfig<RouteMatchList>`, so you pass the whole object:

```dart
MaterialApp.router(
  routerConfig: router,
)
```

One object instead of passing a separate delegate and parser. Under the hood, `routerConfig` just unpacks the delegate and parser from the GoRouter instance — it's syntactic sugar over the same Navigator 2.0 wiring.

### GoRouter is a ChangeNotifier

GoRouter extends `ChangeNotifier`. Every time the navigation state changes, it calls `notifyListeners()`. This means you can listen to route changes from anywhere:

```dart
router.addListener(() {
  print(router.location);  // e.g. '/products/42'
});
```

This is how things like analytics tracking and auth guards can react to every navigation event. The delegate listens to the GoRouter, the GoRouter listens to your navigation calls — it's a reactive chain.

### Lifecycle Summary

```
You call GoRouter(routes: [...])
    |
    +-> Validates & builds RouteConfiguration (route tree)
    +-> Creates GoRouterDelegate (holds nav state, builds pages)
    +-> Creates GoRouteInformationParser (URL <-> state)
    |
    v
MaterialApp.router(routerConfig: router)
    |
    +-> Router widget wires parser + delegate
    +-> Initial route is matched -> first Page stack is built
    +-> Navigator renders the stack
```

GoRouter is not magic. It's a **configuration object** that produces a delegate and a parser. When you understand that, everything else (routes, redirects, guards) is just configuring what that delegate does when a path comes in.

---

## Step 3: GoRoute & Route Matching

How GoRouter decides which screen to show when a path comes in.

### The GoRoute Object

A `GoRoute` is a single node in a route tree. At minimum it has a `path` and something to build:

```dart
GoRoute(
  path: '/products',
  builder: (context, state) => ProductsScreen(),
)
```

`GoRoute` is one subclass of `RouteBase`. The class hierarchy:

```
RouteBase (abstract)
  +-- GoRoute              <-- matches a path segment, builds a page
  +-- ShellRoute           <-- wraps child routes in persistent UI (Step 7)
  +-- StatefulShellRoute   <-- ShellRoute with state preservation (Step 8)
```

### How Path Matching Works

When you call `go('/products/42')`, GoRouter needs to find which route(s) match. Here's what happens internally.

**1. The route tree is walked top-down**

Your routes form a tree. GoRouter walks it depth-first, trying to match each segment of the path:

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => HomeScreen(),
      routes: [
        GoRoute(
          path: 'products',
          builder: (_, __) => ProductsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) => ProductDetailScreen(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
)
```

For the URL `/products/42`, the matcher produces a chain: `/` -> `products` -> `:id`. This chain becomes the `RouteMatchList`.

**2. Path segments are relative to the parent**

Sub-route paths do **not** start with `/`. They are relative:

```dart
// CORRECT -- relative path
GoRoute(
  path: '/',
  routes: [
    GoRoute(path: 'products', ...),   // matches '/products'
  ],
)

// WRONG -- absolute path in a sub-route
GoRoute(
  path: '/',
  routes: [
    GoRoute(path: '/products', ...),  // Error! Sub-routes must not start with /
  ],
)
```

Only top-level routes start with `/`. GoRouter validates this at construction time and throws if you violate it.

**3. The matching algorithm**

For each incoming path, GoRouter:

1. Splits the URL into segments: `/products/42` -> `['products', '42']`
2. Iterates through top-level routes, trying to match the first segment
3. On a match, recurses into that route's `routes` list with the remaining segments
4. A path parameter (`:id`) matches any single segment
5. Matching ends when all segments are consumed

```
Input:  /products/42

Step 1: Try '/' against 'products/42'
        '/' matches empty prefix -> consume it, remaining: 'products/42'

Step 2: Recurse into sub-routes, try 'products' against 'products/42'
        'products' matches -> consume it, remaining: '42'

Step 3: Recurse into sub-routes, try ':id' against '42'
        ':id' matches any segment -> consume '42', remaining: empty

Result: Match chain = [/, /products, /products/:id]
```

**4. The match chain becomes a page stack**

The `RouteMatchList` (the chain of matched routes) gets handed to the delegate. The delegate calls each matched route's `builder` and creates a `List<Page>`. The Navigator renders them as a stack:

```
Bottom:  HomeScreen          (from '/')
Middle:  ProductsScreen      (from 'products')
Top:     ProductDetailScreen (from ':id')
```

When the user presses back, the top page is removed. The URL updates to `/products`. The route match chain shrinks by one.

### Literal vs Parameter Segments

- **Literal segment** (`products`) — matches only that exact string
- **Parameter segment** (`:id`) — matches any single string, captures its value with the name `id`

The `:` prefix tells the matcher "this is a wildcard, capture whatever is here." Without it, it's a literal match. If you wrote `path: ':id'` at the top level, navigating to `/products` would match `:id` and `state.pathParameters['id']` would equal the string `"products"`.

### What If No Route Matches?

GoRouter has an `errorBuilder` parameter. If the matcher exhausts all routes without consuming the full path, the error builder is invoked:

```dart
GoRouter(
  routes: [...],
  errorBuilder: (context, state) => NotFoundScreen(path: state.uri.toString()),
)
```

If you don't provide one, GoRouter shows a default error page with the unmatched path.

---

## Step 4: Path Parameters, Query Parameters & GoRouterState

Every matched route gets a `GoRouterState` object. This is how data flows from the URL into your screen.

### GoRouterState — What's Inside

When the matcher finds a route, it creates a state object with everything about that match:

```dart
GoRoute(
  path: 'products/:productId',
  builder: (context, state) {
    state.pathParameters       // {'productId': '42'}
    state.uri                  // Uri object for '/products/42?sort=price'
    state.uri.queryParameters  // {'sort': 'price'}
    state.fullPath             // '/products/:productId' (the pattern, not the value)
    state.matchedLocation      // '/products/42' (the actual matched URL, no query)
    state.extra                // arbitrary Dart object passed via go() (Step 10)
    state.name                 // route name if you gave one
    return ProductDetailScreen();
  },
)
```

The `state` is unique per route match. If three routes matched (a chain of `/` -> `products` -> `:productId`), each route's builder gets its **own** state with its own slice of the match.

### Path Parameters

The `:paramName` syntax. Here's how they work in depth.

**Single parameter:**

```dart
GoRoute(
  path: 'products/:productId',
  builder: (_, state) {
    final id = state.pathParameters['productId']!;  // '42'
  },
)
```

**Multiple parameters in one path:**

```dart
GoRoute(
  path: 'products/:productId/reviews/:reviewId',
  builder: (_, state) {
    final productId = state.pathParameters['productId']!;  // '42'
    final reviewId = state.pathParameters['reviewId']!;     // '7'
  },
)
// matches: /products/42/reviews/7
```

**Parameters across parent-child routes:**

Parameters from parent routes are **inherited** by child routes:

```dart
GoRoute(
  path: 'products/:productId',
  builder: (_, state) => ...,
  routes: [
    GoRoute(
      path: 'reviews/:reviewId',
      builder: (_, state) {
        // BOTH are available here
        state.pathParameters['productId']!;  // '42'
        state.pathParameters['reviewId']!;   // '7'
      },
    ),
  ],
)
```

The child doesn't re-declare `:productId` — it inherits it from the match chain. Internally, the `RouteMatchList` accumulates all parameters as the matcher walks down the tree, and the final state merges them all.

### Query Parameters

Query parameters are not part of route matching at all. The matcher ignores everything after `?`. They just ride along on the URI:

```dart
// Navigating to: /products?sort=price&page=2

GoRoute(
  path: 'products',  // no mention of query params here
  builder: (_, state) {
    state.uri.queryParameters['sort']!;  // 'price'
    state.uri.queryParameters['page']!;  // '2'
  },
)
```

Key difference from path parameters:
- **Path parameters** affect matching — `/products/:id` won't match `/products` (missing segment)
- **Query parameters** never affect matching — `/products` matches whether you append `?sort=price` or not

### Everything is a String

Both path and query parameters are **always strings**. There's no type system. You parse them yourself:

```dart
final productId = int.parse(state.pathParameters['productId']!);
final page = int.tryParse(state.uri.queryParameters['page'] ?? '') ?? 1;
```

This is a URL limitation, not a go_router limitation. URLs are text.

### Named Routes

You can give routes a name and navigate by name instead of path. The parameters become explicit:

```dart
GoRoute(
  name: 'productDetail',
  path: 'products/:productId',
  builder: (_, state) => ...,
)

// Navigate by name -- go_router builds the path for you
context.goNamed(
  'productDetail',
  pathParameters: {'productId': '42'},
  queryParameters: {'sort': 'price'},
);
// Produces: /products/42?sort=price
```

Under the hood, `goNamed` looks up the route by name in a `Map<String, GoRoute>` that was built during construction, substitutes the parameters into the path pattern, appends query parameters, and then calls the regular `go()` with the resulting URL string. It's a convenience, not a separate system.

---

## Step 5: Sub-Routes & The Navigation Stack

The tree structure of your routes **defines** the page stack. This is a fundamental design decision in go_router.

### The Core Rule

Every matched route in the chain produces a page on the Navigator stack. The tree depth **is** the stack depth.

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => HomeScreen(),
      routes: [
        GoRoute(
          path: 'products',
          builder: (_, __) => ProductsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) => ProductDetailScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          builder: (_, __) => SettingsScreen(),
        ),
      ],
    ),
  ],
)
```

When the user navigates to `/products/42`, the match chain is `/` -> `products` -> `:id`. The delegate builds three pages:

```
Navigator Stack (top to bottom):
+----------------------+
|  ProductDetailScreen  |  <-- visible, from ':id'
+----------------------+
|  ProductsScreen       |  <-- behind it, from 'products'
+----------------------+
|  HomeScreen           |  <-- at the bottom, from '/'
+----------------------+
```

Press back -> removes the top -> stack becomes Home + Products -> URL becomes `/products`.

Press back again -> stack becomes just Home -> URL becomes `/`.

### How the Delegate Builds the Stack

Internally, this is what happens step by step:

```
1. RouteMatchList = [RouteMatch('/'), RouteMatch('products'), RouteMatch(':id')]

2. Delegate iterates the list:
   for each match:
     call match.route.builder(context, state) -> get a Widget
     wrap it in a MaterialPage(child: widget)  -> get a Page
     add to List<Page>

3. Pass List<Page> to Navigator:
   Navigator(pages: [homePage, productsPage, detailPage])

4. Navigator renders them as a stack.
```

The `builder` function you write is called **every time the stack is rebuilt**. It's not called once — it's declarative, like a `build()` method.

### When You Don't Want a Parent Page in the Stack

Say you want `/products/42` to show **only** the detail screen, no Products list behind it.

**Option A: Flat routes (no nesting)**

```dart
GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomeScreen()),
    GoRoute(path: '/products', builder: (_, __) => ProductsScreen()),
    GoRoute(path: '/products/:id', builder: (_, state) => ProductDetailScreen()),
  ],
)
```

Now `/products/:id` is a top-level route. The match chain is just one entry. The stack has only `ProductDetailScreen`. But there's no back button to Products because Products is not in the stack.

**Option B: Nested, with both routes defined**

The tree approach gives you the back-button stack for free. If you don't want the intermediate page, use flat routes. This is a tradeoff you decide per-route based on the UX you want.

### The parentNavigatorKey Escape Hatch

Sometimes you need a sub-route to NOT stack on its parent but instead take over the full screen. This is done with `parentNavigatorKey` — covered in detail in Step 7 (ShellRoute).

**Nesting = stacking. The tree is the stack.**

---

## Step 6: go() vs push() vs pushReplacement()

The most misunderstood part of go_router. These three methods look similar but do fundamentally different things to the navigation stack.

### go() — Declarative, Replaces the Entire Stack

`go()` says: "The URL is now X. Rebuild the stack from scratch."

```dart
context.go('/products/42');
```

The matcher runs against `/products/42`, produces a new match chain, and the **entire** page stack is replaced. Whatever was on the stack before is gone.

```
Before: HomeScreen -> SettingsScreen -> ProfileScreen
After go('/products/42'): HomeScreen -> ProductsScreen -> ProductDetailScreen

The Settings and Profile pages are destroyed.
```

This is pure declarative navigation. You declare the destination, go_router figures out what the stack should look like based on the route tree.

### push() — Imperative, Appends on Top

`push()` says: "Keep everything as-is, add this page on top."

```dart
context.push('/products/42');
```

The matcher still runs to find the matching route and build the page. But instead of replacing the stack, it **appends** the new page on top of whatever is currently there.

```
Before: HomeScreen -> SettingsScreen
After push('/products/42'): HomeScreen -> SettingsScreen -> ProductDetailScreen

Settings is still there underneath.
```

Notice what happened — `ProductDetailScreen` is on the stack but `ProductsScreen` is NOT. With `go()`, the tree structure would have forced Products to be beneath Detail. With `push()`, you bypass the tree. You're back to imperative Navigator 1.0 thinking.

### The Critical Difference, Visualized

```dart
// Route tree:
// /
// +-- products
//     +-- :id

// Scenario: User is on SettingsScreen (/settings)

context.go('/products/42');
// Stack: Home -> Products -> ProductDetail
// Back: ProductDetail -> Products -> Home
// URL syncs at every step

context.push('/products/42');
// Stack: Home -> Settings -> ProductDetail
// Back: ProductDetail -> Settings
// URL shows /products/42 but the stack doesn't match the tree
```

| | go() | push() |
|---|------|--------|
| Stack | Matches route tree | Can be anything |
| Back button | Walks up the tree | Walks back through push history |
| URL sync | Always consistent | Can be misleading |
| Mental model | Declarative | Imperative |

### pushReplacement() — Swap the Top Page

`pushReplacement()` says: "Remove the current top page, put this one in its place."

```dart
context.pushReplacement('/products/42');
```

```
Before: HomeScreen -> SettingsScreen -> ProfileScreen
After:  HomeScreen -> SettingsScreen -> ProductDetailScreen

ProfileScreen was replaced, not stacked upon.
```

Common use case: a login flow where each step replaces the previous one, so the user can't press back to return to an earlier step.

### How This Works Internally

The `GoRouterDelegate` maintains two pieces of state:

```
                    +------------------------+
 go() writes to ->  |   RouteMatchList        |  <-- the "declarative" state
                    |   (matches from tree)   |
                    +------------------------+

                    +------------------------+
 push() writes to-> |   Push stack (extra     |  <-- an imperative layer on top
                    |   pages appended)       |
                    +------------------------+
```

When the delegate builds the final `List<Page>` for the Navigator, it takes the declarative match list and then appends any pushed pages on top. This is why `push()` can create stacks that don't match the tree — it's a separate bookkeeping layer.

When you call `go()`, the push stack is **cleared**. The declarative state takes over completely:

```dart
context.push('/a');
context.push('/b');
context.push('/c');
// Stack: ... -> A -> B -> C (pushed on top)

context.go('/settings');
// Stack: Home -> Settings
// A, B, C are all gone -- go() wiped the push stack
```

### Which Should You Use?

- **`go()`** — When navigating to a destination where the full path context matters. The back button should walk up the logical hierarchy.
- **`push()`** — When opening something **on top of** the current context. Modal screens, quick actions that should return to wherever the user was.
- **`pushReplacement()`** — When stepping through a flow. Login steps, wizard screens, anything where going back to the previous step doesn't make sense.

---

## Step 7: ShellRoute

go_router's solution for persistent UI that stays on screen while inner content changes — bottom navigation bars, side drawers, tab layouts.

### The Problem

Say you have a bottom nav bar with 3 tabs: Products, Orders, Settings. You want the bar to stay visible while the content area switches. With plain `GoRoute`, every route produces a **full screen** page:

```dart
// This replaces the ENTIRE screen on each navigation
// The bottom nav bar disappears and reappears
GoRoute(path: '/products', builder: (_, __) => ProductsScreen()),
GoRoute(path: '/orders', builder: (_, __) => OrdersScreen()),
GoRoute(path: '/settings', builder: (_, __) => SettingsScreen()),
```

Each navigation destroys the previous screen and builds a new one from scratch. No persistent shell.

### ShellRoute — The Wrapper

`ShellRoute` wraps a set of child routes with a shared UI shell. It has its own `builder` that receives the current child as a parameter:

```dart
ShellRoute(
  builder: (context, state, child) {
    //                          ^^^^^ this is the matched child route's widget
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(),
    );
  },
  routes: [
    GoRoute(path: '/products', builder: (_, __) => ProductsScreen()),
    GoRoute(path: '/orders', builder: (_, __) => OrdersScreen()),
    GoRoute(path: '/settings', builder: (_, __) => SettingsScreen()),
  ],
)
```

When the user navigates to `/products`, go_router:
1. Matches the `GoRoute` for `/products`
2. Builds `ProductsScreen`
3. Passes it as `child` to the `ShellRoute`'s builder
4. The shell wraps it with the Scaffold and bottom nav

Navigate to `/orders` -> same shell, `child` changes to `OrdersScreen`. The `Scaffold` and `BottomNavBar` are **not** rebuilt from scratch — they persist.

### How It Works Internally

ShellRoute changes the normal "match chain = page stack" behavior. Instead of every match becoming a separate page, ShellRoute **nests** within a single page:

```
Without ShellRoute:
+---------------------+
|   ProductsScreen     |  <-- Page 2
+---------------------+
|   HomeScreen         |  <-- Page 1
+---------------------+

With ShellRoute:
+---------------------+
|  ShellRoute          |  <-- Single page
|  +-----------------+ |
|  | ProductsScreen   | |  <-- child widget, NOT a separate page
|  +-----------------+ |
|  BottomNavBar        |
+---------------------+
```

The ShellRoute creates its own **nested Navigator**. The shell widget sits in the parent Navigator as one page. The child routes are managed by an inner Navigator that lives inside the shell's `body`. Two Navigators, one inside the other:

```
Root Navigator
  +-- Page: ShellRoute's builder
        +-- BottomNavBar (persistent)
        +-- Child Navigator
              +-- Page: ProductsScreen (swappable)
```

### The navigatorKey Mechanism

ShellRoute creates its own `Navigator` with a unique key. This is how go_router knows where to place pages:

```dart
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/products', builder: ...),  // renders in shell's navigator
        GoRoute(path: '/orders', builder: ...),     // renders in shell's navigator
      ],
    ),
    GoRoute(path: '/login', builder: ...),           // renders in ROOT navigator
  ],
)
```

Routes inside `ShellRoute` render in the shell's navigator (with the persistent UI). Routes outside render in the root navigator (full screen, no shell).

### Breaking Out of the Shell

Sometimes a sub-route of a shell needs to go full screen — like tapping a product opens a detail screen that covers the bottom nav. Use `parentNavigatorKey`:

```dart
ShellRoute(
  navigatorKey: _shellNavigatorKey,
  builder: (context, state, child) => AppShell(child: child),
  routes: [
    GoRoute(
      path: '/products',
      builder: (_, __) => ProductsScreen(),
      routes: [
        GoRoute(
          path: ':id',
          parentNavigatorKey: _rootNavigatorKey,  // <-- break out of shell
          builder: (_, state) => ProductDetailScreen(),
        ),
      ],
    ),
  ],
)
```

Now `/products` renders inside the shell (bottom nav visible), but `/products/42` renders in the root navigator (full screen, bottom nav gone):

```
/products:
+---------------------+
|  Shell               |
|  +-----------------+ |
|  | ProductsScreen   | |
|  +-----------------+ |
|  BottomNavBar        |
+---------------------+

/products/42:
+---------------------+
|  ProductDetailScreen |  <-- full screen, covers the shell
|                      |
|                      |
+---------------------+
```

Internally, `parentNavigatorKey` tells the delegate which Navigator's page list to insert the page into. It's just a routing instruction, not a separate mechanism.

### The Problem ShellRoute Doesn't Solve

When you switch from `/products` to `/orders`, the `ProductsScreen` widget is destroyed. Its scroll position, form state, everything — gone. When you go back to `/products`, it rebuilds from scratch.

This is because the child Navigator has only one page at a time. Switching tabs replaces that page.

StatefulShellRoute solves this.

---

## Step 8: StatefulShellRoute

ShellRoute's weakness: switching tabs destroys the previous tab's widget. StatefulShellRoute fixes this by giving each branch its own Navigator that stays alive.

### The Problem, Concretely

With `ShellRoute`, the child Navigator holds one page. Switch tabs -> old page is removed, new page is inserted. The old widget tree is disposed. Scroll positions, text field content, cubit/bloc state in the widget tree — all gone.

### StatefulShellRoute — Separate Navigator Per Branch

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
      ),
    );
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(path: '/products', builder: (_, __) => ProductsScreen()),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(path: '/orders', builder: (_, __) => OrdersScreen()),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(path: '/settings', builder: (_, __) => SettingsScreen()),
      ],
    ),
  ],
)
```

Two differences from ShellRoute:

1. **`branches`** instead of `routes` — each branch is an isolated navigation group
2. **`navigationShell`** instead of `child` — a special widget that manages all branches

### How It Works Internally

StatefulShellRoute creates a **separate Navigator for each branch** and keeps them all alive using an `IndexedStack`:

```
Root Navigator
  +-- Page: StatefulShellRoute's builder
        +-- BottomNavBar (persistent)
        +-- navigationShell (IndexedStack)
              +-- index 0: Navigator -> ProductsScreen    (ALIVE, hidden)
              +-- index 1: Navigator -> OrdersScreen      (ALIVE, visible)
              +-- index 2: Navigator -> SettingsScreen    (ALIVE, hidden)
```

`IndexedStack` renders all children but only paints the one at `currentIndex`. The other widgets stay mounted in the tree — their state is preserved, their blocs/cubits keep running, their scroll positions remain.

When you call `navigationShell.goBranch(1)`, it just changes the `IndexedStack` index. No widget is destroyed or created.

### The StatefulNavigationShell Object

The `navigationShell` parameter in the builder is a `StatefulNavigationShell`. It gives you:

```dart
navigationShell.currentIndex    // which branch is active (0, 1, 2)
navigationShell.goBranch(index) // switch to a branch

// Go to branch AND reset it to its initial route
navigationShell.goBranch(index, initialLocation: true)
```

`goBranch` is not the same as `go()`. It doesn't rebuild the stack — it switches which Navigator is visible. If the user was deep into `/products/42/reviews` in branch 0, switches to branch 1, then comes back to branch 0, they're still on `/products/42/reviews`.

### Each Branch Has Its Own Navigation Stack

Each branch can have deep navigation independently:

```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/products',
      builder: (_, __) => ProductsScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (_, state) => ProductDetailScreen(),
          routes: [
            GoRoute(
              path: 'reviews',
              builder: (_, __) => ProductReviewsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
)
```

Branch 0's Navigator can have its own stack: `Products -> ProductDetail -> Reviews`. Branch 1 can independently be at `Orders -> OrderDetail`. Switching branches doesn't interfere with either stack.

```
navigationShell (IndexedStack)
  +-- Branch 0 Navigator:  [ProductsScreen, ProductDetailScreen, ReviewsScreen]
  +-- Branch 1 Navigator:  [OrdersScreen, OrderDetailScreen]
  +-- Branch 2 Navigator:  [SettingsScreen]
```

### Breaking Out of StatefulShellRoute

Same pattern as ShellRoute — use `parentNavigatorKey` to push a route onto the root Navigator:

```dart
final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: ...,
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/products',
              builder: (_, __) => ProductsScreen(),
              routes: [
                GoRoute(
                  path: ':id/checkout',
                  parentNavigatorKey: _rootNavigatorKey,  // <-- full screen
                  builder: (_, state) => CheckoutScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
)
```

Checkout covers the entire screen including the bottom nav. Pressing back returns to the shell with all branch state preserved.

### The Memory Tradeoff

`IndexedStack` keeps all branches alive. That means all branches' widget trees, their state managers, their state — all in memory simultaneously. For an app with 3-5 tabs this is fine. For an app with many heavy tabs, it could be a problem.

If you need lazy loading (only create a branch when first visited), you'd build a custom `IndexedStack` alternative. But for most apps, the default is the right choice.

---

## Step 9: Redirect System

Redirects are go_router's mechanism for intercepting navigation before it happens. This is how you build auth guards, onboarding flows, and permission checks.

### Two Levels of Redirects

go_router has redirects at two places — and they run in a specific order:

```
User navigates to /products/42
        |
        v
+--------------------------+
|  Top-level redirect       |  <-- runs FIRST, on every navigation
|  (GoRouter.redirect)      |
+--------------+------------+
        |
        v
+--------------------------+
|  Route-level redirect     |  <-- runs SECOND, only if this route matched
|  (GoRoute.redirect)       |
+--------------+------------+
        |
        v
      Page is built
```

### Top-Level Redirect — The Global Guard

Defined on the `GoRouter` constructor. Runs on **every single navigation**, regardless of destination:

```dart
GoRouter(
  redirect: (context, state) {
    final isLoggedIn = authRepository.isLoggedIn;
    final isGoingToLogin = state.matchedLocation == '/login';

    // Not logged in and not already heading to login
    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }

    // Logged in but going to login -> redirect to home
    if (isLoggedIn && isGoingToLogin) {
      return '/';
    }

    // No redirect needed
    return null;
  },
  routes: [...],
)
```

The return value controls what happens:
- **Return a path string** -> navigation is redirected to that path instead
- **Return `null`** -> no redirect, continue to the original destination

### Route-Level Redirect — Scoped Guard

Defined on a specific `GoRoute`. Only runs when that particular route is matched:

```dart
GoRoute(
  path: 'admin',
  redirect: (context, state) {
    final isAdmin = userRepository.currentUser.isAdmin;
    if (!isAdmin) return '/unauthorized';
    return null;
  },
  builder: (_, __) => AdminScreen(),
)
```

This only fires when someone navigates to `/admin`. All other routes are unaffected.

### The Redirect Pipeline in Detail

Here's exactly what happens when `go('/products/42')` is called:

```
1. Top-level redirect runs with state.matchedLocation = '/products/42'
   -> returns null (no redirect)

2. Route matching runs: / -> products -> :id

3. For each matched route that has a redirect:
   Route '/' redirect -> returns null
   Route 'products' redirect -> returns null
   Route ':id' redirect -> returns null

4. All redirects returned null -> build the pages
```

If any redirect returns a non-null path, the **entire pipeline restarts** with the new path:

```
1. go('/admin')
2. Top-level redirect -> returns null
3. Route matching: / -> admin
4. Route 'admin' redirect -> returns '/unauthorized'
5. RESTART with '/unauthorized'
6. Top-level redirect runs again with '/unauthorized' -> returns null
7. Route matching: / -> unauthorized
8. No more redirects -> build the page
```

### Redirect Loop Protection

Because redirects restart the pipeline, infinite loops are possible:

```dart
// DON'T DO THIS -- infinite loop
GoRouter(
  redirect: (context, state) {
    if (!isLoggedIn) return '/login';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      redirect: (_, __) => '/',  // redirects back, top-level redirects to /login again
      builder: ...,
    ),
  ],
)
```

go_router detects this. It counts redirect iterations and throws an exception after a limit (default is 5 redirects). You'll get a clear error: "Too many redirects."

The fix is always the same pattern — check where you're already going before redirecting:

```dart
redirect: (context, state) {
  final isLoggedIn = authRepository.isLoggedIn;
  final isGoingToLogin = state.matchedLocation == '/login';

  if (!isLoggedIn && !isGoingToLogin) return '/login';
  if (isLoggedIn && isGoingToLogin) return '/';

  return null;
}
```

### Async Redirects

Redirects can be `async`. Useful when you need to check something that involves I/O:

```dart
GoRouter(
  redirect: (context, state) async {
    final user = await authRepository.getCurrentUser();
    if (user == null) return '/login';
    return null;
  },
  routes: [...],
)
```

While the async redirect is resolving, go_router shows nothing (or you can configure an initial route). Be careful — a slow redirect means a blank screen on every navigation. In practice, keep redirects fast. If auth state is async, load it before creating the router and listen for changes via `refreshListenable`.

### refreshListenable — Reactive Redirects

Redirects only run when navigation happens. But what if the auth state changes while the user is sitting on a screen? You need the redirect to re-evaluate. That's what `refreshListenable` does:

```dart
final authNotifier = ValueNotifier<bool>(false);

GoRouter(
  refreshListenable: authNotifier,
  redirect: (context, state) {
    if (!authNotifier.value) return '/login';
    return null;
  },
  routes: [...],
)
```

When `authNotifier` fires `notifyListeners()`, go_router re-runs the redirect pipeline against the **current** location. If the redirect now returns a different path, the user is automatically navigated:

```
User is on /products
    |
authNotifier changes (user logs out)
    |
    v
Redirect pipeline re-runs with current location '/products'
    |
redirect returns '/login'
    |
    v
User is navigated to /login automatically
```

This is how you build reactive auth — the router responds to state changes without any explicit navigation call.

---

## Step 10: Passing Data: extra, State & The Tradeoffs

You need to get data from one screen to another. go_router gives you three mechanisms, each with different tradeoffs.

### Mechanism 1: Path Parameters

```dart
context.go('/products/42');
// Receiver gets: state.pathParameters['productId']  -> '42'
```

Strings only. Part of the URL. Survives browser refresh, deep links, app restart. Always use for identity (IDs, slugs).

### Mechanism 2: Query Parameters

```dart
context.go('/products?sort=price&page=2');
// Receiver gets: state.uri.queryParameters['sort']  -> 'price'
```

Strings only. Part of the URL. Good for filters, sort options, pagination — things that are optional and don't define the resource.

### Mechanism 3: extra — The Dart Object Escape Hatch

`extra` lets you pass any Dart object alongside navigation:

```dart
context.go('/product-detail', extra: productModel);

// Receiver:
GoRoute(
  path: '/product-detail',
  builder: (_, state) {
    final product = state.extra as ProductModel;
    return ProductDetailScreen(product: product);
  },
)
```

You can pass anything — a model, a list, a map. It's a Dart-level mechanism, not a URL-level one.

### How extra Works Internally

When you call `go('/product-detail', extra: productModel)`, here's what happens:

```
1. go() creates a RouteMatchList with the matched routes
2. The 'extra' object is attached to the RouteMatchList -- stored in memory
3. Delegate builds pages, passes 'extra' through GoRouterState
4. Your builder receives state.extra
```

The critical thing: `extra` lives in **Dart memory only**. It's not part of the URL. It's not serialized. It's a pointer to an object in the current process.

### When extra Breaks

**1. Browser refresh (web)**

```
User is on /product-detail with extra: ProductModel(id: 42, name: 'Widget')
User hits F5
Browser sends URL '/product-detail' to the app
App restarts, matches /product-detail
state.extra is null -- the object was in memory, memory is gone
```

**2. Deep linking**

```
User taps a link: yourapp://product-detail
OS launches app with URL '/product-detail'
state.extra is null -- no one passed an object, just a URL string
```

**3. Android process death**

```
User backgrounds app, OS kills the process to free memory
User returns, Flutter restores from the saved URL
state.extra is null -- same reason
```

In all three cases, the URL survives but `extra` doesn't.

### The Safe Pattern

Never rely on `extra` as the only way to get data. Always have a fallback that can reconstruct from the URL:

```dart
GoRoute(
  path: 'products/:productId',
  builder: (_, state) {
    // Try extra first (fast, already have the object)
    final product = state.extra as ProductModel?;

    if (product != null) {
      return ProductDetailScreen(product: product);
    }

    // Fallback: load from ID (handles refresh, deep link, process death)
    final productId = state.pathParameters['productId']!;
    return ProductDetailScreen(productId: productId);
    // Screen loads the full model from repository using the ID
  },
)
```

This way:
- Normal navigation: `extra` provides the object instantly, no loading needed
- Refresh / deep link / restore: the screen fetches data using the path parameter

### When to Use What

| Mechanism | Survives refresh | Type-safe | Use for |
|-----------|-----------------|-----------|---------|
| Path params | Yes | No (strings) | Identity: IDs, slugs |
| Query params | Yes | No (strings) | Filters, options, pagination |
| extra | **No** | Yes (any Dart type) | Optimization: pass preloaded data to avoid re-fetching |

---

## Step 11: Deep Linking & Web

How URLs arrive at your app from the outside world, and how go_router handles them.

### The Full Pipeline with the Missing Piece

In Step 1, we covered three components. There's actually a fourth that sits above everything:

```
+-------------------------------+
|   RouteInformationProvider     |  <-- WHERE the URL comes from
+---------------+---------------+
                v
+-------------------------------+
|   RouteInformationParser       |  <-- Converts URL -> route data
+---------------+---------------+
                v
+-------------------------------+
|   RouterDelegate               |  <-- Route data -> page stack
+---------------+---------------+
                v
+-------------------------------+
|   Navigator                    |  <-- Renders pages
+-------------------------------+
```

`RouteInformationProvider` is the **source** of URLs. It's the interface between the operating system and the Flutter router. go_router uses Flutter's default `PlatformRouteInformationProvider`, which listens to different sources depending on the platform.

### Where URLs Come From, Per Platform

**Web (browser):**
```
User types URL in address bar   -> browser sends it to Flutter
User clicks back/forward        -> browser sends history entry to Flutter
User hits F5                    -> browser sends current URL to Flutter on restart

All flow through RouteInformationProvider
```

**iOS:**
```
Universal Links: https://yourapp.com/products/42
Custom scheme: yourapp://products/42

iOS resolves the link -> launches app -> passes URL to Flutter engine
Flutter engine -> RouteInformationProvider -> go_router pipeline
```

**Android:**
```
App Links: https://yourapp.com/products/42
Custom scheme: yourapp://products/42
Intent filters catch the URL

Android resolves the intent -> launches app -> passes URL to Flutter engine
Flutter engine -> RouteInformationProvider -> go_router pipeline
```

From go_router's perspective, it doesn't matter where the URL came from. By the time it arrives, it's just a string like `/products/42`. The same matching, redirect, and page-building pipeline runs regardless of source.

### Initial Route

When the app first launches with no external URL, go_router needs a starting point:

```dart
GoRouter(
  initialLocation: '/',
  routes: [...],
)
```

The lifecycle on cold start:

```
App launches
    |
    +-- External URL present? (deep link, browser URL)
    |   YES -> use that URL as the initial route
    |   NO  -> use initialLocation
    |
    v
URL enters the pipeline
    |
    v
Top-level redirect runs
    | (might redirect / -> /login if not authenticated)
    v
Route matching -> page stack -> render
```

`initialLocation` is a **fallback**, not a guarantee. If the OS provides a URL, it takes precedence. And the redirect can override both.

### The Bidirectional Flow

URLs don't just flow in. They also flow **out**. When the user navigates inside the app, go_router updates the system:

```
In-app navigation: context.go('/products/42')
    |
    v
Delegate updates route state
    |
    v
Parser converts state -> URL string '/products/42'
    |
    v
RouteInformationProvider sends it back to the OS
    |
    +-- Web: browser address bar updates, history entry added
    +-- iOS: no visible effect (no address bar) but state is saved for restoration
    +-- Android: same as iOS -- state saved for restoration
```

This bidirectional sync is what makes the back button work on web, and what allows state restoration on mobile after process death.

### The Practical Rule

Design routes as if the URL is the **only** thing you have. Because in deep links, browser refresh, and state restoration — it is. Everything else (`extra`, in-memory state) is an optimization on top.

```dart
// This route works from ANY source
GoRoute(
  path: 'products/:productId',
  builder: (_, state) {
    final productId = state.pathParameters['productId']!;
    return ProductDetailScreen(productId: productId);
  },
)

// This route breaks from external sources
GoRoute(
  path: 'product-detail',
  builder: (_, state) {
    final product = state.extra as ProductModel;  // null from deep link
    return ProductDetailScreen(product: product);
  },
)
```

---

## Step 12: Error Handling & Custom Pages

Two separate topics that both involve controlling how go_router renders pages.

### Error Handling

When a URL doesn't match any route, go_router needs to show something.

**Default behavior:**

If you provide no error handler, go_router shows a red `MaterialPage` with the unmatched path. Useful during development, not acceptable in production.

**Custom error builder:**

```dart
GoRouter(
  errorBuilder: (context, state) {
    return NotFoundScreen(path: state.uri.toString());
  },
  routes: [...],
)
```

Or with a page builder for more control:

```dart
GoRouter(
  errorPageBuilder: (context, state) {
    return MaterialPage(
      key: state.pageKey,
      child: NotFoundScreen(path: state.uri.toString()),
    );
  },
  routes: [...],
)
```

**When does the error handler fire?**

```
1. No route matches the URL             -> error handler
2. Route matches but builder throws     -> NOT caught (normal Flutter error)
3. Redirect returns invalid path        -> error handler
4. Too many redirects (loop detected)   -> error handler
```

The error handler is only for **routing** errors, not runtime widget errors. If your screen widget throws during `build()`, that's a regular Flutter exception handled by `ErrorWidget.builder`, not by go_router.

### builder vs pageBuilder

Every `GoRoute` can build its content in two ways. This is where you control transitions.

**builder — simple, uses default transition:**

```dart
GoRoute(
  path: 'products',
  builder: (context, state) => ProductsScreen(),
)
```

Under the hood, go_router wraps this in a `MaterialPage` (or `CupertinoPage` depending on your config). You get the platform-default transition — slide from right on iOS, fade on Android.

**pageBuilder — full control over the Page object:**

```dart
GoRoute(
  path: 'products',
  pageBuilder: (context, state) {
    return MaterialPage(
      key: state.pageKey,
      child: ProductsScreen(),
    );
  },
)
```

Same result as `builder`, but now you own the `Page` object. This is where customization happens.

### Custom Transitions

To customize how a page animates in, use `CustomTransitionPage`:

```dart
GoRoute(
  path: 'products',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: ProductsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  },
)
```

`CustomTransitionPage` extends `Page` and lets you define the `transitionsBuilder` — the same signature as `PageRouteBuilder` from Navigator 1.0. The `animation` parameter goes from 0.0 to 1.0 as the page enters.

**Common transitions:**

```dart
// Fade
FadeTransition(opacity: animation, child: child)

// Slide from bottom
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(animation),
  child: child,
)

// Scale
ScaleTransition(scale: animation, child: child)
```

### No-Transition Page

Sometimes you want no animation at all — instant swap. Common for tab switches:

```dart
GoRoute(
  path: 'settings',
  pageBuilder: (context, state) {
    return NoTransitionPage(
      key: state.pageKey,
      child: SettingsScreen(),
    );
  },
)
```

`NoTransitionPage` is built into go_router. It sets the transition duration to zero.

### state.pageKey — Why It Matters

The Navigator uses `Page.key` to track page identity. When the page list changes, Flutter diffs by key to decide which pages are new, which are removed, and which stayed:

```
Old stack: [Page(key: /), Page(key: /products)]
New stack: [Page(key: /), Page(key: /products), Page(key: /products/42)]

Diff: Page(/products/42) is new -> animate it in
```

`state.pageKey` generates a `ValueKey` from the matched path. If you omit the key or use a wrong one:
- Same page could be rebuilt unnecessarily (key changed but content didn't)
- Different pages could be treated as the same (same key, different content)
- Transitions break because Flutter can't diff correctly

Always use `state.pageKey`.

### Reusable Transition Helper

Instead of setting `pageBuilder` on every route, create a helper:

```dart
Page<void> buildPageWithFadeTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

// Use across routes
GoRoute(
  path: 'products',
  pageBuilder: (_, state) => buildPageWithFadeTransition(state, ProductsScreen()),
),
GoRoute(
  path: 'settings',
  pageBuilder: (_, state) => buildPageWithFadeTransition(state, SettingsScreen()),
),
```
