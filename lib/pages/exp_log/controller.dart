import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/user.dart';
import 'package:liqliquid/models_new/coin_log/data.dart';
import 'package:liqliquid/models_new/coin_log/list.dart';
import 'package:liqliquid/pages/log_table/controller.dart';

class ExpLogController extends LogController<CoinLogData, CoinLogItem> {
  @override
  List<CoinLogItem>? getDataList(CoinLogData response) {
    return response.list;
  }

  @override
  Future<LoadingState<CoinLogData>> customGetData() => UserHttp.expLog();

  @override
  List<(int, String)> getFlexAndText(CoinLogItem item) {
    return [(2, item.time), (1, item.delta), (2, item.reason)];
  }

  @override
  final CoinLogItem header = const CoinLogItem(
    time: '鏃堕棿',
    delta: '鍙樺寲',
    reason: '鍘熷洜',
  );

  @override
  final String title = '缁忛獙璁板綍';
}

