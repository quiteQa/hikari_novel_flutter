import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

import '../common/log.dart';

/// 网络请求重试工具
class RetryHelper {
  RetryHelper._();

  /// 带重试的异步执行
  /// [maxRetries] 最大重试次数（不含首次）
  /// [delay] 重试间隔
  /// [retryIf] 判断是否需要重试的条件
  static Future<T> retry<T>(
    Future<T> Function() action, {
    int maxRetries = 2,
    Duration delay = const Duration(seconds: 1),
    bool Function(dynamic error)? retryIf,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await action();
      } catch (e) {
        attempt++;
        if (attempt > maxRetries || !(retryIf?.call(e) ?? _defaultRetryIf(e))) {
          rethrow;
        }
        Log.w('请求失败，第 $attempt 次重试... 错误: $e');
        await Future.delayed(delay * attempt); // 指数退避
      }
    }
  }

  /// 默认重试条件：网络错误、超时、服务器错误
  static bool _defaultRetryIf(dynamic error) {
    if (error is DioException) {
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError => true,
        _ => error.response?.statusCode != null &&
            error.response!.statusCode! >= 500,
      };
    }
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    return false;
  }
}
