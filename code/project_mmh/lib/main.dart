import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_mmh/core/router/app_router.dart';
import 'package:project_mmh/core/theme/app_theme.dart';
import 'package:project_mmh/core/services/notification_service.dart';
import 'package:project_mmh/core/services/image_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
import 'package:project_mmh/features/core/presentation/providers/theme_provider.dart';
import 'package:project_mmh/features/settings/presentation/providers/reminder_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // App offline-first: las fuentes van empaquetadas como asset, nunca por red.
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting('es_ES', null);
  await ImageService.init();
  await NotificationService.instance.init(
    onNotificationTap: (_) => appRouter.go('/agenda'),
  );
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  runApp(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );

  // Fuera del critical path del arranque: reprogramar recordatorios y procesar
  // el tap de notificación que abrió la app en frío (una vez montado el router).
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.instance.consumePendingLaunch();
    container.read(reminderSettingsProvider.notifier).refreshNotifications();
  });
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Klinik',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES')],
    );
  }
}
