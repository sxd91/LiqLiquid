import 'package:liqliquid/http/fav.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/user.dart';
import 'package:liqliquid/models_new/sub/sub/data.dart';
import 'package:liqliquid/models_new/sub/sub/list.dart';
import 'package:liqliquid/pages/common/common_list_controller.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class SubController extends CommonListController<SubData, SubItemModel> {
  late final account = Accounts.main;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<void> queryData([bool isRefresh = true]) {
    if (!account.isLogin) {
      loadingState.value = const Error('璐﹀彿鏈櫥褰?);
      return Future.syncValue(null);
    }
    return super.queryData(isRefresh);
  }

  // 鍙栨秷璁㈤槄
  void cancelSub(SubItemModel subFolderItem) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('鎻愮ず'),
        content: const Text('纭畾鍙栨秷璁㈤槄鍚楋紵'),
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
              final res = await FavHttp.cancelSub(
                id: subFolderItem.id!,
                type: subFolderItem.type!,
              );
              if (res.isSuccess) {
                loadingState
                  ..value.data!.remove(subFolderItem)
                  ..refresh();
                SmartDialog.showToast('鍙栨秷璁㈤槄鎴愬姛');
              } else {
                res.toast();
              }
              Get.back();
            },
            child: const Text('纭畾'),
          ),
        ],
      ),
    );
  }

  @override
  List<SubItemModel>? getDataList(SubData response) {
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.list;
  }

  @override
  Future<LoadingState<SubData>> customGetData() => UserHttp.userSubFolder(
    pn: page,
    ps: 20,
    mid: account.mid,
  );
}

