import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart' as ckjar;
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:flutter/foundation.dart';
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/models/custom_exception.dart';
import 'package:hikari_novel_flutter/models/resource.dart';

import '../common/log.dart';
import '../models/common/charsets_type.dart';
import '../service/local_storage_service.dart';
import 'api.dart';

/// 网络请求
class Request {
  // 绕过 Cloudflare 的完整 headers
  static const Map<String, String> cfBypassHeaders = {
    io.HttpHeaders.userAgentHeader: 
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0',
    'Accept': 
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'Accept-Language': 
        'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    'Accept-Charset': 
        'GBK,utf-8;q=0.7,*;q=0.3', // 添加 GBK 支持
    'Accept-Encoding': 
        'gzip, deflate, br',
    'Sec-Ch-Ua': 
        '"Not_A Brand";v="8", "Chromium";v="135", "Microsoft Edge";v="135"',
    'Sec-Ch-Ua-Mobile': 
        '?0',
    'Sec-Ch-Ua-Platform': 
        '"Windows"',
    'Sec-Fetch-Dest': 
        'document',
    'Sec-Fetch-Mode': 
        'navigate',
    'Sec-Fetch-Site': 
        'none',
    'Sec-Fetch-User': 
        '?1',
    'Upgrade-Insecure-Requests': 
        '1',
    'Cache-Control': 
        'max-age=0',
    'Connection': 
        'keep-alive',
  };

  static final _dioCookieJar = ckjar.CookieJar();
  static final Dio dio =
      Dio(
          BaseOptions(
            headers: cfBypassHeaders, // 使用完整的反 CF headers
            responseType: ResponseType.bytes, //使用 bytes 获取原始数据，方便解码
            followRedirects: false, //使 302 重定向手动处理
            validateStatus: (status) => status != null, //只要不是 null，就交给拦截器处理,
            sendTimeout: const Duration(seconds: 30), // 增加超时时间
            receiveTimeout: const Duration(seconds: 30),
          ),
        )
        ..interceptors.add(CloudflareInterceptor())
        ..interceptors.add(CookieManager(_dioCookieJar));

  static void initCookie() {
    final localCookie = LocalStorageService.instance.getCookie();

    if (localCookie == null) return;

    final cookies = localCookie.split(';').map((e) => e.trim()).where((e) => e.contains('=')).map((e) {
      final kv = e.split('=');
      return ckjar.Cookie(kv[0], kv.sublist(1).join('='));
    }).toList();

    _dioCookieJar.saveFromResponse(Uri.parse(Wenku8Node.wwwWenku8Cc.node), cookies);
    _dioCookieJar.saveFromResponse(Uri.parse(Wenku8Node.wwwWenku8Net.node), cookies);
  }

  static void initToken() {
    final token = LocalStorageService.instance.getToken();
    if (token == null || token.isEmpty) return;

    // 设置 Authorization header 或 cookie
    dio.options.headers['Cookie'] = "jieqiUserInfo=$token";
  }

  static void deleteCookie() => _dioCookieJar.deleteAll();

  ///获取通用数据（如其他网站的数据，即不用wenku8的cookie）
  /// - [url] 对应网站的url
  static Future<Resource> getCommonData(String url) async {
    try {
      final dio = Dio(BaseOptions(headers: cfBypassHeaders));
      final response = await dio.get(url);
      return Success(response.data);
    } catch (e) {
      return Error(e.toString());
    }
  }

  ///获取wenku8数据
  /// - [url] 对应的url
  /// - [charsetsType] response解码的方式
  static Future<Resource> get(String url, {required CharsetsType charsetsType}) async {
    try {
      if (!url.contains("?")) url += "?";
      switch (charsetsType) {
        case CharsetsType.gbk:
          url += "&charset=gbk";
        case CharsetsType.big5Hkscs:
          url += "&charset=big5";
      }

      Log.d("$url ${charsetsType.name}");

      final response = await dio.get(url);

      //检查是否有重定向
      final result = await _checkRedirects(response);

      final raw = result as Uint8List;
      late String decodedHtml;
      switch (charsetsType) {
        case CharsetsType.gbk:
          try {
            decodedHtml = GbkCodec().decode(raw);
          } catch (e) {
            // 如果 GBK 解码失败，尝试使用 utf-8 作为备选
            Log.w('GBK 解码失败，尝试 UTF-8: $e');
            decodedHtml = utf8.decode(raw, allowMalformed: true);
          }
        case CharsetsType.big5Hkscs:
          decodedHtml = Big5Codec().decode(raw);
      }

      return Success(decodedHtml);
    } catch (e) {
      Log.e(e.toString());
      return Error(e.toString());
    }
  }

  /// 检查Response包中是否要求重定向
  /// - [response] 要检查的Response包
  static Future<dynamic> _checkRedirects(Response response) async {
    if (response.statusCode != null && response.statusCode! >= 300 && response.statusCode! < 400) {
      final location = response.headers.value('location');
      if (location != null) {
        final redirectedResponse = await dio.get("${Api.wenku8Node.node}/$location");
        return redirectedResponse.data;
      }
    }
    return response.data;
  }

  /// 以post方法进行http请求
  /// body以Content-Type: application/x-www-form-urlencoded的形式进行发送
  /// - [url] 要请求的url
  /// - [data] 此post请求的body，当body中含有url编码的内容时，需要使用String类型而非Map类型！目前不知道是什么原因，可能是因为dio的二次编码？
  /// - [charsetsType] response解码的方式
  static Future<Resource> postForm(String url, {required Object? data, required CharsetsType charsetsType}) async {
    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType), //设置为application/x-www-form-urlencoded
      );
      String decodedHtml;
      switch (charsetsType) {
        case CharsetsType.gbk:
          {
            decodedHtml = GbkCodec().decode(response.data as Uint8List);
          }
        case CharsetsType.big5Hkscs:
          {
            decodedHtml = Big5Codec().decode(response.data as Uint8List);
          }
      }
      return Success(decodedHtml);
    } catch (e) {
      Log.e(e.toString());
      return Error(e.toString());
    }
  }
}

class CloudflareInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {
    final statusCode = response.statusCode;
    if (statusCode == 403) {
      handler.reject(Cloudflare403Exception(requestOptions: response.requestOptions));
      return;
    }

    final cfMitigated = response.headers['cf-mitigated'];
    if (cfMitigated == null || !cfMitigated.contains('challenge')) {
      handler.next(response);
      return;
    }
    handler.reject(CloudflareChallengeException(requestOptions: response.requestOptions));
  }
}