import 'package:liqliquid/models/common/enum_with_label.dart';
import 'package:liqliquid/pages/dynamics/view.dart';
import 'package:liqliquid/pages/home/view.dart';
import 'package:liqliquid/pages/mine/view.dart';
import 'package:flutter/material.dart';

enum NavigationBarType implements EnumWithLabel {
  home(
    '棣栭〉',
    Icon(Icons.home_outlined, size: 24),
    Icon(Icons.home, size: 24),
    HomePage(),
  ),
  dynamics(
    '鍔ㄦ€?,
    Icon(Icons.motion_photos_on_outlined, size: 21),
    Icon(Icons.motion_photos_on, size: 21),
    DynamicsPage(),
  ),
  mine(
    '鎴戠殑',
    Icon(Icons.person_outline, size: 24),
    Icon(Icons.person, size: 24),
    MinePage(),
  ),
  ;

  @override
  final String label;
  final Icon icon;
  final Icon selectIcon;
  final Widget page;

  const NavigationBarType(this.label, this.icon, this.selectIcon, this.page);
}

