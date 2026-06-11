class AppConfig {
  const AppConfig({
    this.apiBaseUrl =
        'http://127.0.0.1:5001/demo-org/us-central1/api',
    this.organizationId = 'demo-org',
  });

  final String apiBaseUrl;
  final String organizationId;
}
