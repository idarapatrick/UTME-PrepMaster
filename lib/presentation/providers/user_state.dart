import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;
  String? _displayName;
  String? get displayName => _displayName;

  void setAvatar(String url) {
    _avatarUrl = url;
    notifyListeners();
  }

  void setDisplayName(String name) {
    _displayName = name;
    notifyListeners();
  }

  void loadUserProfile(Map<String, dynamic> profile) {
    _avatarUrl = profile['avatarUrl'] as String?;
    _displayName = profile['displayName'] as String?;
    notifyListeners();
  }
}
