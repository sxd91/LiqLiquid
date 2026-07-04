import 'package:liqliquid/http/api.dart';
import 'package:liqliquid/http/error_msg.dart';
import 'package:liqliquid/http/init.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/models_new/follow/data.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:dio/dio.dart' show Options, Headers;

abstract final class FollowHttp {
  static Future<LoadingState<FollowData>> followings({
    int? vmid,
    int? pn,
    int ps = 20,
    String orderType = '', // ''=>鏈€杩戝叧娉紝'attention'=>鏈€甯歌闂?  }) async {
    final res = await Request().get(
      Api.followings,
      queryParameters: {
        'vmid': vmid,
        'pn': pn,
        'ps': ps,
        'order': 'desc',
        'order_type': orderType,
      },
    );
    if (res.data['code'] == 0) {
      return Success(FollowData.fromJson(res.data['data']));
    } else {
      return Error(errorMsg[res.data['code']] ?? res.data['message']);
    }
  }

  static Future<LoadingState<void>> sortFollowTag({
    required String tagids,
  }) async {
    final res = await Request().post(
      Api.sortFollowTag,
      queryParameters: {
        'x-bili-device-req-json':
            '{"platform":"web","device":"pc","spmid":"333.1387"}',
      },
      data: {
        'tagids': tagids,
        'csrf': Accounts.main.csrf,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return const Success(null);
    } else {
      return Error(res.data['message']);
    }
  }
}

