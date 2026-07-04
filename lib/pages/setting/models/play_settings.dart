import 'dart:io' show Platform;

import 'package:liqliquid/common/widgets/custom_icon.dart';
import 'package:liqliquid/models/common/super_chat_type.dart';
import 'package:liqliquid/models/common/video/subtitle_pref_type.dart';
import 'package:liqliquid/pages/main/controller.dart';
import 'package:liqliquid/pages/setting/models/model.dart';
import 'package:liqliquid/pages/setting/pages/fullscreen_sc_size.dart';
import 'package:liqliquid/pages/setting/widgets/select_dialog.dart';
import 'package:liqliquid/pages/setting/widgets/slider_dialog.dart';
import 'package:liqliquid/plugin/pl_player/models/bottom_progress_behavior.dart';
import 'package:liqliquid/plugin/pl_player/models/fullscreen_mode.dart';
import 'package:liqliquid/plugin/pl_player/models/play_repeat.dart';
import 'package:liqliquid/services/service_locator.dart';
import 'package:liqliquid/utils/extension/num_ext.dart';
import 'package:liqliquid/utils/platform_utils.dart';
import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:liqliquid/utils/storage_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

List<SettingsModel> get playSettings => [
  const SwitchModel(
    title: '寮瑰箷寮€鍏?,
    subtitle: '鏄惁灞曠ず寮瑰箷',
    leading: Icon(CustomIcons.dm_settings),
    setKey: SettingBoxKey.enableShowDanmaku,
    defaultVal: true,
  ),
  if (PlatformUtils.isMobile)
    const SwitchModel(
      title: '鍚敤鐐瑰嚮寮瑰箷',
      subtitle: '鐐瑰嚮寮瑰箷鎮仠锛屾敮鎸佺偣璧炪€佸鍒躲€佷妇鎶ユ搷浣?,
      leading: Icon(Icons.touch_app_outlined),
      setKey: SettingBoxKey.enableTapDm,
      defaultVal: true,
    ),
  NormalModel(
    onTap: (context, setState) => Get.toNamed('/playSpeedSet'),
    leading: const Icon(Icons.speed_outlined),
    title: '鍊嶉€熻缃?,
    subtitle: '璁剧疆瑙嗛鎾斁閫熷害',
  ),
  if (Platform.isAndroid)
    NormalModel(
      onTap: _showAngleDegreesDialog,
      leading: const Icon(MdiIcons.angleAcute),
      title: '鍊炬枩瑙掑害闃堝€?,
      getSubtitle: () => '褰撳墠:銆?{Pref.angleDegrees}掳銆?,
    ),
  const SwitchModel(
    title: '鑷姩鎾斁',
    subtitle: '杩涘叆璇︽儏椤佃嚜鍔ㄦ挱鏀?,
    leading: Icon(Icons.motion_photos_auto_outlined),
    setKey: SettingBoxKey.autoPlayEnable,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '鍏ㄥ睆鏄剧ず閿佸畾鎸夐挳',
    leading: Icon(Icons.lock_outline),
    setKey: SettingBoxKey.showFsLockBtn,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '鍏ㄥ睆鏄剧ず鎴浘鎸夐挳',
    leading: Icon(Icons.photo_camera_outlined),
    setKey: SettingBoxKey.showFsScreenshotBtn,
    defaultVal: true,
  ),
  SwitchModel(
    title: '鍏ㄥ睆鏄剧ず鐢垫睜鐢甸噺',
    leading: const Icon(Icons.battery_3_bar),
    setKey: SettingBoxKey.showBatteryLevel,
    defaultVal: PlatformUtils.isMobile,
  ),
  const SwitchModel(
    title: '鍙屽嚮蹇€€/蹇繘',
    subtitle: '宸︿晶鍙屽嚮蹇€€/鍙充晶鍙屽嚮蹇繘锛屽叧闂垯鍙屽嚮鍧囦负鏆傚仠/鎾斁',
    leading: Icon(Icons.touch_app_outlined),
    setKey: SettingBoxKey.enableQuickDouble,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '宸﹀彸渚ф粦鍔ㄨ皟鑺備寒搴?闊抽噺',
    leading: Icon(MdiIcons.tuneVerticalVariant),
    setKey: SettingBoxKey.enableSlideVolumeBrightness,
    defaultVal: true,
  ),
  if (Platform.isAndroid)
    const SwitchModel(
      title: '璋冭妭绯荤粺浜害',
      leading: Icon(Icons.brightness_6_outlined),
      setKey: SettingBoxKey.setSystemBrightness,
      defaultVal: false,
    ),
  const SwitchModel(
    title: '涓棿婊戝姩杩涘叆/閫€鍑哄叏灞?,
    leading: Icon(MdiIcons.panVertical),
    setKey: SettingBoxKey.enableSlideFS,
    defaultVal: true,
  ),
  if (PlatformUtils.isMobile)
    NormalModel(
      title: '鎾斁鍣ㄩ煶閲?,
      leading: const Icon(Icons.volume_up),
      getSubtitle: () => '褰撳墠:銆?{Pref.playerVolume.toStringAsFixed(0)}%銆?,
      onTap: showPlayerVolumeDialog,
    )
  else
    NormalModel(
      title: '鏈€楂橀煶閲?,
      leading: const Icon(Icons.volume_up),
      getSubtitle: () => '褰撳墠:銆?{(Pref.maxVolume * 100).toStringAsFixed(0)}%銆?,
      onTap: _showMaxVolumeDialog,
    ),
  getVideoFilterSelectModel(
    title: '鍙屽嚮蹇繘/蹇€€鏃堕暱',
    suffix: 's',
    key: SettingBoxKey.fastForBackwardDuration,
    values: [5, 10, 15],
    defaultValue: 10,
    isFilter: false,
  ),
  const SwitchModel(
    title: '婊戝姩蹇繘/蹇€€浣跨敤鐩稿鏃堕暱',
    leading: Icon(Icons.swap_horiz_outlined),
    setKey: SettingBoxKey.useRelativeSlide,
    defaultVal: false,
  ),
  getVideoFilterSelectModel(
    title: '婊戝姩蹇繘/蹇€€鏃堕暱',
    subtitle: '浠庢挱鏀惧櫒涓€绔粦鍒板彟涓€绔殑蹇繘/蹇€€鏃堕暱',
    suffix: Pref.useRelativeSlide ? '%' : 's',
    key: SettingBoxKey.sliderDuration,
    values: [25, 50, 90, 100],
    defaultValue: 90,
    isFilter: false,
  ),
  NormalModel(
    title: '鑷姩鍚敤瀛楀箷',
    leading: const Icon(Icons.closed_caption_outlined),
    getSubtitle: () => '褰撳墠閫夋嫨鍋忓ソ锛?{Pref.subtitlePreferenceV2.desc}',
    onTap: _showSubtitleDialog,
  ),
  if (PlatformUtils.isDesktop)
    SwitchModel(
      title: '鏈€灏忓寲鏃舵殏鍋?杩樺師鏃舵挱鏀?,
      leading: const Icon(Icons.pause_circle_outline),
      setKey: SettingBoxKey.pauseOnMinimize,
      defaultVal: false,
      onChanged: (value) {
        try {
          Get.find<MainController>().pauseOnMinimize = value;
        } catch (_) {}
      },
    ),
  const SwitchModel(
    title: '鍚敤閿洏鎺у埗',
    leading: Icon(Icons.keyboard_alt_outlined),
    setKey: SettingBoxKey.keyboardControl,
    defaultVal: true,
  ),
  NormalModel(
    title: 'SuperChat (閱掔洰鐣欒█) 鏄剧ず绫诲瀷',
    leading: const Icon(Icons.live_tv),
    getSubtitle: () => '褰撳墠:銆?{Pref.superChatType.title}銆?,
    onTap: _showSuperChatDialog,
  ),
  NormalModel(
    title: '鍏ㄥ睆 SC 澶у皬',
    subtitle: 'SuperChat (閱掔洰鐣欒█) 澶у皬璁剧疆',
    leading: const Icon(Icons.open_in_full),
    onTap: (_, _) => Get.to(const FullScreenScSize()),
  ),
  const SwitchModel(
    title: '绔栧睆鎵╁ぇ灞曠ず',
    subtitle: '灏忓睆绔栧睆瑙嗛瀹介珮姣旂敱16:9鎵╁ぇ鑷?:1锛堜笉鏀寔鏀惰捣锛夛紱妯睆閫傞厤鏃讹紝鎵╁ぇ鑷?:16',
    leading: Icon(Icons.expand_outlined),
    setKey: SettingBoxKey.enableVerticalExpand,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '鑷姩鍏ㄥ睆',
    subtitle: '瑙嗛寮€濮嬫挱鏀炬椂杩涘叆鍏ㄥ睆',
    leading: Icon(Icons.fullscreen_outlined),
    setKey: SettingBoxKey.enableAutoEnter,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '鑷姩閫€鍑哄叏灞?,
    subtitle: '瑙嗛缁撴潫鎾斁鏃堕€€鍑哄叏灞?,
    leading: Icon(Icons.fullscreen_exit_outlined),
    setKey: SettingBoxKey.enableAutoExit,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '寤堕暱鎾斁鎺т欢鏄剧ず鏃堕棿',
    subtitle: '寮€鍚悗寤堕暱鑷?0绉掞紝渚夸簬灞忓箷闃呰鍣ㄦ粦鍔ㄥ垏鎹㈡帶浠剁劍鐐?,
    leading: Icon(Icons.timer_outlined),
    setKey: SettingBoxKey.enableLongShowControl,
    defaultVal: false,
  ),
  if (PlatformUtils.isMobile)
    const SwitchModel(
      title: '鍚庡彴鎾斁',
      subtitle: '杩涘叆鍚庡彴鏃剁户缁挱鏀?,
      leading: Icon(Icons.motion_photos_pause_outlined),
      setKey: SettingBoxKey.continuePlayInBackground,
      defaultVal: false,
    ),
  if (Platform.isAndroid) ...[
    SwitchModel(
      title: '鍚庡彴鐢讳腑鐢?,
      subtitle: '杩涘叆鍚庡彴鏃朵互灏忕獥褰㈠紡锛圥iP锛夋挱鏀?,
      leading: const Icon(Icons.picture_in_picture_outlined),
      setKey: SettingBoxKey.autoPiP,
      defaultVal: false,
      onChanged: (val) {
        if (val && !videoPlayerServiceHandler!.enableBackgroundPlay) {
          SmartDialog.showToast('寤鸿寮€鍚悗鍙伴煶棰戞湇鍔?);
        }
      },
    ),
    const SwitchModel(
      title: '鐢讳腑鐢讳笉鍔犺浇寮瑰箷',
      subtitle: '褰撳脊骞曞紑鍏冲紑鍚椂锛屽皬绐楀睆钄藉脊骞曚互鑾峰緱杈冨ソ鐨勪綋楠?,
      leading: Icon(CustomIcons.dm_off),
      setKey: SettingBoxKey.pipNoDanmaku,
      defaultVal: false,
    ),
  ],
  const SwitchModel(
    title: '鍏ㄥ睆鎵嬪娍鍙嶅悜',
    subtitle: '榛樿鎾斁鍣ㄤ腑閮ㄥ悜涓婃粦鍔ㄨ繘鍏ュ叏灞忥紝鍚戜笅閫€鍑篭n寮€鍚悗鍚戜笅鍏ㄥ睆锛屽悜涓婇€€鍑?,
    leading: Icon(Icons.swap_vert),
    setKey: SettingBoxKey.fullScreenGestureReverse,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '鍏ㄥ睆灞曠ず鐐硅禐/鎶曞竵/鏀惰棌绛夋搷浣滄寜閽?,
    leading: Icon(MdiIcons.dotsHorizontalCircleOutline),
    setKey: SettingBoxKey.showFSActionItem,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '瑙傜湅浜烘暟',
    subtitle: '灞曠ず鍚屾椂鍦ㄧ湅浜烘暟',
    leading: Icon(Icons.people_outlined),
    setKey: SettingBoxKey.enableOnlineTotal,
    defaultVal: false,
  ),
  NormalModel(
    title: '榛樿鍏ㄥ睆鏂瑰悜',
    leading: const Icon(Icons.open_with_outlined),
    getSubtitle: () => '褰撳墠鍏ㄥ睆鏂瑰悜锛?{Pref.fullScreenMode.desc}',
    onTap: _showFullScreenModeDialog,
  ),
  NormalModel(
    title: '搴曢儴杩涘害鏉″睍绀?,
    leading: const Icon(Icons.border_bottom_outlined),
    getSubtitle: () => '褰撳墠灞曠ず鏂瑰紡锛?{Pref.btmProgressBehavior.desc}',
    onTap: _showProgressBehaviorDialog,
  ),
  if (PlatformUtils.isMobile)
    SwitchModel(
      title: '鍚庡彴闊抽鏈嶅姟',
      subtitle: '閬垮厤鐢讳腑鐢绘病鏈夋挱鏀炬殏鍋滃姛鑳?,
      leading: const Icon(Icons.volume_up_outlined),
      setKey: SettingBoxKey.enableBackgroundPlay,
      defaultVal: true,
      onChanged: (value) =>
          videoPlayerServiceHandler!.enableBackgroundPlay = value,
    ),
  PopupModel(
    title: '鎾斁椤哄簭',
    leading: const Icon(Icons.repeat),
    value: () => Pref.playRepeat,
    items: PlayRepeat.values,
    onSelected: (value, setState) => GStorage.video
        .put(VideoBoxKey.playRepeat, value.index)
        .whenComplete(setState),
  ),
  const SwitchModel(
    title: '鎾斁鍣ㄨ缃粎瀵瑰綋鍓嶇敓鏁?,
    subtitle: '寮瑰箷銆佸瓧骞曞強閮ㄥ垎璁剧疆涓病鏈夌殑璁剧疆闄ゅ',
    leading: Icon(Icons.video_settings_outlined),
    setKey: SettingBoxKey.tempPlayerConf,
    defaultVal: false,
  ),
];

Future<void> _showSubtitleDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<SubtitlePrefType>(
    context: context,
    builder: (context) => SelectDialog<SubtitlePrefType>(
      title: '瀛楀箷閫夋嫨鍋忓ソ',
      value: Pref.subtitlePreferenceV2,
      values: SubtitlePrefType.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(
      SettingBoxKey.subtitlePreferenceV2,
      res.index,
    );
    setState();
  }
}

Future<void> _showSuperChatDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<SuperChatType>(
    context: context,
    builder: (context) => SelectDialog<SuperChatType>(
      title: 'SuperChat (閱掔洰鐣欒█) 鏄剧ず绫诲瀷',
      value: Pref.superChatType,
      values: SuperChatType.values.map((e) => (e, e.title)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.superChatType, res.index);
    setState();
  }
}

Future<void> _showFullScreenModeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<FullScreenMode>(
    context: context,
    builder: (context) => SelectDialog<FullScreenMode>(
      title: '榛樿鍏ㄥ睆鏂瑰悜',
      value: Pref.fullScreenMode,
      values: FullScreenMode.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.fullScreenMode, res.index);
    setState();
  }
}

Future<void> _showProgressBehaviorDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<BtmProgressBehavior>(
    context: context,
    builder: (context) => SelectDialog<BtmProgressBehavior>(
      title: '搴曢儴杩涘害鏉″睍绀?,
      value: Pref.btmProgressBehavior,
      values: BtmProgressBehavior.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(
      SettingBoxKey.btmProgressBehavior,
      res.index,
    );
    setState();
  }
}

Future<void> _showAngleDegreesDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: const Text('鍊炬枩瑙掑害闃堝€?),
      min: 10.0,
      max: 90.0,
      divisions: 90,
      precise: 0,
      value: Pref.angleDegrees.toDouble(),
      suffix: '掳',
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.angleDegrees, res.toInt());
    setState();
  }
}

Future<void> showPlayerVolumeDialog(
  BuildContext context,
  VoidCallback setState, {
  ValueChanged<double>? onChanged,
}) {
  return showVolumeDialog(
    context,
    title: const Text('鎾斁鍣ㄩ煶閲?),
    value: Pref.playerVolume,
    onChanged: (value) => GStorage.setting
        .put(SettingBoxKey.playerVolume, value)
        .whenComplete(() {
          setState();
          onChanged?.call(value);
        }),
  );
}

Future<void> _showMaxVolumeDialog(
  BuildContext context,
  VoidCallback setState,
) {
  return showVolumeDialog(
    context,
    title: const Text('鏈€楂橀煶閲?),
    value: Pref.maxVolume * 100,
    onChanged: (rawValue) {
      final maxVolume = (rawValue / 100).toPrecision(2);
      if (Pref.desktopVolume > maxVolume) {
        GStorage.setting.put(SettingBoxKey.desktopVolume, maxVolume);
      }
      GStorage.setting
          .put(SettingBoxKey.maxVolume, maxVolume)
          .whenComplete(setState);
    },
  );
}

const kMinVolume = 100.0;
const kMaxVolume = 300.0;

Future<void> showVolumeDialog(
  BuildContext context, {
  required Widget title,
  required double value,
  required ValueChanged<double> onChanged,
}) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: title,
      min: kMinVolume,
      max: kMaxVolume,
      divisions: 40,
      precise: 0,
      value: value,
      suffix: '%',
    ),
  );
  if (res != null) {
    onChanged(res);
  }
}

