import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/member.dart';
import 'package:liqliquid/models_new/member/coin_like_arc/data.dart';
import 'package:liqliquid/models_new/member/coin_like_arc/item.dart';
import 'package:liqliquid/pages/common/common_list_controller.dart';

class MemberCoinArcController
    extends CommonListController<CoinLikeArcData, CoinLikeArcItem> {
  final dynamic mid;
  MemberCoinArcController({this.mid});

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<CoinLikeArcItem>? getDataList(CoinLikeArcData response) {
    return response.item;
  }

  @override
  Future<LoadingState<CoinLikeArcData>> customGetData() =>
      MemberHttp.coinArc(mid: mid, page: page);
}
