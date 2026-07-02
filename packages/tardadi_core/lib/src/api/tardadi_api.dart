import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/models.dart';

class TardadiApi {
  TardadiApi({AppConfig? config}) : _config = config ?? AppConfig.dev();

  final AppConfig _config;

  Uri _uri(String path, [Map<String, String>? extraQuery]) {
    final query = {
      'organizationId': _config.organizationId,
      ...?extraQuery,
    };
    return Uri.parse('${_config.apiBaseUrl}$path')
        .replace(queryParameters: query);
  }

  Future<T> _request<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? query,
    required T Function(dynamic data) parser,
  }) async {
    final uri = _uri(path, query);
    final response = await switch (method) {
      'GET' => http.get(uri),
      'POST' => http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body == null ? null : jsonEncode(body),
        ),
      'DELETE' => http.delete(uri),
      _ => throw UnsupportedError('Unsupported method: $method'),
    };

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['success'] != true) {
      throw Exception(decoded['error'] ?? 'Request failed');
    }

    return parser(decoded['data']);
  }

  Future<List<RouteModel>> getRoutes() {
    return _request(
      '/api/routes',
      parser: (data) => (data as List)
          .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<({RouteModel route, List<StopModel> stops})> getRoute(
    String routeId,
  ) {
    return _request(
      '/api/routes/$routeId',
      parser: (data) {
        final map = data as Map<String, dynamic>;
        return (
          route: RouteModel.fromJson(map['route'] as Map<String, dynamic>),
          stops: (map['stops'] as List)
              .map((e) => StopModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      },
    );
  }

  Future<List<BusModel>> getBuses({bool activeOnly = false}) {
    return _request(
      '/api/buses',
      query: activeOnly ? {'active': 'true'} : null,
      parser: (data) => (data as List)
          .map((e) => BusModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<DriverSession> driverLogin({
    required String phone,
  }) {
    return _request(
      '/api/auth/driver-login',
      method: 'POST',
      body: {
        'organizationId': _config.organizationId,
        'phone': phone,
      },
      parser: (data) {
        final map = data as Map<String, dynamic>;
        return DriverSession(
          driver: DriverModel.fromJson(map['driver'] as Map<String, dynamic>),
          bus: BusModel.fromJson(map['bus'] as Map<String, dynamic>),
          route: RouteModel.fromJson(map['route'] as Map<String, dynamic>),
          stops: (map['stops'] as List)
              .map((e) => StopModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      },
    );
  }

  Future<List<TripModel>> getTrips({String? status}) {
    return _request(
      '/api/trips',
      query: status == null ? null : {'status': status},
      parser: (data) => (data as List)
          .map((e) => TripModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<String> startTrip({
    required String driverId,
    required String busId,
    required String routeId,
  }) {
    return _request(
      '/api/trips/start',
      method: 'POST',
      body: {
        'organizationId': _config.organizationId,
        'driverId': driverId,
        'busId': busId,
        'routeId': routeId,
      },
      parser: (data) => (data as Map<String, dynamic>)['tripId'] as String,
    );
  }

  Future<void> endTrip({
    required String tripId,
    required String driverId,
  }) {
    return _request(
      '/api/trips/end',
      method: 'POST',
      body: {
        'organizationId': _config.organizationId,
        'tripId': tripId,
        'driverId': driverId,
      },
      parser: (_) {},
    );
  }

  Future<void> sendGps({
    required String tripId,
    required String driverId,
    required String busId,
    required double latitude,
    required double longitude,
    double? speedKmh,
    double? heading,
  }) {
    return _request(
      '/api/gps',
      method: 'POST',
      body: {
        'organizationId': _config.organizationId,
        'tripId': tripId,
        'driverId': driverId,
        'busId': busId,
        'latitude': latitude,
        'longitude': longitude,
        if (speedKmh != null) 'speedKmh': speedKmh,
        if (heading != null) 'heading': heading,
      },
      parser: (_) {},
    );
  }

  Future<String> createReminder({
    required String userId,
    required String busId,
    required String routeId,
    required String stopId,
    required String fcmToken,
    int notifyWhenMinutesAway = 5,
  }) {
    return _request(
      '/api/reminders',
      method: 'POST',
      body: {
        'organizationId': _config.organizationId,
        'userId': userId,
        'busId': busId,
        'routeId': routeId,
        'stopId': stopId,
        'fcmToken': fcmToken,
        'notifyWhenMinutesAway': notifyWhenMinutesAway,
      },
      parser: (data) => (data as Map<String, dynamic>)['reminderId'] as String,
    );
  }

  Future<void> cancelReminder(String reminderId) {
    return _request(
      '/api/reminders/$reminderId',
      method: 'DELETE',
      parser: (_) {},
    );
  }
}
