import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tardadi_core/tardadi_core.dart';

import 'l10n/app_localizations.dart';
import 'screens/onboarding/splash_screen.dart';
import 'services/bus_arrival_notifications.dart';
import 'services/local_notification_service.dart';
import 'services/user_session.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.instance.initialize();
  BusArrivalNotificationService.instance
      .attachMessenger(rootScaffoldMessengerKey);
  runApp(const TardadiPassengerApp());
}

class TardadiPassengerApp extends StatefulWidget {
  const TardadiPassengerApp({super.key});

  @override
  State<TardadiPassengerApp> createState() => _TardadiPassengerAppState();
}

class _TardadiPassengerAppState extends State<TardadiPassengerApp> {
  @override
  void initState() {
    super.initState();
    UserSession.instance.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    UserSession.instance.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;
    final localizations = AppLocalizations(session.language);

    return MaterialApp(
      title: 'Tardadi',
      theme: TardadiBrand.darkTheme(),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      locale: localizations.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return AppLocaleScope(
          localizations: localizations,
          child: Directionality(
            textDirection: localizations.textDirection,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
