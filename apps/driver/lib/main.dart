import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'ui/driver_design.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: DriverColors.navy,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TardadiDriverApp());
}

class TardadiDriverApp extends StatelessWidget {
  const TardadiDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ترددي — سائق',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: DriverColors.orange,
          primary: DriverColors.orange,
          surface: DriverColors.softWhite,
        ),
        scaffoldBackgroundColor: DriverColors.softWhite,
        fontFamily: 'Roboto',
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
      home: const LoginScreen(),
      routes: {'/map': (_) => const MapScreen()},
    );
  }
}
