class AppConstants {
  // App Info
  static const String appName = 'Tachiyomi';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String novelsBox = 'novels_box';
  static const String chaptersBox = 'chapters_box';
  static const String settingsBox = 'settings_box';
  static const String favoritesBox = 'favorites_box';
  
  // UI Constants
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double chipRadius = 20.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Grid Configuration
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.6;
  static const double gridSpacing = 8.0;
  
  // Novel Status
  static const String statusOngoing = 'Ongoing';
  static const String statusCompleted = 'Completed';
  static const String statusHiatus = 'Hiatus';
  
  // Sort Options
  static const String sortPopular = 'Popular';
  static const String sortLatest = 'Latest';
  static const String sortRating = 'Rating';
  static const String sortViews = 'Views';
  
  // Filter Options
  static const String filterAll = 'All';
  static const String filterCompleted = 'Completed';
  static const String filterOngoing = 'Ongoing';
  static const String filterRomance = 'Romance';
  static const String filterAction = 'Action';
  static const String filterSliceOfLife = 'Slice of Life';
  static const String filterFantasy = 'Fantasy';
  static const String filterMystery = 'Mystery';
  static const String filterDrama = 'Drama';
  static const String filterComedy = 'Comedy';
  
  // Navigation Routes
  static const String routeLibrary = '/library';
  static const String routeUpdates = '/updates';
  static const String routeHistory = '/history';
  static const String routeBrowse = '/browse';
  static const String routeMore = '/more';
  static const String routeNovelDetails = '/novel-details';
  static const String routeReader = '/reader';
  static const String routeSettings = '/settings';
  
  // Image Placeholders
  static const String placeholderImage = 'assets/images/placeholder.png';
  static const String defaultCover = 'assets/images/default_cover.png';
}
