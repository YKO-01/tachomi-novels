import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tachomi_novel/features/splash_screen.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/constants/app_constants.dart';
import 'core/models/chapter.dart';
import 'features/more/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Register Hive adapters for offline storage
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ChapterAdapter());
  }

  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: LoadingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class TachomiNovelApp extends ConsumerWidget {
  const TachomiNovelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
