import 'package:liqliquid/common/constants.dart';
import 'package:liqliquid/common/dial_prefix.dart';
import 'package:liqliquid/common/widgets/loading_widget/http_error.dart';
import 'package:liqliquid/common/widgets/loading_widget/loading_widget.dart';
import 'package:liqliquid/common/widgets/scroll_physics.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/pages/login/controller.dart';
import 'package:liqliquid/utils/extension/size_ext.dart';
import 'package:liqliquid/utils/extension/widget_ext.dart';
import 'package:liqliquid/utils/image_utils.dart';
import 'package:liqliquid/utils/page_utils.dart';
import 'package:liqliquid/utils/platform_utils.dart';
import 'package:liqliquid/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginPageController _loginPageCtr = Get.put(LoginPageController());
  // 浜岀淮鐮佺敓鎴愭椂闂?  bool showPassword = false;
  GlobalKey globalKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginPageCtr.didChangeDependencies(context);
  }

  Widget loginByQRCode(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('浣跨敤 bilibili 瀹樻柟 App 鎵爜鐧诲綍'),
        const SizedBox(height: 20),
        Obx(
          () => Text(
            '鍓╀綑鏈夋晥鏃堕棿: ${_loginPageCtr.qrCodeLeftTime} 绉?,
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: theme.colorScheme.primaryFixedDim,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _loginPageCtr.refreshQRCode,
              icon: const Icon(Icons.refresh),
              label: const Text('鍒锋柊浜岀淮鐮?),
            ),
            TextButton.icon(
              onPressed: () async {
                SmartDialog.showLoading(msg: '姝ｅ湪鐢熸垚鎴浘');
                final boundary =
                    globalKey.currentContext!.findRenderObject()
                        as RenderRepaintBoundary;
                final image = await boundary.toImage(pixelRatio: 3);
                final byteData = await image.toByteData(format: .png);
                final pngBytes = byteData!.buffer.asUint8List();
                image.dispose();
                SmartDialog.dismiss();
                final picName =
                    "${Constants.appName}_loginQRCode_${_loginPageCtr.codeInfo.value.data.authCode.hashCode.toUnsigned(32).toRadixString(16)}";
                ImageUtils.saveByteImg(bytes: pngBytes, fileName: picName);
              },
              icon: const Icon(Icons.save),
              label: const Text('淇濆瓨鑷崇浉鍐?),
            ),
            if (kDebugMode || PlatformUtils.isMobile)
              TextButton.icon(
                onPressed: () => PageUtils.launchURL(
                  'bilibili://browser?url=${Uri.encodeComponent(_loginPageCtr.codeInfo.value.data.url)}',
                  mode: LaunchMode.externalNonBrowserApplication,
                ),
                icon: const Icon(Icons.open_in_browser_outlined),
                label: const Text('鍏朵粬搴旂敤鎵撳紑'),
              ),
          ],
        ),
        RepaintBoundary(
          key: globalKey,
          child: Obx(
            () => switch (_loginPageCtr.codeInfo.value) {
              Loading() => const SizedBox(
                height: 200,
                width: 200,
                child: m3eLoading,
              ),
              Success(:final response) => Container(
                width: 200,
                height: 200,
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: PrettyQrView.data(
                  data: response.url,
                  decoration: const PrettyQrDecoration(
                    shape: PrettyQrSquaresSymbol(
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              Error(:final errMsg) => HttpError(
                isSliver: false,
                errMsg: errMsg,
                onReload: _loginPageCtr.refreshQRCode,
              ),
            },
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Text(
            _loginPageCtr.statusQRCode.value,
            style: TextStyle(color: theme.colorScheme.secondaryFixedDim),
          ),
        ),
        Obx(
          () {
            final url = _loginPageCtr.codeInfo.value.dataOrNull?.url ?? '';
            return GestureDetector(
              onTap: () => Utils.copyText(
                url,
                toastText: '宸插鍒跺埌鍓创鏉匡紝鍙矘璐磋嚦宸茬櫥褰曠殑app绉佷俊澶勫彂閫侊紝鐒跺悗鐐瑰嚮宸插彂閫佺殑閾炬帴鎵撳紑',
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Text(
                  url,
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '璇峰姟蹇呭湪 ${Constants.appName} 寮€婧愪粨搴撶瓑鍙俊娓犻亾涓嬭浇瀹夎銆?,
            style: theme.textTheme.labelSmall!.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget loginByCookie(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        const Text('浣跨敤Cookie鐧诲綍'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '浣跨敤App绔疉pi瀹炵幇鐨勫姛鑳藉皢涓嶅彲鐢?,
            style: theme.textTheme.labelMedium!.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            minLines: 1,
            maxLines: 10,
            controller: _loginPageCtr.cookieTextController,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.cookie_outlined),
              border: const UnderlineInputBorder(),
              labelText: 'Cookie',
              suffixIcon: IconButton(
                onPressed: _loginPageCtr.cookieTextController.clear,
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _loginPageCtr.loginByCookie,
          icon: const Icon(Icons.login),
          label: const Text('鐧诲綍'),
        ),
      ],
    );
  }

  Widget loginByPassword(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('浣跨敤璐﹀彿瀵嗙爜鐧诲綍'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            controller: _loginPageCtr.usernameTextController,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.account_box),
              border: const UnderlineInputBorder(),
              labelText: '璐﹀彿',
              hintText: '閭/鎵嬫満鍙?,
              suffixIcon: IconButton(
                onPressed: _loginPageCtr.usernameTextController.clear,
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            obscureText: !showPassword,
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            controller: _loginPageCtr.passwordTextController,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.password),
              border: const UnderlineInputBorder(),
              labelText: '瀵嗙爜',
              suffixIcon: IconButton(
                onPressed: _loginPageCtr.passwordTextController.clear,
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            Checkbox(
              value: showPassword,
              onChanged: (value) => setState(() => showPassword = value!),
            ),
            const Text('鏄剧ず瀵嗙爜'),
            const Spacer(),
            TextButton(
              onPressed: () {
                //https://passport.bilibili.com/h5-app/passport/login/findPassword
                //https://passport.bilibili.com/passport/findPassword
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    clipBehavior: Clip.hardEdge,
                    title: const Text('蹇樿瀵嗙爜锛?),
                    contentPadding: const EdgeInsets.fromLTRB(
                      0.0,
                      2.0,
                      0.0,
                      16.0,
                    ),
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
                        child: Text("璇曡瘯鎵爜銆佹墜鏈哄彿鐧诲綍锛屾垨閫夋嫨"),
                      ),
                      ListTile(
                        title: const Text(
                          '鎵惧洖瀵嗙爜锛堟墜鏈虹増锛?,
                        ),
                        leading: const Icon(Icons.smartphone_outlined),
                        subtitle: const Text(
                          'https://passport.bilibili.com/h5-app/passport/login/findPassword',
                        ),
                        dense: false,
                        onTap: () => Get
                          ..back()
                          ..toNamed(
                            '/webview',
                            parameters: {
                              'url':
                                  'https://passport.bilibili.com/h5-app/passport/login/findPassword',
                              'type': 'url',
                              'pageTitle': '蹇樿瀵嗙爜',
                            },
                          ),
                      ),
                      ListTile(
                        title: const Text(
                          '鎵惧洖瀵嗙爜锛堢數鑴戠増锛?,
                        ),
                        leading: const Icon(Icons.desktop_windows_outlined),
                        subtitle: const Text(
                          'https://passport.bilibili.com/pc/passport/findPassword',
                        ),
                        dense: false,
                        onTap: () => Get
                          ..back()
                          ..toNamed(
                            '/webview',
                            parameters: {
                              'url':
                                  'https://passport.bilibili.com/pc/passport/findPassword',
                              'type': 'url',
                              'pageTitle': '蹇樿瀵嗙爜',
                              'uaType': 'pc',
                            },
                          ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('蹇樿瀵嗙爜'),
            ),
            const SizedBox(width: 20),
          ],
        ),
        OutlinedButton.icon(
          onPressed: _loginPageCtr.loginByPassword,
          icon: const Icon(Icons.login),
          label: const Text('鐧诲綍'),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '鏍规嵁 bilibili 瀹樻柟鐧诲綍鎺ュ彛瑙勮寖锛屽瘑鐮佸皢鍦ㄦ湰鍦板姞鐩愩€佸姞瀵嗗悗浼犺緭銆俓n'
            '鐩愪笌鍏挜鍧囩敱瀹樻柟鎻愪緵锛涗互 RSA/ECB/PKCS1Padding 鏂瑰紡鍔犲瘑銆俓n'
            '璐﹀彿瀵嗙爜浠呯敤浜庤鐧诲綍鎺ュ彛锛屼笉浜堜繚瀛橈紱鏈湴浠呭瓨鍌ㄧ櫥褰曞嚟璇併€俓n'
            '璇峰姟蹇呭湪 ${Constants.appName} 寮€婧愪粨搴撶瓑鍙俊娓犻亾涓嬭浇瀹夎銆?,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall!.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget loginBySmS(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('浣跨敤鎵嬫満鐭俊楠岃瘉鐮佺櫥褰?),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: DecoratedBox(
            decoration: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Builder(
                  builder: (context) {
                    return PopupMenuButton(
                      padding: EdgeInsets.zero,
                      tooltip:
                          '閫夋嫨鍥介檯鍐犵爜锛?
                          '褰撳墠涓?{_loginPageCtr.selectedCountryCodeId.cname}锛?
                          '+${_loginPageCtr.selectedCountryCodeId.countryId}',
                      onSelected: (item) {
                        _loginPageCtr.selectedCountryCodeId = item;
                        (context as Element).markNeedsBuild();
                      },
                      initialValue: _loginPageCtr.selectedCountryCodeId,
                      itemBuilder: (_) => Login.dialPrefix.map((item) {
                        return PopupMenuItem(
                          value: item,
                          child: Row(
                            children: [
                              Text(item.cname),
                              const Spacer(),
                              Text("+${item.countryId}"),
                            ],
                          ),
                        );
                      }).toList(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "+${_loginPageCtr.selectedCountryCodeId.countryId}",
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                SizedBox(
                  height: 24,
                  child: VerticalDivider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _loginPageCtr.telTextController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: '鎵嬫満鍙?,
                      suffixIcon: IconButton(
                        onPressed: _loginPageCtr.telTextController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: DecoratedBox(
            decoration: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _loginPageCtr.smsCodeTextController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.sms_outlined),
                      border: InputBorder.none,
                      labelText: '楠岃瘉鐮?,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                Obx(
                  () => TextButton.icon(
                    onPressed: _loginPageCtr.smsSendCooldown > 0
                        ? null
                        : _loginPageCtr.sendSmsCode,
                    icon: const Icon(Icons.send),
                    label: Text(
                      _loginPageCtr.smsSendCooldown > 0
                          ? '绛夊緟${_loginPageCtr.smsSendCooldown}绉?
                          : '鑾峰彇楠岃瘉鐮?,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _loginPageCtr.loginBySmsCode,
          icon: const Icon(Icons.login),
          label: const Text('鐧诲綍'),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '鎵嬫満鍙蜂粎鐢ㄤ簬 bilibili 瀹樻柟鍙戦€侀獙璇佺爜涓庣櫥褰曟帴鍙ｏ紝涓嶄簣淇濆瓨锛沑n'
            '鏈湴浠呭瓨鍌ㄧ櫥褰曞嚟璇併€俓n'
            '璇峰姟蹇呭湪 ${Constants.appName} 寮€婧愪粨搴撶瓑鍙俊娓犻亾涓嬭浇瀹夎銆?,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall!.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  late EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    padding =
        MediaQuery.viewPaddingOf(context).copyWith(top: 0) +
        const EdgeInsets.only(bottom: 25);
    final isLandscape = !MediaQuery.sizeOf(context).isPortrait;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '鍏抽棴',
          icon: const Icon(Icons.close_outlined),
          onPressed: Get.back,
        ),
        title: Row(
          children: [
            const Text('鐧诲綍'),
            if (isLandscape)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TabBar(
                    isScrollable: true,
                    dividerHeight: 0,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.password), Text(' 瀵嗙爜')],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.sms_outlined), Text(' 鐭俊')],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.qr_code), Text(' 鎵爜')],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cookie_outlined),
                            Text(' Cookie'),
                          ],
                        ),
                      ),
                    ],
                    controller: _loginPageCtr.tabController,
                  ),
                ),
              ),
          ],
        ),
        bottom: !isLandscape
            ? TabBar(
                tabs: const [
                  Tab(icon: Icon(Icons.password), text: '瀵嗙爜'),
                  Tab(icon: Icon(Icons.sms_outlined), text: '鐭俊'),
                  Tab(icon: Icon(Icons.qr_code), text: '鎵爜'),
                  Tab(icon: Icon(Icons.cookie_outlined), text: 'Cookie'),
                ],
                controller: _loginPageCtr.tabController,
              )
            : null,
      ),
      body: NotificationListener<ScrollStartNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.horizontal) {
            FocusScope.of(context).unfocus();
          }
          return false;
        },
        child: tabBarView(
          controller: _loginPageCtr.tabController,
          children: [
            tabViewOuter(loginByPassword(theme)),
            tabViewOuter(loginBySmS(theme)),
            tabViewOuter(loginByQRCode(theme)),
            tabViewOuter(loginByCookie(theme)),
          ],
        ),
      ),
    );
  }

  Widget tabViewOuter(Widget child) {
    return SingleChildScrollView(
      padding: padding,
      child: child.constraintWidth(),
    );
  }
}

