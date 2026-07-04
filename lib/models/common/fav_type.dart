import 'package:liqliquid/pages/fav/article/view.dart';
import 'package:liqliquid/pages/fav/cheese/view.dart';
import 'package:liqliquid/pages/fav/note/view.dart';
import 'package:liqliquid/pages/fav/pgc/view.dart';
import 'package:liqliquid/pages/fav/topic/view.dart';
import 'package:liqliquid/pages/fav/video/view.dart';
import 'package:flutter/material.dart';

enum FavTabType {
  video('瑙嗛', FavVideoPage()),
  bangumi('杩界暘', FavPgcPage(type: 1)),
  cinema('杩藉墽', FavPgcPage(type: 2)),
  article('涓撴爮', FavArticlePage()),
  note('绗旇', FavNotePage()),
  topic('璇濋', FavTopicPage()),
  cheese('璇惧爞', FavCheesePage()),
  ;

  final String title;
  final Widget page;
  const FavTabType(this.title, this.page);
}

