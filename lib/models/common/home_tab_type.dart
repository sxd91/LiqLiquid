import 'package:liqliquid/models/common/enum_with_label.dart';
import 'package:liqliquid/pages/common/common_controller.dart';
import 'package:liqliquid/pages/hot/controller.dart';
import 'package:liqliquid/pages/hot/view.dart';
import 'package:liqliquid/pages/live/controller.dart';
import 'package:liqliquid/pages/live/view.dart';
import 'package:liqliquid/pages/pgc/controller.dart';
import 'package:liqliquid/pages/pgc/view.dart';
import 'package:liqliquid/pages/rank/controller.dart';
import 'package:liqliquid/pages/rank/view.dart';
import 'package:liqliquid/pages/rcmd/controller.dart';
import 'package:liqliquid/pages/rcmd/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum HomeTabType implements EnumWithLabel {
  live('鐩存挱'),
  rcmd('鎺ㄨ崘'),
  hot('鐑棬'),
  rank('鍒嗗尯'),
  bangumi('鐣墽'),
  cinema('褰辫'),
  ;

  @override
  final String label;
  const HomeTabType(this.label);

  ScrollOrRefreshMixin Function() get ctr => switch (this) {
    HomeTabType.live => Get.find<LiveController>,
    HomeTabType.rcmd => Get.find<RcmdController>,
    HomeTabType.hot => Get.find<HotController>,
    HomeTabType.rank => Get.find<RankController>,
    HomeTabType.bangumi ||
    HomeTabType.cinema => () => Get.find<PgcController>(tag: name),
  };

  Widget get page => switch (this) {
    HomeTabType.live => const LivePage(),
    HomeTabType.rcmd => const RcmdPage(),
    HomeTabType.hot => const HotPage(),
    HomeTabType.rank => const RankPage(),
    HomeTabType.bangumi => const PgcPage(tabType: HomeTabType.bangumi),
    HomeTabType.cinema => const PgcPage(tabType: HomeTabType.cinema),
  };
}

