import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/library/pages/library_page.dart';
import '../../features/browse/pages/browse_page.dart';
import '../../features/favorites/pages/favorites_page.dart';
import '../../features/history/pages/history_page.dart';
import '../../features/novel_details/pages/novel_details_page.dart';
import '../../features/more/pages/more_page.dart';
import '../../features/reader/pages/reader_page.dart';
import '../../features/download_queue/pages/download_queue_page.dart';
import '../../shared/constants/app_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.routeLibrary,
    routes: [
      // Main Navigation Shell
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppConstants.routeLibrary,
            name: 'library',
            builder: (context, state) => const LibraryPage(),
          ),
          GoRoute(
            path: AppConstants.routeUpdates,
            name: 'updates',
            builder: (context, state) => const BrowsePage(),
          ),
          GoRoute(
            path: AppConstants.routeHistory,
            name: 'history',
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: AppConstants.routeBrowse,
            name: 'favorites',
            builder: (context, state) => const FavoritesPage(),
          ),
          GoRoute(
            path: AppConstants.routeMore,
            name: 'more',
            builder: (context, state) => const MorePage(),
          ),
        ],
      ),
      
      // Novel Details
      GoRoute(
        path: '${AppConstants.routeNovelDetails}/:novelId',
        name: 'novel-details',
        builder: (context, state) {
          final novelId = state.pathParameters['novelId']!;
          return NovelDetailsPage(novelId: novelId);
        },
      ),
      
      // Reader
      GoRoute(
        path: '/reader/:novelId/:chapterId',
        name: 'reader',
        builder: (context, state) {
          final novelId = state.pathParameters['novelId']!;
          final chapterId = state.pathParameters['chapterId']!;
          return ReaderPage(novelId: novelId, chapterId: chapterId);
        },
      ),
      
      // Download Queue
      GoRoute(
        path: '/download-queue',
        name: 'download-queue',
        builder: (context, state) => const DownloadQueuePage(),
      ),
    ],
  );
}

class MainNavigationShell extends StatefulWidget {
  final Widget child;

  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          switch (index) {
            case 0:
              context.go(AppConstants.routeLibrary);
              break;
            case 1:
              context.go(AppConstants.routeUpdates);
              break;
            case 2:
              context.go(AppConstants.routeHistory);
              break;
            case 3:
              context.go(AppConstants.routeBrowse);
              break;
            case 4:
              context.go(AppConstants.routeMore);
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Updates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// Placeholder pages for navigation
class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Updates Page'),
      ),
    );
  }
}

