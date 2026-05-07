import
'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Notification service initialization
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: MahallaApp(),
    ),
  );
}

class MahallaApp extends ConsumerWidget {
  const MahallaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Mahalla Xizmati',
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('uz', 'UZ'), // O'zbek tili
      ],
      locale: const Locale('uz', 'UZ'),
      
      // Router
      routerConfig: router,
      
      // Builder for loading state
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
