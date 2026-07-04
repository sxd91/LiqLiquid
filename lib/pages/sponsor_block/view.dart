import 'package:liqliquid/common/widgets/pair.dart';
import 'package:liqliquid/http/constants.dart';
import 'package:liqliquid/http/init.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/sponsor_block.dart';
import 'package:liqliquid/models/common/sponsor_block/segment_type.dart';
import 'package:liqliquid/models/common/sponsor_block/skip_type.dart';
import 'package:liqliquid/models_new/sponsor_block/user_info.dart';
import 'package:liqliquid/pages/setting/slide_color_picker.dart';
import 'package:liqliquid/utils/filtering_text.dart';
import 'package:liqliquid/utils/page_utils.dart';
import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:liqliquid/utils/storage_pref.dart';
import 'package:liqliquid/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SponsorBlockPage extends StatefulWidget {
  const SponsorBlockPage({super.key});

  @override
  State<SponsorBlockPage> createState() => _SponsorBlockPageState();
}

class _SponsorBlockPageState extends State<SponsorBlockPage> {
  final _url = 'https://github.com/hanydd/BilibiliSponsorBlock';
  final _textController = TextEditingController();
  double _blockLimit = Pref.blockLimit;
  final _blockSettings = Pref.blockSettings;
  final List<Color> _blockColor = Pref.blockColor;
  String _userId = Pref.blockUserID;
  bool _blockToast = Pref.blockToast;
  String _blockServer = Pref.blockServer;
  bool _blockTrack = Pref.blockTrack;
  final _serverStatus = Rxn<bool>();
  final _userInfo = LoadingState<UserInfo>.loading().obs;

  Box setting = GStorage.setting;

  @override
  void initState() {
    super.initState();
    _checkServerStatus();
    _getUserInfo();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _checkServerStatus() async {
    _serverStatus.value = (await SponsorBlock.uptimeStatus()).isSuccess;
  }

  Future<void> _getUserInfo() async {
    _userInfo.value = await SponsorBlock.userInfo(const [
      'viewCount',
      'minutesSaved',
      'segmentCount',
    ], userId: _userId);
  }

  Widget _blockLimitItem(
    ThemeData theme,
    TextStyle titleStyle,
    TextStyle subTitleStyle,
  ) => Builder(
    builder: (context) {
      return ListTile(
        dense: true,
        onTap: () {
          _textController.text = _blockLimit.toString();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('鏈€鐭墖娈垫椂闀?, style: titleStyle),
              content: TextFormField(
                keyboardType: const .numberWithOptions(decimal: true),
                controller: _textController,
                autofocus: true,
                decoration: const InputDecoration(suffixText: 's'),
                inputFormatters: FilteringText.decimal,
              ),
              actions: [
                TextButton(
                  onPressed: Get.back,
                  child: Text(
                    '鍙栨秷',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    try {
                      _blockLimit = double.parse(_textController.text);
                      Get.back();
                      setting.put(SettingBoxKey.blockLimit, _blockLimit);
                      (context as Element).markNeedsBuild();
                    } catch (e) {
                      SmartDialog.showToast(e.toString());
                    }
                  },
                  child: const Text('纭畾'),
                ),
              ],
            ),
          );
        },
        title: Text('鏈€鐭墖娈垫椂闀?, style: titleStyle),
        subtitle: Text(
          '蹇界暐鐭簬姝ゆ椂闀跨殑鐗囨',
          style: subTitleStyle,
        ),
        trailing: Text(
          '${_blockLimit}s',
          style: const TextStyle(fontSize: 13),
        ),
      );
    },
  );

  Widget _aboutItem(TextStyle titleStyle, TextStyle subTitleStyle) => ListTile(
    dense: true,
    title: Text('鍏充簬绌洪檷鍔╂墜', style: titleStyle),
    subtitle: Text(_url, style: subTitleStyle),
    onTap: () => PageUtils.launchURL(_url),
  );

  Widget _userIdItem(
    ThemeData theme,
    TextStyle titleStyle,
    TextStyle subTitleStyle,
  ) => Builder(
    builder: (context) {
      return ListTile(
        dense: true,
        title: Text('鐢ㄦ埛ID', style: titleStyle),
        subtitle: Text(_userId, style: subTitleStyle),
        onTap: () {
          final key = GlobalKey<FormFieldState<String>>();
          _textController.text = _userId;
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text('鐢ㄦ埛ID', style: titleStyle),
                content: TextFormField(
                  key: key,
                  minLines: 1,
                  maxLines: 4,
                  autofocus: true,
                  controller: _textController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d]+')),
                  ],
                  decoration: const InputDecoration(errorMaxLines: 2),
                  validator: (value) {
                    if ((value?.length ?? -1) < 30) {
                      return '鐢ㄦ埛ID瑕佹眰鑷冲皯涓?0涓瓧绗﹂暱搴︾殑绾瓧绗︿覆';
                    }
                    return null;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      _userId = Digest(
                        List.generate(16, (_) => Utils.random.nextInt(256)),
                      ).toString();
                      setting.put(SettingBoxKey.blockUserID, _userId);
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('闅忔満'),
                  ),
                  TextButton(
                    onPressed: Get.back,
                    child: Text(
                      '鍙栨秷',
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (key.currentState?.validate() == true) {
                        Get.back();
                        _userId = _textController.text;
                        setting.put(SettingBoxKey.blockUserID, _userId);
                        (context as Element).markNeedsBuild();
                      }
                    },
                    child: const Text('纭畾'),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );

  Widget _blockToastItem(TextStyle titleStyle) => Builder(
    builder: (context) {
      void update() {
        _blockToast = !_blockToast;
        setting.put(SettingBoxKey.blockToast, _blockToast);
        (context as Element).markNeedsBuild();
      }

      return ListTile(
        dense: true,
        onTap: update,
        title: Text(
          '鏄剧ず璺宠繃Toast',
          style: titleStyle,
        ),
        trailing: Transform.scale(
          alignment: Alignment.centerRight,
          scale: 0.8,
          child: Switch(
            value: _blockToast,
            onChanged: (val) => update(),
          ),
        ),
      );
    },
  );

  Widget _blockTrackItem(
    TextStyle titleStyle,
    TextStyle subTitleStyle,
  ) => Builder(
    builder: (context) {
      void update() {
        _blockTrack = !_blockTrack;
        setting.put(SettingBoxKey.blockTrack, _blockTrack);
        (context as Element).markNeedsBuild();
      }

      return ListTile(
        dense: true,
        onTap: update,
        title: Text(
          '璺宠繃娆℃暟缁熻璺熻釜',
          style: titleStyle,
        ),
        subtitle: Text(
          // from origin extension
          '姝ゅ姛鑳借拷韪偍璺宠繃浜嗗摢浜涚墖娈碉紝璁╃敤鎴风煡閬撲粬浠彁浜ょ殑鐗囨甯姪浜嗗灏戜汉銆傚悓鏃剁偣璧炰細浣滀负渚濇嵁锛岀‘淇濆瀮鍦句俊鎭笉浼氭薄鏌撴暟鎹簱銆傚湪鎮ㄦ瘡娆¤烦杩囩墖娈垫椂锛屾垜浠兘浼氬悜鏈嶅姟鍣ㄥ彂閫佷竴鏉℃秷鎭€傚笇鏈涘ぇ瀹跺紑鍚椤硅缃紝浠ヤ究寰楀埌鏇村噯纭殑缁熻鏁版嵁銆?)',
          style: subTitleStyle,
        ),
        trailing: Transform.scale(
          alignment: Alignment.centerRight,
          scale: 0.8,
          child: Switch(
            value: _blockTrack,
            onChanged: (val) => update(),
          ),
        ),
      );
    },
  );

  Widget _blockUserInfo(
    ThemeData theme,
    TextStyle titleStyle,
    TextStyle subTitleStyle,
  ) => Obx(
    () {
      return ListTile(
        dense: true,
        onTap: () {
          _userInfo.value = LoadingState.loading();
          _getUserInfo();
        },
        title: Text(
          '鎮ㄧ殑淇℃伅',
          style: titleStyle,
        ),
        subtitle: switch (_userInfo.value) {
          Loading() => const SizedBox.shrink(),
          Success<UserInfo>(:final response) => Text(
            response.toString(),
            style: subTitleStyle,
          ),
          Error(:final errMsg) => Text(
            errMsg ?? '鏈嶅姟鍣ㄩ敊璇?,
            style: subTitleStyle.copyWith(color: theme.colorScheme.error),
          ),
        },
      );
    },
  );

  Widget _blockServerItem(
    ThemeData theme,
    TextStyle titleStyle,
    TextStyle subTitleStyle,
  ) => Builder(
    builder: (context) {
      return ListTile(
        dense: true,
        onTap: () {
          _textController.text = _blockServer;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('鏈嶅姟鍣ㄥ湴鍧€', style: titleStyle),
              content: TextFormField(
                keyboardType: TextInputType.url,
                controller: _textController,
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    _blockServer = HttpString.sponsorBlockBaseUrl;
                    setting.put(SettingBoxKey.blockServer, _blockServer);
                    Request.accountManager.blockServer = _blockServer;
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('閲嶇疆'),
                ),
                TextButton(
                  onPressed: Get.back,
                  child: Text(
                    '鍙栨秷',
                    style: TextStyle(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    _blockServer = _textController.text;
                    setting.put(SettingBoxKey.blockServer, _blockServer);
                    Request.accountManager.blockServer = _blockServer;
                    _checkServerStatus();
                    _getUserInfo();
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('纭畾'),
                ),
              ],
            ),
          );
        },
        title: Text(
          '鏈嶅姟鍣ㄥ湴鍧€',
          style: titleStyle,
        ),
        subtitle: Text(
          _blockServer,
          style: subTitleStyle,
        ),
      );
    },
  );

  Widget _serverStatusItem(ThemeData theme, TextStyle titleStyle) => Obx(
    () {
      String status;
      Color? color;
      switch (_serverStatus.value) {
        case null:
          status = '鈥斺€?;
        case true:
          status = '姝ｅ父';
          color = theme.colorScheme.primary;
        case false:
          status = '閿欒';
          color = theme.colorScheme.error;
      }
      return ListTile(
        dense: true,
        onTap: () {
          _serverStatus.value = null;
          _checkServerStatus();
        },
        title: Text('鏈嶅姟鍣ㄧ姸鎬?, style: titleStyle),
        trailing: Text(
          status,
          style: TextStyle(fontSize: 13, color: color),
        ),
      );
    },
  );

  void onSelectColor(
    BuildContext context,
    int index,
    Color color,
    Pair<SegmentType, SkipType> item,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        title: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Color Picker ',
                style: TextStyle(fontSize: 15),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                style: const TextStyle(fontSize: 13, height: 1),
              ),
              TextSpan(
                text: ' ${item.first.title}',
                style: const TextStyle(fontSize: 13, height: 1),
              ),
            ],
          ),
        ),
        content: SlideColorPicker(
          color: color,
          showResetBtn: true,
          onChanged: (Color? color) {
            _blockColor[index] = color ?? item.first.color;
            setting.put(
              SettingBoxKey.blockColor,
              _blockColor
                  .map((item) => item.toARGB32().toRadixString(16).substring(2))
                  .toList(),
            );
            (context as Element).markNeedsBuild();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const titleStyle = TextStyle(fontSize: 15);

    final subTitleStyle = TextStyle(
      fontSize: 13,
      color: theme.colorScheme.outline,
    );

    final divider = Divider(
      height: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );

    final sliverDivider = SliverToBoxAdapter(child: divider);

    final dividerL = SliverToBoxAdapter(
      child: Divider(
        thickness: 16,
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('绌洪檷鍔╂墜')),
      body: CustomScrollView(
        slivers: [
          dividerL,
          SliverToBoxAdapter(child: _serverStatusItem(theme, titleStyle)),
          dividerL,
          SliverToBoxAdapter(
            child: _blockLimitItem(theme, titleStyle, subTitleStyle),
          ),
          sliverDivider,
          SliverToBoxAdapter(child: _blockToastItem(titleStyle)),
          sliverDivider,
          SliverToBoxAdapter(child: _blockTrackItem(titleStyle, subTitleStyle)),
          sliverDivider,
          SliverToBoxAdapter(
            child: _blockUserInfo(theme, titleStyle, subTitleStyle),
          ),
          dividerL,
          SliverList.separated(
            itemCount: _blockSettings.length,
            itemBuilder: (context, index) =>
                _buildItem(theme, index, _blockSettings[index]),
            separatorBuilder: (context, index) => divider,
          ),
          dividerL,
          SliverToBoxAdapter(
            child: _userIdItem(theme, titleStyle, subTitleStyle),
          ),
          sliverDivider,
          SliverToBoxAdapter(
            child: _blockServerItem(theme, titleStyle, subTitleStyle),
          ),
          dividerL,
          SliverToBoxAdapter(child: _aboutItem(titleStyle, subTitleStyle)),
          dividerL,
          SliverToBoxAdapter(
            child: SizedBox(
              height: 55 + MediaQuery.viewPaddingOf(context).bottom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    ThemeData theme,
    int index,
    Pair<SegmentType, SkipType> item,
  ) {
    return Builder(
      builder: (context) {
        Color color = _blockColor[index];
        final isDisable = item.second == SkipType.disable;
        return ListTile(
          dense: true,
          enabled: item.second != SkipType.disable,
          onTap: () => onSelectColor(context, index, color, item),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14, height: 1),
                    ),
                    TextSpan(
                      text: ' ${item.first.title}',
                      style: const TextStyle(fontSize: 14, height: 1),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (btnContext) {
                  return PopupMenuButton<SkipType>(
                    initialValue: item.second,
                    onSelected: (e) {
                      final updateItem = isDisable || e == SkipType.disable;
                      item.second = e;
                      setting.put(
                        SettingBoxKey.blockSettings,
                        _blockSettings.map((e) => e.second.index).toList(),
                      );
                      if (updateItem) {
                        (context as Element).markNeedsBuild();
                      } else {
                        (btnContext as Element).markNeedsBuild();
                      }
                    },
                    itemBuilder: (context) => SkipType.values
                        .map(
                          (item) => PopupMenuItem<SkipType>(
                            value: item,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text.rich(
                        style: TextStyle(
                          height: 1,
                          fontSize: 14,
                          color: isDisable
                              ? theme.colorScheme.outline.withValues(
                                  alpha: 0.7,
                                )
                              : theme.colorScheme.secondary,
                        ),
                        strutStyle: const StrutStyle(
                          height: 1,
                          leading: 0,
                          fontSize: 14,
                        ),
                        TextSpan(
                          children: [
                            TextSpan(text: item.second.label),
                            WidgetSpan(
                              alignment: .middle,
                              child: Icon(
                                size: 14,
                                MdiIcons.unfoldMoreHorizontal,
                                color: isDisable
                                    ? theme.colorScheme.outline.withValues(
                                        alpha: 0.7,
                                      )
                                    : theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          subtitle: Text(
            item.first.description,
            style: TextStyle(
              fontSize: 12,
              color: isDisable ? null : theme.colorScheme.outline,
            ),
          ),
        );
      },
    );
  }
}

