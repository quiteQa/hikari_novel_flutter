import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/resource.dart';

import '../../common/database/database.dart';
import '../../common/log.dart';
import '../../network/api.dart';
import '../../network/parser.dart';
import '../../network/request.dart';
import '../../router/route_path.dart';
import '../../service/db_service.dart';
import '../../service/local_storage_service.dart';

class TokenLoginController extends GetxController {
  final tokenController = TextEditingController();
  final RxString token = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onClose() {
    tokenController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (token.value.isEmpty) {
      errorMessage.value = 'please_enter_token'.tr;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 使用 token 设置 cookie
      final cookie = "jieqiUserInfo=${token.value};";
      LocalStorageService.instance.setCookie(cookie);
      Request.initCookie();

      // 获取用户信息验证 token 是否有效
      final userInfo = await _getUserInfo();
      
      if (userInfo != null) {
        // 刷新书架
        await _refreshBookshelf();
        
        // 登录成功，跳转到主页
        Get.offAllNamed(RoutePath.main);
      } else {
        // Token 无效，清空
        LocalStorageService.instance.setCookie(null);
        Request.deleteCookie();
        errorMessage.value = 'invalid_token'.tr;
      }
    } catch (e) {
      Log.e('Token login error: $e');
      LocalStorageService.instance.setCookie(null);
      Request.deleteCookie();
      errorMessage.value = 'login_failed'.tr + ': ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearToken() async {
    tokenController.clear();
    token.value = '';
    errorMessage.value = '';
    LocalStorageService.instance.setCookie(null);
    Request.deleteCookie();
  }

  Future<Map<String, dynamic>?> _getUserInfo() async {
    final data = await Api.getUserInfo();
    switch (data) {
      case Success():
        final userInfo = Parser.getUserInfo(data.data);
        LocalStorageService.instance.setUserInfo(userInfo);
        return userInfo;
      case Error():
        throw data.error;
    }
  }

  Future<void> _refreshBookshelf() async {
    await DBService.instance.deleteAllBookshelf();

    final futures = Iterable.generate(6, (index) async {
      await _insertAll(index);
    });
    await Future.wait(futures);
  }

  Future<void> _insertAll(int index) async {
    final data = await Api.getBookshelf(classId: index);
    switch (data) {
      case Success():
        final list = Parser.getBookshelf(data.data, classId: index);
        if (list.isNotEmpty) {
          await DBService.instance.insertBookshelf(list);
        }
      case Error():
        // 忽略错误，继续获取其他书架
    }
  }
}
