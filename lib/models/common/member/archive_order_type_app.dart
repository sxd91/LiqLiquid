import 'package:liqliquid/models/common/enum_with_label.dart';

enum ArchiveOrderTypeApp with EnumWithLabel {
  pubdate('鏈€鏂板彂甯?),
  click('鏈€澶氭挱鏀?),
  ;

  @override
  final String label;
  const ArchiveOrderTypeApp(this.label);
}

