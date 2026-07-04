import 'package:liqliquid/models/common/enum_with_label.dart';

enum PlayRepeat implements EnumWithLabel {
  pause('鎾畬鏆傚仠'),
  listOrder('椤哄簭鎾斁'),
  singleCycle('鍗曚釜寰幆'),
  listCycle('鍒楄〃寰幆'),
  autoPlayRelated('鑷姩杩炴挱'),
  ;

  @override
  final String label;
  const PlayRepeat(this.label);
}

