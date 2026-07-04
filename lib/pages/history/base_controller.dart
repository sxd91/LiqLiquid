import 'package:liqliquid/http/user.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class HistoryBaseController extends GetxController {
  RxBool pauseStatus = false.obs;

  RxBool enableMultiSelect = false.obs;
  RxInt checkedCount = 0.obs;

  final account = Accounts.history;

  // 娓呯┖瑙傜湅鍘嗗彶
  void onClearHistory(BuildContext context, VoidCallback onSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('鎻愮ず'),
        content: const Text('鍟婂徎锛熶綘瑕佹竻绌哄巻鍙茶褰曞姛鑳藉悧锛?),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              '鍙栨秷',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              SmartDialog.showLoading(msg: '璇锋眰涓?);
              final res = await UserHttp.clearHistory(account: account);
              SmartDialog.dismiss();
              if (res.isSuccess) {
                SmartDialog.showToast('娓呯┖瑙傜湅鍘嗗彶');
                onSuccess();
              } else {
                res.toast();
              }
            },
            child: const Text('纭娓呯┖'),
          ),
        ],
      ),
    );
  }

  // 鏆傚仠瑙傜湅鍘嗗彶
  void onPauseHistory(BuildContext context) {
    final pauseStatus = !this.pauseStatus.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('鎻愮ず'),
        content: Text(pauseStatus ? '鍟婂徎锛熶綘瑕佹殏鍋滃巻鍙茶褰曞姛鑳藉悧锛? : '鍟婂徎锛熻鎭㈠鍘嗗彶璁板綍鍔熻兘鍚楋紵'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              '鍙栨秷',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              SmartDialog.showLoading(msg: '璇锋眰涓?);
              final res = await UserHttp.pauseHistory(
                pauseStatus,
                account: account,
              );
              SmartDialog.dismiss();
              if (res.isSuccess) {
                SmartDialog.showToast(pauseStatus ? '鏆傚仠瑙傜湅鍘嗗彶' : '鎭㈠瑙傜湅鍘嗗彶');
                this.pauseStatus.value = pauseStatus;
                GStorage.localCache.put(
                  LocalCacheKey.historyPause,
                  pauseStatus,
                );
              } else {
                res.toast();
              }
              Get.back();
            },
            child: Text(pauseStatus ? '纭鏆傚仠' : '纭鎭㈠'),
          ),
        ],
      ),
    );
  }
}

