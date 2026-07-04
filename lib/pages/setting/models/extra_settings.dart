import 'dart:io';
import 'dart:math' show max;

import 'package:liqliquid/common/widgets/custom_icon.dart';
import 'package:liqliquid/common/widgets/dialog/simple_dialog_option.dart';
import 'package:liqliquid/common/widgets/flutter/refresh_indicator.dart';
import 'package:liqliquid/common/widgets/gesture/horizontal_drag_gesture_recognizer.dart'
    show deviceTouchSlop, touchSlopH;
import 'package:liqliquid/common/widgets/image_grid/image_grid_view.dart'
    show ImageGridView, ImageModel;
import 'package:liqliquid/common/widgets/pendant_avatar.dart';
import 'package:liqliquid/grpc/reply.dart';
import 'package:liqliquid/http/fav.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/models/common/audio_normalization.dart';
import 'package:liqliquid/models/common/dynamic/dynamics_type.dart';
import 'package:liqliquid/models/common/member/tab_type.dart';
import 'package:liqliquid/models/common/reply/reply_sort_type.dart';
import 'package:liqliquid/models/common/sponsor_block/skip_type.dart';
import 'package:liqliquid/models/common/super_resolution_type.dart';
import 'package:liqliquid/models/dynamics/result.dart'
    show DynamicsDataModel, ItemModulesModel;
import 'package:liqliquid/pages/common/slide/common_slide_page.dart';
import 'package:liqliquid/pages/home/controller.dart';
import 'package:liqliquid/pages/main/controller.dart';
import 'package:liqliquid/pages/setting/models/model.dart';
import 'package:liqliquid/pages/setting/widgets/select_dialog.dart';
import 'package:liqliquid/pages/setting/widgets/slider_dialog.dart';
import 'package:liqliquid/pages/video/reply/widgets/reply_item_grpc.dart';
import 'package:liqliquid/plugin/pl_player/controller.dart';
import 'package:liqliquid/services/download/download_service.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:liqliquid/utils/cache_manager.dart';
import 'package:liqliquid/utils/extension/num_ext.dart';
import 'package:liqliquid/utils/feed_back.dart';
import 'package:liqliquid/utils/filtering_text.dart';
import 'package:liqliquid/utils/global_data.dart';
import 'package:liqliquid/utils/image_utils.dart';
import 'package:liqliquid/utils/path_utils.dart';
import 'package:liqliquid/utils/platform_utils.dart';
import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:liqliquid/utils/storage_pref.dart';
import 'package:liqliquid/utils/update.dart';
import 'package:liqliquid/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

List<SettingsModel> get extraSettings => [
  if (PlatformUtils.isDesktop) ...[
    SwitchModel(
      title: '閫€鍑烘椂鏈€灏忓寲',
      leading: const Icon(Icons.exit_to_app),
      setKey: SettingBoxKey.minimizeOnExit,
      defaultVal: true,
      onChanged: (value) {
        try {
          Get.find<MainController>().minimizeOnExit = value;
        } catch (_) {}
      },
    ),
    NormalModel(
      title: '缂撳瓨璺緞',
      getSubtitle: () => downloadPath,
      leading: const Icon(Icons.storage),
      onTap: _showDownPathDialog,
    ),
  ],
  SplitModel(
    normalModel: const NormalModel.split(
      title: '绌洪檷鍔╂墜',
      subtitle: '鐐瑰嚮閰嶇疆',
      leading: Icon(CustomIcons.shield_play_arrow),
    ),
    switchModel: SwitchModel.split(
      defaultVal: false,
      setKey: SettingBoxKey.enableSponsorBlock,
      onTap: (context) => Get.toNamed('/sponsorBlock'),
    ),
  ),
  PopupModel<SkipType>(
    title: '鐣墽鐗囧ご/鐗囧熬璺宠繃绫诲瀷',
    leading: const Icon(MdiIcons.debugStepOver),
    value: () => Pref.pgcSkipType,
    items: SkipType.values,
    onSelected: (value, setState) => GStorage.setting
        .put(SettingBoxKey.pgcSkipType, value.index)
        .whenComplete(setState),
  ),
  SplitModel(
    normalModel: const NormalModel.split(
      title: '妫€鏌ユ湭璇诲姩鎬?,
      subtitle: '鐐瑰嚮璁剧疆妫€鏌ュ懆鏈?min)',
      leading: Icon(Icons.notifications_none),
    ),
    switchModel: SwitchModel.split(
      defaultVal: true,
      setKey: SettingBoxKey.checkDynamic,
      onChanged: (value) => Get.find<MainController>().checkDynamic = value,
      onTap: _showDynDialog,
    ),
  ),
  const SwitchModel(
    title: '鏄剧ず瑙嗛鍒嗘淇℃伅',
    leading: Icon(CustomIcons.view_headline_rotate_90),
    setKey: SettingBoxKey.showViewPoints,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '瑙嗛椤垫樉绀虹浉鍏宠棰?,
    leading: Icon(MdiIcons.motionPlayOutline),
    setKey: SettingBoxKey.showRelatedVideo,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '鏄剧ず瑙嗛璇勮',
    leading: Icon(MdiIcons.commentTextOutline),
    setKey: SettingBoxKey.showVideoReply,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '鏄剧ず鐣墽璇勮',
    leading: Icon(MdiIcons.commentTextOutline),
    setKey: SettingBoxKey.showBangumiReply,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '榛樿灞曞紑瑙嗛绠€浠?,
    leading: Icon(Icons.expand_more),
    setKey: SettingBoxKey.alwaysExpandIntroPanel,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '妯睆鑷姩灞曞紑瑙嗛绠€浠?,
    leading: Icon(Icons.expand_more),
    setKey: SettingBoxKey.expandIntroPanelH,
    defaultVal: false,
  ),
  SwitchModel(
    title: '妯睆鍒哖/鍚堥泦鍒楄〃鏄剧ず鍦═ab鏍?,
    leading: const Icon(Icons.format_list_numbered_rtl_sharp),
    setKey: SettingBoxKey.horizontalSeasonPanel,
    defaultVal: Pref.horizontalScreen,
  ),
  SwitchModel(
    title: '妯睆鎾斁椤靛湪渚ф爮鎵撳紑UP涓婚〉',
    leading: const Icon(Icons.account_circle_outlined),
    setKey: SettingBoxKey.horizontalMemberPage,
    defaultVal: Pref.horizontalScreen,
  ),
  SwitchModel(
    title: '妯睆鍦ㄤ晶鏍忔墦寮€鍥剧墖棰勮',
    leading: const Icon(Icons.photo_outlined),
    setKey: SettingBoxKey.horizontalPreview,
    defaultVal: false,
    onChanged: (value) => ImageGridView.horizontalPreview = value,
  ),
  NormalModel(
    title: '璇勮鎶樺彔琛屾暟',
    subtitle: '0琛屼负涓嶆姌鍙?,
    leading: const Icon(Icons.compress),
    getTrailing: (theme) => Text(
      '${ReplyItemGrpc.replyLengthLimit}琛?,
      style: theme.textTheme.titleSmall,
    ),
    onTap: _showReplyLengthDialog,
  ),
  NormalModel(
    title: '寮瑰箷琛岄珮',
    subtitle: '榛樿1.6',
    leading: const Icon(CustomIcons.dm_settings),
    getTrailing: (theme) => Text(
      Pref.danmakuLineHeight.toString(),
      style: theme.textTheme.titleSmall,
    ),
    onTap: _showDmHeightDialog,
  ),
  const SwitchModel(
    title: '鏄剧ず瑙嗛璀﹀憡/浜夎淇℃伅',
    leading: Icon(Icons.warning_amber_rounded),
    setKey: SettingBoxKey.showArgueMsg,
    defaultVal: true,
  ),
  SwitchModel(
    title: '鏄剧ず鍔ㄦ€佽鍛?浜夎淇℃伅',
    leading: const Icon(Icons.warning_amber_rounded),
    setKey: SettingBoxKey.showDynDispute,
    defaultVal: false,
    onChanged: (val) => ItemModulesModel.showDynDispute = val,
  ),
  const SwitchModel(
    title: '鍒哖/鍚堥泦锛氬€掑簭鎾斁浠庨闆嗗紑濮嬫挱鏀?,
    subtitle: '寮€鍚垯鑷姩鍒囨崲涓哄€掑簭棣栭泦锛屽惁鍒欎繚鎸佸綋鍓嶉泦',
    leading: Icon(MdiIcons.sort),
    setKey: SettingBoxKey.reverseFromFirst,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '绂佺敤 SSL 璇佷功楠岃瘉',
    subtitle: '璋ㄦ厧寮€鍚紝绂佺敤瀹规槗鍙楀埌涓棿浜烘敾鍑?,
    leading: Icon(Icons.security),
    needReboot: true,
    setKey: SettingBoxKey.badCertificateCallback,
  ),
  const SwitchModel(
    title: '鏄剧ず缁х画鎾斁鍒哖鎻愮ず',
    leading: Icon(Icons.local_parking),
    setKey: SettingBoxKey.continuePlayingPart,
    defaultVal: true,
  ),
  getBanWordModel(
    title: '璇勮鍏抽敭璇嶈繃婊?,
    key: SettingBoxKey.banWordForReply,
    onChanged: (value) {
      ReplyGrpc.replyRegExp = value;
      ReplyGrpc.enableFilter = value.pattern.isNotEmpty;
    },
  ),
  getBanWordModel(
    title: '鍔ㄦ€佸叧閿瘝杩囨护',
    key: SettingBoxKey.banWordForDyn,
    onChanged: (value) {
      DynamicsDataModel.banWordForDyn = value;
      DynamicsDataModel.enableFilter = value.pattern.isNotEmpty;
    },
  ),
  const SwitchModel(
    title: '浣跨敤澶栭儴娴忚鍣ㄦ墦寮€閾炬帴',
    leading: Icon(Icons.open_in_browser),
    setKey: SettingBoxKey.openInBrowser,
    defaultVal: false,
  ),
  NormalModel(
    title: '妯悜婊戝姩闃堝€?,
    getSubtitle: () => '褰撳墠:銆?{Pref.touchSlopH}銆嶏紝绯荤粺榛樿鍊? $deviceTouchSlop',
    onTap: _showTouchSlopDialog,
    leading: const Icon(Icons.pan_tool_alt_outlined),
  ),
  NormalModel(
    title: '鍒锋柊婊戝姩璺濈',
    leading: const Icon(Icons.refresh),
    getSubtitle: () => '褰撳墠婊戝姩璺濈: ${Pref.refreshDragPercentage}x',
    onTap: _showRefreshDragDialog,
  ),
  NormalModel(
    title: '鍒锋柊鎸囩ず鍣ㄩ珮搴?,
    leading: const Icon(Icons.height),
    getSubtitle: () => '褰撳墠鎸囩ず鍣ㄩ珮搴? ${Pref.refreshDisplacement}',
    onTap: _showRefreshDialog,
  ),
  const SwitchModel(
    title: '鏄剧ず浼氬憳褰╄壊寮瑰箷',
    leading: Icon(MdiIcons.gradientHorizontal),
    setKey: SettingBoxKey.showVipDanmaku,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '鍚堝苟寮瑰箷',
    subtitle: '鍚堝苟涓€娈垫椂闂村唴鑾峰彇鍒扮殑鐩稿悓寮瑰箷',
    leading: Icon(Icons.merge),
    setKey: SettingBoxKey.mergeDanmaku,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '鏄剧ず鐑棬鎺ㄨ崘',
    subtitle: '鐑棬椤甸潰鏄剧ず姣忓懆蹇呯湅绛夋帹鑽愬唴瀹瑰叆鍙?,
    leading: Icon(Icons.local_fire_department_outlined),
    setKey: SettingBoxKey.showHotRcmd,
    defaultVal: false,
    needReboot: true,
  ),
  if (kDebugMode || Platform.isAndroid)
    NormalModel(
      title: '闊抽噺鍧囪　',
      leading: const Icon(Icons.multitrack_audio),
      getSubtitle: () {
        final audioNormalization = AudioNormalization.getTitleFromConfig(
          Pref.audioNormalization,
        );
        String fallback = Pref.fallbackNormalization;
        if (fallback == '0') {
          fallback = '';
        } else {
          fallback =
              '锛屾棤鍙傛暟鏃?銆?{AudioNormalization.getTitleFromConfig(fallback)}銆?;
        }
        return '褰撳墠:銆?audioNormalization銆?fallback';
      },
      onTap: audioNormalization,
    ),
  NormalModel(
    title: '瓒呭垎杈ㄧ巼',
    leading: const Icon(Icons.stay_current_landscape_outlined),
    getSubtitle: () =>
        '褰撳墠:銆?{Pref.superResolutionType.label}銆峔n榛樿璁剧疆瀵圭暘鍓х敓鏁? 鍏朵粬瑙嗛榛樿鍏抽棴\n瓒呭垎杈ㄧ巼闇€瑕佸惎鐢ㄧ‖浠惰В鐮? 鑻ュ惎鐢ㄧ‖浠惰В鐮佸悗浠嶇劧涓嶇敓鏁? 灏濊瘯鍒囨崲纭欢瑙ｇ爜鍣ㄤ负 auto-copy',
    onTap: _showSuperResolutionDialog,
  ),
  const SwitchModel(
    title: '鎻愬墠鍒濆鍖栨挱鏀惧櫒',
    subtitle: '鐩稿鍑忓皯鎵嬪姩鎾斁鍔犺浇鏃堕棿',
    leading: Icon(Icons.play_circle_outlined),
    setKey: SettingBoxKey.preInitPlayer,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '棣栭〉鍒囨崲椤甸潰鍔ㄧ敾',
    leading: Icon(Icons.home_outlined),
    setKey: SettingBoxKey.mainTabBarView,
    defaultVal: false,
    needReboot: true,
  ),
  const SwitchModel(
    title: '鎼滅储寤鸿',
    leading: Icon(Icons.search),
    setKey: SettingBoxKey.searchSuggestion,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '璁板綍鎼滅储鍘嗗彶',
    leading: Icon(Icons.history),
    setKey: SettingBoxKey.recordSearchHistory,
    defaultVal: true,
  ),
  SwitchModel(
    title: '灞曠ず澶村儚/璇勮/鍔ㄦ€佽楗?,
    leading: const Icon(MdiIcons.stickerCircleOutline),
    setKey: SettingBoxKey.showDecorate,
    defaultVal: true,
    onChanged: (value) => PendantAvatar.showDecorate = value,
  ),
  SwitchModel(
    title: '鏄剧ず绮変笣鍕嬬珷',
    leading: const Icon(MdiIcons.medalOutline),
    setKey: SettingBoxKey.showMedal,
    defaultVal: true,
    onChanged: (value) => GlobalData().showMedal = value,
  ),
  SwitchModel(
    title: '棰勮 Live Photo',
    subtitle: '寮€鍚垯浠ヨ棰戝舰寮忛瑙?Live Photo锛屽惁鍒欓瑙堥潤鎬佸浘鐗?,
    leading: const Icon(Icons.image_outlined),
    setKey: SettingBoxKey.enableLivePhoto,
    defaultVal: true,
    onChanged: (value) => ImageModel.enableLivePhoto = value,
  ),
  const SwitchModel(
    title: '婊戝姩璺宠浆棰勮瑙嗛缂╃暐鍥?,
    leading: Icon(Icons.preview_outlined),
    setKey: SettingBoxKey.showSeekPreview,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '鏄剧ず楂樿兘杩涘害鏉?,
    subtitle: '楂樿兘杩涘害鏉″弽搴斾簡鍦ㄦ椂鍩熶笂锛屽崟浣嶆椂闂村唴寮瑰箷鍙戦€侀噺鐨勫彉鍖栬秼鍔?,
    leading: Icon(Icons.show_chart),
    setKey: SettingBoxKey.showDmChart,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '璁板綍璇勮',
    leading: Icon(Icons.message_outlined),
    setKey: SettingBoxKey.saveReply,
    defaultVal: true,
    needReboot: true,
  ),
  const SwitchModel(
    title: '鍙戣瘎鍙嶈瘓',
    subtitle: '鍙戦€佽瘎璁哄悗妫€鏌ヨ瘎璁烘槸鍚﹀彲瑙?,
    leading: Icon(CustomIcons.shield_reply),
    setKey: SettingBoxKey.enableCommAntifraud,
    defaultVal: false,
  ),
  if (Platform.isAndroid)
    const SwitchModel(
      title: '浣跨敤銆屽摂鍝╁彂璇勫弽璇堛€嶆鏌ヨ瘎璁?,
      leading: Icon(
        FontAwesomeIcons.b,
        size: 22,
      ),
      setKey: SettingBoxKey.biliSendCommAntifraud,
      defaultVal: false,
    ),
  const SwitchModel(
    title: '鍙戝竷/杞彂鍔ㄦ€佸弽璇?,
    subtitle: '鍙戝竷/杞彂鍔ㄦ€佸悗妫€鏌ュ姩鎬佹槸鍚﹀彲瑙?,
    leading: Icon(CustomIcons.shield_published),
    setKey: SettingBoxKey.enableCreateDynAntifraud,
    defaultVal: false,
  ),
  SwitchModel(
    title: '灞忚斀甯﹁揣鍔ㄦ€?,
    leading: const Icon(CustomIcons.shopping_bag_not_interested),
    setKey: SettingBoxKey.antiGoodsDyn,
    defaultVal: false,
    onChanged: (value) => DynamicsDataModel.antiGoodsDyn = value,
  ),
  SwitchModel(
    title: '灞忚斀甯﹁揣璇勮',
    leading: const Icon(CustomIcons.shopping_bag_not_interested),
    setKey: SettingBoxKey.antiGoodsReply,
    defaultVal: false,
    onChanged: (value) => ReplyGrpc.antiGoodsReply = value,
  ),
  SwitchModel(
    title: '渚ф粦鍏抽棴浜岀骇椤甸潰',
    leading: const Icon(CustomIcons.touch_app_rotate_270),
    setKey: SettingBoxKey.slideDismissReplyPage,
    defaultVal: Platform.isIOS,
    onChanged: (value) => CommonSlideMixin.slideDismissReplyPage = value,
  ),
  const SwitchModel(
    title: '鍚敤鍙屾寚缂╁皬瑙嗛',
    leading: Icon(Icons.pinch),
    setKey: SettingBoxKey.enableShrinkVideoSize,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '鍔ㄦ€?涓撴爮璇︽儏椤靛睍绀哄簳閮ㄦ搷浣滄爮',
    leading: Icon(Icons.more_horiz),
    setKey: SettingBoxKey.showDynActionBar,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '鍚敤鎷栨嫿瀛楀箷璋冩暣搴曢儴杈硅窛',
    leading: Icon(MdiIcons.dragVariant),
    setKey: SettingBoxKey.enableDragSubtitle,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '灞曠ず杩界暘鏃堕棿琛?,
    leading: Icon(MdiIcons.chartTimelineVariantShimmer),
    setKey: SettingBoxKey.showPgcTimeline,
    defaultVal: true,
    needReboot: true,
  ),
  SwitchModel(
    title: '闈欓粯涓嬭浇鍥剧墖',
    subtitle: '涓嶆樉绀轰笅杞?Loading 寮圭獥',
    leading: const Icon(Icons.download_for_offline_outlined),
    setKey: SettingBoxKey.silentDownImg,
    defaultVal: false,
    onChanged: (value) => ImageUtils.silentDownImg = value,
  ),
  SwitchModel(
    title: '闀挎寜/鍙抽敭鏄剧ず鍥剧墖鑿滃崟',
    leading: const Icon(Icons.menu),
    setKey: SettingBoxKey.enableImgMenu,
    defaultVal: false,
    onChanged: (value) => ImageGridView.enableImgMenu = value,
  ),
  SwitchModel(
    setKey: SettingBoxKey.feedBackEnable,
    onChanged: (value) {
      enableFeedback = value;
      feedBack();
    },
    leading: const Icon(Icons.vibration_outlined),
    title: '闇囧姩鍙嶉',
    subtitle: '璇风‘瀹氭墜鏈鸿缃腑宸插紑鍚渿鍔ㄥ弽棣?,
  ),
  const SwitchModel(
    title: '澶у閮藉湪鎼?,
    subtitle: '鏄惁灞曠ず銆屽ぇ瀹堕兘鍦ㄦ悳銆?,
    leading: Icon(Icons.data_thresholding_outlined),
    setKey: SettingBoxKey.enableHotKey,
    defaultVal: true,
  ),
  const SwitchModel(
    title: '鎼滅储鍙戠幇',
    subtitle: '鏄惁灞曠ず銆屾悳绱㈠彂鐜般€?,
    leading: Icon(Icons.search_outlined),
    setKey: SettingBoxKey.enableSearchRcmd,
    defaultVal: true,
  ),
  SwitchModel(
    title: '鎼滅储榛樿璇?,
    subtitle: '鏄惁灞曠ず鎼滅储妗嗛粯璁よ瘝',
    leading: const Icon(Icons.whatshot_outlined),
    setKey: SettingBoxKey.enableSearchWord,
    defaultVal: false,
    onChanged: (val) {
      try {
        final controller = Get.find<HomeController>()..enableSearchWord = val;
        if (val) {
          controller.querySearchDefault();
        } else {
          controller.defaultSearch.value = '';
        }
      } catch (_) {}
    },
  ),
  const SwitchModel(
    title: '蹇€熸敹钘?,
    subtitle: '鐐瑰嚮璁剧疆榛樿鏀惰棌澶筡n鐐规寜鏀惰棌鑷抽粯璁わ紝闀挎寜閫夋嫨鏂囦欢澶?,
    leading: Icon(Icons.bookmark_add_outlined),
    setKey: SettingBoxKey.enableQuickFav,
    onTap: _showFavDialog,
    defaultVal: false,
  ),
  SwitchModel(
    title: '璇勮鍖烘悳绱㈠叧閿瘝',
    subtitle: '灞曠ず璇勮鍖烘悳绱㈠叧閿瘝',
    leading: const Icon(Icons.search_outlined),
    setKey: SettingBoxKey.enableWordRe,
    defaultVal: false,
    onChanged: (value) => ReplyItemGrpc.enableWordRe = value,
  ),
  const SwitchModel(
    title: '鍚敤AI鎬荤粨',
    subtitle: '瑙嗛璇︽儏椤靛紑鍚疉I鎬荤粨',
    leading: Icon(Icons.engineering_outlined),
    setKey: SettingBoxKey.enableAi,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '娑堟伅椤电鐢?鏀跺埌鐨勮禐"鍔熻兘',
    subtitle: '绂佹鎵撳紑鍏ュ彛锛岄檷浣庣綉缁滅ぞ浜や緷璧?,
    leading: Icon(Icons.beach_access_outlined),
    setKey: SettingBoxKey.disableLikeMsg,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '榛樿灞曠ず璇勮鍖?,
    subtitle: '鍦ㄨ棰戣鎯呴〉榛樿鍒囨崲鑷宠瘎璁哄尯椤碉紙浠匱ab鍨嬪竷灞€锛?,
    leading: Icon(Icons.mode_comment_outlined),
    setKey: SettingBoxKey.defaultShowComment,
    defaultVal: false,
  ),
  const SwitchModel(
    title: '鍚敤HTTP/2',
    leading: Icon(Icons.swap_horizontal_circle_outlined),
    setKey: SettingBoxKey.enableHttp2,
    defaultVal: false,
    needReboot: true,
  ),
  const NormalModel(
    title: '杩炴帴閲嶈瘯娆℃暟',
    subtitle: '涓?鏃剁鐢?,
    leading: Icon(Icons.repeat),
    onTap: _showReplyCountDialog,
  ),
  const NormalModel(
    title: '杩炴帴閲嶈瘯闂撮殧',
    subtitle: '瀹為檯闂撮殧 = 闂撮殧 * 绗瑇娆￠噸璇?,
    leading: Icon(Icons.more_time_outlined),
    onTap: _showReplyDelayDialog,
  ),
  NormalModel(
    title: '璇勮灞曠ず',
    leading: const Icon(Icons.whatshot_outlined),
    getSubtitle: () => '褰撳墠浼樺厛灞曠ず銆?{Pref.replySortType.title}銆?,
    onTap: _showReplySortDialog,
  ),
  NormalModel(
    title: '鍔ㄦ€佸睍绀?,
    leading: const Icon(Icons.dynamic_feed_rounded),
    getSubtitle: () => '褰撳墠浼樺厛灞曠ず銆?{Pref.defaultDynamicType.label}銆?,
    onTap: _showDefDynDialog,
  ),
  SwitchModel(
    title: '鏄剧ず鍔ㄦ€佷簰鍔ㄥ唴瀹?,
    subtitle: '寮€鍚悗鍒欏湪鍔ㄦ€佸崱鐗囧簳閮ㄦ樉绀轰簰鍔ㄥ唴瀹癸紙濡傚叧娉ㄧ殑浜虹偣璧炪€佺儹璇勭瓑锛?,
    leading: const Icon(Icons.quickreply_outlined),
    setKey: SettingBoxKey.showDynInteraction,
    defaultVal: true,
    onChanged: (val) => ItemModulesModel.showDynInteraction = val,
  ),
  NormalModel(
    title: '鐢ㄦ埛椤甸粯璁ゅ睍绀篢AB',
    leading: const Icon(Icons.tab),
    getSubtitle: () => '褰撳墠浼樺厛灞曠ず銆?{Pref.memberTab.title}銆?,
    onTap: _showMemberTabDialog,
  ),
  SwitchModel(
    title: '鏄剧ずUP涓婚〉灏忓簵TAB',
    leading: const Icon(Icons.shop_outlined),
    setKey: SettingBoxKey.showMemberShop,
    defaultVal: false,
    onChanged: (value) => MemberTabType.showMemberShop = value,
  ),
  const SplitModel(
    normalModel: NormalModel.split(
      title: '璁剧疆浠ｇ悊',
      subtitle: '璁剧疆浠ｇ悊 host:port',
      leading: Icon(Icons.airplane_ticket_outlined),
    ),
    switchModel: SwitchModel.split(
      defaultVal: false,
      setKey: SettingBoxKey.enableSystemProxy,
      onTap: _showProxyDialog,
    ),
  ),
  NormalModel(
    title: '鏈€澶х紦瀛樺ぇ灏?,
    getSubtitle: () =>
        '褰撳墠鏈€澶х紦瀛樺ぇ灏? 銆?{CacheManager.formatSize(Pref.maxCacheSize)}銆?,
    leading: const Icon(Icons.delete_outlined),
    onTap: _showCacheDialog,
  ),
  SwitchModel(
    title: '妫€鏌ユ洿鏂?,
    subtitle: '姣忔鍚姩鏃舵鏌ユ槸鍚﹂渶瑕佹洿鏂?,
    leading: const Icon(Icons.system_update_alt),
    setKey: SettingBoxKey.autoUpdate,
    defaultVal: true,
    onChanged: (val) {
      if (val) {
        Update.checkUpdate(false);
      }
    },
  ),
];

Future<void> audioNormalization(
  BuildContext context,
  VoidCallback setState, {
  bool fallback = false,
}) async {
  final key = fallback
      ? SettingBoxKey.fallbackNormalization
      : SettingBoxKey.audioNormalization;
  final res = await showDialog<String>(
    context: context,
    builder: (context) {
      String audioNormalization = fallback
          ? Pref.fallbackNormalization
          : Pref.audioNormalization;
      Set<String> values = {
        '0',
        '1',
        if (!fallback) '2',
        audioNormalization,
        '3',
      };
      return SelectDialog<String>(
        title: fallback ? '鏈嶅姟鍣ㄦ棤loudnorm閰嶇疆鏃朵娇鐢? : '闊抽噺鍧囪　',
        toggleable: true,
        value: audioNormalization,
        values: values
            .map(
              (e) => (
                e,
                switch (e) {
                  '0' => AudioNormalization.disable.title,
                  '1' => AudioNormalization.dynaudnorm.title,
                  '2' => AudioNormalization.loudnorm.title,
                  '3' => AudioNormalization.custom.title,
                  _ => e,
                },
              ),
            )
            .toList(),
      );
    },
  );
  if (res != null && context.mounted) {
    if (res == '3') {
      String param = '';
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('鑷畾涔夊弬鏁?),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              const Text('绛夊悓浜?--lavfi-complex="[aid1] 鍙傛暟 [ao]"'),
              TextField(
                autofocus: true,
                onChanged: (value) => param = value,
              ),
            ],
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
              onPressed: () {
                Get.back();
                GStorage.setting.put(key, param);
                if (!fallback &&
                    PlPlayerController.loudnormRegExp.hasMatch(param)) {
                  audioNormalization(context, setState, fallback: true);
                }
                setState();
              },
              child: const Text('纭畾'),
            ),
          ],
        ),
      );
    } else {
      GStorage.setting.put(key, res);
      if (res == '2') {
        audioNormalization(context, setState, fallback: true);
      }
      setState();
    }
  }
}

void _showDownPathDialog(BuildContext context, VoidCallback setState) {
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      clipBehavior: Clip.hardEdge,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        DialogOption(
          onPressed: () {
            Get.back();
            Utils.copyText(downloadPath);
          },
          child: const Text('澶嶅埗', style: TextStyle(fontSize: 14)),
        ),
        DialogOption(
          onPressed: () {
            Get.back();
            final defPath = defDownloadPath;
            if (downloadPath == defPath) return;
            downloadPath = defPath;
            setState();
            Get.find<DownloadService>().initDownloadList();
            GStorage.setting.delete(SettingBoxKey.downloadPath);
          },
          child: const Text('閲嶇疆', style: TextStyle(fontSize: 14)),
        ),
        DialogOption(
          onPressed: () async {
            Get.back();
            final path = await FilePicker.getDirectoryPath();
            if (path == null || path == downloadPath) return;
            downloadPath = path;
            setState();
            Get.find<DownloadService>().initDownloadList();
            GStorage.setting.put(SettingBoxKey.downloadPath, path);
          },
          child: const Text('璁剧疆鏂拌矾寰?, style: TextStyle(fontSize: 14)),
        ),
      ],
    ),
  );
}

void _showDynDialog(BuildContext context) {
  String dynamicPeriod = Pref.dynamicPeriod.toString();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('妫€鏌ュ懆鏈?),
      content: TextFormField(
        autofocus: true,
        initialValue: dynamicPeriod,
        keyboardType: TextInputType.number,
        onChanged: (value) => dynamicPeriod = value,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(suffixText: 'min'),
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
          onPressed: () {
            try {
              final val = int.parse(dynamicPeriod);
              Get.back();
              GStorage.setting.put(SettingBoxKey.dynamicPeriod, val);
              Get.find<MainController>().dynamicPeriod = val * 60 * 1000;
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

void _showReplyLengthDialog(BuildContext context, VoidCallback setState) {
  String replyLengthLimit = ReplyItemGrpc.replyLengthLimit.toString();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('璇勮鎶樺彔琛屾暟'),
      content: TextFormField(
        autofocus: true,
        initialValue: replyLengthLimit,
        keyboardType: TextInputType.number,
        onChanged: (value) => replyLengthLimit = value,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(suffixText: '琛?),
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
              final val = int.parse(replyLengthLimit);
              Get.back();
              ReplyItemGrpc.replyLengthLimit = val == 0 ? null : val;
              await GStorage.setting.put(SettingBoxKey.replyLengthLimit, val);
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

void _showDmHeightDialog(BuildContext context, VoidCallback setState) {
  String danmakuLineHeight = Pref.danmakuLineHeight.toString();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('寮瑰箷琛岄珮'),
      content: TextFormField(
        autofocus: true,
        initialValue: danmakuLineHeight,
        keyboardType: const .numberWithOptions(decimal: true),
        onChanged: (value) => danmakuLineHeight = value,
        inputFormatters: FilteringText.decimal,
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
              final val = max(
                1.0,
                double.parse(danmakuLineHeight).toPrecision(1),
              );
              Get.back();
              await GStorage.setting.put(SettingBoxKey.danmakuLineHeight, val);
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

void _showTouchSlopDialog(BuildContext context, VoidCallback setState) {
  String initialValue = Pref.touchSlopH.toString();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('妯悜婊戝姩闃堝€?),
      content: TextFormField(
        autofocus: true,
        initialValue: initialValue,
        keyboardType: const .numberWithOptions(decimal: true),
        onChanged: (value) => initialValue = value,
        inputFormatters: FilteringText.decimal,
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
              final val = double.parse(initialValue);
              Get.back();
              touchSlopH = val;
              await GStorage.setting.put(SettingBoxKey.touchSlopH, val);
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

Future<void> _showRefreshDragDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: const Text('鍒锋柊婊戝姩璺濈'),
      min: 0.1,
      max: 0.5,
      divisions: 8,
      precise: 2,
      value: Pref.refreshDragPercentage,
      suffix: 'x',
    ),
  );
  if (res != null) {
    kDragContainerExtentPercentage = res;
    await GStorage.setting.put(SettingBoxKey.refreshDragPercentage, res);
    setState();
  }
}

Future<void> _showRefreshDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: const Text('鍒锋柊鎸囩ず鍣ㄩ珮搴?),
      min: 10.0,
      max: 100.0,
      divisions: 9,
      value: Pref.refreshDisplacement,
    ),
  );
  if (res != null) {
    displacement = res;
    await GStorage.setting.put(SettingBoxKey.refreshDisplacement, res);
    if (WidgetsBinding.instance.rootElement case final context?) {
      context.visitChildElements(_visitor);
    }
    setState();
  }
}

void _visitor(Element context) {
  if (!context.mounted) return;
  if (context.widget is RefreshIndicator) {
    context.markNeedsBuild();
  } else {
    context.visitChildren(_visitor);
  }
}

Future<void> _showSuperResolutionDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<SuperResolutionType>(
    context: context,
    builder: (context) => SelectDialog<SuperResolutionType>(
      title: '瓒呭垎杈ㄧ巼',
      value: Pref.superResolutionType,
      values: SuperResolutionType.values.map((e) => (e, e.label)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(
      SettingBoxKey.superResolutionType,
      res.index,
    );
    setState();
  }
}

Future<void> _showFavDialog(BuildContext context) async {
  if (Accounts.main.isLogin) {
    final res = await FavHttp.allFavFolders(Accounts.main.mid);
    if (res case Success(:final response)) {
      final list = response.list;
      if (list == null || list.isEmpty) {
        return;
      }
      final quickFavId = Pref.quickFavId;
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          clipBehavior: Clip.hardEdge,
          title: const Text('閫夋嫨榛樿鏀惰棌澶?),
          contentPadding: const EdgeInsets.only(top: 5, bottom: 18),
          content: SingleChildScrollView(
            child: RadioGroup(
              onChanged: (value) {
                Get.back();
                GStorage.setting.put(SettingBoxKey.quickFavId, value);
                SmartDialog.showToast('璁剧疆鎴愬姛');
              },
              groupValue: quickFavId,
              child: Column(
                children: list
                    .map(
                      (item) => RadioListTile(
                        toggleable: true,
                        dense: true,
                        title: Text(item.title),
                        value: item.id,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      );
    } else {
      res.toast();
    }
  }
}

Future<void> _showReplyCountDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: const Text('杩炴帴閲嶈瘯娆℃暟'),
      min: 0,
      max: 8,
      divisions: 8,
      precise: 0,
      value: Pref.retryCount.toDouble(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.retryCount, res.toInt());
    setState();
    SmartDialog.showToast('閲嶅惎鐢熸晥');
  }
}

Future<void> _showReplyDelayDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: const Text('杩炴帴閲嶈瘯闂撮殧'),
      min: 0,
      max: 1000,
      divisions: 10,
      precise: 0,
      value: Pref.retryDelay.toDouble(),
      suffix: 'ms',
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.retryDelay, res.toInt());
    setState();
    SmartDialog.showToast('閲嶅惎鐢熸晥');
  }
}

Future<void> _showReplySortDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<ReplySortType>(
    context: context,
    builder: (context) => SelectDialog<ReplySortType>(
      title: '璇勮灞曠ず',
      value: Pref.replySortType,
      values: ReplySortType.values.take(2).map((e) => (e, e.title)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.replySortType, res.index);
    setState();
  }
}

Future<void> _showDefDynDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<DynamicsTabType>(
    context: context,
    builder: (context) => SelectDialog<DynamicsTabType>(
      title: '鍔ㄦ€佸睍绀?,
      value: Pref.defaultDynamicType,
      values: DynamicsTabType.values.take(4).map((e) => (e, e.label)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(
      SettingBoxKey.defaultDynamicType,
      res.index,
    );
    setState();
  }
}

Future<void> _showMemberTabDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<MemberTabType>(
    context: context,
    builder: (context) => SelectDialog<MemberTabType>(
      title: '鐢ㄦ埛椤甸粯璁ゅ睍绀篢AB',
      value: Pref.memberTab,
      values: MemberTabType.values.map((e) => (e, e.title)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.memberTab, res.index);
    setState();
  }
}

void _showProxyDialog(BuildContext context) {
  String systemProxyHost = Pref.systemProxyHost;
  String systemProxyPort = Pref.systemProxyPort;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('璁剧疆浠ｇ悊'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          TextFormField(
            initialValue: systemProxyHost,
            decoration: const InputDecoration(
              isDense: true,
              labelText: '璇疯緭鍏ost锛屼娇鐢?. 鍒嗗壊',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
            onChanged: (e) => systemProxyHost = e,
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: systemProxyPort,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              labelText: '璇疯緭鍏ort',
              border: OutlineInputBorder(borderRadius: .all(.circular(6))),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (e) => systemProxyPort = e,
          ),
        ],
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
          onPressed: () {
            Get.back();
            GStorage.setting.put(
              SettingBoxKey.systemProxyHost,
              systemProxyHost,
            );
            GStorage.setting.put(
              SettingBoxKey.systemProxyPort,
              systemProxyPort,
            );
          },
          child: const Text('纭'),
        ),
      ],
    ),
  );
}

void _showCacheDialog(BuildContext context, VoidCallback setState) {
  String valueStr = '';
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('鏈€澶х紦瀛樺ぇ灏?),
      content: TextField(
        autofocus: true,
        onChanged: (value) => valueStr = value,
        keyboardType: TextInputType.number,
        inputFormatters: FilteringText.decimal,
        decoration: const InputDecoration(suffixText: 'MB'),
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
              final val = num.parse(valueStr);
              Get.back();
              await GStorage.setting.put(
                SettingBoxKey.maxCacheSize,
                val * 1024 * 1024,
              );
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

