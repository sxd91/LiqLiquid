import 'package:liqliquid/models/common/enum_with_label.dart';

enum ArchiveOrderTypeWeb with EnumWithLabel {
  pubdate('鏈€鏂板彂甯?),
  click('鏈€澶氭挱鏀?),
  stow('鏈€澶氭敹钘?),
  ;

  @override
  final String label;
  const ArchiveOrderTypeWeb(this.label);
}

