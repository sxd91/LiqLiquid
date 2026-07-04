import 'package:liqliquid/models/horizontal_video_model.dart';
import 'package:liqliquid/models/model_video.dart';
import 'package:liqliquid/utils/duration_utils.dart';

class VListItemModel extends HorizontalVideoModel {
  VListItemModel.fromJson(Map<String, dynamic> json) {
    cover = json['pic'];
    desc = json['description'];
    title = json['title'];
    pubdate = json['created'];
    if (json['length'] != null) {
      duration = DurationUtils.parseDuration(json['length']);
    }
    aid = json['aid'];
    bvid = json['bvid'];
    stat = VListStat.fromJson(json);
    owner = VListOwner.fromJson(json);
    if (json['is_lesson_video'] == 1) {
      isPugv = true;
      badge = '璇惧爞';
    } else if (json['is_charging_arc'] == true) {
      badge = '鍏呯數涓撳睘';
    } else if (json['is_union_video'] == 1) {
      badge = '鍚堜綔';
    }
    seasonId = json['season_id'];
    redirectUrl = json['jump_url'];
    final position = json['playback_position'] as num?; // percent
    if (position != null) {
      if (position == 100) {
        progress = -1;
      } else {
        progress = ((position / 100) * duration).round();
      }
    }
  }
}

class VListOwner extends BaseOwner {
  VListOwner.fromJson(Map<String, dynamic> json) {
    mid = json["mid"];
    name = json["author"];
  }
}

class VListStat extends BaseStat {
  VListStat.fromJson(Map<String, dynamic> json) {
    view = json["play"];
    danmu = json['video_review'];
  }
}

