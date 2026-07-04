import 'package:liqliquid/common/style.dart';
import 'package:liqliquid/pages/webdav/webdav.dart';
import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:liqliquid/utils/storage_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class WebDavSettingPage extends StatefulWidget {
  const WebDavSettingPage({
    super.key,
    this.showAppBar = true,
  });

  final bool showAppBar;

  @override
  State<WebDavSettingPage> createState() => _WebDavSettingPageState();
}

class _WebDavSettingPageState extends State<WebDavSettingPage> {
  final _uriCtr = TextEditingController(text: Pref.webdavUri);
  final _usernameCtr = TextEditingController(text: Pref.webdavUsername);
  final _passwordCtr = TextEditingController(text: Pref.webdavPassword);
  final _directoryCtr = TextEditingController(text: Pref.webdavDirectory);
  bool _obscureText = true;

  @override
  void dispose() {
    _uriCtr.dispose();
    _usernameCtr.dispose();
    _passwordCtr.dispose();
    _directoryCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showAppBar = widget.showAppBar;
    final padding = MediaQuery.viewPaddingOf(context);
    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('WebDAV 璁剧疆')) : null,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          ListView(
            padding: padding.copyWith(
              top: 20,
              left: 20 + (showAppBar ? padding.left : 0),
              right: 20 + (showAppBar ? padding.right : 0),
              bottom: padding.bottom + 100,
            ),
            children: [
              TextField(
                controller: _uriCtr,
                decoration: const InputDecoration(
                  labelText: '鍦板潃',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameCtr,
                decoration: const InputDecoration(
                  labelText: '鐢ㄦ埛',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordCtr,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: '瀵嗙爜',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                    icon: _obscureText
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                  ),
                ),
                obscureText: _obscureText,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _directoryCtr,
                decoration: const InputDecoration(
                  labelText: '璺緞',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: Style.mdRadius,
                        ),
                      ),
                      onPressed: WebDav().backup,
                      child: const Text('澶囦唤璁剧疆'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: Style.mdRadius,
                        ),
                      ),
                      onPressed: WebDav().restore,
                      child: const Text('鎭㈠璁剧疆'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right:
                kFloatingActionButtonMargin + (showAppBar ? padding.right : 0),
            bottom: kFloatingActionButtonMargin + padding.bottom,
            child: FloatingActionButton(
              child: const Icon(Icons.save),
              onPressed: () async {
                await GStorage.setting.putAll({
                  SettingBoxKey.webdavUri: _uriCtr.text,
                  SettingBoxKey.webdavUsername: _usernameCtr.text,
                  SettingBoxKey.webdavPassword: _passwordCtr.text,
                  SettingBoxKey.webdavDirectory: _directoryCtr.text,
                });
                if (_uriCtr.text.isEmpty) {
                  return;
                }
                try {
                  final res = await WebDav().init();
                  if (res.first) {
                    SmartDialog.showToast('閰嶇疆鎴愬姛');
                  } else {
                    SmartDialog.showToast('閰嶇疆澶辫触: ${res.second}');
                  }
                } catch (e) {
                  SmartDialog.showToast('閰嶇疆澶辫触: ${e.toString()}');
                  return;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

