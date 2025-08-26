import 'package:connectivity_plus/connectivity_plus.dart';

/// True if any interface is up (wifi/mobile/ethernet).
Future<bool> hasNetwork() async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none; // single enum compare
}
