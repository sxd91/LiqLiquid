import 'package:liqliquid/utils/storage_pref.dart';

enum MemberTabType {
  def('榛樿'),
  home('涓婚〉'),
  dynamic('鍔ㄦ€?),
  contribute('鎶曠'),
  favorite('鏀惰棌'),
  bangumi('鐣墽'),
  cheese('璇惧爞'),
  shop('灏忓簵'),
  ;

  static bool showMemberShop = Pref.showMemberShop;

  static bool contains(String type) {
    if (type == shop.name && !showMemberShop) {
      return false;
    }
    for (final e in MemberTabType.values) {
      if (e.name == type) {
        return true;
      }
    }
    return false;
  }

  final String title;
  const MemberTabType(this.title);
}

