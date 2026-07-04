import 'package:liqliquid/models/common/enum_with_label.dart';

enum SkipType implements EnumWithLabel {
  alwaysSkip('鎬绘槸璺宠繃'),
  skipOnce('璺宠繃涓€娆?),
  skipManually('鎵嬪姩璺宠繃'),
  showOnly('浠呮樉绀?),
  disable('绂佺敤'),
  ;

  @override
  final String label;
  const SkipType(this.label);
}

