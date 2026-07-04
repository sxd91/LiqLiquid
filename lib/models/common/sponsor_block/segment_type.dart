// ignore_for_file: constant_identifier_names

import 'dart:ui';

import 'package:liqliquid/models/common/sponsor_block/action_type.dart';

enum SegmentType {
  sponsor(
    '璧炲姪/鎭伴キ',
    '璧炲姪',
    '浠樿垂鎺ㄥ箍銆佹帹鑽愬拰鐩存帴骞垮憡銆備笉鏄嚜鎴戞帹骞挎垨鍏嶈垂鎻愬強浠栦滑鍠滄鐨勫晢鍝?鍒涗綔鑰?缃戠珯/浜у搧銆?,
    Color(0xFF00d400),
    [
      ActionType.skip,
      ActionType.mute,
      ActionType.full,
    ],
  ),
  selfpromo(
    '鏃犲伩/鑷垜鎺ㄥ箍',
    '鎺ㄥ箍',
    '绫讳技浜?鈥滆禐鍔╁箍鍛娾€?锛屼絾鏃犳姤閰垨鏄嚜鎴戞帹骞裤€傚寘鎷湁鍏冲晢鍝併€佹崘璧犵殑閮ㄥ垎鎴栧悎浣滆€呯殑淇℃伅銆?,
    Color(0xFFffff00),
    [
      ActionType.skip,
      ActionType.mute,
      ActionType.full,
    ],
  ),
  exclusive_access(
    '鐙璁块棶/鎶㈠厛浣撻獙',
    '鍝佺墝鍚堜綔',
    '浠呯敤浜庡鏁翠釜瑙嗛杩涜鏍囪銆傞€傜敤浜庡睍绀篣P涓诲厤璐规垨鑾峰緱琛ヨ创鍚庝娇鐢ㄧ殑浜у搧銆佹湇鍔℃垨鍦哄湴鐨勮棰戙€?,
    Color(0xFF008a5c),
    [ActionType.full],
  ),
  interaction(
    '涓夎繛/浜掑姩鎻愰啋',
    '涓夎繛鎻愰啋',
    '瑙嗛涓棿绠€鐭彁閱掕浼楁潵涓€閿笁杩炴垨鍏虫敞銆?濡傛灉鐗囨杈冮暱锛屾垨鏄湁鍏蜂綋鍐呭锛屽垯搴斿垎绫讳负鑷垜鎺ㄥ箍銆?,
    Color(0xFFcc00ff),
    [
      ActionType.skip,
      ActionType.mute,
    ],
  ),
  poi_highlight(
    '绮惧僵鏃跺埢/閲嶇偣',
    '绮惧僵鏃跺埢',
    '澶ч儴鍒嗕汉閮藉湪瀵绘壘鐨勭┖闄嶆椂闂淬€傜被浼间簬鈥滃皝闈㈠湪12:34鈥濈殑璇勮銆?,
    Color(0xFFff1684),
    [ActionType.poi],
  ),
  intro(
    '杩囧満/寮€鍦哄姩鐢?,
    '寮€鍦哄姩鐢?,
    '娌℃湁瀹為檯鍐呭鐨勯棿闅旂墖娈点€傚彲浠ユ槸鏆傚仠銆侀潤鎬佸抚鎴栭噸澶嶅姩鐢汇€備笉閫傜敤浜庡寘鍚唴瀹圭殑杩囧満銆?,
    Color(0xFF00ffff),
    [
      ActionType.skip,
      ActionType.mute,
    ],
  ),
  outro(
    '楦ｈ阿/缁撴潫鐢婚潰',
    '鐗囧熬',
    '鑷磋阿鐢婚潰鎴栫墖灏剧敾闈€備笉鍖呭惈鍐呭鐨勭粨灏俱€?,
    Color(0xFF0202ed),
    [
      ActionType.skip,
      ActionType.mute,
    ],
  ),
  preview(
    '鍥為【/姒傝',
    '棰勮',
    '灞曠ず姝よ棰戞垨鍚岀郴鍒楄棰戝皢鍑虹幇鐨勭敾闈㈤泦閿︼紝鐗囨涓墍鏈夊唴瀹归兘灏嗗湪涔嬪悗鐨勬鐗囦腑鍐嶆鍑虹幇銆?,
    Color(0xFF008fd6),
    [
      ActionType.skip,
      ActionType.mute,
    ],
  ),
  padding(
    '濉厖鍐呭/鍓嶉粦/鍚庨粦',
    '濉厖鍐呭',
    '鎼繍瑙嗛鐗囧ご鐗囧熬鐨勭函绮瑰～鍏呭唴瀹癸紝濡傞粦灞忔垨鏃犲叧鐢婚潰锛屼笌瑙嗛涓讳綋鍐呭鏃犲疄闄呮剰涔夊拰鍏宠仈銆?,
    Color(0xFF222222),
    [ActionType.skip],
  ),
  filler(
    '绂婚闂茶亰/鐜╃瑧',
    '绂婚',
    "浠呬綔涓哄～鍏呭唴瀹规垨澧炴坊瓒ｅ懗鑰屾坊鍔犵殑绂婚鐗囨锛岃繖浜涘唴瀹瑰鐞嗚В瑙嗛鐨勪富瑕佸唴瀹瑰苟闈炲繀闇€銆傝繖涓嶅寘鎷彁渚涜儗鏅俊鎭垨涓婁笅鏂囩殑鐗囨銆傝繖鏄竴涓潪甯告縺杩涚殑鍒嗙被锛岄€傜敤浜庡綋浣犱笉鎯崇湅'濞变箰鎬?鍐呭鐨勬椂鍊欍€?,
    Color(0xFF7300FF),
    [
      ActionType.skip,
      ActionType.mute,
    ],
  ),
  music_offtopic(
    '闊充箰:闈為煶涔愰儴鍒?,
    '闈為煶涔?,
    '浠呯敤浜庨煶涔愯棰戙€傛鍒嗙被鍙兘鐢ㄤ簬闊充箰瑙嗛涓湭鍖呮嫭浜庡叾浠栧垎绫荤殑閮ㄥ垎銆?,
    Color(0xFFff9900),
    [ActionType.skip],
  ),
  ;

  /// from https://github.com/hanydd/BilibiliSponsorBlock/blob/master/public/_locales/zh_CN/messages.json
  final String title;
  final String shortTitle;
  final String description;
  final Color color;
  final List<ActionType> toActionType;

  const SegmentType(
    this.title,
    this.shortTitle,
    this.description,
    this.color,
    this.toActionType,
  );
}

// List<SegmentType> _actionType2SegmentType(ActionType actionType) {
//   return switch (actionType) {
//     ActionType.skip => [
//         SegmentType.sponsor,
//         SegmentType.selfpromo,
//         SegmentType.interaction,
//         SegmentType.intro,
//         SegmentType.outro,
//         SegmentType.preview,
//         SegmentType.filler,
//       ],
//     ActionType.mute => [
//         SegmentType.sponsor,
//         SegmentType.selfpromo,
//         SegmentType.interaction,
//         SegmentType.intro,
//         SegmentType.outro,
//         SegmentType.preview,
//         SegmentType.music_offtopic,
//         SegmentType.filler,
//       ],
//     ActionType.full => [
//         SegmentType.sponsor,
//         SegmentType.selfpromo,
//         SegmentType.exclusive_access,
//       ],
//     ActionType.poi => [
//         SegmentType.poi_highlight,
//       ],
//   };
// }

