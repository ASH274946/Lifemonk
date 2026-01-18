import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/services/supabase_service.dart';

Future<void> main() async {
  // Ensure Flutter is ready - minimal blocking
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ensure Flutter is ready - minimal blocking
  WidgetsFlutterBinding.ensureInitialized();
  
  // Note: Environment and Supabase initialization moved to SplashScreen
  // to prevent app freeze on startup if config is missing.
  
  // Set preferred orientations (non-blocking)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI style for status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFAFAFA),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Catch unhandled exceptions from Supabase deep link handler
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log the error but don't crash
    print('❌ Unhandled Flutter error: ${details.exception}');
    print('Stack: ${details.stack}');
  };

  // Run app immediately - initialization happens in splash screen
  runApp(const ProviderScope(child: LifemonkApp()));
}

/// Root widget for the Lifemonk app
class LifemonkApp extends ConsumerWidget {
  const LifemonkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Lifemonk',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Router configuration
      routerConfig: router,
    );
  }
}
