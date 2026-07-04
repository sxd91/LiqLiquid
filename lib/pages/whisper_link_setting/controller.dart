import 'dart:async';

import 'package:liqliquid/common/widgets/dialog/dialog.dart';
import 'package:liqliquid/common/widgets/dialog/report_member.dart';
import 'package:liqliquid/grpc/bilibili/app/im/v1.pb.dart';
import 'package:liqliquid/grpc/im.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/msg.dart';
import 'package:liqliquid/http/video.dart';
import 'package:liqliquid/models_new/msg/im_user_infos/datum.dart';
import 'package:liqliquid/models_new/msg/msg_dnd/uid_setting.dart';
import 'package:liqliquid/models_new/msg/session_ss/data.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart' show Text;
import 'package:get/get.dart';

class WhisperLinkSettingController extends GetxController {
  WhisperLinkSettingController({
    required this.talkerUid,
  });

  final int talkerUid;
  RxBool isPinned = false.obs;
  late final sessionId = SessionId(
    privateId: PrivateId(talkerUid: Int64(talkerUid)),
  );

  @override
  void onInit() {
    super.onInit();
    getUserInfo();
    getSessionSs();
    getMsgDnd();
    getIsPinned();
  }

  final Rx<LoadingState<List<ImUserInfosData>?>> userState =
      LoadingState<List<ImUserInfosData>?>.loading().obs;
  final Rx<LoadingState<SessionSsData>> sessionSs =
      LoadingState<SessionSsData>.loading().obs;
  final Rx<LoadingState<List<UidSetting>?>> msgDnd =
      LoadingState<List<UidSetting>?>.loading().obs;

  Future<void> getUserInfo() async {
    userState.value = await MsgHttp.imUserInfos(uids: talkerUid.toString());
  }

  Future<void> getSessionSs() async {
    sessionSs.value = await MsgHttp.getSessionSs(talkerUid: talkerUid);
  }

  Future<void> getMsgDnd() async {
    msgDnd.value = await MsgHttp.getMsgDnd(uidsStr: talkerUid);
  }

  Future<void> getIsPinned() async {
    final res = await ImGrpc.sessionUpdate(sessionId: sessionId);
    if (res case Success(:final response)) {
      isPinned.value = response.session.isPinned;
    }
  }

  void setPush(bool isPush) {
    if (isPush) {
      showConfirmDialog(
        context: Get.context!,
        title: const Text('纭鍏抽棴鍐呭鎺ㄩ€佸悧锛?),
        content: const Text('鑻ュ叧闂寮€鍏筹紝浣犲皢涓嶅啀鏀跺埌璇ヨ处鍙风殑鍥炬枃娑堟伅涓庣浠舵帹閫侊紝浣嗛€氱煡绫绘秷鎭笉鍙楀奖鍝?),
        onConfirm: () => _setPush(isPush),
      );
      return;
    }
    _setPush(isPush);
  }

  Future<void> _setPush(bool isPush) async {
    int setting = isPush ? 1 : 0;
    final res = await MsgHttp.setPushSs(
      setting: setting,
      talkerUid: talkerUid,
    );
    if (res.isSuccess) {
      sessionSs
        ..value.data.pushSetting = setting
        ..refresh();
    } else {
      res.toast();
    }
  }

  Future<void> setPin() async {
    final res = isPinned.value
        ? await ImGrpc.unpinSession(sessionId: sessionId)
        : await ImGrpc.pinSession(sessionId: sessionId);
    if (res.isSuccess) {
      isPinned.value = !isPinned.value;
    } else {
      res.toast();
    }
  }

  Future<void> setMute(bool isMuted) async {
    int setting = isMuted ? 0 : 1;
    final res = await MsgHttp.setMsgDnd(
      uid: Accounts.main.mid,
      setting: setting,
      dndUid: talkerUid,
    );
    if (res.isSuccess) {
      msgDnd
        ..value.data!.first.setting = setting
        ..refresh();
    } else {
      res.toast();
    }
  }

  Future<void> setBlock(bool isBlocked) async {
    if (isBlocked) {
      final res = await VideoHttp.relationMod(
        mid: talkerUid,
        act: 6,
        reSrc: 11,
      );
      if (res.isSuccess) {
        sessionSs
          ..value.data.followStatus = null
          ..refresh();
      } else {
        res.toast();
      }
    } else {
      showConfirmDialog(
        context: Get.context!,
        title: const Text('纭鎷夐粦璇ョ敤鎴?),
        content: const Text('鍔犲叆榛戝悕鍗曞悗锛屽皢鑷姩瑙ｉ櫎鍏虫敞鍏崇郴鍜屽璇ョ敤鎴风殑鍚堥泦璁㈤槄鍏崇郴锛岀姝㈣鐢ㄦ埛涓庢垜浜掑姩鎴栨煡鐪嬫垜鐨勭┖闂?),
        onConfirm: () async {
          final res = await VideoHttp.relationMod(
            mid: talkerUid,
            act: 5,
            reSrc: 11,
          );
          if (res.isSuccess) {
            sessionSs
              ..value.data.followStatus = 128
              ..refresh();
          } else {
            res.toast();
          }
        },
      );
    }
  }

  void report() => showMemberReportDialog(
    Get.context!,
    name: userState.value.dataOrNull?.firstOrNull?.name,
    mid: talkerUid,
  );
}

