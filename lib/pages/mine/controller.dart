import 'package:liqliquid/http/fav.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/user.dart';
import 'package:liqliquid/models/common/account_type.dart';
import 'package:liqliquid/models/common/theme/theme_type.dart';
import 'package:liqliquid/models/user/info.dart';
import 'package:liqliquid/models/user/stat.dart';
import 'package:liqliquid/models_new/fav/fav_folder/data.dart';
import 'package:liqliquid/pages/common/common_data_controller.dart';
import 'package:liqliquid/services/account_service.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:liqliquid/utils/accounts/account.dart';
import 'package:liqliquid/utils/extension/scroll_controller_ext.dart';
import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:liqliquid/utils/storage_pref.dart';
import 'package:liqliquid/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MineController extends CommonDataController<FavFolderData, FavFolderData>
    with AccountMixin {
  @override
  AccountService accountService = Get.find<AccountService>();

  int? favFolderCount;

  // 鐢ㄦ埛淇℃伅 澶村儚銆佹樀绉般€乴v
  final Rx<UserInfoData> userInfo = UserInfoData().obs;
  // 鐢ㄦ埛鐘舵€?鍔ㄦ€併€佸叧娉ㄣ€佺矇涓?
  final Rx<UserStat> userStat = const UserStat().obs;

  final Rx<ThemeType> themeType = Pref.themeType.obs;

  ThemeType get nextThemeType =>
      ThemeType.values[(themeType.value.index + 1) % ThemeType.values.length];

  static RxBool anonymity =
      (Accounts.account.isNotEmpty && !Accounts.heartbeat.isLogin).obs;

  late final list =
      <({IconData icon, double size, String title, VoidCallback onTap})>[
        (
          size: 23,
          icon: MdiIcons.folderDownloadOutline,
          title: '绂荤嚎缂撳瓨',
          onTap: () => Get.toNamed('/download'),
        ),
        (
          size: 23,
          icon: Icons.history,
          title: '瑙傜湅璁板綍',
          onTap: () {
            if (isLogin) {
              Get.toNamed('/history');
            }
          },
        ),
        (
          size: 20,
          icon: Icons.subscriptions_outlined,
          title: '鎴戠殑璁㈤槄',
          onTap: () {
            if (isLogin) {
              Get.toNamed('/subscription');
            }
          },
        ),
        (
          size: 21,
          icon: Icons.watch_later_outlined,
          title: '绋嶅悗鍐嶇湅',
          onTap: () {
            if (isLogin) {
              Get.toNamed('/later');
            }
          },
        ),
      ];

  @override
  void onInit() {
    super.onInit();
    UserInfoData? userInfoCache = Pref.userInfoCache;
    if (userInfoCache != null) {
      userInfo.value = userInfoCache;
      queryData();
      queryUserInfo();
    }
  }

  bool get isLogin {
    if (!accountService.isLogin.value) {
      // SmartDialog.showToast('璐﹀彿鏈櫥褰?);
      return false;
    }
    return true;
  }

  Future<void> queryUserInfo() async {
    final res = await UserHttp.userInfo();
    if (res case Success(:final response)) {
      if (response.isLogin == true) {
        userInfo.value = response;
        if (response != Pref.userInfoCache) {
          GStorage.userInfo.put('userInfoCache', response);
        }
        accountService
          ..face.value = response.face!
          ..isLogin.value = true;
      } else {
        _onLogoutMain();
        return;
      }
    } else {
      final errMsg = res.toString();
      SmartDialog.showToast(errMsg);
      if (errMsg == '璐﹀彿鏈櫥褰?) {
        _onLogoutMain();
        return;
      }
    }
    queryUserStatOwner();
  }

  void _onLogoutMain() => Accounts.deleteAll({Accounts.main});

  Future<void> queryUserStatOwner() async {
    final res = await UserHttp.userStatOwner();
    if (res case Success(:final response)) {
      userStat.value = response;
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<FavFolderData> response) {
    favFolderCount = response.response.count;
    loadingState.value = response;
    return true;
  }

  @override
  Future<LoadingState<FavFolderData>> customGetData() {
    return FavHttp.userfavFolder(
      pn: 1,
      ps: 20,
      mid: Accounts.main.mid,
    );
  }

  static void onChangeAnonymity() {
    if (Accounts.account.isEmpty) {
      SmartDialog.showToast('璇峰厛鐧诲綍');
      return;
    }
    final newVal = !anonymity.value;
    anonymity.value = newVal;
    if (newVal) {
      SmartDialog.dismiss();
      SmartDialog.show<bool>(
        clickMaskDismiss: false,
        usePenetrate: true,
        displayTime: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
        builder: (context) {
          final theme = Theme.of(context);
          final style = TextStyle(
            color: theme.colorScheme.onSecondaryContainer,
          );
          return ColoredBox(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: EdgeInsets.only(
                top: 15,
                left: 20,
                right: 20,
                bottom: MediaQuery.viewPaddingOf(context).bottom + 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(MdiIcons.incognito, size: 20),
                      const SizedBox(width: 10),
                      Text('宸茶繘鍏ユ棤鐥曟ā寮?, style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '鎼滅储涓嶆惡甯﹁韩浠戒俊鎭痋n'
                    '涓嶄骇鐢熸煡璇㈡垨鎾斁璁板綍\n'
                    '鐐硅禐绛夊叾瀹冩搷浣滀笉鍙楀奖鍝峔n'
                    '鎾斁杩涘害淇℃伅璺熼殢瑙嗛鍙栨祦\n'
                    '(鍓嶅線闅愮璁剧疆浜嗚В璇︽儏)',
                    style: theme.textTheme.bodySmall,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          SmartDialog.dismiss(result: true);
                          SmartDialog.showToast('宸茶涓烘案涔呮棤鐥曟ā寮?);
                        },
                        child: Text('淇濆瓨涓烘案涔?, style: style),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          SmartDialog.dismiss();
                          SmartDialog.showToast('宸茶涓轰复鏃舵棤鐥曟ā寮?);
                        },
                        child: Text('浠呮湰娆★紙榛樿锛?, style: style),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ).then((res) {
        if (res == false) {
          return;
        }
        res == true
            ? Accounts.set(AccountType.heartbeat, AnonymousAccount())
            : Accounts.accountMode[AccountType.heartbeat.index] =
                  AnonymousAccount();
      });
    } else {
      Accounts.set(AccountType.heartbeat, Accounts.main);
      SmartDialog.dismiss(result: false);
      SmartDialog.show(
        clickMaskDismiss: false,
        usePenetrate: true,
        displayTime: const Duration(seconds: 1),
        alignment: Alignment.bottomCenter,
        builder: (context) {
          final theme = Theme.of(context);
          return ColoredBox(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: EdgeInsets.only(
                top: 15,
                left: 20,
                right: 20,
                bottom: MediaQuery.viewPaddingOf(context).bottom + 15,
              ),
              child: Row(
                children: [
                  const Icon(MdiIcons.incognitoOff, size: 20),
                  const SizedBox(width: 10),
                  Text('宸查€€鍑烘棤鐥曟ā寮?, style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void onChangeTheme() {
    final newVal = nextThemeType;
    themeType.value = newVal;
    GStorage.setting.put(SettingBoxKey.themeMode, newVal.index);
    Get.changeThemeMode(ThemeUtils.themeMode = newVal.toThemeMode);
  }

  void push(String name) {
    late final mid = userInfo.value.mid;
    if (isLogin && mid != null) {
      Get.toNamed('/$name?mid=$mid');
    }
  }

  void onLogin([bool longPress = false]) {
    if (!accountService.isLogin.value || longPress) {
      Get.toNamed('/loginPage');
    } else {
      Get.toNamed('/member?mid=${userInfo.value.mid}');
    }
  }

  @override
  Future<void> onRefresh({bool isManual = true}) {
    if (!accountService.isLogin.value) {
      return Future.syncValue(null);
    }
    queryUserInfo();
    return super.onRefresh().whenComplete(() {
      if (isManual) {
        scrollController.jumpToTop();
      }
    });
  }

  @override
  void onChangeAccount(bool isLogin) {
    if (isLogin) {
      onRefresh();
    } else {
      userInfo.value = UserInfoData();
      userStat.value = const UserStat();
      loadingState.value = LoadingState.loading();
    }
  }
}

