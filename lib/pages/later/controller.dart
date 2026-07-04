import 'package:liqliquid/common/widgets/dialog/dialog.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/user.dart';
import 'package:liqliquid/models/common/later_view_type.dart';
import 'package:liqliquid/models/common/video/source_type.dart';
import 'package:liqliquid/models_new/later/data.dart';
import 'package:liqliquid/models_new/later/list.dart';
import 'package:liqliquid/pages/common/common_list_controller.dart'
    show CommonListController;
import 'package:liqliquid/pages/common/multi_select/base.dart';
import 'package:liqliquid/pages/common/multi_select/multi_select_controller.dart';
import 'package:liqliquid/pages/later/base_controller.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:liqliquid/utils/extension/scroll_controller_ext.dart';
import 'package:liqliquid/utils/page_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

mixin BaseLaterController
    on
        CommonListController<LaterData, LaterItemModel>,
        CommonMultiSelectMixin<LaterItemModel>,
        DeleteItemMixin<LaterData, LaterItemModel> {
  ValueChanged<int>? updateCount;

  @override
  void onRemove() {
    showConfirmDialog(
      context: Get.context!,
      title: const Text('鎻愮ず'),
      content: const Text('纭鍒犻櫎鎵€閫夌◢鍚庡啀鐪嬪悧锛?),
      onConfirm: () async {
        final removeList = allChecked.toSet();
        SmartDialog.showLoading(msg: '璇锋眰涓?);
        final res = await UserHttp.toViewDel(
          aids: removeList.map((item) => item.aid).join(','),
        );
        if (res.isSuccess) {
          updateCount?.call(removeList.length);
          afterDelete(removeList);
        }
        SmartDialog.dismiss();
      },
    );
  }

  // single
  void toViewDel(
    BuildContext context,
    int index,
    int? aid,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('鎻愮ず'),
        content: const Text('鍗冲皢绉婚櫎璇ヨ棰戯紝纭畾鏄惁绉婚櫎'),
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
              final res = await UserHttp.toViewDel(aids: aid.toString());
              if (res.isSuccess) {
                loadingState
                  ..value.data!.removeAt(index)
                  ..refresh();
                updateCount?.call(1);
              }
            },
            child: const Text('纭绉婚櫎'),
          ),
        ],
      ),
    );
  }
}

class LaterController extends MultiSelectController<LaterData, LaterItemModel>
    with BaseLaterController {
  LaterController(this.laterViewType);
  final LaterViewType laterViewType;

  late final mid = Accounts.main.mid;

  final RxBool asc = false.obs;

  final LaterBaseController baseCtr = Get.put(LaterBaseController());

  @override
  RxBool get enableMultiSelect => baseCtr.enableMultiSelect;

  @override
  RxInt get rxCount => baseCtr.checkedCount;

  @override
  Future<LoadingState<LaterData>> customGetData() => UserHttp.seeYouLater(
    page: page,
    viewed: laterViewType.type,
    asc: asc.value,
  );

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<LaterItemModel>? getDataList(response) {
    baseCtr.counts[laterViewType.index] = response.count ?? 0;
    return response.list;
  }

  @override
  void checkIsEnd(int length) {
    if (length >= baseCtr.counts[laterViewType.index]) {
      isEnd = true;
    }
  }

  // 涓€閿竻绌?  void toViewClear(BuildContext context, [int? cleanType]) {
    String content = switch (cleanType) {
      1 => '纭畾娓呯┖宸插け鏁堣棰戝悧锛?,
      2 => '纭畾娓呯┖宸茬湅瀹岃棰戝悧锛?,
      _ => '纭畾娓呯┖绋嶅悗鍐嶇湅鍒楄〃鍚楋紵',
    };
    showConfirmDialog(
      context: context,
      title: const Text('纭'),
      content: Text(content),
      onConfirm: () async {
        final res = await UserHttp.toViewClear(cleanType);
        if (res.isSuccess) {
          onReload();
          final restTypes = List<LaterViewType>.from(LaterViewType.values)
            ..remove(laterViewType);
          for (final item in restTypes) {
            try {
              Get.find<LaterController>(tag: item.type.toString()).onReload();
            } catch (_) {}
          }
          SmartDialog.showToast('宸叉竻绌?);
        } else {
          res.toast();
        }
      },
    );
  }

  // 绋嶅悗鍐嶇湅鎾斁鍏ㄩ儴
  void toViewPlayAll() {
    if (loadingState.value case Success(:final response)) {
      if (response == null || response.isEmpty) return;

      for (LaterItemModel item in response) {
        if (item.cid == null || item.pgcLabel?.isNotEmpty == true) {
          continue;
        } else {
          PageUtils.toVideoPage(
            bvid: item.bvid,
            cid: item.cid!,
            cover: item.pic,
            title: item.title,
            dimension: item.dimension,
            extraArguments: {
              'sourceType': SourceType.watchLater,
              'count': baseCtr.counts[LaterViewType.all.index],
              'favTitle': '绋嶅悗鍐嶇湅',
              'mediaId': mid,
              'desc': asc.value,
            },
          );
          break;
        }
      }
    }
  }

  @override
  ValueChanged<int>? get updateCount =>
      (count) => baseCtr.counts[laterViewType.index] -= count;

  @override
  Future<void> onReload() {
    scrollController.jumpToTop();
    return super.onReload();
  }
}

