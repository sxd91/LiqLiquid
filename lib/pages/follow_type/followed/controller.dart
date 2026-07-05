import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/user.dart';
import 'package:liqliquid/models_new/follow/data.dart';
import 'package:liqliquid/pages/follow_type/controller.dart';

class FollowedController extends FollowTypeController {
  @override
  Future<LoadingState<FollowData>> customGetData() =>
      UserHttp.followedUp(mid: mid, pn: page);
}
