import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/user.dart';
import 'package:liqliquid/models_new/coin_log/data.dart';
import 'package:liqliquid/models_new/coin_log/list.dart';
import 'package:liqliquid/pages/log_table/controller.dart';

class CoinLogController extends LogController<CoinLogData, CoinLogItem> {
  @override
  List<CoinLogItem>? getDataList(CoinLogData response) {
    return response.list;
  }

  @override
  Future<LoadingState<CoinLogData>> customGetData() => UserHttp.coinLog();

  @override
  List<(int, String)> getFlexAndText(CoinLogItem item) {
    return [(3, item.time), (1, item.delta), (4, item.reason)];
  }

  @override
  final CoinLogItem header = const CoinLogItem(
    time: '鏃堕棿',
    delta: '鍙樺寲',
    reason: '鍘熷洜',
  );

  @override
  final String title = '纭竵璁板綍';
}

