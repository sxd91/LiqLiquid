import 'package:liqliquid/utils/duration_utils.dart';
import 'package:liqliquid/utils/num_utils.dart';

class UserInfo {
  final int viewCount;
  final double minutesSaved;
  final int segmentCount;

  const UserInfo({
    required this.viewCount,
    required this.minutesSaved,
    required this.segmentCount,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    viewCount: json['viewCount'],
    minutesSaved: (json['minutesSaved'] as num).toDouble(),
    segmentCount: json['segmentCount'],
  );

  @override
  String toString() {
    String minutes = DurationUtils.formatTimeDuration(
      Duration(minutes: minutesSaved.round()),
    );
    if (minutes.isEmpty) {
      minutes = '0鍒嗛挓';
    }
    return ('鎮ㄦ彁浜や簡 ${NumUtils.formatPositiveDecimal(segmentCount)} 鐗囨\n'
        '鎮ㄤ负澶у鑺傜渷浜?${NumUtils.formatPositiveDecimal(viewCount)} 鐗囨\n'
        '($minutes 鐨勭敓鍛?');
  }
}

