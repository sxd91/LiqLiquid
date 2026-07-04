import 'package:liqliquid/models/common/enum_with_label.dart';

enum SuperResolutionType with EnumWithLabel {
  disable('绂佺敤'),
  efficiency('鏁堢巼'),
  quality('鐢昏川'),
  ;

  @override
  final String label;
  const SuperResolutionType(this.label);
}

