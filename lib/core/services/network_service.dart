import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final Connectivity _connectivity = Connectivity();

  static Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map((results) => _hasAnyConnection(results));

  static Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _hasAnyConnection(results);
  }

  static bool _hasAnyConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}


