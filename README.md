# Real-World Flutter News Dashboard


## 🎯 Project Overview

This project is a **responsive news dashboard web application** built following the architectural principles and best practices from the acclaimed book "Real-World Flutter by Tutorials." It demonstrates professional Flutter development with clean architecture, proper state management, and comprehensive testing.

### 📱 Key Features

- **Responsive Design**: Seamlessly adapts from mobile to desktop layouts
- **Clean Architecture**: Follows package-by-feature organization with proper separation of concerns
- **State Management**: Implemented using BLoC/Cubit pattern for predictable state handling
- **Local Caching**: Intelligent caching strategy using Hive for offline-first experience
- **Search & Filtering**: Real-time search with debouncing and category filtering
- **Performance Optimized**: Implements pagination and efficient image loading

## 🏗️ Architecture

This application follows the **Real-World Flutter by Tutorials** architecture principles:

```
lib/
├── main.dart                 # App entry point
├── routing_table.dart        # Navigation configuration
└── screen_view_observer.dart # Analytics helper

packages/
├── component_library/        # Reusable UI components
├── domain_models/           # Domain entities
├── key_value_storage/       # Hive storage layer
├── news_api/               # Remote API layer
├── news_repository/        # Repository pattern implementation
└── features/
    ├── article/            # Article details feature
    └── article_list/       # News list feature
```

### Key Architectural Patterns:

- **Repository Pattern**: Coordinates between remote API and local storage
- **Package-by-Feature**: Isolated, testable feature modules
- **Clean Separation**: UI, Business Logic, and Data layers are properly separated
- **Dependency Injection**: Proper dependency management throughout the app

## 🚀 Getting Started

### Prerequisites

- Flutter 3.0.5 or higher
- Dart SDK 3.0.5 or higher
- Make (for build automation)
- News API key from [NewsAPI.org](https://newsapi.org/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Yasoury/rwf_architecture_boiler_plate.git
   cd flutter-news-dashboard
   Switch to the news app branch
   git checkout news_app
   ```



2. **Get dependencies**
   ```bash
   make get
   ```

3. **Generate Hive adapters**
   ```bash
   make build-runner
   ```

4. **Get your News API key**
   - Visit [NewsAPI.org](https://newsapi.org/)
   - Register for a free API key
   - Note your API key for the next step

### 🔧 Configuration

You **must** provide your News API token via Dart define variables:

#### VS Code Configuration
Create or update `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter Web (News Dashboard)",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--dart-define",
                "news-api-app-token=YOUR_API_KEY_HERE"
            ]
        }
    ]
}
```

#### Android Studio Configuration
1. Go to **Run/Debug Configurations**
2. Add to **Additional run args**:
   ```
   --dart-define=news-api-app-token=YOUR_API_KEY_HERE
   ```

#### Command Line
```bash
flutter run -d chrome --dart-define=news-api-app-token=YOUR_API_KEY_HERE
```

### 🎮 Available Make Commands

```bash
make get          # Install dependencies for all packages
make clean        # Clean all packages
make lint         # Run static analysis
make format       # Format code
make testing      # Run all tests
make build-runner # Generate code (Hive adapters)
make gen-l10n     # Generate localizations
```

## 🌟 Features Breakdown

### 📱 Responsive Design
- **Grid Layout**: Desktop and tablet views with masonry grid
- **List Layout**: Mobile-optimized list view
- **Adaptive UI**: Automatic layout switching based on screen size
- **Touch-Friendly**: Optimized for both mouse and touch interactions

### 🔍 Search & Filtering
- **Real-time Search**: Debounced search with 1-second delay
- **Category Filters**: Technology, Business, Science, Health, and more
- **Smart Caching**: Search results are cached for better performance
- **Clear Indicators**: Visual feedback for active filters

### 💾 Offline-First Architecture
- **Intelligent Caching**: Articles cached using Hive database
- **Fetch Policies**: Multiple strategies for data fetching
  - `cacheAndNetwork`: Show cached first, then fresh data
  - `networkOnly`: Always fetch fresh data
  - `cachePreferably`: Prefer cache, fallback to network
  - `networkPreferably`: Prefer network, fallback to cache

### 🎨 Theme Support
- **Dark/Light Mode**: Automatic system preference detection
- **Custom Components**: Consistent design system
- **Material Design 3**: Modern Material You theming

## 📊 State Management

Following the book's principles, this app uses **BLoC/Cubit** pattern:

### Article List BLoC
```dart
class ArticleListBloc extends Bloc<ArticleListEvent, ArticleListState> {
  // Handles pagination, search, filtering, and view mode switching
  // Uses stream transformers for debouncing and request cancellation
}
```

### Events & States
- **Events**: User interactions (search, filter, pagination)
- **States**: UI states (loading, success, error, empty)
- **Transformers**: Advanced event processing with debouncing

## 🧪 Testing Strategy

The application includes comprehensive testing following the book's testing pyramid:

- **Unit Tests**: Repository, API, and business logic
- **Widget Tests**: Individual component testing
- **Integration Tests**: End-to-end user flows

Run tests with:
```bash
make testing
```

## 📱 Responsive Breakpoints

```dart
final isTablet = constraints.maxWidth >= 768;
final isDesktop = constraints.maxWidth >= 1024;
```

- **Mobile**: < 768px (List view)
- **Tablet**: 768px - 1024px (2-column grid)
- **Desktop**: > 1024px (Multi-column grid with enhanced layout)

## 🌐 API Integration

### NewsAPI Integration
- **Everything Endpoint**: Searches across articles
- **Error Handling**: Comprehensive error management
- **Rate Limiting**: Handles API rate limits gracefully
- **Caching Strategy**: Reduces API calls through intelligent caching

### Supported Parameters
- Query search terms
- Category filtering
- Pagination with page size control
- Date range filtering
- Source filtering

## 🚀 Performance Optimizations

- **Lazy Loading**: Images loaded on demand
- **Pagination**: Infinite scroll with efficient memory usage
- **Debouncing**: Prevents excessive API calls during search
- **Caching**: Aggressive caching strategy for better UX
- **Widget Optimization**: Minimal rebuilds using BlocSelector

## 📝 Code Quality

- **Linting**: Strict linting rules following Dart/Flutter conventions
- **Formatting**: Consistent code formatting
- **Documentation**: Comprehensive inline documentation
- **Type Safety**: Strong typing throughout the codebase

## 🔮 Future Enhancements

- [ ] Push notifications using Firebase Cloud Messaging
- [ ] Advanced analytics with Firebase Analytics
- [ ] A/B testing capabilities
- [ ] Deep linking support
- [ ] Progressive Web App (PWA) features
- [ ] Advanced search filters
- [ ] Bookmarking system
- [ ] Social sharing
- [ ] Multiple language support


## 🤝 Contributing

Contributions are welcome! Please read the [contributing guidelines](CONTRIBUTING.md) and follow the established architecture patterns.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ using Flutter and Real-World Flutter by Tutorials principles**