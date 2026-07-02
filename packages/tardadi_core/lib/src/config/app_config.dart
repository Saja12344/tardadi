import 'dart:io' show Platform;

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    this.organizationId = 'demo-org',
  });

  /// Local dev defaults. Android emulator uses `10.0.2.2` to reach the host.
  factory AppConfig.dev() {
    final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    return AppConfig(
      apiBaseUrl: 'http://$host:5001/demo-org/us-central1/api',
    );
  }

  final String apiBaseUrl;
  final String organizationId;
}
