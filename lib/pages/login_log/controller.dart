import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/user.dart';
import 'package:liqliquid/models_new/login_log/data.dart';
import 'package:liqliquid/models_new/login_log/list.dart';
import 'package:liqliquid/pages/log_table/controller.dart';

class LoginLogController extends LogController<LoginLogData, LoginLogItem> {
  @override
  List<LoginLogItem>? getDataList(LoginLogData response) {
    return response.list;
  }

  @override
  Future<LoadingState<LoginLogData>> customGetData() => UserHttp.loginLog();

  @override
  List<(int, String)> getFlexAndText(LoginLogItem item) {
    return [(3, item.timeAt), (2, item.ip), (3, item.geo)];
  }

  @override
  final LoginLogItem header = const LoginLogItem(
    timeAt: '鏃堕棿',
    ip: '鍙樺寲',
    geo: '鍦扮悊浣嶇疆',
  );

  @override
  final String title = '鐧诲綍璁板綍';
}

