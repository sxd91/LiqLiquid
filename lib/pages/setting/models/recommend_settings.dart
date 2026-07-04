import 'package:liqliquid/http/video.dart';
import 'package:liqliquid/pages/rcmd/controller.dart';
import 'package:liqliquid/pages/setting/models/model.dart';
import 'package:liqliquid/utils/recommend_filter.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<SettingsModel> get recommendSettings => [
  const SwitchModel(
    title: '棣栭〉浣跨敤app绔帹鑽?,
    subtitle: '鑻eb绔帹鑽愪笉澶鍚堥鏈燂紝鍙皾璇曞垏鎹㈣嚦app绔帹鑽?,
    leading: Icon(Icons.model_training_outlined),
    setKey: SettingBoxKey.appRcmd,
    defaultVal: true,
    needReboot: true,
  ),
  SwitchModel(
    title: '淇濈暀棣栭〉鎺ㄨ崘鍒锋柊',
    subtitle: '涓嬫媺鍒锋柊鏃朵繚鐣欎笂娆″唴瀹?,
    leading: const Icon(Icons.refresh),
    setKey: SettingBoxKey.enableSaveLastData,
    defaultVal: true,
    onChanged: (value) {
      try {
        Get.find<RcmdController>()
          ..enableSaveLastData = value
          ..lastRefreshAt = null;
      } catch (e) {
        if (kDebugMode) debugPrint('$e');
      }
    },
  ),
  SwitchModel(
    title: '鏄剧ず涓婃鐪嬪埌浣嶇疆鎻愮ず',
    subtitle: '淇濈暀涓婃鎺ㄨ崘鏃讹紝鍦ㄤ笂娆″埛鏂颁綅缃樉绀烘彁绀?,
    leading: const Icon(Icons.tips_and_updates_outlined),
    setKey: SettingBoxKey.savedRcmdTip,
    defaultVal: true,
    onChanged: (value) {
      try {
        Get.find<RcmdController>()
          ..savedRcmdTip = value
          ..lastRefreshAt = null;
      } catch (e) {
        if (kDebugMode) debugPrint('$e');
      }
    },
  ),
  getVideoFilterSelectModel(
    title: '鐐硅禐鐜?,
    suffix: '%',
    key: SettingBoxKey.minLikeRatioForRecommend,
    values: [0, 1, 2, 3, 4],
    onChanged: (value) => RecommendFilter.minLikeRatioForRecommend = value,
  ),
  getBanWordModel(
    title: '鏍囬鍏抽敭璇嶈繃婊?,
    key: SettingBoxKey.banWordForRecommend,
    onChanged: (value) {
      RecommendFilter.rcmdRegExp = value;
      RecommendFilter.enableFilter = value.pattern.isNotEmpty;
    },
  ),
  getBanWordModel(
    title: 'App鎺ㄨ崘/鐑棬/鎺掕姒? 瑙嗛鍒嗗尯鍏抽敭璇嶈繃婊?,
    key: SettingBoxKey.banWordForZone,
    onChanged: (value) {
      VideoHttp.zoneRegExp = value;
      VideoHttp.enableFilter = value.pattern.isNotEmpty;
    },
  ),
  getVideoFilterSelectModel(
    title: '瑙嗛鏃堕暱',
    suffix: 's',
    key: SettingBoxKey.minDurationForRcmd,
    values: [0, 30, 60, 90, 120],
    onChanged: (value) => RecommendFilter.minDurationForRcmd = value,
  ),
  getVideoFilterSelectModel(
    title: '鎾斁閲?,
    key: SettingBoxKey.minPlayForRcmd,
    values: [0, 50, 100, 500, 1000],
    onChanged: (value) => RecommendFilter.minPlayForRcmd = value,
  ),
  SwitchModel(
    title: '宸插叧娉║P璞佸厤鎺ㄨ崘杩囨护',
    subtitle: '鎺ㄨ崘涓凡鍏虫敞鐢ㄦ埛鍙戝竷鐨勫唴瀹逛笉浼氳杩囨护',
    leading: const Icon(Icons.favorite_border_outlined),
    setKey: SettingBoxKey.exemptFilterForFollowed,
    defaultVal: true,
    onChanged: (value) => RecommendFilter.exemptFilterForFollowed = value,
  ),
  SwitchModel(
    title: '杩囨护鍣ㄤ篃搴旂敤浜庤鎯呴〉鐩稿叧瑙嗛',
    subtitle: '鍏跺畠锛堝鐑棬瑙嗛銆佹悳绱㈢瓑锛夊潎涓嶅彈杩囨护鍣ㄥ奖鍝嶏紝鏃犳硶璞佸厤鐩稿叧瑙嗛涓殑宸插叧娉║P',
    leading: const Icon(Icons.explore_outlined),
    setKey: SettingBoxKey.applyFilterToRelatedVideos,
    defaultVal: true,
    onChanged: (value) => RecommendFilter.applyFilterToRelatedVideos = value,
  ),
];

