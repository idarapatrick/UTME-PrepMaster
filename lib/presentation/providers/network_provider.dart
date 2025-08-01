import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkProvider extends ChangeNotifier {
  bool _isConnected = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.wifi;
  bool _isInitialized = false;

  bool get isConnected => _isConnected;
  ConnectivityResult get connectivityResult => _connectivityResult;
  bool get isInitialized => _isInitialized;

  // Initialize network monitoring
  Future<void> initialize() async {
    try {
      // Get initial connectivity status
      final connectivity = Connectivity();
      _connectivityResult = await connectivity.checkConnectivity();
      _isConnected = _connectivityResult != ConnectivityResult.none;

      // Listen to connectivity changes
      connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
        _connectivityResult = result;
        final wasConnected = _isConnected;
        _isConnected = result != ConnectivityResult.none;

        // Only notify if connection status actually changed
        if (wasConnected != _isConnected) {
          notifyListeners();
        }
      });

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // If connectivity check fails, assume connected
      _isConnected = true;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Get connection type string
  String get connectionTypeString {
    switch (_connectivityResult) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  // Check if connection is stable (WiFi or Ethernet)
  bool get isStableConnection {
    return _connectivityResult == ConnectivityResult.wifi ||
           _connectivityResult == ConnectivityResult.ethernet;
  }

  // Check if connection is mobile
  bool get isMobileConnection {
    return _connectivityResult == ConnectivityResult.mobile;
  }

  // Get connection quality indicator
  String get connectionQuality {
    if (!_isConnected) return 'No Connection';
    if (isStableConnection) return 'Excellent';
    if (isMobileConnection) return 'Good';
    return 'Fair';
  }

  // Get connection icon
  IconData get connectionIcon {
    switch (_connectivityResult) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.mobile:
        return Icons.mobile_friendly;
      case ConnectivityResult.ethernet:
        return Icons.wifi;
      case ConnectivityResult.vpn:
        return Icons.vpn_key;
      case ConnectivityResult.bluetooth:
        return Icons.bluetooth;
      case ConnectivityResult.other:
        return Icons.network_check;
      case ConnectivityResult.none:
        return Icons.signal_wifi_off;
    }
  }

  // Get connection color
  Color get connectionColor {
    if (!_isConnected) return Colors.red;
    if (isStableConnection) return Colors.green;
    if (isMobileConnection) return Colors.orange;
    return Colors.yellow;
  }

  // Dispose
  @override
  void dispose() {
    super.dispose();
  }
} 