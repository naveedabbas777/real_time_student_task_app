import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  final Dio _dio = Dio();
  final SharedPreferences _prefs;

  ApiService(this._prefs) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      final user = User.fromJson(response.data['user']);

      await _prefs.setString('token', token);

      return {'user': user, 'token': token};
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _prefs.remove('token');
  }

  // Task endpoints
  Future<List<Task>> getTasks() async {
    try {
      final response = await _dio.get('$baseUrl/tasks');
      return (response.data as List)
          .map((json) => Task.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Task>> getMyTasks() async {
    try {
      final response = await _dio.get('$baseUrl/tasks/my');
      return (response.data as List)
          .map((json) => Task.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await _dio.post('$baseUrl/tasks', data: taskData);
      return Task.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> updateTaskStatus(String taskId, String status) async {
    try {
      final response = await _dio.patch(
        '$baseUrl/tasks/$taskId/status',
        data: {'status': status},
      );
      return Task.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Student endpoints
  Future<List<User>> getStudents() async {
    try {
      final response = await _dio.get('$baseUrl/users/students');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadStudents(
    List<Map<String, dynamic>> students,
  ) async {
    try {
      final response = await _dio.post('$baseUrl/users/upload', data: students);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getStudentPerformance(String studentId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/users/students/$studentId/performance',
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null &&
          error.response?.data['message'] != null) {
        return error.response?.data['message'];
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout';
        case DioExceptionType.badResponse:
          return 'Server error';
        case DioExceptionType.cancel:
          return 'Request cancelled';
        default:
          return 'Network error';
      }
    }
    return 'Something went wrong';
  }
}
