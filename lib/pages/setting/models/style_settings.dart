import 'dart:io';
import 'dart:math' as math;

import 'package:liqliquid/common/widgets/color_palette.dart';
import 'package:liqliquid/common/widgets/custom_toast.dart';
import 'package:liqliquid/common/widgets/dialog/dialog.dart';
import 'package:liqliquid/common/widgets/image/network_img_layer.dart';
import 'package:liqliquid/common/widgets/scale_app.dart';
import 'package:liqliquid/common/widgets/stateful_builder.dart';
import 'package:liqliquid/models/common/bar_hide_type.dart';
import 'package:liqliquid/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:liqliquid/models/common/dynamic/up_panel_position.dart';
import 'package:liqliquid/models/common/home_tab_type.dart';
import 'package:liqliquid/models/common/msg/msg_unread_type.dart';
import 'package:liqliquid/models/common/nav_bar_config.dart';
import 'package:liqliquid/models/common/theme/theme_color_type.dart';
import 'package:liqliquid/models/common/theme/theme_type.dart';
import 'package:liqliquid/pages/main/controller.dart';
import 'package:liqliquid/pages/mine/controller.dart';
import 'package:liqliquid/pages/setting/models/model.dart';
import 'package:liqliquid/pages/setting/slide_color_picker.dart';
import 'package:liqliquid/pages/setting/widgets/dual_slider_dialog.dart';
import 'package:liqliquid/pages/setting/widgets/multi_select_dialog.dart';
import 'package:liqliquid/pages/setting/widgets/select_dialog.dart';
import 'package:liqliquid/pages/setting/widgets/slider_dialog.dart';
import 'package:liqliquid/plugin/pl_player/utils/fullscreen.dart';
import 'package:liqliquid/utils/extension/file_ext.dart';
import 'package:liqliquid/utils/extension/get_ext.dart';
import 'package:liqliquid/utils/extension/num_ext.dart';
import 'package:liqliquid/utils/extension/theme_ext.dart';
import 'package:liqliquid/utils/global_data.dart';
import 'package:liqliquid/utils/path_utils.dart';
import 'package:liqliquid/utils/platform_utils.dart';
import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:liqliquid/utils/storage_pref.dart';
import 'package:liqliquid/utils/theme_utils.dart';
import 'package:flutter/material.dart' hide StatefulBuilder;
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' as path;

List<SettingsModel> get styleSettings => [
  if (PlatformUtils.isDesktop) ...[
    const SwitchModel(
      title: '鏄剧ず绐楀彛鏍囬鏍?,
      leading: Icon(Icons.window),
      setKey: SettingBoxKey.showWindowTitleBar,
      defaultVal: true,
      needReboot: true,
    ),
    const SwitchModel(
      title: '鏄剧ず鎵樼洏鍥炬爣',
      leading: Icon(Icons.donut_large_rounded),
      setKey: SettingBoxKey.showTrayIcon,
      defaultVal: true,
      needReboot: true,
    ),
  ],
  if (Platform.isLinux) _useSSDModel(),
  SwitchModel(
    title: '妯睆閫傞厤',
    subtitle: '鍚敤妯睆甯冨眬涓庨€昏緫锛屽钩鏉裤€佹姌鍙犲睆绛夊彲寮€鍚紱寤鸿鍏ㄥ睆鏂瑰悜璁句负銆愪笉鏀瑰彉褰撳墠鏂瑰悜銆?,
    leading: const Icon(Icons.phonelink_outlined),
    setKey: SettingBoxKey.horizontalScreen,
    defaultVal: Pref.horizontalScreen,
    onChanged: (value) {
      if (value) {
        fullMode();
      } else {
        portraitUpMode();
      }
    },
  ),
  const SwitchModel(
    title: '鏀圭敤渚ц竟鏍?,
    subtitle: '寮€鍚悗搴曟爮涓庨《鏍忚鏇挎崲锛屼笖鐩稿叧璁剧疆澶辨晥',
    leading: Icon(Icons.chrome_reader_mode_outlined),
    setKey: SettingBoxKey.useSideBar,
    defaultVal: false,
    needReboot: true,
  ),
  SplitModel(
    normalModel: const NormalModel.split(
      title: 'App瀛椾綋瀛楅噸',
      subtitle: '鐐瑰嚮璁剧疆',
      leading: Icon(Icons.text_fields),
    ),
    switchModel: SwitchModel.split(
      defaultVal: false,
      setKey: SettingBoxKey.appFontWeight,
      onChanged: (_) => Get.updateMyAppTheme(),
      onTap: _showFontWeightDialog,
    ),
  ),
  NormalModel(
    title: '鐣岄潰缂╂斁',
    getSubtitle: () => '褰撳墠缂╂斁姣斾緥锛?{Pref.uiScale.toStringAsFixed(2)}',
    leading: const Icon(Icons.zoom_in_outlined),
    onTap: _showUiScaleDialog,
  ),
  NormalModel(
    title: '椤甸潰杩囨浮鍔ㄧ敾',
    leading: const Icon(Icons.animation),
    getSubtitle: () => '褰撳墠锛?{Pref.pageTransition.name}',
    onTap: _showTransitionDialog,
  ),
  const SwitchModel(
    title: '浼樺寲骞虫澘瀵艰埅鏍?,
    leading: Icon(Icons.auto_fix_high),
    setKey: SettingBoxKey.optTabletNav,
    defaultVal: true,
    needReboot: true,
  ),
  const SwitchModel(
    title: 'MD3鏍峰紡搴曟爮',
    subtitle: 'Material You璁捐瑙勮寖搴曟爮锛屽叧闂彲鍙樼獎',
    leading: Icon(Icons.design_services_outlined),
    setKey: SettingBoxKey.enableMYBar,
    defaultVal: true,
    needReboot: true,
  ),
  const SwitchModel(
    title: '鎮诞搴曟爮',
    leading: Icon(MdiIcons.soundbar),
    setKey: SettingBoxKey.floatingNavBar,
    defaultVal: false,
    needReboot: true,
  ),
  NormalModel(
    leading: const Icon(Icons.calendar_view_week_outlined),
    title: '鍒楄〃瀹藉害锛坉p锛夐檺鍒?,
    getSubtitle: () =>
        '褰撳墠: 涓婚〉${Pref.recommendCardWidth.toInt()}dp 鍏朵粬${Pref.smallCardWidth.toInt()}dp锛屽睆骞曞搴?${MediaQuery.widthOf(Get.context!).toPrecision(2)}dp銆傚搴﹁秺灏忓垪鏁拌秺澶氥€?,
    onTap: _showCardWidthDialog,
  ),
  const SwitchModel(
    title: '鎾斁椤电Щ闄ゅ畨鍏ㄨ竟璺?,
    leading: Icon(Icons.fit_screen_outlined),
    setKey: SettingBoxKey.removeSafeArea,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '瑙嗛鎾斁椤典娇鐢ㄦ繁鑹蹭富棰?,
    leading: Icon(Icons.dark_mode_outlined),
    setKey: SettingBoxKey.darkVideoPage,
    defaultVal: false,
  ),
  SwitchModel(
    title: '鍔ㄦ€侀〉鍚敤鐎戝竷娴?,
    subtitle: '鍏抽棴浼氭樉绀轰负鍗曞垪',
    leading: const Icon(Icons.view_array_outlined),
    setKey: SettingBoxKey.dynamicsWaterfallFlow,
    defaultVal: Pref.horizontalScreen,
    needReboot: true,
  ),
  NormalModel(
    title: '鍔ㄦ€侀〉UP涓绘樉绀轰綅缃?,
    leading: const Icon(Icons.person_outlined),
    getSubtitle: () => '褰撳墠锛?{Pref.upPanelPosition.label}',
    onTap: _showUpPosDialog,
  ),
  const SwitchModel(
    title: '鍔ㄦ€侀〉鏄剧ず鎵€鏈夊凡鍏虫敞UP涓?,
    leading: Icon(Icons.people_alt_outlined),
    setKey: SettingBoxKey.dynamicsShowAllFollowedUp,
    defaultVal: false,
    needReboot: true,
  ),
  const SwitchModel(
    title: '鍔ㄦ€侀〉灞曞紑姝ｅ湪鐩存挱UP鍒楄〃',
    leading: Icon(Icons.live_tv),
    setKey: SettingBoxKey.expandDynLivePanel,
    defaultVal: false,
    needReboot: true,
  ),
  NormalModel(
    title: '鍔ㄦ€佹湭璇绘爣璁?,
    leading: const Icon(Icons.motion_photos_on_outlined),
    getSubtitle: () => '褰撳墠鏍囪鏍峰紡锛?{Pref.dynamicBadgeType.desc}',
    onTap: _showDynBadgeDialog,
  ),
  NormalModel(
    title: '娑堟伅鏈鏍囪',
    leading: const Icon(MdiIcons.bellBadgeOutline),
    getSubtitle: () => '褰撳墠鏍囪鏍峰紡锛?{Pref.msgBadgeMode.desc}',
    onTap: _showMsgBadgeDialog,
  ),
  NormalModel(
    onTap: _showMsgUnReadDialog,
    title: '娑堟伅鏈绫诲瀷',
    leading: const Icon(MdiIcons.bellCogOutline),
    getSubtitle: () =>
        '褰撳墠娑堟伅绫诲瀷锛?{Pref.msgUnReadTypeV2.map((item) => item.title).join('銆?)}',
  ),
  NormalModel(
    onTap: _showBarHideTypeDialog,
    title: '椤?搴曟爮鏀惰捣绫诲瀷',
    leading: const Icon(MdiIcons.arrowExpandVertical),
    getSubtitle: () => '褰撳墠锛?{Pref.barHideType.label}',
  ),
  SwitchModel(
    title: '棣栭〉椤舵爮鏀惰捣',
    subtitle: '棣栭〉鍒楄〃婊戝姩鏃讹紝鏀惰捣椤舵爮',
    leading: const Icon(Icons.vertical_align_top_outlined),
    setKey: SettingBoxKey.hideTopBar,
    defaultVal: PlatformUtils.isMobile,
    needReboot: true,
  ),
  SwitchModel(
    title: '棣栭〉搴曟爮鏀惰捣',
    subtitle: '棣栭〉鍒楄〃婊戝姩鏃讹紝鏀惰捣搴曟爮',
    leading: const Icon(Icons.vertical_align_bottom_outlined),
    setKey: SettingBoxKey.hideBottomBar,
    defaultVal: PlatformUtils.isMobile,
    needReboot: true,
  ),
  NormalModel(
    onTap: (context, setState) => _showQualityDialog(
      context: context,
      title: const Text('鍥剧墖璐ㄩ噺'),
      initValue: Pref.picQuality,
      onChanged: (picQuality) async {
        GlobalData().imgQuality = picQuality;
        await GStorage.setting.put(SettingBoxKey.defaultPicQa, picQuality);
        setState();
      },
    ),
    title: '鍥剧墖璐ㄩ噺',
    subtitle: '閫夋嫨鍚堥€傜殑鍥剧墖娓呮櫚搴︼紝涓婇檺100%',
    leading: const Icon(Icons.image_outlined),
    getTrailing: (theme) => Text(
      '${Pref.picQuality}%',
      style: theme.textTheme.titleSmall,
    ),
  ),
  NormalModel(
    onTap: (context, setState) => _showQualityDialog(
      context: context,
      title: const Text('鏌ョ湅澶у浘璐ㄩ噺'),
      initValue: Pref.previewQ,
      onChanged: (picQuality) async {
        await GStorage.setting.put(SettingBoxKey.previewQuality, picQuality);
        setState();
      },
    ),
    title: '鏌ョ湅澶у浘璐ㄩ噺',
    subtitle: '閫夋嫨鍚堥€傜殑鍥剧墖娓呮櫚搴︼紝涓婇檺100%',
    leading: const Icon(Icons.image_outlined),
    getTrailing: (theme) => Text(
      '${Pref.previewQ}%',
      style: theme.textTheme.titleSmall,
    ),
  ),
  NormalModel(
    onTap: _showReduceColorDialog,
    title: '娣辫壊涓嬪浘鐗囬鑹插彔鍔?,
    subtitle: '鏄剧ず棰滆壊=鍥剧墖鍘熻壊x鎵€閫夐鑹诧紝澶у浘鏌ョ湅涓嶅彈褰卞搷',
    leading: const Icon(Icons.format_color_fill_outlined),
    getTrailing: (theme) => Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Pref.reduceLuxColor ?? Colors.white,
        shape: BoxShape.circle,
      ),
    ),
  ),
  NormalModel(
    leading: const Icon(Icons.opacity_outlined),
    title: '姘旀场鎻愮ず涓嶉€忔槑搴?,
    subtitle: '鑷畾涔夋皵娉℃彁绀?Toast)涓嶉€忔槑搴?,
    getTrailing: (theme) => Text(
      CustomToast.toastOpacity.toStringAsFixed(1),
      style: theme.textTheme.titleSmall,
    ),
    onTap: _showToastDialog,
  ),
  NormalModel(
    onTap: _showThemeTypeDialog,
    leading: const Icon(Icons.flashlight_on_outlined),
    title: '涓婚妯″紡',
    getSubtitle: () => '褰撳墠妯″紡锛?{Pref.themeType.desc}',
  ),
  SwitchModel(
    leading: const Icon(Icons.invert_colors),
    title: '绾粦涓婚',
    setKey: SettingBoxKey.isPureBlackTheme,
    defaultVal: false,
    onChanged: (value) {
      if (ThemeUtils.isDarkMode || Pref.darkVideoPage) {
        Get.updateMyAppTheme();
      }
    },
  ),
  NormalModel(
    onTap: (context, setState) => Get.toNamed('/colorSetting'),
    leading: const Icon(Icons.color_lens_outlined),
    title: '搴旂敤涓婚',
    getSubtitle: () => '褰撳墠涓婚锛?{Pref.dynamicColor ? '鍔ㄦ€佸彇鑹? : '鎸囧畾棰滆壊'}',
    getTrailing: (theme) => Pref.dynamicColor
        ? Icon(Icons.color_lens_rounded, color: theme.colorScheme.primary)
        : SizedBox.square(
            dimension: 20,
            child: ColorPalette(
              colorScheme: colorThemeTypes[Pref.customColor].color
                  .asColorSchemeSeed(Pref.schemeVariant, theme.brightness),
              selected: false,
              showBgColor: false,
            ),
          ),
  ),
  NormalModel(
    leading: const Icon(Icons.home_outlined),
    title: '榛樿鍚姩椤?,
    getSubtitle: () => '褰撳墠鍚姩椤碉細${Pref.defaultHomePage.label}',
    onTap: _showDefHomeDialog,
  ),
  const NormalModel(
    title: '婊戝姩鍔ㄧ敾寮圭哀鍙傛暟',
    leading: Icon(Icons.chrome_reader_mode_outlined),
    onTap: _showSpringDialog,
  ),
  NormalModel(
    onTap: (context, setState) async {
      final res = await Get.toNamed('/fontSizeSetting');
      if (res != null) {
        setState();
      }
    },
    title: '瀛椾綋澶у皬',
    leading: const Icon(Icons.format_size_outlined),
    getSubtitle: () {
      final scale = Pref.defaultTextScale;
      return scale == 1.0 ? '榛樿' : scale.toString();
    },
  ),
  NormalModel(
    onTap: (context, setState) => Get.toNamed(
      '/barSetting',
      arguments: {
        'key': SettingBoxKey.tabBarSort,
        'defaultBars': HomeTabType.values,
        'title': '棣栭〉鏍囩椤?,
      },
    ),
    title: '棣栭〉鏍囩椤?,
    subtitle: '鍒犻櫎鎴栬皟鎹㈤椤垫爣绛鹃〉',
    leading: const Icon(Icons.toc_outlined),
  ),
  NormalModel(
    onTap: (context, setState) => Get.toNamed(
      '/barSetting',
      arguments: {
        'key': SettingBoxKey.navBarSort,
        'defaultBars': NavigationBarType.values,
        'title': 'Navbar',
      },
    ),
    title: 'Navbar缂栬緫',
    subtitle: '鍒犻櫎鎴栬皟鎹avbar',
    leading: const Icon(Icons.toc_outlined),
  ),
  SwitchModel(
    title: '杩斿洖鏃剁洿鎺ラ€€鍑?,
    subtitle: '寮€鍚悗鍦ㄤ富椤典换鎰弔ab鎸夎繑鍥為敭閮界洿鎺ラ€€鍑猴紝鍏抽棴鍒欏厛鍥炲埌Navbar鐨勭涓€涓猼ab',
    leading: const Icon(Icons.exit_to_app_outlined),
    setKey: SettingBoxKey.directExitOnBack,
    defaultVal: false,
    onChanged: (value) => Get.find<MainController>().directExitOnBack = value,
  ),
  if (Platform.isAndroid)
    NormalModel(
      onTap: (context, setState) => Get.toNamed('/displayModeSetting'),
      title: '灞忓箷甯х巼',
      leading: const Icon(Icons.autofps_select_outlined),
    ),
];

void _showQualityDialog({
  required BuildContext context,
  required Widget title,
  required int initValue,
  required ValueChanged<int> onChanged,
}) {
  showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      value: initValue.toDouble(),
      title: title,
      min: 10,
      max: 100,
      divisions: 9,
      suffix: '%',
      precise: 0,
    ),
  ).then((result) {
    if (result != null) {
      SmartDialog.showToast('璁剧疆鎴愬姛');
      onChanged(result.toInt());
    }
  });
}

void _showUiScaleDialog(
  BuildContext context,
  VoidCallback setState,
) {
  const minUiScale = 0.5;
  const maxUiScale = 2.0;

  double uiScale = Pref.uiScale;
  final textController = TextEditingController(
    text: uiScale.toStringAsFixed(2),
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('鐣岄潰缂╂斁'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      content: StatefulBuilder(
        onDispose: textController.dispose,
        builder: (context, setDialogState) => Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              padding: .zero,
              value: uiScale,
              min: minUiScale,
              max: maxUiScale,
              secondaryTrackValue: 1.0,
              divisions: ((maxUiScale - minUiScale) * 20).toInt(),
              label: textController.text,
              onChanged: (value) => setDialogState(() {
                uiScale = value.toPrecision(2);
                textController.text = uiScale.toStringAsFixed(2);
              }),
            ),
            TextFormField(
              controller: textController,
              keyboardType: const .numberWithOptions(decimal: true),
              inputFormatters: [
                LengthLimitingTextInputFormatter(4),
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]+')),
              ],
              decoration: const InputDecoration(
                labelText: '缂╂斁姣斾緥',
                hintText: '0.50 - 2.00',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null &&
                    parsed >= minUiScale &&
                    parsed <= maxUiScale) {
                  setDialogState(() {
                    uiScale = parsed;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            GStorage.setting.delete(SettingBoxKey.uiScale).whenComplete(() {
              setState();
              Get.appUpdate();
              ScaledWidgetsFlutterBinding.instance.scaleFactor = 1.0;
            });
          },
          child: const Text('閲嶇疆'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '鍙栨秷',
            style: TextStyle(color: ColorScheme.of(context).outline),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            GStorage.setting.put(SettingBoxKey.uiScale, uiScale).whenComplete(
              () {
                setState();
                Get.appUpdate();
                ScaledWidgetsFlutterBinding.instance.scaleFactor = uiScale;
              },
            );
          },
          child: const Text('纭畾'),
        ),
      ],
    ),
  );
}

void _showSpringDialog(BuildContext context, _) {
  final List<String> springDescription = Pref.springDescription
      .map((i) => i.toString())
      .toList(growable: false);
  bool physicalMode = true;

  void physical2Duration() {
    final mass = double.parse(springDescription[0]);
    final stiffness = double.parse(springDescription[1]);
    final damping = double.parse(springDescription[2]);

    final duration = math.sqrt(4 * math.pi * math.pi * mass / stiffness);
    final dampingRatio = damping / (2.0 * math.sqrt(mass * stiffness));
    final bounce = dampingRatio < 1.0
        ? 1.0 - dampingRatio
        : 1.0 / dampingRatio - 1;

    springDescription[0] = duration.toString();
    springDescription[1] = bounce.toString();
  }

  /// from [SpringDescription.withDurationAndBounce] but with higher precision
  void duration2Physical() {
    final duration = double.parse(springDescription[0]);
    final bounce = double.parse(springDescription[1]).clamp(-1.0, 1.0);

    final stiffness = 4 * math.pi * math.pi / math.pow(duration, 2);
    final dampingRatio = bounce > 0 ? 1.0 - bounce : 1.0 / (bounce + 1);
    final damping = 2 * math.sqrt(stiffness) * dampingRatio;

    springDescription[0] = '1';
    springDescription[1] = stiffness.toString();
    springDescription[2] = damping.toString();
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          const Text('寮圭哀鍙傛暟'),
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: .compact,
              tapTargetSize: .shrinkWrap,
            ),
            onPressed: () {
              try {
                if (physicalMode) {
                  physical2Duration();
                } else {
                  duration2Physical();
                }
                physicalMode = !physicalMode;
                (context as Element).markNeedsBuild();
              } catch (e) {
                SmartDialog.showToast(e.toString());
              }
            },
            child: Text(physicalMode ? '婊戝姩鏃堕棿' : '鐗╃悊鍙傛暟'),
          ),
        ],
      ),
      content: Column(
        key: ValueKey(physicalMode),
        mainAxisSize: .min,
        children: List.generate(
          physicalMode ? 3 : 2,
          (index) => TextFormField(
            autofocus: index == 0,
            initialValue: springDescription[index],
            keyboardType: .numberWithOptions(
              signed: !physicalMode && index == 1,
              decimal: true,
            ),
            onChanged: (value) => springDescription[index] = value,
            inputFormatters: [
              !physicalMode && index == 1
                  ? FilteringTextInputFormatter.allow(RegExp(r'[-\d\.]+'))
                  : FilteringTextInputFormatter.allow(RegExp(r'[\d\.]+')),
            ],
            decoration: InputDecoration(
              labelText: (physicalMode
                  ? const ['mass', 'stiffness', 'damping']
                  : const ['duration', 'bounce'])[index],
              suffixText: !physicalMode && index == 0 ? 's' : null,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            GStorage.setting.delete(SettingBoxKey.springDescription);
            SmartDialog.showToast('閲嶇疆鎴愬姛锛岄噸鍚敓鏁?);
          },
          child: const Text('閲嶇疆'),
        ),
        TextButton(
          onPressed: Get.back,
          child: Text(
            '鍙栨秷',
            style: TextStyle(color: ColorScheme.of(context).outline),
          ),
        ),
        TextButton(
          onPressed: () {
            try {
              if (!physicalMode) {
                duration2Physical();
              }
              final res = springDescription.map(double.parse).toList();
              Get.back();
              GStorage.setting.put(SettingBoxKey.springDescription, res);
              SmartDialog.showToast('璁剧疆鎴愬姛锛岄噸鍚敓鏁?);
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

Future<void> _showFontWeightDialog(BuildContext context) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: const Text('App瀛椾綋瀛楅噸'),
      value: Pref.appFontWeight.toDouble() + 1,
      min: 1,
      max: FontWeight.values.length.toDouble(),
      divisions: FontWeight.values.length - 1,
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.appFontWeight, res.toInt() - 1);
    Get.updateMyAppTheme();
  }
}

Future<void> _showTransitionDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<Transition>(
    context: context,
    builder: (context) => SelectDialog<Transition>(
      title: '椤甸潰杩囨浮鍔ㄧ敾',
      value: Pref.pageTransition,
      values: Transition.values.map((e) => (e, e.name)).toList(),
    ),
  );
  if (res != null) {
    Get.rootController.defaultTransition = res;
    await GStorage.setting.put(SettingBoxKey.pageTransition, res.index);
    setState();
  }
}

Future<void> _showCardWidthDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<(double, double)>(
    context: context,
    builder: (context) => DualSliderDialog(
      title: const Text('鍒楄〃鏈€澶у垪瀹藉害锛堥粯璁?40dp锛?),
      value1: Pref.recommendCardWidth,
      value2: Pref.smallCardWidth,
      description1: const Text('涓婚〉鎺ㄨ崘娴?),
      description2: const Text('鍏朵粬'),
      min: 150.0,
      max: 500.0,
      divisions: 35,
      suffix: 'dp',
    ),
  );
  if (res != null) {
    await GStorage.setting.putAll({
      SettingBoxKey.recommendCardWidth: res.$1,
      SettingBoxKey.smallCardWidth: res.$2,
    });
    SmartDialog.showToast('閲嶅惎鐢熸晥');
    setState();
  }
}

Future<void> _showUpPosDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<UpPanelPosition>(
    context: context,
    builder: (context) => SelectDialog<UpPanelPosition>(
      title: '鍔ㄦ€侀〉UP涓绘樉绀轰綅缃?,
      value: Pref.upPanelPosition,
      values: UpPanelPosition.values.map((e) => (e, e.label)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.upPanelPosition, res.index);
    SmartDialog.showToast('閲嶅惎鐢熸晥');
    setState();
  }
}

Future<void> _showDynBadgeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<DynamicBadgeMode>(
    context: context,
    builder: (context) => SelectDialog<DynamicBadgeMode>(
      title: '鍔ㄦ€佹湭璇绘爣璁?,
      value: Pref.dynamicBadgeType,
      values: DynamicBadgeMode.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    final mainController = Get.find<MainController>()
      ..dynamicBadgeMode = DynamicBadgeMode.values[res.index];
    if (mainController.dynamicBadgeMode != DynamicBadgeMode.hidden) {
      mainController.getUnreadDynamic();
    }
    await GStorage.setting.put(
      SettingBoxKey.dynamicBadgeMode,
      res.index,
    );
    SmartDialog.showToast('璁剧疆鎴愬姛');
    setState();
  }
}

Future<void> _showMsgBadgeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<DynamicBadgeMode>(
    context: context,
    builder: (context) => SelectDialog<DynamicBadgeMode>(
      title: '娑堟伅鏈鏍囪',
      value: Pref.msgBadgeMode,
      values: DynamicBadgeMode.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    final mainController = Get.find<MainController>()
      ..msgBadgeMode = DynamicBadgeMode.values[res.index];
    if (mainController.msgBadgeMode != DynamicBadgeMode.hidden) {
      mainController.queryUnreadMsg(true);
    } else {
      mainController.msgUnReadCount.value = '';
    }
    await GStorage.setting.put(SettingBoxKey.msgBadgeMode, res.index);
    SmartDialog.showToast('璁剧疆鎴愬姛');
    setState();
  }
}

Future<void> _showMsgUnReadDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<Set<MsgUnReadType>>(
    context: context,
    builder: (context) => MultiSelectDialog<MsgUnReadType>(
      title: '娑堟伅鏈绫诲瀷',
      initValues: Pref.msgUnReadTypeV2,
      values: {for (final i in MsgUnReadType.values) i: i.title},
    ),
  );
  if (res != null) {
    final mainController = Get.find<MainController>()..msgUnReadTypes = res;
    if (mainController.msgBadgeMode != DynamicBadgeMode.hidden) {
      mainController.queryUnreadMsg();
    }
    await GStorage.setting.put(
      SettingBoxKey.msgUnReadTypeV2,
      res.map((item) => item.index).toList()..sort(),
    );
    SmartDialog.showToast('璁剧疆鎴愬姛');
    setState();
  }
}

void _showReduceColorDialog(
  BuildContext context,
  VoidCallback setState,
) {
  final reduceLuxColor = Pref.reduceLuxColor;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      clipBehavior: Clip.hardEdge,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      title: const Text('Color Picker'),
      content: SlideColorPicker(
        color: reduceLuxColor ?? Colors.white,
        onChanged: (Color? color) {
          if (color != null && color != reduceLuxColor) {
            if (color == Colors.white) {
              NetworkImgLayer.reduceLuxColor = null;
              GStorage.setting.delete(SettingBoxKey.reduceLuxColor);
              SmartDialog.showToast('璁剧疆鎴愬姛');
              setState();
            } else {
              void onConfirm() {
                NetworkImgLayer.reduceLuxColor = color;
                GStorage.setting.put(
                  SettingBoxKey.reduceLuxColor,
                  color.toARGB32(),
                );
                SmartDialog.showToast('璁剧疆鎴愬姛');
                setState();
              }

              if (color.computeLuminance() < 0.2) {
                showConfirmDialog(
                  context: context,
                  title: Text(
                    '纭浣跨敤#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6)}锛?,
                  ),
                  content: const Text('鎵€閫夐鑹茶繃浜庢槒鏆楋紝鍙兘浼氬奖鍝嶅浘鐗囪鐪?),
                  onConfirm: onConfirm,
                );
              } else {
                onConfirm();
              }
            }
          }
        },
      ),
    ),
  );
}

Future<void> _showToastDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: const Text('Toast涓嶉€忔槑搴?),
      value: CustomToast.toastOpacity,
      min: 0.0,
      max: 1.0,
      divisions: 10,
    ),
  );
  if (res != null) {
    CustomToast.toastOpacity = res;
    await GStorage.setting.put(SettingBoxKey.defaultToastOp, res);
    SmartDialog.showToast('璁剧疆鎴愬姛');
    setState();
  }
}

Future<void> _showThemeTypeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<ThemeType>(
    context: context,
    builder: (context) => SelectDialog<ThemeType>(
      title: '涓婚妯″紡',
      value: Pref.themeType,
      values: ThemeType.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    try {
      Get.find<MineController>().themeType.value = res;
    } catch (_) {}
    GStorage.setting.put(SettingBoxKey.themeMode, res.index);
    Get.changeThemeMode(ThemeUtils.themeMode = res.toThemeMode);
    setState();
  }
}

Future<void> _showDefHomeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<NavigationBarType>(
    context: context,
    builder: (context) => SelectDialog<NavigationBarType>(
      title: '棣栭〉鍚姩椤?,
      value: Pref.defaultHomePage,
      values: NavigationBarType.values.map((e) => (e, e.label)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.defaultHomePage, res.index);
    SmartDialog.showToast('璁剧疆鎴愬姛锛岄噸鍚敓鏁?);
    setState();
  }
}

Future<void> _showBarHideTypeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<BarHideType>(
    context: context,
    builder: (context) => SelectDialog<BarHideType>(
      title: '椤?搴曟爮鏀惰捣绫诲瀷',
      value: Pref.barHideType,
      values: BarHideType.values.map((e) => (e, e.label)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.barHideType, res.index);
    SmartDialog.showToast('閲嶅惎鐢熸晥');
    setState();
  }
}

NormalModel _useSSDModel() {
  final file = File(path.join(appSupportDirPath, 'use_ssd'));
  void onChanged(BuildContext context, VoidCallback setState) {
    (file.existsSync() ? file.tryDel() : file.create()).whenComplete(() {
      if (context.mounted) {
        setState();
      }
    });
  }

  return NormalModel(
    title: '浣跨敤SSD锛圫erver-Side Decoration锛?,
    leading: const Icon(Icons.web_asset),
    onTap: onChanged,
    getTrailing: (theme) => Builder(
      builder: (context) => Transform.scale(
        scale: 0.8,
        alignment: .centerRight,
        child: Switch(
          value: file.existsSync(),
          onChanged: (_) =>
              onChanged(context, (context as Element).markNeedsBuild),
        ),
      ),
    ),
  );
}

