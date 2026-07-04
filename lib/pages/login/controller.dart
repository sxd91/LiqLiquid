import 'dart:async';
import 'dart:io';

import 'package:liqliquid/common/dial_prefix.dart';
import 'package:liqliquid/common/widgets/button/icon_button.dart';
import 'package:liqliquid/common/widgets/radio_widget.dart';
import 'package:liqliquid/http/init.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/login.dart';
import 'package:liqliquid/models/common/account_type.dart';
import 'package:liqliquid/models/login/model.dart';
import 'package:liqliquid/pages/login/geetest/geetest_webview_dialog.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:liqliquid/utils/accounts/account.dart';
import 'package:liqliquid/utils/platform_utils.dart';
import 'package:liqliquid/utils/theme_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class LoginPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final TextEditingController telTextController = TextEditingController();
  final TextEditingController usernameTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController smsCodeTextController = TextEditingController();
  final TextEditingController cookieTextController = TextEditingController();

  late final codeInfo =
      LoadingState<({String authCode, String url})>.loading().obs;

  late final TabController tabController;

  late final CaptchaDataModel captchaData = CaptchaDataModel();
  late final RxInt qrCodeLeftTime = 180.obs;
  late final RxString statusQRCode = ''.obs;

  late var selectedCountryCodeId = Login.dialPrefix.first;
  late String captchaKey = '';
  late final RxInt smsSendCooldown = 0.obs;
  late int smsSendTimestamp = 0;

  // 瀹氭椂鍣?  Timer? qrCodeTimer;
  Timer? smsSendCooldownTimer;

  bool _isReq = false;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this)
      ..addListener(_handleTabChange);
  }

  @override
  void onClose() {
    tabController
      ..removeListener(_handleTabChange)
      ..dispose();
    qrCodeTimer?.cancel();
    smsSendCooldownTimer?.cancel();
    telTextController.dispose();
    usernameTextController.dispose();
    passwordTextController.dispose();
    smsCodeTextController.dispose();
    cookieTextController.dispose();
    super.onClose();
  }

  Future<void> refreshQRCode() async {
    final res = await LoginHttp.getHDcode();
    if (res case Success(:final response)) {
      qrCodeTimer?.cancel();
      codeInfo.value = res;
      qrCodeTimer = Timer.periodic(const Duration(milliseconds: 1000), (t) {
        final left = 180 - t.tick;
        if (left <= 0) {
          t.cancel();
          statusQRCode.value = '浜岀淮鐮佸凡杩囨湡锛岃鍒锋柊';
          qrCodeLeftTime.value = 0;
          return;
        }
        qrCodeLeftTime.value = left;
        if (_isReq || tabController.index != 2) return;

        _isReq = true;
        LoginHttp.codePoll(response.authCode).then((value) async {
          _isReq = false;
          if (value['status']) {
            t.cancel();
            statusQRCode.value = '鎵爜鎴愬姛';
            await setAccount(
              value['data'],
              value['data']['cookie_info']['cookies'],
            );
            Get.back();
          } else if (value['code'] == 86038) {
            t.cancel();
            qrCodeLeftTime.value = 0;
          } else {
            statusQRCode.value = value['msg'];
          }
        });
      });
    }
  }

  void _handleTabChange() {
    if (tabController.index == 2) {
      if (qrCodeTimer == null || !qrCodeTimer!.isActive) {
        refreshQRCode();
      }
    }
  }

  // 鐢宠鏋侀獙楠岃瘉鐮?  void getCaptcha(
    String geeGt,
    String geeChallenge,
    VoidCallback onSuccess,
  ) {
    GeetestWebviewDialog.geetest(geeGt, geeChallenge).then((res) {
      if (res is Map) {
        captchaData
          ..validate = res['geetest_validate']
          ..seccode = res['geetest_seccode']
          ..geetest = GeetestData(
            challenge: res['geetest_challenge'],
            gt: geeGt,
          );
        SmartDialog.showToast('楠岃瘉鎴愬姛');
        onSuccess();
      }
    });
  }

  static String validateCookie(String cookie) {
    return cookie
        .split(';')
        .where((e) {
          try {
            Cookie.fromSetCookieValue(e.trim());
          } catch (_) {
            return false;
          }
          return true;
        })
        .join(';');
  }

  // cookie鐧诲綍
  Future<void> loginByCookie() async {
    if (cookieTextController.text.isEmpty) {
      SmartDialog.showToast('cookie涓嶈兘涓虹┖');
      return;
    }
    try {
      final result = await Request().get(
        "/x/member/web/account",
        options: Options(
          headers: {
            "cookie": validateCookie(cookieTextController.text),
          },
          extra: {'account': AnonymousAccount()},
        ),
      );
      if (result.data['code'] == 0) {
        try {
          await LoginAccount(
            BiliCookieJar.fromJson(
              Map.fromEntries(
                cookieTextController.text.split(';').map((item) {
                  final list = item.split('=');
                  return MapEntry(list.first, list.skip(1).join());
                }),
              ),
            ),
            null,
            null,
          ).onChange();
          if (!Accounts.main.isLogin) await switchAccountDialog(Get.context!);
          SmartDialog.showToast('鐧诲綍鎴愬姛');
          Get.back();
        } catch (e) {
          SmartDialog.showToast("鐧诲綍澶辫触: $e");
        }
      } else {
        SmartDialog.showToast("鍝斿摡鍝斿摡鐧诲綍宸插け鏁堬紝璇烽噸鏂扮櫥褰?);
      }
    } catch (e) {
      SmartDialog.showToast("鑾峰彇鍝斿摡鍝斿摡鐢ㄦ埛淇℃伅澶辫触锛屽彲鍓嶅線璐﹀彿绠＄悊閲嶈瘯");
    }
  }

  // app绔瘑鐮佺櫥褰?  Future<void> loginByPassword() async {
    String username = usernameTextController.text;
    String password = passwordTextController.text;
    if (username.isEmpty || password.isEmpty) {
      SmartDialog.showToast('鐢ㄦ埛鍚嶆垨瀵嗙爜涓嶈兘涓虹┖');
      return;
    }
    // if ((passwordFormKey.currentState as FormState).validate()) {
    final webKeyRes = await LoginHttp.getWebKey();
    if (!webKeyRes['status']) {
      SmartDialog.showToast(webKeyRes['msg']);
      return;
    }
    String salt = webKeyRes['data']['hash'];
    String key = webKeyRes['data']['key'];
    final res = await LoginHttp.loginByPwd(
      username: username,
      password: password,
      key: key,
      salt: salt,
      geeValidate: captchaData.validate,
      geeSeccode: captchaData.seccode,
      geeChallenge: captchaData.geetest?.challenge,
      recaptchaToken: captchaData.token,
    );
    if (res['status']) {
      final data = res['data'];
      if (data == null) {
        SmartDialog.showToast('鐧诲綍寮傚父锛屾帴鍙ｆ湭杩斿洖鏁版嵁锛?{res["msg"]}');
        return;
      }
      if (data['status'] == 2) {
        SmartDialog.showToast(data['message']);
        // return;
        //{"code":0,"message":"0","ttl":1,"data":{"status":2,"message":"鏈鐧诲綍鐜瀛樺湪椋庨櫓, 闇€浣跨敤鎵嬫満鍙疯繘琛岄獙璇佹垨缁戝畾","url":"https://passport.bilibili.com/h5-app/passport/risk/verify?tmp_token=9e785433940891dfa78f033fb7928181&request_id=e5a6d6480df04097870be56c6e60f7ef&source=risk","token_info":null,"cookie_info":null,"sso":null,"is_new":false,"is_tourist":false}}
        String url = data['url']!;
        Uri currentUri = Uri.parse(url);
        final safeCenterRes = await LoginHttp.safeCenterGetInfo(
          tmpCode: currentUri.queryParameters['tmp_token']!,
        );
        //{"code":0,"message":"0","ttl":1,"data":{"account_info":{"hide_tel":"111*****111","hide_mail":"aaa*****aaaa.aaa","bind_mail":true,"bind_tel":true,"tel_verify":true,"mail_verify":true,"unneeded_check":false,"bind_safe_question":false,"mid":1111111},"member_info":{"nickname":"xxxxxxx","face":"https://i0.hdslb.com/bfs/face/xxxxxxx.jpg","realname_status":false},"sns_info":{"bind_google":false,"bind_fb":false,"bind_apple":false,"bind_qq":true,"bind_weibo":true,"bind_wechat":false},"account_safe":{"score":80}}}
        if (!safeCenterRes['status']) {
          SmartDialog.showToast(
            "鑾峰彇瀹夊叏楠岃瘉淇℃伅澶辫触锛岃灏濊瘯鍏跺畠鐧诲綍鏂瑰紡\n"
            "(${safeCenterRes['code']}) ${safeCenterRes['msg']}",
          );
          return;
        }
        Map<String, String> accountInfo = {
          "hindTel": safeCenterRes['data']['account_info']!["hide_tel"],
          "hindMail": safeCenterRes['data']['account_info']!["hide_mail"],
        };
        if (!safeCenterRes['data']['account_info']!['tel_verify']) {
          SmartDialog.showToast("褰撳墠璐﹀彿鏈敮鎸佹墜鏈哄彿楠岃瘉锛岃灏濊瘯鍏跺畠鐧诲綍鏂瑰紡");
          return;
        }

        TextEditingController textFieldController = TextEditingController();
        String captchaKey = '';
        showDialog(
          context: Get.context!,
          builder: (context) => AlertDialog(
            titlePadding: const EdgeInsets.only(
              left: 16,
              top: 18,
              right: 16,
              bottom: 12,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            title: const Text(
              "鏈鐧诲綍闇€瑕侀獙璇佹偍鐨勬墜鏈哄彿",
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  accountInfo['hindTel'] ?? '鏈兘鑾峰彇鎵嬫満鍙?,
                  style: const TextStyle(fontSize: 18),
                ),
                // 甯︽湁娓呯┖鎸夐挳鐨勮緭鍏ユ
                TextField(
                  style: const TextStyle(fontSize: 15),
                  controller: textFieldController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "璇疯緭鍏ョ煭淇￠獙璇佺爜",
                    hintStyle: const TextStyle(fontSize: 15),
                    suffixIcon: iconButton(
                      icon: const Icon(Icons.clear),
                      size: 32,
                      onPressed: textFieldController.clear,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      maxHeight: 32,
                      maxWidth: 32,
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("鍙戦€侀獙璇佺爜"),
                onPressed: () async {
                  final preCaptureRes = await LoginHttp.preCapture();
                  if (!preCaptureRes['status'] ||
                      preCaptureRes['data'] == null) {
                    SmartDialog.showToast(
                      "鑾峰彇楠岃瘉鐮佸け璐ワ紝璇峰皾璇曞叾瀹冪櫥褰曟柟寮廫n"
                      "(${preCaptureRes['code']}) ${preCaptureRes['msg']} ${preCaptureRes['data']}",
                    );
                  }
                  String geeGt = preCaptureRes['data']['gee_gt'];
                  String geeChallenge = preCaptureRes['data']['gee_challenge'];
                  captchaData.token = preCaptureRes['data']['recaptcha_token'];
                  if (!isGeeArgumentValid(geeGt, geeChallenge)) {
                    SmartDialog.showToast(
                      "鑾峰彇鏋侀獙鍙傛暟涓虹┖锛岃灏濊瘯鍏跺畠鐧诲綍鏂瑰紡\n"
                      "(${preCaptureRes['code']}) ${preCaptureRes['msg']} ${preCaptureRes['data']}",
                    );
                    return;
                  }

                  getCaptcha(
                    geeGt,
                    geeChallenge,
                    () async {
                      final safeCenterSendSmsCodeRes =
                          await LoginHttp.safeCenterSmsCode(
                            tmpCode: currentUri.queryParameters['tmp_token']!,
                            geeChallenge: geeChallenge,
                            geeSeccode: captchaData.seccode,
                            geeValidate: captchaData.validate,
                            recaptchaToken: captchaData.token,
                            refererUrl: url,
                          );
                      if (!safeCenterSendSmsCodeRes['status']) {
                        SmartDialog.showToast(
                          "鍙戦€佺煭淇￠獙璇佺爜澶辫触锛岃灏濊瘯鍏跺畠鐧诲綍鏂瑰紡\n"
                          "(${safeCenterSendSmsCodeRes['code']}) ${safeCenterSendSmsCodeRes['msg']}",
                        );
                        return;
                      }
                      SmartDialog.showToast("鐭俊楠岃瘉鐮佸凡鍙戦€侊紝璇锋煡鏀?);
                      captchaKey =
                          safeCenterSendSmsCodeRes['data']['captcha_key'];
                    },
                  );
                },
              ),
              TextButton(
                onPressed: Get.back,
                child: Text(
                  "鍙栨秷",
                  style: TextStyle(color: ThemeUtils.theme.colorScheme.outline),
                ),
              ),
              TextButton(
                onPressed: () async {
                  String? code = textFieldController.text;
                  if (code.isEmpty) {
                    SmartDialog.showToast("璇疯緭鍏ョ煭淇￠獙璇佺爜");
                    return;
                  }
                  final safeCenterSmsVerifyRes =
                      await LoginHttp.safeCenterSmsVerify(
                        code: code,
                        tmpCode: currentUri.queryParameters['tmp_token']!,
                        requestId: currentUri.queryParameters['request_id']!,
                        source: currentUri.queryParameters['source']!,
                        captchaKey: captchaKey,
                        refererUrl: url,
                      );
                  if (!safeCenterSmsVerifyRes['status']) {
                    SmartDialog.showToast(
                      "楠岃瘉鐭俊楠岃瘉鐮佸け璐ワ紝璇峰皾璇曞叾瀹冪櫥褰曟柟寮廫n"
                      "(${safeCenterSmsVerifyRes['code']}) ${safeCenterSmsVerifyRes['msg']}",
                    );
                    return;
                  }
                  SmartDialog.showToast("楠岃瘉鎴愬姛锛屾鍦ㄧ櫥褰?);
                  final oauth2AccessTokenRes =
                      await LoginHttp.oauth2AccessToken(
                        code: safeCenterSmsVerifyRes['data']['code'],
                      );
                  if (!oauth2AccessTokenRes['status']) {
                    SmartDialog.showToast(
                      "鐧诲綍澶辫触锛岃灏濊瘯鍏跺畠鐧诲綍鏂瑰紡\n"
                      "(${oauth2AccessTokenRes['code']}) ${oauth2AccessTokenRes['msg']}",
                    );
                    return;
                  }
                  final data = oauth2AccessTokenRes['data'];
                  if (data['token_info'] == null ||
                      data['cookie_info'] == null) {
                    SmartDialog.showToast(
                      '鐧诲綍寮傚父锛屾帴鍙ｆ湭杩斿洖韬唤淇℃伅锛屽彲鑳芥槸鍥犱负璐﹀彿椋庢帶锛岃灏濊瘯鍏跺畠鐧诲綍鏂瑰紡銆俓n${oauth2AccessTokenRes["msg"]}锛孿n $data',
                    );
                    return;
                  }
                  SmartDialog.showToast('姝ｅ湪淇濆瓨韬唤淇℃伅');
                  await setAccount(
                    data['token_info'],
                    data['cookie_info']['cookies'],
                  );
                  Get
                    ..back()
                    ..back();
                },
                child: const Text("纭"),
              ),
            ],
          ),
        ).whenComplete(textFieldController.dispose);

        return;
      }
      if (data['token_info'] == null || data['cookie_info'] == null) {
        SmartDialog.showToast(
          '鐧诲綍寮傚父锛屾帴鍙ｆ湭杩斿洖韬唤淇℃伅锛屽彲鑳芥槸鍥犱负璐﹀彿椋庢帶锛岃灏濊瘯鍏跺畠鐧诲綍鏂瑰紡銆俓n${res["msg"]}锛孿n $data',
        );
        return;
      }
      SmartDialog.showToast('姝ｅ湪淇濆瓨韬唤淇℃伅');
      await setAccount(data['token_info'], data['cookie_info']['cookies']);
      Get.back();
    } else {
      // handle login result
      switch (res['code']) {
        case 0:
          // login success
          break;
        case -105:
          String captureUrl = res['data']['url'];
          Uri captureUri = Uri.parse(captureUrl);
          captchaData.token = captureUri.queryParameters['recaptcha_token']!;
          String geeGt = captureUri.queryParameters['gee_gt']!;
          String geeChallenge = captureUri.queryParameters['gee_challenge']!;

          getCaptcha(geeGt, geeChallenge, loginByPassword);
          break;
        default:
          SmartDialog.showToast(res['msg']);
          // login failed
          break;
      }
    }
    // }
  }

  // 鐭俊楠岃瘉鐮佺櫥褰?  Future<void> loginBySmsCode() async {
    if (telTextController.text.isEmpty) {
      SmartDialog.showToast('鎵嬫満鍙蜂笉鑳戒负绌?);
      return;
    }
    if (captchaKey.isEmpty) {
      SmartDialog.showToast('璇峰厛鐐瑰嚮鑾峰彇楠岃瘉鐮?);
      return;
    }
    if (smsCodeTextController.text.isEmpty) {
      SmartDialog.showToast('楠岃瘉鐮佷笉鑳戒负绌?);
      return;
    }
    if (DateTime.now().millisecondsSinceEpoch - smsSendTimestamp >
        1000 * 60 * 5) {
      SmartDialog.showToast('楠岃瘉鐮佸凡杩囨湡锛岃閲嶆柊鑾峰彇');
      return;
    }
    final webKeyRes = await LoginHttp.getWebKey();
    if (!webKeyRes['status']) {
      SmartDialog.showToast(webKeyRes['msg']);
      return;
    }
    String key = webKeyRes['data']['key'];
    final res = await LoginHttp.loginBySms(
      tel: telTextController.text,
      code: smsCodeTextController.text,
      captchaKey: captchaKey,
      cid: selectedCountryCodeId.countryId,
      key: key,
    );
    if (res['status']) {
      SmartDialog.showToast('鐧诲綍鎴愬姛');
      final data = res['data'];
      await setAccount(data['token_info'], data['cookie_info']['cookies']);
      Get.back();
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  // app绔獙璇佺爜
  Future<void> sendSmsCode() async {
    if (telTextController.text.isEmpty) {
      SmartDialog.showToast('鎵嬫満鍙蜂笉鑳戒负绌?);
      return;
    }
    // String? guestId;
    // final webKeyRes = await LoginHttp.getWebKey();
    // if (!webKeyRes['status']) {
    //   SmartDialog.showToast(webKeyRes['msg']);
    // } else {
    //   String key = webKeyRes['data']['key'];
    //   final guestIdRes = await LoginHttp.getGuestId(key);
    //   if (!guestIdRes['status']) {
    //     SmartDialog.showToast(guestIdRes['msg']);
    //   } else {
    //     guestId = guestIdRes['data']['guest_id'];
    //   }
    // }
    // final preCaptureRes = await LoginHttp.preCapture();
    // if (!preCaptureRes['status']) {
    //   SmartDialog.showToast("鑾峰彇楠岃瘉鐮佸け璐ワ紝璇峰皾璇曞叾瀹冪櫥褰曟柟寮廫n"
    //       "(${preCaptureRes['code']}) ${preCaptureRes['msg']}");
    //   return;
    // }
    // String geeGt = preCaptureRes['data']['gee_gt']!;
    // String geeChallenge = preCaptureRes['data']['gee_challenge'];
    // captchaData.token = preCaptureRes['data']['recaptcha_token']!;

    // getCaptcha(geeGt, geeChallenge, () async {

    // final safeCenterSendSmsCodeRes =
    // await LoginHttp.safeCenterSmsCode(
    //   tmpCode: currentUri.queryParameters['tmp_token']!,
    //   geeChallenge: geeChallenge,
    //   geeSeccode: captchaData.seccode!,
    //   geeValidate: captchaData.validate!,
    //   recaptchaToken: captchaData.token!,
    //   refererUrl: url,
    // );
    // if (!safeCenterSendSmsCodeRes['status']) {
    //   SmartDialog.showToast("鍙戦€佺煭淇￠獙璇佺爜澶辫触锛岃灏濊瘯鍏跺畠鐧诲綍鏂瑰紡\n"
    //       "(${safeCenterSendSmsCodeRes['code']}) ${safeCenterSendSmsCodeRes['msg']}");
    //   return;
    // }
    // SmartDialog.showToast("鐭俊楠岃瘉鐮佸凡鍙戦€侊紝璇锋煡鏀?);
    // captchaKey = safeCenterSendSmsCodeRes['data']['captcha_key'];

    final res = await LoginHttp.sendSmsCode(
      tel: telTextController.text,
      cid: selectedCountryCodeId.countryId,
      // deviceTouristId: guestId,
      geeValidate: captchaData.validate,
      geeSeccode: captchaData.seccode,
      geeChallenge: captchaData.geetest?.challenge,
      recaptchaToken: captchaData.token,
    );
    if (res['status']) {
      SmartDialog.showToast('鍙戦€佹垚鍔?);
      smsSendTimestamp = DateTime.now().millisecondsSinceEpoch;
      smsSendCooldown.value = 60;
      captchaKey = res['data']['captcha_key'];
      smsSendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) {
        smsSendCooldown.value = 60 - timer.tick;
        if (smsSendCooldown <= 0) {
          smsSendCooldownTimer?.cancel();
          smsSendCooldown.value = 0;
        }
      });
    } else {
      // handle login result
      switch (res['code']) {
        case 0:
        case -105:
          String? captureUrl = res['data']?['recaptcha_url'];
          String? geeGt;
          String? geeChallenge;
          if (captureUrl != null && captureUrl.isNotEmpty) {
            Uri captureUri = Uri.parse(captureUrl);
            captchaData.token = captureUri.queryParameters['recaptcha_token'];
            geeGt = captureUri.queryParameters['gee_gt'];
            geeChallenge = captureUri.queryParameters['gee_challenge'];
          }

          if (!isGeeArgumentValid(geeGt, geeChallenge)) {
            if (kDebugMode) {
              debugPrint(
                '楠岃瘉淇℃伅閿欒锛?{res["msg"]}\n杩斿洖鍐呭锛?{res["data"]}锛屽皾璇曞彟涓€涓獙璇佺爜鎺ュ彛',
              );
            }
            final preCaptureRes = await LoginHttp.preCapture();
            if (!preCaptureRes['status'] || preCaptureRes['data'] == null) {
              SmartDialog.showToast(
                "鑾峰彇楠岃瘉鐮佸け璐ワ紝璇峰皾璇曞叾瀹冪櫥褰曟柟寮廫n"
                "(${preCaptureRes['code']}) ${preCaptureRes['msg']} ${preCaptureRes['data']}",
              );
              return;
            }
            geeGt = preCaptureRes['data']['gee_gt'];
            geeChallenge = preCaptureRes['data']['gee_challenge'];
            captchaData.token = preCaptureRes['data']['recaptcha_token'];
          }

          if (!isGeeArgumentValid(geeGt, geeChallenge)) {
            SmartDialog.showToast("鑾峰彇楠岃瘉鐮佸け璐ワ紝璇峰皾璇曞叾瀹冪櫥褰曟柟寮廫n");
            return;
          }

          getCaptcha(geeGt!, geeChallenge!, sendSmsCode);
          break;
        default:
          SmartDialog.showToast(res['msg']);
          break;
      }
    }
  }

  bool isGeeArgumentValid(String? geeGt, String? geeChallenge) {
    return geeGt?.isNotEmpty == true &&
        geeChallenge?.isNotEmpty == true &&
        captchaData.token?.isNotEmpty == true;
  }

  Future<void> setAccount(Map tokenInfo, List cookieInfo) async {
    final account = LoginAccount(
      BiliCookieJar.fromList(cookieInfo),
      tokenInfo['access_token'],
      tokenInfo['refresh_token'],
    );
    await Future.wait([account.onChange(), AnonymousAccount().delete()]);
    for (int i = 0; i < AccountType.values.length; i++) {
      if (Accounts.accountMode[i].mid == account.mid) {
        Accounts.accountMode[i] = account;
      }
    }
    if (Accounts.main.isLogin) {
      SmartDialog.showToast('鐧诲綍鎴愬姛');
    } else {
      SmartDialog.showToast('鐧诲綍鎴愬姛, 璇峰厛璁剧疆璐﹀彿妯″紡');
      await switchAccountDialog(Get.context!);
    }
  }

  static Future<void>? switchAccountDialog(BuildContext context) {
    if (Accounts.account.isEmpty) {
      SmartDialog.showToast('璇峰厛鐧诲綍');
      return Get.toNamed('/loginPage');
    }
    final colorScheme = ColorScheme.of(context);
    final selectAccount = List.of(Accounts.accountMode);
    final options = {
      AnonymousAccount(): '0',
      ...Accounts.account.toMap().map(
        (k, v) => MapEntry(v, k as String),
      ),
    };
    bool quickSelect = selectAccount.every((e) => e == selectAccount.first);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          crossAxisAlignment: .start,
          mainAxisAlignment: .spaceBetween,
          children: [
            Text.rich(
              style: const TextStyle(height: 1.5),
              TextSpan(
                children: [
                  const TextSpan(text: '璐﹀彿鍒囨崲'),
                  TextSpan(
                    text: '\nmid涓?鏃朵娇鐢ㄥ尶鍚?,
                    style: TextStyle(fontSize: 14, color: colorScheme.outline),
                  ),
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                visualDensity: .compact,
                tapTargetSize: .shrinkWrap,
              ),
              onPressed: () {
                quickSelect = !quickSelect;
                (context as Element).markNeedsBuild();
              },
              child: Text(quickSelect ? '璇︾粏' : '蹇€?),
            ),
          ],
        ),
        titlePadding: const .only(left: 22, top: 16, right: 22, bottom: 3),
        contentPadding: const .symmetric(vertical: 5),
        actionsPadding: const .only(left: 16, right: 16, bottom: 10),
        content: SingleChildScrollView(
          child: AnimatedSize(
            curve: Curves.easeIn,
            alignment: .topCenter,
            duration: const Duration(milliseconds: 200),
            child: quickSelect
                ? Builder(
                    builder: (context) => RadioGroup<Account>(
                      groupValue: selectAccount[0],
                      onChanged: (v) {
                        selectAccount.fillRange(0, selectAccount.length, v);
                        (context as Element).markNeedsBuild();
                      },
                      child: Column(
                        crossAxisAlignment: .start,
                        children: options.entries
                            .map(
                              (entry) => RadioWidget<Account>(
                                value: entry.key,
                                title: entry.value,
                                mainAxisSize: .max,
                                padding: PlatformUtils.isDesktop
                                    ? const .only(left: 12)
                                    : const .only(left: 12, top: 2, bottom: 2),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: .start,
                    children: AccountType.values
                        .map(
                          (e) => Builder(
                            builder: (context) => RadioGroup<Account>(
                              groupValue: selectAccount[e.index],
                              onChanged: (v) {
                                selectAccount[e.index] = v!;
                                (context as Element).markNeedsBuild();
                              },
                              child: WrapRadioOptionsGroup<Account>(
                                groupTitle: e.title,
                                options: options,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('鍙栨秷', style: TextStyle(color: colorScheme.outline)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              for (final type in AccountType.values) {
                final index = type.index;
                final account = quickSelect
                    ? selectAccount.first
                    : selectAccount[index];
                if (account != Accounts.accountMode[index]) {
                  Accounts.set(type, account);
                }
              }
            },
            child: const Text('纭畾'),
          ),
        ],
      ),
    );
  }
}

