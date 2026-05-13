import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/ads/ad_service.dart';
import 'core/services/isar_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize services
    await AdService.instance.initialize();
    await IsarService.init();
    await NotificationService.init();
  } catch (e) {
    debugPrint('Error during initialization: $e');
  }

  runApp(
    const ProviderScope(
      child: PactoraApp(),
    ),
  );
}

class PactoraApp extends ConsumerWidget {
  const PactoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pactora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLightTheme(),
      darkTheme: AppTheme.buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
