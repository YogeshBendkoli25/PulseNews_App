# PulseNews - Clean Architecture Flutter News Application

A modern, production-grade Flutter news application built strictly adhering to **Clean Architecture** principles, **BLoC state management**, **Real Live News API integration (Zero API Key required)**, **intelligent offline Hive caching**, and **Material Design 3**.

---

## 🌟 Features

- **Clean Architecture**: Decoupled into `Domain`, `Data`, and `Presentation` layers for high maintainability, testability, and scalability.
- **BLoC State Management**: Predictable state flows powered by `flutter_bloc` with events and states.
- **Real Live News API (Zero API Key Required)**: Seamless integration with a live, public, real-time news API ([Spaceflight News API SNAPI v4](https://api.spaceflightnewsapi.net/v4/articles/)). Delivers authentic, up-to-the-minute news articles from real news agencies, complete with high-resolution imagery, article summaries, timestamps, author credits, and original publisher links without requiring any API keys or registration tokens.
- **Zero Mock Data**: 100% genuine, live remote news data. No artificial mock files or synthetic payloads.
- **Offline First & Hive Caching**: Automatic caching of fetched real news in a fast key-value Hive database. When offline or connection drops, cached articles are seamlessly rendered with an informative offline banner and retry action.
- **Interactive Search**: Real-time keyword search across titles and content, querying the live API remotely when online and instantly filtering Hive-cached records when offline.
- **Article Detail View**: Rich article layout featuring Hero image transitions, author & publisher metadata, formatted dates, full reading content, and an "Open Original Article" action using `url_launcher`.
- **Material Design 3 & Theme Switching**: Support for Light and Dark modes with instant toggle and persistent storage via `SharedPreferences`.
- **Pull-to-Refresh & Infinite Pagination**: Smooth pull-to-refresh (`RefreshIndicator`) and lazy infinite-scroll pagination (`offset` / `limit`).
- **Comprehensive Test Suite**: Unit tests for models and BLoC logic (`bloc_test`, `mocktail`), plus Flutter widget tests.

---

## 🏗️ Architecture Explanation

The project follows Uncle Bob's **Clean Architecture** patterns, ensuring the business logic remains strictly independent of UI frameworks and external data sources.

```
lib/
├── core/                         # Cross-cutting concerns & shared infrastructure
│   ├── constants/                # API endpoints, design constants
│   ├── error/                    # Custom failures & exceptions
│   ├── network/                  # NetworkInfo (connectivity checks)
│   ├── theme/                    # Material 3 light/dark themes & ThemeBloc
│   ├── utils/                    # DateFormatter, UrlHelper
│   └── service_locator.dart      # GetIt dependency injection setup
│
├── features/
│   └── news/
│       ├── domain/               # Enterprise & Business Logic (Pure Dart)
│       │   ├── entities/         # Article domain entity
│       │   ├── repositories/     # NewsRepository abstract contract
│       │   └── usecases/         # GetTopHeadlines, SearchNews, GetCachedNews
│       │
│       ├── data/                 # Data Retrieval & Persistence
│       │   ├── datasources/      # Remote (Dio/SNAPI) & Local (Hive Box)
│       │   ├── models/           # ArticleModel (JSON serialization & entity conversion)
│       │   └── repositories/     # NewsRepositoryImpl (Coordinates remote & cache)
│       │
│       └── presentation/         # UI & State Management
│           ├── bloc/             # NewsBloc, NewsEvent, NewsState
│           ├── pages/            # NewsListPage, ArticleDetailPage
│           └── widgets/          # ArticleCard, ShimmerLoader, OfflineStatusBanner
│
└── main.dart                     # App entry point & Root Providers
```

### 1. Domain Layer (`lib/features/news/domain/`)
- Contains pure Dart code with **zero dependencies on Flutter UI or external packages**.
- **Entities**: Core data representation (`Article`).
- **Repository Interface**: `NewsRepository` contract defining the operations required by business use cases.
- **Use Cases**: Single-responsibility interactors (`GetTopHeadlines`, `SearchNews`, `GetCachedNews`).

### 2. Data Layer (`lib/features/news/data/`)
- Implements the contracts defined by the domain layer.
- **Models**: `ArticleModel` extends `Article`, adding robust `fromJson` and `toJson` methods supporting the live news API format.
- **Data Sources**:
  - `NewsRemoteDataSource`: Communicates with the live REST API via `Dio` HTTP client with query parameter support for pagination and keyword search.
  - `NewsLocalDataSource`: Manages local persistence with `Hive`.
- **Repository Implementation**: `NewsRepositoryImpl` checks network connectivity via `NetworkInfo`. When online, it fetches real news and updates the local Hive cache; when offline, it transparently recovers cached articles.

### 3. Presentation Layer (`lib/features/news/presentation/`)
- **BLoC**: `NewsBloc` processes user events (`FetchHeadlinesEvent`, `SearchNewsEvent`, `LoadMoreHeadlinesEvent`) and emits distinct immutable states (`NewsLoading`, `NewsLoaded`, `NewsEmpty`, `NewsError`).
- **Widgets**: Componentized, reusable UI elements following Material Design 3 guidelines.

---

## 🛠️ Setup Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.13.0 or later; tested on Flutter 3.47.2 / Dart 3.13.2)
- iOS Simulator / Android Emulator / Physical Device / Chrome

### 1. Clone & Navigate to Project
```bash
git clone <repository-url>
cd traker_task
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Static Analysis & Tests
```bash
# Verify static code health (0 issues guaranteed)
flutter analyze

# Run unit and widget test suite
flutter test
```

### 4. Launch the Application
```bash
# Run on connected device or simulator (Zero configuration required!)
flutter run
```

---

## ⚖️ Architectural Highlights

1. **Zero-Configuration Live API**:
   - Integrates with an open REST API delivering real-world news articles with full metadata, without requiring API keys, registration, or secret tokens.
2. **Lightweight Key-Value Caching with Hive**:
   - Fast, cross-platform key-value persistence without SQLite native C compilation overhead or fragile schema migration scripts.
3. **Hero Transitions & Modern Polish**:
   - Fluid transitions between feed cards and the detailed view, along with dark/light mode toggle and shimmering loading placeholders.
4. **Resilient Offline Fallback**:
   - Seamlessly switches to cached articles when internet connectivity drops, ensuring continuous availability with an offline warning indicator.

---

## 🧪 Testing

The repository includes comprehensive tests across all architectural tiers:

- **Model Unit Tests** (`test/unit/article_model_test.dart`): Verifies JSON serialization, missing field resilience, and entity parity.
- **BLoC Unit Tests** (`test/unit/news_bloc_test.dart`): Verifies state sequence transitions (`[NewsLoading, NewsLoaded]`), offline cache fallbacks, and keyword queries using `bloc_test` and `mocktail`.
- **Widget Tests** (`test/widget_test.dart`): Verifies Material card rendering, author metadata, and interactive tap handlers.
