import 'package:liqliquid/pages/later/child_view.dart';
import 'package:flutter/material.dart';

enum LaterViewType {
  all(0, '鍏ㄩ儴'),
  // toView(1, '鏈湅'),
  unfinished(2, '鏈湅瀹?),
  // viewed(3, '宸茬湅瀹?),
  ;

  Widget get page => LaterViewChildPage(laterViewType: this);

  final int type;
  final String title;
  const LaterViewType(this.type, this.title);
}

