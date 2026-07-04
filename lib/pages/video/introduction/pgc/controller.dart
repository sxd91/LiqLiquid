import 'dart:async';
import 'dart:math' show max;

import 'package:liqliquid/common/widgets/dialog/simple_dialog_option.dart';
import 'package:liqliquid/http/constants.dart';
import 'package:liqliquid/http/fav.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/pgc.dart';
import 'package:liqliquid/http/search.dart';
import 'package:liqliquid/http/video.dart';
import 'package:liqliquid/models/common/video/source_type.dart';
import 'package:liqliquid/models/common/video/video_type.dart';
import 'package:liqliquid/models_new/pgc/pgc_info_model/episode.dart';
import 'package:liqliquid/models_new/pgc/pgc_info_model/result.dart';
import 'package:liqliquid/models_new/video/video_detail/episode.dart'
    hide EpisodeItem;
import 'package:liqliquid/models_new/video/video_detail/stat_detail.dart';
import 'package:liqliquid/pages/common/common_intro_controller.dart';
import 'package:liqliquid/pages/dynamics_repost/view.dart';
import 'package:liqliquid/pages/video/reply/controller.dart';
import 'package:liqliquid/plugin/pl_player/models/play_repeat.dart';
import 'package:liqliquid/services/service_locator.dart';
import 'package:liqliquid/utils/feed_back.dart';
import 'package:liqliquid/utils/global_data.dart';
import 'package:liqliquid/utils/id_utils.dart';
import 'package:liqliquid/utils/page_utils.dart';
import 'package:liqliquid/utils/platform_utils.dart';
import 'package:liqliquid/utils/share_utils.dart';
import 'package:liqliquid/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class PgcIntroController extends CommonIntroController {
  int? seasonId;
  int? epId;

  late final String pgcType = pgcItem.type == 1 || pgcItem.type == 4
      ? '杩界暘'
      : '杩藉墽';

  late final bool isPgc;
  late final PgcInfoModel pgcItem;

  @override
  (Object, int) get getFavRidType => (epId!, 24);

  @override
  StatDetail? getStat() => pgcItem.stat;

  late final RxBool isFollowed = false.obs;
  late final RxInt followStatus = (-1).obs;
  late final RxBool isFav = (pgcItem.userStatus?.favored == 1).obs;

  @override
  void onInit() {
    final args = Get.arguments;
    seasonId = args['seasonId'];
    epId = args['epId'];
    isPgc = args['videoType'] == VideoType.pgc;
    pgcItem = args['pgcItem'];

    super.onInit();

    if (isPgc) {
      if (isLogin) {
        queryIsFollowed();
        if (epId != null) {
          queryPgcLikeCoinFav();
        }
      }
      queryVideoTags();
    }
  }

  // 鑾峰彇鐐硅禐/鎶曞竵/鏀惰棌鐘舵€?  Future<void> queryPgcLikeCoinFav() async {
    final result = await VideoHttp.pgcLikeCoinFav(epId: epId!);
    if (result case Success(:final response)) {
      final hasLike = response.like == 1;
      final hasFav = response.favorite == 1;
      late final stat = pgcItem.stat;
      if (hasLike) {
        stat?.like = max(1, stat.like);
      }
      if (hasFav) {
        stat?.favorite = max(1, stat.favorite);
      }
      this.hasLike.value = hasLike;
      coinNum.value = response.coinNumber!;
      this.hasFav.value = hasFav;
    } else {
      result.toast();
    }
  }

  // 锛堝彇娑堬級鐐硅禐
  @override
  Future<void> actionLikeVideo() async {
    if (!isLogin) {
      SmartDialog.showToast('璐﹀彿鏈櫥褰?);
      return;
    }
    final newVal = !hasLike.value;
    final result = await VideoHttp.likeVideo(bvid: bvid, type: newVal);
    if (result case Success(:final response)) {
      SmartDialog.showToast(newVal ? response : '鍙栨秷璧?);
      pgcItem.stat?.like += newVal ? 1 : -1;
      hasLike.value = newVal;
    } else {
      result.toast();
    }
  }

  @override
  int get copyright => 1;

  // 鍒嗕韩瑙嗛
  @override
  void actionShareVideo(BuildContext context) {
    String videoUrl =
        '${HttpString.baseUrl}/bangumi/play/ep$epId${videoDetailCtr.playedTimePos}';
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          DialogOption(
            child: const Text('澶嶅埗閾炬帴', style: TextStyle(fontSize: 14)),
            onPressed: () {
              Get.back();
              Utils.copyText(videoUrl);
            },
          ),
          DialogOption(
            child: const Text('鍏跺畠app鎵撳紑', style: TextStyle(fontSize: 14)),
            onPressed: () {
              Get.back();
              PageUtils.launchURL(videoUrl);
            },
          ),
          if (PlatformUtils.isMobile)
            DialogOption(
              child: const Text('鍒嗕韩瑙嗛', style: TextStyle(fontSize: 14)),
              onPressed: () {
                final item = pgcItem.episodes?.firstWhereOrNull(
                  (item) => item.epId == epId,
                );
                Get.back();
                ShareUtils.shareText(
                  '${pgcItem.title}${item != null ? ' ${item.showTitle}' : ''}'
                  ' - $videoUrl',
                );
              },
            ),
          if (isLogin)
            DialogOption(
              child: const Text('鍒嗕韩鑷冲姩鎬?, style: TextStyle(fontSize: 14)),
              onPressed: () {
                Get.back();
                final item = pgcItem.episodes?.firstWhereOrNull(
                  (item) => item.epId == epId,
                );
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (context) => RepostPanel(
                    rid: epId,
                    /*
                    1锛氱暘鍓?// 4097
                    2锛氱數褰?// 4098
                    3锛氱邯褰曠墖 // 4101
                    4锛氬浗鍒?// 4100
                    5锛氱數瑙嗗墽 // 4099
                    6锛氭极鐢?                    7锛氱患鑹?// 4099
                  */
                    dynType: switch (pgcItem.type) {
                      1 => 4097,
                      2 => 4098,
                      3 => 4101,
                      4 => 4100,
                      5 || 7 => 4099,
                      _ => -1,
                    },
                    pic: pgcItem.cover,
                    title:
                        '${pgcItem.title}${item != null ? '\n${item.showTitle}' : ''}',
                    uname: '',
                  ),
                );
              },
            ),
          if (isLogin)
            DialogOption(
              child: const Text(
                '鍒嗕韩鑷虫秷鎭?,
                style: TextStyle(fontSize: 14),
              ),
              onPressed: () {
                Get.back();
                try {
                  final item = pgcItem.episodes!.firstWhere(
                    (item) => item.epId == epId,
                  );
                  final title =
                      item.shareCopy ??
                      '${pgcItem.title} ${item.showTitle ?? item.longTitle}';
                  PageUtils.pmShare(
                    context,
                    content: {
                      "id": epId!.toString(),
                      "title": title,
                      "url": item.shareUrl,
                      "headline": title,
                      "source": 16,
                      "thumb": item.cover,
                      "source_desc": switch (pgcItem.type) {
                        1 => '鐣墽',
                        2 => '鐢靛奖',
                        3 => '绾綍鐗?,
                        4 => '鍥藉垱',
                        5 => '鐢佃鍓?,
                        6 => '婕敾',
                        7 => '缁艰壓',
                        _ => null,
                      },
                    },
                  );
                } catch (e) {
                  SmartDialog.showToast(e.toString());
                }
              },
            ),
        ],
      ),
    );
  }

  // 淇敼鍒哖鎴栫暘鍓у垎闆?  Future<bool> onChangeEpisode(BaseEpisodeItem episode) async {
    try {
      final int epId = episode.epId ?? episode.id!;
      final String bvid = episode.bvid ?? this.bvid;
      final int aid = episode.aid ?? IdUtils.bv2av(bvid);
      final int? cid =
          episode.cid ?? await SearchHttp.ab2c(aid: aid, bvid: bvid);
      if (cid == null) {
        return false;
      }
      final String? cover = episode.cover;

      // 閲嶆柊鑾峰彇瑙嗛璧勬簮
      this.epId = epId;
      this.bvid = bvid;

      videoDetailCtr
        ..plPlayerController.pause()
        ..makeHeartBeat()
        ..onReset()
        ..epId = epId
        ..bvid = bvid
        ..aid = aid
        ..cid.value = cid
        ..queryVideoUrl();
      if (cover != null && cover.isNotEmpty) {
        videoDetailCtr.cover.value = cover;
      }

      // 閲嶆柊璇锋眰璇勮
      if (videoDetailCtr.showReply) {
        try {
          final replyCtr = Get.find<VideoReplyController>(tag: heroTag)
            ..aid = aid;
          if (replyCtr.loadingState.value is! Loading) {
            replyCtr.onReload();
          }
        } catch (_) {}
      }

      if (isPgc && isLogin) {
        queryPgcLikeCoinFav();
      }

      hasLater.value = videoDetailCtr.sourceType == SourceType.watchLater;
      this.cid.value = cid;
      queryOnlineTotal();
      queryVideoIntro(episode as EpisodeItem);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('pgc onChangeEpisode: $e');
      return false;
    }
  }

  // 杩界暘
  Future<void> pgcAdd() async {
    final result = await VideoHttp.pgcAdd(seasonId: pgcItem.seasonId);
    if (result case Success(:final response)) {
      isFollowed.value = true;
      followStatus.value = 2;
      SmartDialog.showToast(response);
    } else {
      result.toast();
    }
  }

  // 鍙栨秷杩界暘
  Future<void> pgcDel() async {
    final result = await VideoHttp.pgcDel(seasonId: pgcItem.seasonId);
    if (result case Success(:final response)) {
      isFollowed.value = false;
      SmartDialog.showToast(response);
    } else {
      result.toast();
    }
  }

  Future<void> pgcUpdate(int status) async {
    final result = await VideoHttp.pgcUpdate(
      seasonId: pgcItem.seasonId.toString(),
      status: status,
    );
    if (result case Success(:final response)) {
      followStatus.value = status;
      SmartDialog.showToast(response);
    } else {
      result.toast();
    }
  }

  @override
  bool prevPlay() {
    final episodes = pgcItem.episodes!;
    int currentIndex = episodes.indexWhere(
      (e) => e.cid == videoDetailCtr.cid.value,
    );
    int prevIndex = currentIndex - 1;
    PlayRepeat playRepeat = videoDetailCtr.plPlayerController.playRepeat;
    if (prevIndex < 0) {
      if (playRepeat == PlayRepeat.listCycle) {
        prevIndex = episodes.length - 1;
      } else {
        return false;
      }
    }
    onChangeEpisode(episodes[prevIndex]);
    return true;
  }

  /// 鍒楄〃寰幆鎴栬€呴『搴忔挱鏀炬椂锛岃嚜鍔ㄦ挱鏀句笅涓€涓紱鑷姩杩炴挱鏃讹紝鎾斁鐩稿叧瑙嗛
  @override
  bool nextPlay() {
    try {
      final episodes = pgcItem.episodes!;

      PlayRepeat playRepeat = videoDetailCtr.plPlayerController.playRepeat;

      int currentIndex = episodes.indexWhere(
        (e) => e.cid == videoDetailCtr.cid.value,
      );
      int nextIndex = currentIndex + 1;
      // 鍒楄〃寰幆
      if (nextIndex >= episodes.length) {
        if (playRepeat == PlayRepeat.listCycle) {
          nextIndex = 0;
        } else if (playRepeat == PlayRepeat.autoPlayRelated) {
          return false;
        } else {
          return false;
        }
      }
      onChangeEpisode(episodes[nextIndex]);
      return true;
    } catch (_) {
      return false;
    }
  }

  // 涓€閿笁杩?  @override
  Future<void> actionTriple() async {
    feedBack();
    if (!isLogin) {
      SmartDialog.showToast('璐﹀彿鏈櫥褰?);
      return;
    }
    if (hasLike.value && hasCoin && hasFav.value) {
      // 宸茬偣璧炪€佹姇甯併€佹敹钘?      SmartDialog.showToast('宸蹭笁杩?);
      return;
    }
    final result = await VideoHttp.pgcTriple(epId: epId!, seasonId: seasonId);
    if (result case Success(:final response)) {
      late final stat = pgcItem.stat;
      if (response.like == 1 && !hasLike.value) {
        stat?.like++;
        hasLike.value = true;
      }
      if (response.coin == 1 && !hasCoin) {
        stat?.coin += 2;
        coinNum.value = 2;
        GlobalData().afterCoin(2);
      }
      if (response.favorite == 1 && !hasFav.value) {
        stat?.favorite++;
        hasFav.value = true;
      }
      if (!hasCoin) {
        SmartDialog.showToast('鎶曞竵澶辫触');
      } else {
        SmartDialog.showToast('涓夎繛鎴愬姛');
      }
    } else {
      result.toast();
    }
  }

  Future<void> queryIsFollowed() async {
    // try {
    //   final result = await Request().get(
    //     'https://www.bilibili.com/bangumi/play/ss$seasonId',
    //   );
    //   dom.Document document = html_parser.parse(result.data);
    //   dom.Element? scriptElement =
    //       document.querySelector('script#__NEXT_DATA__');
    //   if (scriptElement != null) {
    //     dynamic scriptContent = jsonDecode(scriptElement.text);
    //     isFollowed.value =
    //         scriptContent['props']['pageProps']['followState']['isFollowed'];
    //     followStatus.value =
    //         scriptContent['props']['pageProps']['followState']['followStatus'];
    //   }
    // } catch (_) {}

    // ViewGrpc.view(bvid: bvid).then((res) {
    //   if (res.isSuccess) {
    //     ViewPgcAny view = ViewPgcAny.fromBuffer(res.data.supplement.value);
    //     final userStatus = view.ogvData.userStatus;
    //     isFollowed.value = userStatus.follow == 1;
    //     followStatus.value = userStatus.followStatus;
    //   }
    // });

    final res = await PgcHttp.seasonStatus(seasonId!);
    if (res case Success(:final response)) {
      isFollowed.value = response['follow'] == 1;
      followStatus.value = response['follow_status'];
    }
  }

  @override
  void queryVideoIntro([EpisodeItem? episode]) {
    episode ??= pgcItem.episodes!.firstWhere((e) => e.cid == cid.value);
    videoDetail
      ..value.title = episode.showTitle
      ..refresh();
    videoPlayerServiceHandler?.onVideoDetailChange(
      episode,
      cid.value,
      heroTag,
      artist: pgcItem.title,
    );
  }

  Future<void> onFavPugv(bool isFav) async {
    final res = isFav
        ? await FavHttp.delFavPugv(seasonId!)
        : await FavHttp.addFavPugv(seasonId!);
    if (res.isSuccess) {
      this.isFav.value = !isFav;
      SmartDialog.showToast('${isFav ? '鍙栨秷' : ''}鏀惰棌鎴愬姛');
    } else {
      res.toast();
    }
  }
}

