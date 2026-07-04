import 'dart:io';

import 'package:liqliquid/models/common/video/audio_quality.dart';
import 'package:liqliquid/models/common/video/cdn_type.dart';
import 'package:liqliquid/models/common/video/live_quality.dart';
import 'package:liqliquid/models/common/video/video_decode_type.dart';
import 'package:liqliquid/models/common/video/video_quality.dart';
import 'package:liqliquid/pages/setting/models/model.dart';
import 'package:liqliquid/pages/setting/widgets/ordered_multi_select_dialog.dart';
import 'package:liqliquid/pages/setting/widgets/select_dialog.dart';
import 'package:liqliquid/plugin/pl_player/models/audio_output_type.dart';
import 'package:liqliquid/plugin/pl_player/models/hwdec_type.dart';
import 'package:liqliquid/utils/filtering_text.dart';
import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:liqliquid/utils/storage_pref.dart';
import 'package:liqliquid/utils/video_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

List<SettingsModel> get videoSettings => [
  const SwitchModel(
    title: '寮€鍚‖瑙?,
    subtitle: '浠ヨ緝浣庡姛鑰楁挱鏀捐棰戯紝鑻ュ紓甯稿崱姝昏鍏抽棴',
    leading: Icon(Icons.flash_on_outlined),
    setKey: SettingBoxKey.enableHA,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '鍏嶇櫥褰?080P',
    subtitle: '鍏嶇櫥褰曟煡鐪?080P瑙嗛',
    leading: Icon(Icons.hd_outlined),
    setKey: SettingBoxKey.p1080,
    defaultVal: true,
  ),
  NormalModel(
    title: 'B绔欏畾鍚戞祦閲忔敮鎸?,
    subtitle: '鑻ュ椁愬惈B绔欏畾鍚戞祦閲忥紝鍒欎細鑷姩浣跨敤銆傚彲鏌ラ槄杩愯惀鍟嗙殑娴侀噺璁板綍纭銆?,
    leading: const Icon(Icons.perm_data_setting_outlined),
    getTrailing: (theme) => IgnorePointer(
      child: Transform.scale(
        scale: 0.8,
        alignment: Alignment.centerRight,
        child: Switch(
          value: true,
          onChanged: (_) {},
          thumbIcon: WidgetStateProperty.all(
            const Icon(Icons.lock_outline_rounded),
          ),
        ),
      ),
    ),
  ),
  NormalModel(
    title: 'CDN 璁剧疆',
    leading: const Icon(MdiIcons.cloudPlusOutline),
    getSubtitle: () =>
        '褰撳墠浣跨敤锛?{VideoUtils.cdnService.desc}锛岄儴鍒?CDN 鍙兘澶辨晥锛屽鏃犳硶鎾斁璇峰皾璇曞垏鎹?,
    onTap: _showCDNDialog,
  ),
  NormalModel(
    title: '鐩存挱 CDN 璁剧疆',
    leading: const Icon(MdiIcons.cloudPlusOutline),
    getSubtitle: () => '褰撳墠浣跨敤锛?{Pref.liveCdnUrl ?? "榛樿"}',
    onTap: _showLiveCDNDialog,
  ),
  const SwitchModel(
    title: 'CDN 娴嬮€?,
    leading: Icon(Icons.speed),
    subtitle: '娴嬮€熼€氳繃妯℃嫙鍔犺浇瑙嗛瀹炵幇锛屾敞鎰忔祦閲忔秷鑰楋紝缁撴灉浠呬緵鍙傝€?,
    setKey: SettingBoxKey.cdnSpeedTest,
    defaultVal: true,
  ),
  SwitchModel(
    title: '闊抽涓嶈窡闅?CDN 璁剧疆',
    subtitle: '鐩存帴閲囩敤澶囩敤 URL锛屽彲瑙ｅ喅閮ㄥ垎瑙嗛鏃犲０',
    leading: const Icon(MdiIcons.musicNotePlus),
    setKey: SettingBoxKey.disableAudioCDN,
    defaultVal: false,
    onChanged: (value) => VideoUtils.disableAudioCDN = value,
  ),
  NormalModel(
    title: '榛樿鐢昏川',
    leading: const Icon(Icons.video_settings_outlined),
    getSubtitle: () =>
        '褰撳墠鐢昏川锛?{VideoQuality.fromCode(Pref.defaultVideoQa).desc}',
    onTap: _showVideoQaDialog,
  ),
  NormalModel(
    title: '铚傜獫缃戠粶鐢昏川',
    leading: const Icon(Icons.video_settings_outlined),
    getSubtitle: () =>
        '褰撳墠鐢昏川锛?{VideoQuality.fromCode(Pref.defaultVideoQaCellular).desc}',
    onTap: _showVideoCellularQaDialog,
  ),
  NormalModel(
    title: '榛樿闊宠川',
    leading: const Icon(Icons.music_video_outlined),
    getSubtitle: () =>
        '褰撳墠闊宠川锛?{AudioQuality.fromCode(Pref.defaultAudioQa).desc}',
    onTap: _showAudioQaDialog,
  ),
  NormalModel(
    title: '铚傜獫缃戠粶闊宠川',
    leading: const Icon(Icons.music_video_outlined),
    getSubtitle: () =>
        '褰撳墠闊宠川锛?{AudioQuality.fromCode(Pref.defaultAudioQaCellular).desc}',
    onTap: _showAudioCellularQaDialog,
  ),
  NormalModel(
    title: '鐩存挱榛樿鐢昏川',
    leading: const Icon(Icons.video_settings_outlined),
    getSubtitle: () => '褰撳墠鐢昏川锛?{LiveQuality.fromCode(Pref.liveQuality)?.desc}',
    onTap: _showLiveQaDialog,
  ),
  NormalModel(
    title: '铚傜獫缃戠粶鐩存挱榛樿鐢昏川',
    leading: const Icon(Icons.video_settings_outlined),
    getSubtitle: () =>
        '褰撳墠鐢昏川锛?{LiveQuality.fromCode(Pref.liveQualityCellular)?.desc}',
    onTap: _showLiveCellularQaDialog,
  ),
  NormalModel(
    title: '棣栭€夎В鐮佹牸寮?,
    leading: const Icon(Icons.movie_creation_outlined),
    getSubtitle: () {
      final list = Pref.preferCodecs;
      return '棣栭€夎В鐮佹牸寮忥細${(list.isEmpty ? '绗竴涓彲鐢? : list.map((i) => i.name).join(","))}锛岃鏍规嵁璁惧鏀寔鎯呭喌涓庨渶姹傝皟鏁?;
    },
    onTap: _showCodecsDialog,
  ),
  if (kDebugMode || Platform.isAndroid)
    NormalModel(
      title: '闊抽杈撳嚭璁惧',
      leading: const Icon(Icons.speaker_outlined),
      getSubtitle: () => '褰撳墠锛?{Pref.audioOutput}',
      onTap: _showAudioOutputDialog,
    ),
  NormalModel(
    title: '缂撳啿澶у皬',
    leading: const Icon(Icons.storage_outlined),
    getSubtitle: () =>
        '褰撳墠锛?{Pref.bufferSize}MB銆傚悓鏃朵负鍓嶅悜鍜屽悗鍚戠紦鍐插尯澶у皬銆傚浜庣洿鎾祦锛屾棤鍚庡悜缂撳啿澶у皬锛屽叏閮ㄨ浆缁欏墠鍚戯紙姝ら€夐」鍗砿pv鐨?-demuxer-max-bytes锛?-demuxer-max-back-bytes锛?,
    onTap: _showBufferSizeDialog,
  ),
  NormalModel(
    title: '缂撳啿鏃堕暱',
    leading: const Icon(Icons.av_timer),
    getSubtitle: () =>
        '褰撳墠锛?{Pref.bufferSec}s銆傚疄闄呯紦鍐蹭负浜岃€呮渶灏忓€笺€傚浜庣洿鎾祦锛岃閫夐」鏃犳晥锛堟閫夐」鍗砿pv鐨?-cache-secs锛?,
    onTap: _showBufferSecDialog,
  ),
  NormalModel(
    title: '鑷姩鍚屾',
    leading: const Icon(Icons.sync_rounded),
    getSubtitle: () => '褰撳墠锛?{Pref.autosync}锛堟椤瑰嵆mpv鐨?-autosync锛?,
    onTap: _showAutoSyncDialog,
  ),
  NormalModel(
    title: '瑙嗛鍚屾',
    leading: const Icon(Icons.view_timeline_outlined),
    getSubtitle: () => '褰撳墠锛?{Pref.videoSync}锛堟椤瑰嵆mpv鐨?-video-sync锛?,
    onTap: _showVideoSyncDialog,
  ),
  NormalModel(
    title: '纭В妯″紡',
    leading: const Icon(Icons.memory_outlined),
    getSubtitle: () => '褰撳墠锛?{Pref.hardwareDecoding}锛堟椤瑰嵆mpv鐨?-hwdec锛?,
    onTap: _showHwDecDialog,
  ),
];

Future<void> _showCDNDialog(BuildContext context, VoidCallback setState) async {
  final res = await showDialog<CDNService>(
    context: context,
    builder: (context) => const CdnSelectDialog(),
  );
  if (res != null) {
    VideoUtils.cdnService = res;
    await GStorage.setting.put(SettingBoxKey.CDNService, res.name);
    setState();
  }
}

Future<void> _showLiveCDNDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  String host = Pref.liveCdnUrl ?? '';
  String? res = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('杈撳叆CDN host'),
      content: TextFormField(
        initialValue: host,
        autofocus: true,
        onChanged: (value) => host = value,
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(
            '鍙栨秷',
            style: TextStyle(color: ColorScheme.of(context).outline),
          ),
        ),
        TextButton(
          onPressed: () => Get.back(result: host),
          child: const Text('纭畾'),
        ),
      ],
    ),
  );
  if (res != null) {
    if (res.isEmpty) {
      res = null;
      await GStorage.setting.delete(SettingBoxKey.liveCdnUrl);
    } else {
      if (!res.startsWith('http')) {
        res = 'https://$res';
      }
      await GStorage.setting.put(SettingBoxKey.liveCdnUrl, res);
    }
    VideoUtils.liveCdnUrl = res;
    setState();
  }
}

Future<void> _showVideoQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: '榛樿鐢昏川',
      value: Pref.defaultVideoQa,
      values: VideoQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.defaultVideoQa, res);
    setState();
  }
}

Future<void> _showVideoCellularQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: '铚傜獫缃戠粶鐢昏川',
      value: Pref.defaultVideoQaCellular,
      values: VideoQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(
      SettingBoxKey.defaultVideoQaCellular,
      res,
    );
    setState();
  }
}

Future<void> _showAudioQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: '榛樿闊宠川',
      value: Pref.defaultAudioQa,
      values: AudioQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.defaultAudioQa, res);
    setState();
  }
}

Future<void> _showAudioCellularQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: '铚傜獫缃戠粶闊宠川',
      value: Pref.defaultAudioQaCellular,
      values: AudioQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(
      SettingBoxKey.defaultAudioQaCellular,
      res,
    );
    setState();
  }
}

Future<void> _showLiveQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: '鐩存挱榛樿鐢昏川',
      value: Pref.liveQuality,
      values: LiveQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.liveQuality, res);
    setState();
  }
}

Future<void> _showLiveCellularQaDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<int>(
    context: context,
    builder: (context) => SelectDialog<int>(
      title: '铚傜獫缃戠粶鐩存挱榛樿鐢昏川',
      value: Pref.liveQualityCellular,
      values: LiveQuality.values.map((e) => (e.code, e.desc)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.liveQualityCellular, res);
    setState();
  }
}

Future<void> _showCodecsDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<List<VideoDecodeFormatType>>(
    context: context,
    builder: (context) => OrderedMultiSelectDialog<VideoDecodeFormatType>(
      title: '棣栭€夎В鐮佹牸寮?,
      initValues: Pref.preferCodecs,
      values: {for (final e in VideoDecodeFormatType.values) e: e.name},
    ),
  );
  if (res != null) {
    await (res.isEmpty
        ? GStorage.setting.delete(SettingBoxKey.preferCodecs)
        : GStorage.setting.put(
            SettingBoxKey.preferCodecs,
            res.map((i) => i.name).toList(),
          ));
    setState();
  }
}

Future<void> _showAudioOutputDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<List<String>>(
    context: context,
    builder: (context) => OrderedMultiSelectDialog<String>(
      title: '闊抽杈撳嚭璁惧',
      initValues: Pref.audioOutput.split(','),
      values: {
        for (final e in AudioOutput.values) e.name: e.label,
      },
    ),
  );
  if (res != null && res.isNotEmpty) {
    await GStorage.setting.put(
      SettingBoxKey.audioOutput,
      res.join(','),
    );
    setState();
  }
}

Future<void> _showVideoSyncDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<String>(
    context: context,
    builder: (context) => SelectDialog<String>(
      title: '瑙嗛鍚屾',
      value: Pref.videoSync,
      values: const [
        'audio',
        'display-resample',
        'display-resample-vdrop',
        'display-resample-desync',
        'display-tempo',
        'display-vdrop',
        'display-adrop',
        'display-desync',
        'desync',
      ].map((e) => (e, e)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.videoSync, res);
    setState();
  }
}

Future<void> _showHwDecDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<List<String>>(
    context: context,
    builder: (context) => OrderedMultiSelectDialog<String>(
      title: '纭В妯″紡',
      initValues: Pref.hardwareDecoding.split(','),
      values: {
        for (final e in HwDecType.values) e.hwdec: '${e.hwdec}\n${e.desc}',
      },
    ),
  );
  if (res != null && res.isNotEmpty) {
    await GStorage.setting.put(
      SettingBoxKey.hardwareDecoding,
      res.join(','),
    );
    setState();
  }
}

void _showAutoSyncDialog(BuildContext context, VoidCallback setState) {
  String autosync = Pref.autosync.toString();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('鑷姩鍚屾'),
      content: TextFormField(
        autofocus: true,
        initialValue: autosync,
        keyboardType: TextInputType.number,
        onChanged: (value) => autosync = value,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(
            '鍙栨秷',
            style: TextStyle(color: ColorScheme.of(context).outline),
          ),
        ),
        TextButton(
          onPressed: () async {
            try {
              // validate
              int.parse(autosync);
              Get.back();
              await GStorage.setting.put(SettingBoxKey.autosync, autosync);
              setState();
            } catch (e) {
              SmartDialog.showToast(e.toString());
            }
          },
          child: const Text('纭畾'),
        ),
      ],
    ),
  );
}

void _showDecimalDialog(
  BuildContext context,
  VoidCallback setState, {
  required String key,
  required double defVal,
  required String title,
  required String? suffix,
}) {
  String value = (GStorage.setting.get(key) ?? defVal).toString();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextFormField(
        autofocus: true,
        initialValue: value,
        keyboardType: const .numberWithOptions(decimal: true),
        onChanged: (val) => value = val,
        inputFormatters: FilteringText.decimal,
        decoration: suffix == null ? null : InputDecoration(suffixText: suffix),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(
            '鍙栨秷',
            style: TextStyle(color: ColorScheme.of(context).outline),
          ),
        ),
        TextButton(
          onPressed: () async {
            try {
              final val = double.parse(value);
              Get.back();
              await GStorage.setting.put(key, val);
              setState();
            } catch (e) {
              SmartDialog.showToast(e.toString());
            }
          },
          child: const Text('纭畾'),
        ),
      ],
    ),
  );
}

void _showBufferSizeDialog(BuildContext context, VoidCallback setState) =>
    _showDecimalDialog(
      context,
      setState,
      key: SettingBoxKey.bufferSize,
      defVal: Pref.bufferSize,
      title: '缂撳啿澶у皬',
      suffix: 'MB',
    );

void _showBufferSecDialog(BuildContext context, VoidCallback setState) =>
    _showDecimalDialog(
      context,
      setState,
      key: SettingBoxKey.bufferSec,
      defVal: Pref.bufferSec,
      title: '缂撳啿鏃堕暱',
      suffix: 's',
    );

