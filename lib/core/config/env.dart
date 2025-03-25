import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  }

  static String get apiVersion {
    return dotenv.env['API_VERSION'] ?? 'v1';
  }

  static Duration get connectionTimeout {
    final timeout =
        int.tryParse(dotenv.env['CONNECTION_TIMEOUT'] ?? '30') ?? 30;
    return Duration(seconds: timeout);
  }

  static Duration get receiveTimeout {
    final timeout = int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '30') ?? 30;
    return Duration(seconds: timeout);
  }
}
