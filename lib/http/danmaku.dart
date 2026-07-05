import 'package:liqliquid/http/api.dart';
import 'package:liqliquid/http/init.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/models_new/danmaku/post.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:dio/dio.dart';

abstract final class DanmakuHttp {
  static Future<LoadingState<DanmakuPost>> shootDanmaku({
    int type = 1, //寮瑰箷绫婚€夋嫨(1锛氳棰戝脊骞?2锛氭极鐢诲脊骞?
    required int oid, // 瑙嗛cid
    required String msg, //寮瑰箷鏂囨湰(闀垮害灏忎簬 100 瀛楃)
    // 寮瑰箷绫诲瀷(1锛氭粴鍔ㄥ脊骞?4锛氬簳绔脊骞?5锛氶《绔脊骞?6锛氶€嗗悜寮瑰箷(涓嶈兘浣跨敤锛?7锛氶珮绾у脊骞?8锛氫唬鐮佸脊骞曪紙涓嶈兘浣跨敤锛?9锛欱AS寮瑰箷锛坧ool蹇呴』涓?锛?
    int mode = 1,
    // String? aid,// 绋夸欢avid
    // String? bvid,// bvid涓巃id蹇呴』鏈変竴涓?    required String bvid,
    int? progress, // 寮瑰箷鍑虹幇鍦ㄨ棰戝唴鐨勬椂闂达紙鍗曚綅涓烘绉掞紝榛樿涓?锛?    int? color, // 寮瑰箷棰滆壊(榛樿鐧借壊锛?6777215锛?    int? fontSize, // 寮瑰箷瀛楀彿锛堥粯璁?5锛?    int? pool, // 寮瑰箷姹犻€夋嫨锛?锛氭櫘閫氭睜 1锛氬瓧骞曟睜 2锛氱壒娈婃睜锛堜唬鐮?BAS寮瑰箷锛夐粯璁ゆ櫘閫氭睜锛?锛?    //int? rnd,// 褰撳墠鏃堕棿鎴?1000000锛堣嫢鏃犳椤癸紝鍒欏彂閫佸脊骞曞喎鍗存椂闂撮檺鍒朵负90s锛涜嫢鏈夋椤癸紝鍒欏彂閫佸脊骞曞喎鍗存椂闂撮檺鍒朵负5s锛?    bool colorful = false, //60001锛氫笓灞炴笎鍙樺僵鑹诧紙闇€瑕佷細鍛橈級
    int? checkboxType, //鏄惁甯?UP 韬唤鏍囪瘑锛?锛氭櫘閫氾紱4锛氬甫鏈夋爣璇嗭級
    // String? csrf,//CSRF Token锛堜綅浜?Cookie锛?Cookie 鏂瑰紡蹇呰
    // String? access_key,//	APP 鐧诲綍 Token		APP 鏂瑰紡蹇呰
  }) async {
    // 鏋勫缓鍙傛暟瀵硅薄
    // assert(aid != null || bvid != null);
    // assert(csrf != null || access_key != null);
    // 鏋勫缓鍙傛暟瀵硅薄
    final data = <String, Object>{
      'type': type,
      'oid': oid,
      'msg': msg,
      'mode': mode,
      //'aid': aid,
      'bvid': bvid,
      'progress': ?progress,
      'color': ?colorful ? 16777215 : color,
      'fontsize': ?fontSize,
      'pool': ?pool,
      'rnd': DateTime.now().microsecondsSinceEpoch,
      'colorful': ?colorful ? 60001 : null,
      'checkbox_type': ?checkboxType,
      'csrf': Accounts.main.csrf,
      // 'access_key': access_key,
    };

    final res = await Request().post(
      Api.shootDanmaku,
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (res.data['code'] == 0) {
      return Success(DanmakuPost.fromJson(res.data['data']));
    } else {
      return Error(res.data['message'], code: res.data['code']);
    }
  }

  static Future<LoadingState<void>> danmakuLike({
    required bool isLike,
    required int cid,
    required int id,
  }) async {
    final data = {
      'op': isLike ? 1 : 2,
      'dmid': id,
      'oid': cid,
      'platform': 'web_player',
      'polaris_app_id': 100,
      'polaris_platform': 5,
      'spmid': '333.788.0.0',
      'from_spmid': '333.788.0.0',
      'statistics': '{"appId":100,"platform":5,"abtest":"","version":""}',
      'csrf': Accounts.main.csrf,
    };
    final res = await Request().post(
      Api.danmakuLike,
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return const Success(null);
    } else {
      return Error(res.data['message'], code: res.data['code']);
    }
  }

  static Future<LoadingState<void>> danmakuReport({
    required int reason,
    required int cid,
    required int id,
    bool block = false,
    String? content,
  }) async {
    final data = {
      'cid': cid,
      'dmid': id,
      'reason': reason,
      'block': block,
      'originCid': cid,
      'content': ?content,
      'polaris_app_id': 100,
      'polaris_platform': 5,
      'spmid': '333.788.0.0',
      'from_spmid': '333.788.0.0',
      'statistics': '{"appId":100,"platform":5,"abtest":"","version":""}',
      'csrf': Accounts.main.csrf,
    };
    final res = await Request().post(
      Api.danmakuReport,
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (res.data['code'] == 0) {
      return const Success(null);
    } else {
      return Error(res.data['message']);
    }

    /// res.data['data']['block']
    /// {
    ///       0: "涓炬姤宸叉彁浜?,
    ///       "-1": "涓炬姤澶辫触锛岃鍏堟縺娲昏处鍙枫€?,
    ///       "-2": "涓炬姤澶辫触锛岀郴缁熸嫆缁濆彈鐞嗘偍鐨勪妇鎶ヨ姹傘€?,
    ///       "-3": "涓炬姤澶辫触锛屾偍宸茬粡琚瑷€銆?,
    ///       "-4": "鎮ㄧ殑鎿嶄綔杩囦簬棰戠箒锛岃绋嶅悗鍐嶈瘯銆?,
    ///       "-5": "鎮ㄥ凡缁忎妇鎶ヨ繃杩欐潯寮瑰箷浜嗐€?,
    ///       "-6": "涓炬姤澶辫触锛岀郴缁熼敊璇€?
    /// }
  }

  static Future<LoadingState<String?>> danmakuRecall({
    required int cid,
    required int id,
  }) async {
    final data = {
      'dmid': id,
      'cid': cid,
      'type': 1,
      'csrf': Accounts.main.csrf,
    };
    final res = await Request().post(
      Api.danmakuRecall,
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return Success(res.data['message']);
    } else {
      return Error(res.data['message']);
    }
  }

  static Future<LoadingState<String?>> danmakuEditState({
    required int oid,
    required Iterable<int> ids,
    required int state,
  }) async {
    /// 0: 鍙栨秷鍒犻櫎
    /// 1锛氬垹闄ゅ脊骞?    /// 2锛氬脊骞曚繚鎶?    /// 3锛氬彇娑堜繚鎶?
    final data = {
      'dmids': ids.join(','),
      'oid': oid,
      'state': state,
      'type': 1,
      'csrf': Accounts.main.csrf,
    };
    final res = await Request().post(
      Api.danmakuRecall,
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return Success(res.data['message']);
    } else {
      return Error(res.data['message']);
    }
  }
}

