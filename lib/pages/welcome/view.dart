import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/router/route_path.dart';
import 'package:hikari_novel_flutter/service/local_storage_service.dart';
import 'package:hikari_novel_flutter/widgets/custom_tile.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});

  final wenku8Node = LocalStorageService.instance.getWenku8Node().obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LogoPage(),
              const SizedBox(height: 20),
              Text("welcome_to_use_app".tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text("welcome_tip".tr, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              TextButton.icon(onPressed: () => Get.toNamed(RoutePath.login), label: Text("go_to_login".tr), icon: const Icon(Icons.login)),
              const SizedBox(height: 12),
              Obx(
                () => OutlinedButton.icon(
                  onPressed: () =>
                      Get.dialog(
                        RadioListDialog(
                          value: wenku8Node.value,
                          values: [(Wenku8Node.wwwWenku8Net, Wenku8Node.wwwWenku8Net.node), (Wenku8Node.wwwWenku8Cc, Wenku8Node.wwwWenku8Cc.node)],
                          title: "node".tr,
                        ),
                      ).then((value) {
                        if (value != null) {
                          wenku8Node.value = value;
                          LocalStorageService.instance.setWenku8Node(value);
                        }
                      }),
                  icon: const Icon(Icons.lan_outlined),
                  label: Text("${"node".tr}：${wenku8Node.value.node}"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
