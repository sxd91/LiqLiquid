import 'package:liqliquid/models/model_rec_video_item.dart';
import 'package:liqliquid/models/model_video.dart';
import 'package:liqliquid/utils/id_utils.dart';
import 'package:liqliquid/utils/num_utils.dart';

class RcmdVideoItemAppModel extends BaseRcmdVideoItemModel {
  int? get id => aid;
  String? talkBack;

  String? cardType;
  ThreePoint? threePoint;

  RcmdVideoItemAppModel.fromJson(Map<String, dynamic> json) {
    aid = json['player_args']?['aid'] ?? int.tryParse(json['param'] ?? '0');
    bvid = json['bvid'] ?? IdUtils.av2bv(aid!);
    cid = json['player_args']?['cid'];
    cover = json['cover'];
    stat = RcmdStat.fromJson(json);
    // 鏀圭敤player_args涓殑duration浣滀负鍘熷鏁版嵁锛堢鏁帮級
    duration = json['player_args']?['duration'] ?? 0;
    //duration = json['cover_right_text'];
    title = json['title'];
    owner = RcmdOwner.fromJson(json);
    rcmdReason = json['rcmd_reason'];
    //     json['bottom_rcmd_reason'] ??
    //     json['top_rcmd_reason'];
    if (rcmdReason != null && rcmdReason!.contains('璧?)) {
      // 鏈夋椂鑳藉湪鎺ㄨ崘鍘熷洜閲岃幏寰楃偣璧炴暟
      (stat as RcmdStat).like = NumUtils.parseNum(rcmdReason!);
    }
    // 鐢变簬app绔痑pi骞朵笉浼氱洿鎺ヨ繑鍥炰笌owner鐨勫叧娉ㄧ姸鎬?    // 鎵€浠ュ€熺敤鎺ㄨ崘鍘熷洜鏄惁涓衡€滃凡鍏虫敞鈥濄€佲€滄柊鍏虫敞鈥濆垽鍒叧娉ㄧ姸鎬侊紝浠庤€屼笌web绔帴鍙ｇ瓑鏁?    isFollowed = const {'宸插叧娉?, '鏂板叧娉?}.contains(rcmdReason);
    // 濡傛灉鏄紝灏辨棤闇€鍐嶆樉绀烘帹鑽愬師鍥狅紝浜ょ敱view缁熶竴澶勭悊鍗冲彲
    if (isFollowed) rcmdReason = null;

    goto = json['goto'];
    param = int.parse(json['param']);
    uri = json['uri'];
    talkBack = json['talk_back'];

    if (json['goto'] == 'bangumi') {
      pgcBadge = json['cover_right_text'];
    }

    cardType = json['card_type'];
    threePoint = json['three_point_v2'] != null
        ? ThreePoint.fromJson(json['three_point_v2'])
        : null;
    desc = json['desc'];
  }
}

class RcmdStat extends BaseStat {
  RcmdStat.fromJson(Map<String, dynamic> json) {
    view = NumUtils.parseNum(json["cover_left_text_1"] ?? '');
    danmu = NumUtils.parseNum(json["cover_left_text_2"] ?? '');
  }
}

class RcmdOwner extends BaseOwner {
  RcmdOwner.fromJson(Map<String, dynamic> json) {
    name = json['goto'] == 'av'
        ? (json['args']?['up_name'] ?? '')
        : (json['desc_button']?['text'] ?? '');
    mid = json['args']?['up_id'] ?? 0;
  }
}

class ThreePoint {
  List<Reason>? dislikeReasons;
  List<Reason>? feedbacks;
  // int? watchLater;

  ThreePoint.fromJson(List json) {
    for (final elem in json) {
      switch (elem['type']) {
        // case 'watch_later':
        //   watchLater = 1;
        //   break;
        case 'feedback':
          feedbacks = (elem['reasons'] as List?)
              ?.map((i) => Reason.fromJson(i))
              .toList();
          break;
        case 'dislike':
          dislikeReasons = (elem['reasons'] as List?)
              ?.map((i) => Reason.fromJson(i))
              .toList();
          break;
      }
    }
  }
}

class Reason {
  int? id;
  String? name;
  String? toast;

  Reason.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    toast = json['toast'];
  }
}

