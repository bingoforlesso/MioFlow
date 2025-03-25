import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@singleton
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _username;
  String? _companyName;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoggedIn => _isAuthenticated;
  String? get token => _token;
  String? get username => _username;
  String? get companyName => _companyName;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }

  void setUsername(String? username) {
    _username = username;
    notifyListeners();
  }

  void setCompanyName(String? companyName) {
    _companyName = companyName;
    notifyListeners();
  }

  void clear() {
    _isAuthenticated = false;
    _token = null;
    _username = null;
    _companyName = null;
    notifyListeners();
  }
}
