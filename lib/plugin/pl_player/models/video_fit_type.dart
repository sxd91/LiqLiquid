import 'package:liqliquid/common/style.dart';
import 'package:flutter/material.dart' show BoxFit;

enum VideoFitType {
  fill('鎷変几', boxFit: BoxFit.fill),
  contain('鑷姩', boxFit: BoxFit.contain),
  cover('瑁佸壀', boxFit: BoxFit.cover),
  fitWidth('绛夊', boxFit: BoxFit.fitWidth),
  fitHeight('绛夐珮', boxFit: BoxFit.fitHeight),
  none('鍘熷', boxFit: BoxFit.none),
  scaleDown('闄愬埗', boxFit: BoxFit.scaleDown),
  ratio_4x3('4:3', aspectRatio: 4 / 3),
  ratio_16x9('16:9', aspectRatio: Style.aspectRatio16x9),
  ;

  final String desc;
  final BoxFit boxFit;
  final double? aspectRatio;
  const VideoFitType(
    this.desc, {
    this.boxFit = BoxFit.contain,
    this.aspectRatio,
  });
}

