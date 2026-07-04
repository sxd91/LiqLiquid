import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive_ce/hive.dart';

class SetDisplayMode extends StatefulWidget {
  const SetDisplayMode({super.key});

  @override
  State<SetDisplayMode> createState() => _SetDisplayModeState();
}

class _SetDisplayModeState extends State<SetDisplayMode> {
  List<DisplayMode> modes = <DisplayMode>[];
  DisplayMode? active;
  DisplayMode? preferred;

  Box setting = GStorage.setting;

  @override
  void initState() {
    super.initState();
    init();
  }

  // 鑾峰彇鎵€鏈夌殑mode
  Future<void> fetchAll() async {
    preferred = await FlutterDisplayMode.preferred;
    active = await FlutterDisplayMode.active;
    setting.put(SettingBoxKey.displayMode, preferred.toString());
    if (mounted) {
      setState(() {});
    }
  }

  // 鍒濆鍖杕ode/鎵嬪姩璁剧疆
  Future<void> init() async {
    try {
      modes = await FlutterDisplayMode.supported;
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint(e.toString());
    }

    final value = setting.get(SettingBoxKey.displayMode);
    if (value != null) {
      preferred = modes.firstWhereOrNull((e) => e.toString() == value);
    }

    preferred ??= DisplayMode.auto;

    FlutterDisplayMode.setPreferredMode(preferred!).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 100), fetchAll);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('灞忓箷甯х巼璁剧疆')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                MediaQuery.viewPaddingOf(context).copyWith(top: 0, bottom: 0) +
                const EdgeInsets.only(left: 25, top: 10, bottom: 5),
            child: Text(
              '娌℃湁鐢熸晥锛熼噸鍚痑pp璇曡瘯',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          Expanded(
            child: RadioGroup(
              onChanged: (DisplayMode? newMode) {
                FlutterDisplayMode.setPreferredMode(
                  newMode!,
                ).whenComplete(
                  () => Future.delayed(
                    const Duration(milliseconds: 100),
                    fetchAll,
                  ),
                );
              },
              groupValue: preferred,
              child: ListView.builder(
                itemCount: modes.length,
                itemBuilder: (context, index) {
                  final DisplayMode mode = modes[index];
                  return RadioListTile<DisplayMode>(
                    value: mode,
                    title: mode == DisplayMode.auto
                        ? const Text('鑷姩')
                        : Text('$mode${mode == active ? '  [绯荤粺]' : ''}'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

