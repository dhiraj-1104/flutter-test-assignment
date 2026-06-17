import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkConnectivity {
  Future<bool> get isConnected;
}

class NetworkConnectivityImpl implements NetworkConnectivity {
  final Connectivity connectivity;

  NetworkConnectivityImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();

    return !result.contains(ConnectivityResult.none);
  }
}
