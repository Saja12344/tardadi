import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../services/driver_prefs.dart';
import '../services/locale_notifier.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'ui/driver_design.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DriverPrefs.instance.init();
  await LocaleNotifier.instance.loadSaved();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: DriverColors.navy,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: DriverColors.navy,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TardadiDriverApp());
}

class TardadiDriverApp extends StatelessWidget {
  const TardadiDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleNotifier.instance,
      builder: (context, _) {
        final locale = LocaleNotifier.instance.locale;
        return MaterialApp(
          title: 'ترددي — سائق',
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: DriverColors.orange,
              primary: DriverColors.orange,
              surface: DriverColors.softWhite,
            ),
            scaffoldBackgroundColor: DriverColors.softWhite,
            fontFamily: locale.languageCode == 'ar' ? null : 'Roboto',
            inputDecorationTheme: const InputDecorationTheme(
              filled: false,
              border: InputBorder.none,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          builder: (context, child) {
            final data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaler: TextScaler.noScaling),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const SplashScreen(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/map': (_) => const MapScreen(),
          },
        );
      },
    );
  }
}
