import 'dart:io' show Platform;

import 'package:tardadi_core/tardadi_core.dart';

TardadiApi createPassengerApi() {
  final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  return TardadiApi(
    config: AppConfig(
      apiBaseUrl: 'http://$host:5001/tardadi-5bd8e/us-central1/api',
    ),
  );
}
