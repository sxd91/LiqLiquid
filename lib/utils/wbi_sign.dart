// Wbi绛惧悕 鐢ㄤ簬鐢熸垚 REST API 璇锋眰涓殑 w_rid 鍜?wts 瀛楁
// https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/misc/sign/wbi.md
// import md5 from 'md5'
// import axios from 'axios'
import 'dart:async';
import 'dart:convert';

import 'package:liqliquid/http/api.dart';
import 'package:liqliquid/http/init.dart';
import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:liqliquid/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:hive_ce/hive.dart';

abstract final class WbiSign {
  static Box get _localCache => GStorage.localCache;
  static final RegExp _chrFilter = RegExp(r"[!\'\(\)\*]");
  static const _mixinKeyEncTab = <int>[
    46,
    47,
    18,
    2,
    53,
    8,
    23,
    32,
    15,
    50,
    10,
    31,
    58,
    3,
    45,
    35,
    27,
    43,
    5,
    49,
    33,
    9,
    42,
    19,
    29,
    28,
    14,
    39,
    12,
    38,
    41,
    13,
  ];

  static Future<String>? _future;

  // 瀵?imgKey 鍜?subKey 杩涜瀛楃椤哄簭鎵撲贡缂栫爜
  static String getMixinKey(String orig) {
    final codeUnits = orig.codeUnits;
    return String.fromCharCodes(_mixinKeyEncTab.map((i) => codeUnits[i]));
  }

  // 涓鸿姹傚弬鏁拌繘琛?wbi 绛惧悕
  static void encWbi(Map<String, Object> params, String mixinKey) {
    params['wts'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // 鎸夌収 key 閲嶆帓鍙傛暟
    final List<String> keys = params.keys.toList()..sort();
    final queryStr = keys
        .map(
          (i) =>
              '${Uri.encodeComponent(i)}=${Uri.encodeComponent(params[i].toString().replaceAll(_chrFilter, ''))}',
        )
        .join('&');
    params['w_rid'] = md5
        .convert(utf8.encode(queryStr + mixinKey))
        .toString(); // 璁＄畻 w_rid
  }

  static Future<String> _getWbiKeys() async {
    final resp = await Request().get(Api.userInfo);
    try {
      final wbiUrls = resp.data['data']['wbi_img'];

      final mixinKey = getMixinKey(
        Utils.getFileName(wbiUrls['img_url'], fileExt: false) +
            Utils.getFileName(wbiUrls['sub_url'], fileExt: false),
      );

      _localCache.put(LocalCacheKey.mixinKey, mixinKey);

      return mixinKey;
    } catch (_) {
      return '';
    }
  }

  static FutureOr<String> getWbiKeys() {
    final nowDate = DateTime.now();
    if (DateTime.fromMillisecondsSinceEpoch(
          _localCache.get(LocalCacheKey.timeStamp, defaultValue: 0) as int,
        ).day ==
        nowDate.day) {
      final String? mixinKey = _localCache.get(LocalCacheKey.mixinKey);
      if (mixinKey != null) return mixinKey;
      return _future ??= _getWbiKeys();
    } else {
      return _future = _localCache
          .put(LocalCacheKey.timeStamp, nowDate.millisecondsSinceEpoch)
          .then((_) => _getWbiKeys());
    }
  }

  static Future<Map<String, Object>> makSign(
    Map<String, Object> params,
  ) async {
    // params 涓洪渶瑕佸姞瀵嗙殑璇锋眰鍙傛暟
    final String mixinKey = await getWbiKeys();
    encWbi(params, mixinKey);
    return params;
  }
}

