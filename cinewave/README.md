# CineWave

CineWave is a modern, high-performance streaming application for movies and TV shows, built with Flutter. It features a cinematic user experience, intelligent watch history tracking, and instant "Code Push" updates.

## 🚀 Key Features

*   **Premium Video Player**: Custom-built landscape player with double-tap to seek, playback speed control (0.5x - 2.0x), and multiple scaling modes (Fit, Zoom, Stretch).
*   **Smart Library**:
    *   **Continue Watching**: Resume exactly where you left off with visual progress indicators.
    *   **Watch History**: Automatic tracking of your recently watched content.
    *   **Watchlist**: Bookmark movies and shows you want to watch later.
    *   **Favorites**: Keep your most-loved content just a tap away.
*   **Subtitle Support**: Automatic detection of available subtitles and support for custom `.vtt` or `.srt` files (local or URL).
*   **Native Ads**: Non-intrusive banner ads and rewarded interstitial ads for sustainable monetization.
*   **Shorebird Integration**: Instant over-the-air updates for UI tweaks and critical bug fixes.
*   **Performance Focused**: Optimized image caching, shimmer loading effects, and staggered UI animations.

## 🛠 Tech Stack

*   **Framework**: Flutter
*   **State Management**: Bloc / Cubit
*   **Local Database**: SQLite (Sqflite)
*   **Networking**: Dio & HTTP
*   **Video Playback**: Chewie & Video Player
*   **Ad Network**: Google Mobile Ads (AdMob)
*   **Code Push**: Shorebird

## 📦 Getting Started

### Prerequisites
*   Flutter SDK (^3.11.5)
*   Android Studio / VS Code
*   Shorebird CLI (for hot updates)

### Setup
1.  Clone the repository.
2.  Run `flutter pub get` to install dependencies.
3.  Ensure your `android/key.properties` is configured for signing.
4.  Run the app using `flutter run`.

## 🚀 Production Build
To build for the Play Store with Shorebird support:
```bash
shorebird release android
```

---
*Created by Ayesh Chamodya • Built with ❤️ for Cinema lovers.*
