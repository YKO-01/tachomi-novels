# 📚 Tachomi Novel

A **fully functional** Flutter iOS novel reader app inspired by Tapas and Tachiyomi, featuring a clean, modern UI with comprehensive library management, reading features, and complete navigation system.

## ✨ **FULLY FUNCTIONAL FEATURES**

### 🏠 **Home / Browse Page**
- ✅ **Grid layout** showing novel covers, titles, and subtitles
- ✅ **Filter chips** for "Popular", "Latest", "Romance", "BL", "Slice of Life"
- ✅ **Search functionality** with real-time filtering
- ✅ **Novel cards** with tap navigation to details page
- ✅ **Long-press actions** for favorites and downloads

### 📖 **Novel Details Page**
- ✅ **Full novel information** with cover, title, author, tags, description
- ✅ **"Add to Library" button** with state management
- ✅ **"WebView" button** for external links
- ✅ **Chapter list** with download icons and timestamps
- ✅ **Floating "Start Reading" button** with navigation
- ✅ **Tag chips** for categorization

### 📚 **Reader Page**
- ✅ **Full text display** with customizable settings
- ✅ **Font size controls** (12-24px range)
- ✅ **Theme selection** (Light, Dark, Sepia)
- ✅ **Line height adjustment** (1.0-2.5)
- ✅ **Next/Previous chapter navigation**
- ✅ **Bookmark functionality**
- ✅ **Reading progress tracking**

### 📚 **Library Page**
- ✅ **All added novels** with grid layout
- ✅ **Sort by Recently Read / Favorites**
- ✅ **Tap to open details**, Long press for actions
- ✅ **Search and filter** functionality
- ✅ **State management** with Riverpod

### 📱 **More / Settings Page**
- ✅ **Toggle switches** for "Downloaded only" and "Incognito mode"
- ✅ **Download Queue** with progress indicators
- ✅ **Categories** management
- ✅ **Statistics** display
- ✅ **Backup & Restore** options
- ✅ **Settings** and **About** pages

### 🧭 **Bottom Navigation**
- ✅ **Library** - Main library with novels
- ✅ **Updates** - New chapters and notifications
- ✅ **History** - Reading history and progress
- ✅ **Browse** - Discover new novels
- ✅ **More** - Settings and app management

### 📥 **Download Queue**
- ✅ **Progress indicators** with real-time updates
- ✅ **Pause/Resume/Cancel** functionality
- ✅ **Download status** (Queued, Downloading, Completed, Failed)
- ✅ **Queue management** with clear all option

### 📊 **Updates Page**
- ✅ **New chapter notifications**
- ✅ **Status indicators** (New, Unread, Read, Downloaded)
- ✅ **Chapter actions** (Read, Download, Mark as Read)
- ✅ **Sort by date** and status

### 📈 **History Page**
- ✅ **Reading progress** tracking
- ✅ **Chapter completion** status
- ✅ **Sort by recent** or novel name
- ✅ **Continue reading** functionality
- ✅ **Remove from history** option

## 🎨 Design Features

- **Clean, card-based grid layout** for novels (inspired by Tapas)
- **Soft rounded corners** and balanced padding
- **Readable typography** with Nunito font family
- **Minimal top app bar** with search, filter, and sort options
- **Bottom navigation** with Library, Updates, History, Browse, and More tabs
- **Light and dark themes** with adaptive color schemes
- **iOS-style design** with Cupertino switches and clean iconography

## 🧩 Core Features

### 1. Library Page
- Grid view of novels with cover, title, and metadata
- Filter chips for categories (Popular, Latest, Romance, BL, Slice of Life, etc.)
- Smooth infinite scroll with lazy-loading covers
- Long-press actions for favorites and collections
- Search and sort functionality

### 2. Novel Details Page
- Large cover image with metadata display
- Novel information (title, author, tags, description)
- "Add to Library" and "WebView" action buttons
- Tag chips for categorization
- Chapters list with download options
- Floating "Start/Continue Reading" button

### 3. More/Settings Page
- Toggle switches for "Downloaded only" and "Incognito mode"
- Library management options (Download Queue, Categories, Statistics)
- Data management (Backup & Restore, Clear Cache)
- App information and help sections

## ⚙️ Technical Stack

- **Flutter** (latest stable)
- **State Management**: Riverpod
- **Local Storage**: Hive
- **Networking**: Dio
- **Routing**: go_router
- **Image Caching**: cached_network_image
- **UI Components**: flutter_staggered_grid_view
- **Storage**: path_provider, shared_preferences

## 🏗️ Architecture

The app follows clean architecture principles with feature-based organization:

```
lib/
├── core/
│   ├── models/          # Data models (Novel, Chapter, UserSettings)
│   ├── services/        # Business logic services
│   ├── theme/           # App themes and styling
│   └── routing/         # Navigation configuration
├── features/
│   ├── library/         # Library page and providers
│   ├── novel_details/    # Novel details page and providers
│   └── more/           # Settings and more page
└── shared/
    ├── widgets/         # Reusable UI components
    └── constants/       # App constants and configuration
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- iOS development environment (Xcode, iOS Simulator)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tachomi_novel
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for iOS

1. **Open in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure signing** in Xcode
3. **Build and run** on device or simulator

## 📱 Features Overview

### Library Management
- Browse novels in a beautiful grid layout
- Filter by categories and tags
- Sort by popularity, latest, rating, or views
- Search functionality
- Favorite and download management

### Reading Experience
- Clean, distraction-free reading interface
- Customizable font size and family
- Dark and light theme support
- Offline reading capabilities
- Chapter navigation and bookmarks

### Settings & Customization
- Theme preferences (light/dark)
- Reading settings (font size, line height)
- Download preferences (WiFi only, auto-download)
- Library organization options
- Data backup and restore

## 🎨 UI/UX Guidelines

- **Typography**: Nunito font family for readability
- **Grid Cards**: 2:3 aspect ratio for novel covers
- **Spacing**: Consistent 8/16/24px spacing system
- **Corner Radius**: 12-16px for cards and buttons
- **Shadows**: Subtle elevation for depth
- **Colors**: Adaptive color schemes for light/dark themes
- **Icons**: Material Design and Cupertino icons

## 🔧 Development

### Code Generation
The app uses Hive for local storage, which requires code generation:

```bash
# Generate Hive adapters
dart run build_runner build

# Watch for changes during development
dart run build_runner watch
```

### State Management
The app uses Riverpod for state management with:
- `Provider` for services and dependencies
- `StateNotifierProvider` for complex state management
- `FutureProvider` for async data loading
- `AsyncValue` for loading states

### Architecture Patterns
- **Clean Architecture**: Separation of concerns
- **Feature-based**: Organized by app features
- **Repository Pattern**: Data access abstraction
- **Provider Pattern**: State management
- **MVVM**: Model-View-ViewModel structure

## 📦 Dependencies

Key dependencies used in this project:

```yaml
dependencies:
  flutter_riverpod: ^2.4.9      # State management
  hive: ^2.2.3                   # Local storage
  hive_flutter: ^1.1.0           # Hive Flutter integration
  dio: ^5.4.0                    # HTTP client
  go_router: ^12.1.3             # Navigation
  cached_network_image: ^3.3.0   # Image caching
  flutter_staggered_grid_view: ^0.7.0  # Grid layouts
  path_provider: ^2.1.2          # File system access
  shared_preferences: ^2.2.2     # Simple storage

dev_dependencies:
  hive_generator: ^2.0.1        # Code generation
  build_runner: ^2.4.7          # Build system
```

## 🎯 Future Enhancements

- [ ] Reader page with customizable reading experience
- [ ] Offline reading with downloaded chapters
- [ ] Text-to-speech (TTS) support
- [ ] Advanced search and filtering
- [ ] Reading statistics and analytics
- [ ] Cloud sync and backup
- [ ] Social features (reviews, ratings)
- [ ] Push notifications for updates
- [ ] Widget support for quick access

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support, email support@tachomi.com or create an issue in the repository.

---

**Tachomi Novel** - A beautiful reading experience, inspired by the best.