import 'package:liqliquid/utils/storage_pref.dart';

class GlobalData {
  int imgQuality = Pref.picQuality;

  num? coins;

  void afterCoin(num coin) {
    if (coins != null) {
      coins = coins! - coin;
    }
  }

  Set<int> blackMids = Pref.blackMids;

  bool dynamicsWaterfallFlow = Pref.dynamicsWaterfallFlow;

  bool showMedal = Pref.showMedal;

  // 绉佹湁鏋勯€犲嚱鏁?  GlobalData._();

  // 鍗曚緥瀹炰緥
  static final GlobalData _instance = GlobalData._();

  // 鑾峰彇鍏ㄥ眬瀹炰緥
  factory GlobalData() => _instance;
}

