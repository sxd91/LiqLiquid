import 'package:liqliquid/models/common/account_type.dart';
import 'package:liqliquid/pages/setting/models/model.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:liqliquid/utils/accounts/api_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

List<SettingsModel> get privacySettings => [
  NormalModel(
    onTap: (context, setState) {
      if (!Accounts.main.isLogin) {
        SmartDialog.showToast('鐧诲綍鍚庢煡鐪?);
        return;
      }
      Get.toNamed('/blackListPage');
    },
    title: '榛戝悕鍗曠鐞?,
    subtitle: '宸叉媺榛戠敤鎴?,
    leading: const Icon(Icons.block),
  ),
  NormalModel(
    onTap: (context, setState) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('璐﹀彿妯″紡璇︽儏'),
          content: SingleChildScrollView(child: _getAccountDetail(context)),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: const Text('纭'),
            ),
          ],
        ),
      );
    },
    leading: const Icon(Icons.flag_outlined),
    title: '浜嗚В璐﹀彿妯″紡',
    subtitle: '鏌ョ湅鍚勪釜璐﹀彿妯″紡浣滅敤鐨凙PI鍒楄〃',
  ),
];

Widget _getAccountDetail(BuildContext context) {
  final slivers = <Widget>[];
  final theme = TextTheme.of(context);
  for (final i in AccountType.values) {
    final url = ApiType.apiTypeSet[i];
    if (url == null) continue;

    slivers
      ..add(Center(child: Text(i.title, style: theme.titleMedium)))
      ..add(SelectableText(url.join('\n')));
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8,
    children: slivers,
  );
}

