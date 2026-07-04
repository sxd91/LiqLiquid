import 'package:liqliquid/models/common/enum_with_label.dart';

enum ArchiveSortTypeApp with EnumWithLabel {
  desc('榛樿'),
  asc('鍊掑簭'),
  ;

  @override
  final String label;
  const ArchiveSortTypeApp(this.label);
}

