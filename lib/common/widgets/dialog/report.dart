import 'package:liqliquid/common/widgets/radio_widget.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/utils/extension/string_ext.dart';
import 'package:liqliquid/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

Future<void> autoWrapReportDialog(
  BuildContext context,
  Map<String, Map<int, String>> options,
  Future<LoadingState> Function(int reasonType, String? reasonDesc, bool banUid)
  onSuccess, {
  bool ban = true,
}) {
  int? reasonType;
  String? reasonDesc;
  bool banUid = false;
  late final key = GlobalKey<FormFieldState<String>>();
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('涓炬姤'),
      titlePadding: const .only(left: 22, top: 16, right: 22),
      contentPadding: const .symmetric(vertical: 5),
      actionsPadding: const .only(left: 16, right: 16, bottom: 10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: Builder(
                  builder: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: .only(left: 22, right: 22, bottom: 5),
                        child: Text('璇烽€夋嫨涓炬姤鐨勭悊鐢憋細'),
                      ),
                      RadioGroup(
                        onChanged: (value) {
                          reasonType = value;
                          (context as Element).markNeedsBuild();
                        },
                        groupValue: reasonType,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: options.entries.map((entry) {
                            return WrapRadioOptionsGroup<int>(
                              groupTitle: entry.key,
                              options: entry.value,
                            );
                          }).toList(),
                        ),
                      ),
                      if (reasonType == 0)
                        Padding(
                          padding: const .only(left: 22, top: 5, right: 22),
                          child: TextFormField(
                            key: key,
                            autofocus: true,
                            minLines: 2,
                            maxLines: 4,
                            initialValue: reasonDesc,
                            decoration: const InputDecoration(
                              labelText: '涓哄府鍔╁鏍镐汉鍛樻洿蹇鐞嗭紝璇疯ˉ鍏呴棶棰樼被鍨嬪拰鍑虹幇浣嶇疆绛夎缁嗕俊鎭?,
                              border: OutlineInputBorder(),
                              contentPadding: .all(10),
                              labelStyle: TextStyle(fontSize: 14),
                              floatingLabelStyle: TextStyle(fontSize: 14),
                            ),
                            onChanged: (value) => reasonDesc = value,
                            validator: (value) =>
                                value.isNullOrEmpty ? '鐞嗙敱涓嶈兘涓虹┖' : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (ban)
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 6),
              child: CheckBoxText(
                text: '鎷夐粦璇ョ敤鎴?,
                onChanged: (value) => banUid = value,
              ),
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
          onPressed: () async {
            if (reasonType == null ||
                (reasonType == 0 && key.currentState?.validate() != true)) {
              return;
            }
            SmartDialog.showLoading();
            try {
              final res = await onSuccess(reasonType!, reasonDesc, banUid);
              SmartDialog.dismiss();
              if (res.isSuccess) {
                Get.back();
                SmartDialog.showToast('涓炬姤鎴愬姛');
              } else {
                res.toast();
              }
            } catch (e, s) {
              SmartDialog.dismiss();
              SmartDialog.showToast('鎻愪氦澶辫触锛?e');
              Utils.reportError(e, s);
            }
          },
          child: const Text('纭畾'),
        ),
      ],
    ),
  );
}

class CheckBoxText extends StatefulWidget {
  final String text;
  final ValueChanged<bool> onChanged;
  final bool selected;

  const CheckBoxText({
    super.key,
    required this.text,
    required this.onChanged,
    this.selected = false,
  });

  @override
  State<CheckBoxText> createState() => _CheckBoxTextState();
}

class _CheckBoxTextState extends State<CheckBoxText> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return InkWell(
      onTap: () {
        setState(() {
          _selected = !_selected;
          widget.onChanged(_selected);
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              size: 22,
              _selected
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank,
              color: _selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            Text(
              ' ${widget.text}',
              style: TextStyle(color: _selected ? colorScheme.primary : null),
            ),
          ],
        ),
      ),
    );
  }
}

abstract final class ReportOptions {
  // from https://s1.hdslb.com/bfs/seed/jinkela/comment-h5/static/js/605.chunks.js
  static Map<String, Map<int, String>> get commentReport => const {
    '杩濆弽娉曞緥娉曡': {9: '杩濇硶杩濊', 2: '鑹叉儏', 10: '浣庝織', 12: '璧屽崥璇堥獥', 23: '杩濇硶淇℃伅澶栭摼'},
    '璋ｈ█绫讳笉瀹炰俊鎭?: {19: '娑夋斂璋ｈ█', 22: '铏氬亣涓嶅疄淇℃伅', 20: '娑夌ぞ浼氫簨浠惰埃瑷€'},
    '渚电姱涓汉鏉冪泭': {7: '浜鸿韩鏀诲嚮', 15: '渚电姱闅愮'},
    '鏈夊绀惧尯鐜': {
      1: '鍨冨溇骞垮憡',
      4: '寮曟垬',
      5: '鍓ч€?,
      3: '鍒峰睆',
      8: '瑙嗛涓嶇浉鍏?,
      18: '杩濊鎶藉',
      17: '闈掑皯骞翠笉鑹俊鎭?,
    },
    '鍏朵粬': {0: '鍏朵粬'},
  };

  static Map<String, Map<int, String>> get dynamicReport => const {
    '': {
      4: '鍨冨溇骞垮憡',
      8: '寮曟垬',
      1: '鑹叉儏',
      5: '浜鸿韩鏀诲嚮',
      3: '杩濇硶淇℃伅',
      9: '娑夋斂璋ｈ█',
      10: '娑夌ぞ浼氫簨浠惰埃瑷€',
      12: '铏氬亣涓嶅疄淇℃伅',
      13: '杩濇硶淇℃伅澶栭摼',
      0: '鍏朵粬',
    },
  };

  static Map<String, Map<int, String>> get danmakuReport => const {
    '': {
      1: '杩濇硶杩濈',
      2: '鑹叉儏浣庝織',
      3: '璧屽崥璇堥獥',
      4: '浜鸿韩鏀诲嚮',
      5: '渚电姱闅愮',
      6: '鍨冨溇骞垮憡',
      7: '寮曟垬',
      8: '鍓ч€?,
      9: '鎭舵剰鍒峰睆',
      10: '瑙嗛鏃犲叧',
      12: '闈掑皯骞翠笉鑹俊鎭?,
      13: '杩濇硶淇℃伅澶栭摼',
      0: '鍏跺畠', // 11
    },
  };

  static Map<String, Map<int, String>> get liveDanmakuReport => const {
    '': {
      1: '杩濇硶杩濊',
      2: '浣庝織鑹叉儏',
      3: '鍨冨溇骞垮憡',
      4: '杈遍獋寮曟垬',
      5: '鏀挎不鏁忔劅',
      6: '闈掑皯骞翠笉鑹俊鎭?,
      7: '鍏朵粬', // avoid show form
    },
  };

  static Map<String, Map<int, String>> get imMsgReport => const {
    '': {
      1: '鑹叉儏浣庝織',
      2: '鏀挎不鏁忔劅',
      3: '杩濇硶鏈夊',
      4: '骞垮憡楠氭壈',
      5: '浜鸿韩鏀诲嚮',
      6: '璇堥獥',
      0: '鍏朵粬闂',
    },
  };
}

