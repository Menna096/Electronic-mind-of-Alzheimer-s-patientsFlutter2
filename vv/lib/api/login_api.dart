import 'package:dio/dio.dart';
import 'package:vv/utils/token_manage.dart';

class DioService {
  static final DioService _instance = DioService._internal();
  late Dio dio;

  factory DioService() => _instance;

  DioService._internal() {
    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final String? token = await TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] ='Bearer $token' ;
          }
          return handler.next(options);
        },
      ),
    );
  }
}