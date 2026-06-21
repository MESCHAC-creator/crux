import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AppConfig {
  static late String appVersion;
  static late String buildNumber;
  static late String deviceId;
  static late bool isDebugMode;

  // API Endpoints
  static const String baseUrl = 'https://api.crux.app/v1';
  static const String wsUrl = 'wss://ws.crux.app';

  // Firebase
  static const String firebaseProjectId = 'crux-project-id';

  // Feature flags
  static const bool enableAnalytics = !kDebugMode;
  static const bool enableCrashlytics = !kDebugMode;
  static const bool enablePerformanceMonitoring = !kDebugMode;

  static Future<void> initialize() async {
    isDebugMode = kDebugMode;
    
    // Get package info
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    buildNumber = packageInfo.buildNumber;

    // Get device ID
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      deviceId = 'unknown';
    }
  }

  static String get apiBaseUrl => baseUrl;
  static String get webSocketUrl => wsUrl;
  static bool get isProduction => !isDebugMode;
}
