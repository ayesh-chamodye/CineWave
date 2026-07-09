# CineWave 🎬

A modern, high-performance **Flutter streaming application** for movies and TV shows with a cinematic user experience. CineWave delivers premium video playback, intelligent watch history tracking, and instant over-the-air updates through Shorebird integration.

---

## 🌟 Key Features

### Video Playback
- **Premium Custom Player**: Landscape mode with intuitive gesture controls
  - Double-tap to seek (±10 seconds)
  - Adjustable playback speed (0.5x – 2.0x)
  - Multiple scaling modes: Fit, Zoom, Stretch
  - Full subtitle support (`.vtt`, `.srt`, local or URL-based)

### Smart Library Management
- **Continue Watching**: Resume exactly where you left off with visual progress indicators
- **Watch History**: Automatic tracking of recently watched content
- **Watchlist**: Bookmark movies and shows for later viewing
- **Favorites**: Quick access to your most-loved content

### Monetization & Updates
- **Native Ads**: Non-intrusive banner ads and rewarded interstitial ads
- **Shorebird Integration**: Instant over-the-air (OTA) updates for UI tweaks and critical bug fixes without app store resubmission

### Performance
- Optimized image caching with `cached_network_image`
- Shimmer loading effects for smooth UX
- Staggered UI animations
- Efficient state management with Bloc/Cubit pattern

---

## 🛠 Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter (^3.11.5) |
| **State Management** | Flutter Bloc (8.1.0) / Cubit |
| **Local Storage** | SQLite (Sqflite 2.3.0) |
| **Networking** | Dio (5.4.1), HTTP (1.1.0) |
| **Video Playback** | Video Player (2.11.1), Chewie (1.13.0) |
| **UI Components** | Material Design, Shimmer (2.0.0) |
| **Ad Network** | Google Mobile Ads / AdMob (5.3.0) |
| **Code Push** | Shorebird |
| **Image Handling** | Cached Network Image (3.2.0), Flutter SVG (2.0.0) |
| **Platform Support** | Android, iOS, Web, Windows, macOS, Linux |

---

## 📁 Project Structure

```
cinewave/
├── lib/
│   ├── main.dart                    # App entry point, Bloc/Repository setup
│   ├── splash_page.dart             # Animated splash screen
│   │
│   ├── core/                        # Shared utilities & infrastructure
│   │   ├── ads/                     # AdMob integration (AdService)
│   │   ├── constants/               # App-wide constants
│   │   ├── database/                # SQLite setup (DatabaseHelper)
│   │   ├── models/                  # Shared data models
│   │   ├── network/                 # API client (Dio configuration)
│   │   └── theme/                   # App theming & ThemeBloc
│   │
│   ├── features/                    # Feature modules (clean architecture)
│   │   ├── home/                    # Home screen with trending content
│   │   │   ├── data/                # Remote datasource, repository
│   │   │   └── presentation/        # HomeBloc, UI pages
│   │   │
│   │   ├── search/                  # Search functionality
│   │   │   ├── data/                # Search API integration
│   │   │   └── presentation/        # SearchBloc, search UI
│   │   │
│   │   ├── movie_list/              # Movie catalog
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   ├── movie_detail/            # Movie detail & player
│   │   │   ├── data/                # Movie details datasource
│   │   │   └── presentation/        # MovieDetailBloc, video player
│   │   │
│   │   ├── tv_list/                 # TV shows catalog
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   ├── tv_detail/               # TV show detail & player
│   │   │   ├── data/                # Episode & show details
│   │   │   └── presentation/        # TVDetailBloc
│   │   │
│   │   ├── library/                 # User library (watchlist, history, favorites)
│   │   │   ├── data/                # LibraryLocalDataSource, SQLite queries
│   │   │   └── presentation/        # LibraryBloc, library UI
│   │   │
│   │   ├── all_media/               # Browse all content
│   │   │
│   │   └── settings/                # App settings & preferences
│   │
│   └── shared/
│       └── routes/                  # AppRoutes navigation management
│
├── assets/
│   └── images/                      # App logos, icons, placeholder images
│
├── android/                         # Android native code
├── ios/                             # iOS native code
├── web/                             # Web platform
├── windows/                         # Windows platform
├── macos/                           # macOS platform
├── linux/                           # Linux platform
│
├── test/                            # Unit & widget tests
├── pubspec.yaml                     # Dart dependencies & project config
├── pubspec.lock                     # Locked dependency versions
├── shorebird.yaml                   # Shorebird code push config
└── analysis_options.yaml            # Dart linter rules
```

---

## 🏗 Architecture & Data Flow

**CineWave follows Clean Architecture with Bloc pattern:**

1. **Presentation Layer**: Bloc, UI widgets, pages
2. **Domain Layer**: Business logic, use cases (abstracted via repositories)
3. **Data Layer**: Remote datasources (API), local datasources (SQLite), repositories

**Request Flow Example (Home → MovieDetail):**
```
HomeScreen (Bloc) 
  → HomeBloc.LoadHomeData()
    → HomeRepository.getHomeData()
      → HomeRemoteDataSource (API via Dio)
        → Parse JSON → return Movie models
      → UI re-renders with state changes (success/loading/error)

User taps movie → MovieDetailScreen
  → MovieDetailBloc.LoadMovieDetail(movieId)
    → MovieDetailRepository.getMovieDetails()
      → MovieDetailRemoteDataSource (API)
    → Continue Watching stored in SQLite (LibraryBloc)
    → Video Player launches with Chewie
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: Version ^3.11.5
- **Dart**: ^3.11.5 (included with Flutter)
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Shorebird CLI**: For code push updates (optional, install via `brew install shorebird`)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ayesh-chamodye/CineWave.git
   cd CineWave/cinewave
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up Android signing** (for release builds):
   - Create `android/key.properties`:
     ```properties
     storePassword=<your_store_password>
     keyPassword=<your_key_password>
     keyAlias=upload
     storeFile=../key.jks
     ```

4. **Run the app:**
   ```bash
   flutter run
   ```

   Or specify a target device:
   ```bash
   flutter run -d <device_id>
   ```

### Development Build

```bash
# Debug build (default)
flutter run

# For Android emulator
flutter run -d emulator-5554

# For iOS simulator
flutter run -d iPhone-14-Pro-Max
```

### Release Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS IPA
flutter build ipa --release

# Web
flutter build web --release
```

### Shorebird Code Push

Deploy instant updates without store resubmission:

```bash
# Release with Shorebird
cd cinewave
shorebird release android

# Check release status
shorebird releases
```

---

## 📚 Key Code Sections

### API Integration (`core/network/api_client.dart`)
Centralized Dio configuration for all HTTP requests with interceptors for error handling and auth tokens.

### Database Setup (`core/database/database_helper.dart`)
SQLite initialization for:
- Watch history
- Continue watching progress
- Watchlist entries
- User favorites

### Bloc Setup (`main.dart`)
Multi-provider & multi-bloc setup:
- `HomeBloc`: Trending & featured content
- `SearchBloc`: Search functionality
- `MovieDetailBloc` / `TVDetailBloc`: Detail pages & player
- `LibraryBloc`: User library management
- `ThemeBloc`: Dark/light mode toggle

### Video Player Integration
Chewie wraps the Video Player plugin with:
- Custom controls
- Subtitle support
- Landscape mode optimization
- Playback speed adjustment

### Ad Integration (`core/ads/ad_service.dart`)
AdMob initialization for banner and rewarded ads in designated screen areas.

---

## 🧪 Testing

Run tests with:

```bash
flutter test

# With coverage
flutter test --coverage

# Watch mode (re-run on file changes)
flutter test --watch
```

Test files are located in the `test/` directory.

---

## 📱 Supported Platforms

- ✅ **Android** (5.1+)
- ✅ **iOS** (11.0+)
- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **Windows** (10+)
- ✅ **macOS** (10.11+)
- ✅ **Linux** (Ubuntu 18.04+)

---

## 🔧 Configuration

### Environment Variables / Secrets
Create a `.env` file in `cinewave/` if using external APIs:
```
API_KEY=your_tmdb_or_api_key
AD_MOB_APP_ID=your_admob_app_id
```

### Theme Customization
Edit `core/theme/app_theme.dart` to modify colors, typography, and theming logic.

### Shorebird Configuration
Update `shorebird.yaml` for code push settings:
```yaml
release_version: <version>
target_platforms:
  - android
  - ios
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| `flutter pub get` fails | Run `flutter clean` then `flutter pub get` again |
| Android build fails | Check Android Studio SDK versions; update `gradle.properties` if needed |
| Video player shows black screen | Ensure video URL is accessible; check codec support |
| Ads not showing | Verify AdMob app ID and ad unit IDs are correctly configured |
| Shorebird release fails | Run `shorebird auth` and ensure Shorebird CLI is up-to-date |

---

## 📖 Dependencies Reference

For detailed docs on major dependencies:
- [Flutter Bloc](https://bloclibrary.dev/)
- [Chewie Video Player](https://pub.dev/packages/chewie)
- [Dio HTTP Client](https://pub.dev/packages/dio)
- [Sqflite Database](https://pub.dev/packages/sqflite)
- [Shorebird Code Push](https://shorebird.dev/)
- [Google Mobile Ads](https://pub.dev/packages/google_mobile_ads)

---

## 📄 License

This project is provided as-is. Check the repository for any license file.

---

## 👨‍💻 Author

**Ayesh Chamodya**  
Created with ❤️ for cinema lovers.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

---

## 📞 Support

For questions or support, please open a GitHub issue in the repository.

