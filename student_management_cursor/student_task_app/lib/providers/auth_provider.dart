import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _user;
  String? _token;
  bool _isLoading = false;

  AuthProvider(this._apiService);

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _apiService.login(email, password);
      _user = result['user'];
      _token = result['token'];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
      _user = null;
      _token = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
} 