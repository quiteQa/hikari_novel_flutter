import 'package:enough_convert/enough_convert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/dual_page_mode.dart';

extension Controller on GetInterface {
  T findOrPut<T>(T Function() creator) {
    try {
      return Get.find<T>();
    } catch (_) {
      final instance = creator();
      Get.put<T>(instance);
      return instance;
    }
  }
}

extension ScreenInfo on BuildContext {
  bool isLargeScreen() => MediaQuery.of(this).size.width > MediaQuery.of(this).size.height;

  bool isTabletLikeScreen() => MediaQuery.of(this).size.shortestSide >= 600;

  bool shouldAutoUseDualPage() {
    final size = MediaQuery.of(this).size;
    return size.shortestSide >= 600 && size.width > size.height;
  }
}

extension UrlEncodingIfNotAscii on String {
  String gbkUrlEncodingIfNotAscii() {
    final bytes = GbkCodec().encode(this);
    return _encode(bytes);
  }

  String big5UrlEncodingIfNotAscii() {
    final bytes = Big5Codec().encode(this);
    return _encode(bytes);
  }

  String _encode(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      if (byte >= 0x00 && byte <= 0x7F) {
        buffer.write(String.fromCharCode(byte));
      } else {
        buffer.write('%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}');
      }
    }
    return buffer.toString();
  }
}

extension DualPageModeExt on DualPageMode {
  bool isEffective(BuildContext context) => switch (this) {
    DualPageMode.auto => context.shouldAutoUseDualPage(),
    DualPageMode.enabled => true,
    DualPageMode.disabled => false,
  };
}