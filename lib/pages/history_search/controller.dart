import 'package:liqliquid/common/widgets/dialog/dialog.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/user.dart';
import 'package:liqliquid/models_new/history/data.dart';
import 'package:liqliquid/models_new/history/list.dart';
import 'package:liqliquid/pages/common/multi_select/base.dart';
import 'package:liqliquid/pages/common/search/common_search_controller.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:flutter/widgets.dart' show Text;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class HistorySearchController
    extends CommonSearchController<HistoryData, HistoryItemModel>
    with CommonMultiSelectMixin<HistoryItemModel>, DeleteItemMixin {
  @override
  Future<LoadingState<HistoryData>> customGetData() => UserHttp.searchHistory(
    pn: page,
    keyword: editController.value.text,
    account: account,
  );

  @override
  List<HistoryItemModel>? getDataList(HistoryData response) {
    return response.list;
  }

  final account = Accounts.history;

  Future<void> onDelHistory(int index, kid, String business) async {
    final res = await UserHttp.delHistory(
      '${business}_$kid',
      account: account,
    );
    if (res.isSuccess) {
      loadingState
        ..value.data!.removeAt(index)
        ..refresh();
      SmartDialog.showToast('宸插垹闄?);
    } else {
      res.toast();
    }
  }

  @override
  void onRemove() {
    showConfirmDialog(
      context: Get.context!,
      title: const Text('鎻愮ず'),
      content: const Text('纭鍒犻櫎鎵€閫夊巻鍙茶褰曞悧锛?),
      onConfirm: () async {
        SmartDialog.showLoading(msg: '璇锋眰涓?);
        final removeList = allChecked.toSet();
        final response = await UserHttp.delHistory(
          removeList
              .map((item) => '${item.history.business!}_${item.kid!}')
              .join(','),
          account: account,
        );
        if (response.isSuccess) {
          afterDelete(removeList);
          SmartDialog.showToast('宸插垹闄?);
        } else {
          response.toast();
        }
        SmartDialog.dismiss();
      },
    );
  }
}

