import 'package:liqliquid/pages/setting/models/extra_settings.dart';
import 'package:liqliquid/pages/setting/models/model.dart';
import 'package:liqliquid/pages/setting/models/play_settings.dart';
import 'package:liqliquid/pages/setting/models/privacy_settings.dart';
import 'package:liqliquid/pages/setting/models/recommend_settings.dart';
import 'package:liqliquid/pages/setting/models/style_settings.dart';
import 'package:liqliquid/pages/setting/models/video_settings.dart';

enum SettingType {
  privacySetting('闅愮璁剧疆'),
  recommendSetting('鎺ㄨ崘娴佽缃?),
  videoSetting('闊宠棰戣缃?),
  playSetting('鎾斁鍣ㄨ缃?),
  styleSetting('澶栬璁剧疆'),
  extraSetting('鍏跺畠璁剧疆'),
  webdavSetting('WebDAV 璁剧疆'),
  about('鍏充簬'),
  ;

  final String title;
  const SettingType(this.title);

  List<SettingsModel> get settings => switch (this) {
    .privacySetting => privacySettings,
    .recommendSetting => recommendSettings,
    .videoSetting => videoSettings,
    .playSetting => playSettings,
    .styleSetting => styleSettings,
    .extraSetting => extraSettings,
    _ => throw UnimplementedError(),
  };
}

