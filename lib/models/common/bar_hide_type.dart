import 'package:liqliquid/models/common/enum_with_label.dart';

enum BarHideType with EnumWithLabel {
  instant('鍗虫椂'),
  sync('鍚屾'),
  ;

  @override
  final String label;
  const BarHideType(this.label);
}

