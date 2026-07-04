import 'dart:async';
import 'dart:math';

import 'package:liqliquid/common/widgets/button/icon_button.dart';
import 'package:liqliquid/common/widgets/scroll_physics.dart';
import 'package:liqliquid/http/api.dart';
import 'package:liqliquid/http/constants.dart';
import 'package:liqliquid/http/init.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/member.dart';
import 'package:liqliquid/http/search.dart';
import 'package:liqliquid/http/user.dart';
import 'package:liqliquid/http/video.dart';
import 'package:liqliquid/models/common/video/source_type.dart';
import 'package:liqliquid/models_new/member_card_info/data.dart';
import 'package:liqliquid/models_new/relation/data.dart';
import 'package:liqliquid/models_new/video/video_ai_conclusion/model_result.dart';
import 'package:liqliquid/models_new/video/video_detail/dimension.dart';
import 'package:liqliquid/models_new/video/video_detail/episode.dart';
import 'package:liqliquid/models_new/video/video_detail/page.dart';
import 'package:liqliquid/models_new/video/video_detail/section.dart';
import 'package:liqliquid/models_new/video/video_detail/staff.dart';
import 'package:liqliquid/models_new/video/video_detail/stat_detail.dart';
import 'package:liqliquid/models_new/video/video_detail/ugc_season.dart';
import 'package:liqliquid/pages/common/common_intro_controller.dart';
import 'package:liqliquid/pages/dynamics_repost/view.dart';
import 'package:liqliquid/pages/video/related/controller.dart';
import 'package:liqliquid/pages/video/reply/controller.dart';
import 'package:liqliquid/plugin/pl_player/models/play_repeat.dart';
import 'package:liqliquid/services/service_locator.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:liqliquid/utils/device_utils.dart';
import 'package:liqliquid/utils/extension/size_ext.dart';
import 'package:liqliquid/utils/extension/string_ext.dart';
import 'package:liqliquid/utils/feed_back.dart';
import 'package:liqliquid/utils/global_data.dart';
import 'package:liqliquid/utils/id_utils.dart';
import 'package:liqliquid/utils/page_utils.dart';
import 'package:liqliquid/utils/platform_utils.dart';
import 'package:liqliquid/utils/request_utils.dart';
import 'package:liqliquid/utils/share_utils.dart';
import 'package:liqliquid/utils/storage_pref.dart';
import 'package:liqliquid/utils/utils.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class UgcIntroController extends CommonIntroController with ReloadMixin {
  late ExpandableController expandableCtr;

  final RxBool status = true.obs;

  // up涓荤矇涓濇暟
  final Rx<MemberCardInfoData> userStat = MemberCardInfoData().obs;
  // 鍏虫敞鐘舵€?榛樿鏈叧娉?  late final Rx<RelationData> followStatus = Rx(RelationData());
  late final RxMap staffRelations = {}.obs;

  // 鏄惁鐐硅俯
  final RxBool hasDislike = false.obs;

  late final showArgueMsg = Pref.showArgueMsg;
  late final enableAi = Pref.enableAi;
  late final horizontalMemberPage = Pref.horizontalMemberPage;

  AiConclusionResult? aiConclusionResult;

  late final Map<int?, bool> seasonFavState = {};

  @override
  void onInit() {
    super.onInit();
    bool alwaysExpandIntroPanel = Pref.alwaysExpandIntroPanel;
    expandableCtr = ExpandableController(
      initialExpanded: alwaysExpandIntroPanel,
    );
    if (!alwaysExpandIntroPanel && Pref.expandIntroPanelH) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!expandableCtr.expanded && !DeviceUtils.size.isPortrait) {
          expandableCtr.toggle();
        }
      });
    }

    videoDetail.value.title = Get.arguments['title'] ?? '';
  }

  // 鑾峰彇瑙嗛绠€浠?鍒唒
  @override
  Future<void> queryVideoIntro() async {
    queryVideoTags();
    final res = await VideoHttp.videoIntro(bvid: bvid);
    if (res case Success(:final response)) {
      if (response.redirectUrl != null &&
          videoDetailCtr.epId == null &&
          videoDetailCtr.seasonId == null) {
        if (!isClosed) {
          PageUtils.viewPgcFromUri(response.redirectUrl!, off: true);
        }
        return;
      }
      videoPlayerServiceHandler?.onVideoDetailChange(
        response,
        cid.value,
        heroTag,
      );
      if (videoDetail.value.ugcSeason?.id == response.ugcSeason?.id) {
        // keep reversed season
        response.ugcSeason = videoDetail.value.ugcSeason;
      }
      if (videoDetail.value.cid == response.cid) {
        // keep reversed pages
        response
          ..pages = videoDetail.value.pages
          ..isPageReversed = videoDetail.value.isPageReversed;
      }
      videoDetail.value = response;
      try {
        if (videoDetailCtr.cover.value.isEmpty ||
            (videoDetailCtr.videoUrl.isNullOrEmpty &&
                !videoDetailCtr.isQuerying)) {
          videoDetailCtr.cover.value = response.pic ?? '';
        }
        if (videoDetailCtr.showReply) {
          try {
            Get.find<VideoReplyController>(tag: heroTag).count.value =
                response.stat?.reply ?? 0;
          } catch (_) {}
        }
      } catch (_) {}
      final pages = videoDetail.value.pages;
      if (pages != null && pages.isNotEmpty && cid.value == 0) {
        cid.value = pages.first.cid!;
      }
      queryUserStat(response.staff);
    } else {
      res.toast();
      status.value = false;
    }

    if (isLogin) {
      queryAllStatus();
      queryFollowStatus();
    }
  }

  // 鑾峰彇up涓荤矇涓濇暟
  Future<void> queryUserStat(List<Staff>? staff) async {
    if (staff != null && staff.isNotEmpty) {
      final res = await Request().get(
        Api.relations,
        queryParameters: {'fids': staff.map((item) => item.mid).join(',')},
      );
      if (res.data['code'] == 0) {
        staffRelations.addAll({'status': true, ...?res.data['data']});
      }
    } else {
      final mid = videoDetail.value.owner?.mid;
      if (mid == null) {
        return;
      }
      final res = await MemberHttp.memberCardInfo(mid: mid);
      if (res case Success(:final response)) {
        userStat.value = response;
      }
    }
  }

  Future<void> queryAllStatus() async {
    final result = await VideoHttp.videoRelation(bvid: bvid);
    if (result case Success(:final response)) {
      late final stat = videoDetail.value.stat;
      if (response.like!) {
        stat?.like = max(1, stat.like);
      }
      if (response.favorite!) {
        stat?.favorite = max(1, stat.favorite);
      }
      hasLike.value = response.like!;
      hasDislike.value = response.dislike!;
      coinNum.value = response.coin!;
      hasFav.value = response.favorite!;
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
    final result = await VideoHttp.ugcTriple(bvid: bvid);
    if (result case Success(:final response)) {
      late final stat = videoDetail.value.stat;
      if (response.like == true && !hasLike.value) {
        stat?.like++;
        hasLike.value = true;
      }
      if (response.coin == true && !hasCoin) {
        stat?.coin += 2;
        coinNum.value = 2;
        GlobalData().afterCoin(2);
      }
      if (response.fav == true && !hasFav.value) {
        stat?.favorite++;
        hasFav.value = true;
      }
      hasDislike.value = false;
      if (!hasCoin) {
        SmartDialog.showToast('鎶曞竵澶辫触');
      } else {
        SmartDialog.showToast('涓夎繛鎴愬姛');
      }
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
    if (videoDetail.value.stat == null) {
      return;
    }
    final newVal = !hasLike.value;
    final result = await VideoHttp.likeVideo(bvid: bvid, type: newVal);
    if (result case Success(:final response)) {
      SmartDialog.showToast(newVal ? response : '鍙栨秷璧?);
      videoDetail.value.stat?.like += newVal ? 1 : -1;
      hasLike.value = newVal;
      if (newVal) {
        hasDislike.value = false;
      }
    } else {
      result.toast();
    }
  }

  Future<void> actionDislikeVideo() async {
    if (!isLogin) {
      SmartDialog.showToast('璐﹀彿鏈櫥褰?);
      return;
    }
    final res = await VideoHttp.dislikeVideo(
      bvid: bvid,
      type: !hasDislike.value,
    );
    if (res.isSuccess) {
      if (!hasDislike.value) {
        SmartDialog.showToast('鐐硅俯鎴愬姛');
        hasDislike.value = true;
        if (hasLike.value) {
          videoDetail.value.stat?.like--;
          hasLike.value = false;
        }
      } else {
        SmartDialog.showToast('鍙栨秷韪?);
        hasDislike.value = false;
      }
    } else {
      res.toast();
    }
  }

  @override
  int get copyright => videoDetail.value.copyright ?? 1;

  @override
  (Object, int) get getFavRidType => (IdUtils.bv2av(bvid), 2);

  @override
  StatDetail? getStat() => videoDetail.value.stat;

  // 鍒嗕韩瑙嗛
  @override
  void actionShareVideo(BuildContext context) {
    final videoDetail = this.videoDetail.value;
    final playedTimePos = videoDetailCtr.playedTimePos;
    String videoUrl = '${HttpString.baseUrl}/video/$bvid';
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          ListTile(
            dense: true,
            title: const Text(
              '澶嶅埗閾炬帴',
              style: TextStyle(fontSize: 14),
            ),
            onTap: () {
              Get.back();
              Utils.copyText(videoUrl);
            },
            trailing: playedTimePos.isNotEmpty
                ? iconButton(
                    tooltip: '绮剧‘鍒嗕韩',
                    icon: const Icon(Icons.timer_outlined),
                    onPressed: () {
                      Get.back();
                      Utils.copyText('$videoUrl$playedTimePos');
                    },
                  )
                : null,
          ),
          ListTile(
            dense: true,
            title: const Text(
              '鍏跺畠app鎵撳紑',
              style: TextStyle(fontSize: 14),
            ),
            onTap: () {
              Get.back();
              PageUtils.launchURL(videoUrl);
            },
          ),
          if (PlatformUtils.isMobile)
            ListTile(
              dense: true,
              title: const Text(
                '鍒嗕韩瑙嗛',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                Get.back();
                ShareUtils.shareText(
                  '${videoDetail.title} '
                  'UP涓? ${videoDetail.owner!.name!}'
                  ' - $videoUrl',
                );
              },
            ),
          if (isLogin)
            ListTile(
              dense: true,
              title: const Text(
                '鍒嗕韩鑷冲姩鎬?,
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                Get.back();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (context) => RepostPanel(
                    rid: videoDetail.aid,
                    dynType: 8,
                    pic: videoDetail.pic,
                    title: videoDetail.title,
                    uname: videoDetail.owner?.name,
                  ),
                );
              },
            ),
          if (isLogin)
            ListTile(
              dense: true,
              title: const Text(
                '鍒嗕韩鑷虫秷鎭?,
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                Get.back();
                try {
                  PageUtils.pmShare(
                    context,
                    content: {
                      "id": videoDetail.aid!.toString(),
                      "title": videoDetail.title!,
                      "headline": videoDetail.title!,
                      "source": 5,
                      "thumb": videoDetail.pic!,
                      "author": videoDetail.owner!.name!,
                      "author_id": videoDetail.owner!.mid!.toString(),
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

  // 鏌ヨ鍏虫敞鐘舵€?  Future<void> queryFollowStatus() async {
    final videoDetail = this.videoDetail.value;
    if (videoDetail.owner == null || videoDetail.staff?.isNotEmpty == true) {
      return;
    }
    final res = await UserHttp.userRelation(videoDetail.owner!.mid!);
    if (res case Success(:final response)) {
      if (response.special == 1) response.attribute = -10;
      followStatus.value = response;
    }
  }

  // 鍏虫敞/鍙栧叧up
  Future<void> actionRelationMod(BuildContext context) async {
    if (!isLogin) {
      SmartDialog.showToast('璐﹀彿鏈櫥褰?);
      return;
    }
    final videoDetail = this.videoDetail.value;
    if (videoDetail.staff?.isNotEmpty == true) {
      return;
    }
    int? mid = videoDetail.owner?.mid;
    if (mid == null) {
      return;
    }
    int attr = followStatus.value.attribute ?? 0;
    if (attr == 128) {
      final res = await VideoHttp.relationMod(
        mid: mid,
        act: 6,
        reSrc: 11,
      );
      if (res.isSuccess) {
        followStatus
          ..value.attribute = 0
          ..refresh();
      }
      return;
    } else {
      RequestUtils.actionRelationMod(
        context: context,
        mid: mid,
        isFollow: attr != 0,
        followStatus: followStatus.value,
        afterMod: (attribute) {
          followStatus
            ..value.attribute = attribute
            ..refresh();
          Future.delayed(const Duration(milliseconds: 500), queryFollowStatus);
        },
      );
    }
  }

  // 淇敼鍒哖鎴栫暘鍓у垎闆?  Future<bool> onChangeEpisode(
    BaseEpisodeItem episode, {
    bool isStein = false,
  }) async {
    try {
      final String bvid = episode.bvid ?? this.bvid;
      final int aid = episode.aid ?? IdUtils.bv2av(bvid);
      int? cid = episode.cid;
      Dimension? dimension;
      if (cid == null) {
        if (await SearchHttp.ab2cWithDimension(aid: aid, bvid: bvid)
            case final res?) {
          cid = res.cid;
          dimension = res.dimension;
        }
      }
      if (cid == null) {
        return false;
      }

      final String? cover = episode.cover;

      // 閲嶆柊鑾峰彇瑙嗛璧勬簮
      if (videoDetailCtr.isPlayAll) {
        if (videoDetailCtr.mediaList.indexWhere((item) => item.bvid == bvid) ==
            -1) {
          if (dimension == null && episode is EpisodeItem) {
            dimension = episode.page?.dimension;
          }
          PageUtils.toVideoPage(
            bvid: bvid,
            cid: cid,
            cover: cover,
            dimension: dimension,
          );
          return false;
        }
      }

      videoDetailCtr
        ..plPlayerController.pause()
        ..makeHeartBeat()
        ..updateMediaListHistory(aid)
        ..onReset(isStein: isStein)
        ..bvid = bvid
        ..aid = aid
        ..cid.value = cid
        ..queryVideoUrl();

      if (this.bvid != bvid) {
        reload = true;
        aiConclusionResult = null;

        if (cover != null && cover.isNotEmpty) {
          videoDetailCtr.cover.value = cover;
        }

        // 閲嶆柊璇锋眰鐩稿叧瑙嗛
        if (videoDetailCtr.plPlayerController.showRelatedVideo) {
          try {
            Get.find<RelatedController>(tag: heroTag)
              ..bvid = bvid
              ..queryData();
          } catch (_) {}
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

        hasLater.value = videoDetailCtr.sourceType == SourceType.watchLater;
        this.bvid = bvid;
        queryVideoIntro();
      } else {
        if (episode is Part) {
          final videoDetail = this.videoDetail.value;
          videoPlayerServiceHandler?.onVideoDetailChange(
            episode,
            cid,
            heroTag,
            artist: videoDetail.owner?.name,
            cover: videoDetail.pic,
          );
        }
      }

      this.cid.value = cid;
      queryOnlineTotal();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('ugc onChangeEpisode: $e');
      return false;
    }
  }

  @override
  void onClose() {
    expandableCtr.dispose();
    super.onClose();
  }

  /// 鎾斁涓婁竴涓?  @override
  bool prevPlay([bool skipPart = false]) {
    final List<BaseEpisodeItem> episodes = <BaseEpisodeItem>[];
    bool isPart = false;

    final videoDetail = this.videoDetail.value;

    if (!skipPart && (videoDetail.pages?.length ?? 0) > 1) {
      isPart = true;
      episodes.addAll(videoDetail.pages!);
    } else if (videoDetailCtr.isPlayAll) {
      episodes.addAll(videoDetailCtr.mediaList);
    } else if (videoDetail.ugcSeason != null) {
      final UgcSeason ugcSeason = videoDetail.ugcSeason!;
      final List<SectionItem> sections = ugcSeason.sections!;
      for (int i = 0; i < sections.length; i++) {
        final List<EpisodeItem> episodesList = sections[i].episodes!;
        episodes.addAll(episodesList);
      }
    }

    final int currentIndex = episodes.indexWhere(
      (e) =>
          e.cid ==
          (skipPart
              ? videoDetail.isPageReversed
                    ? videoDetail.pages!.last.cid
                    : videoDetail.pages!.first.cid
              : this.cid.value),
    );

    int prevIndex = currentIndex - 1;
    final PlayRepeat playRepeat = videoDetailCtr.plPlayerController.playRepeat;

    // 鍒楄〃寰幆
    if (prevIndex < 0) {
      if (isPart &&
          (videoDetailCtr.isPlayAll || videoDetail.ugcSeason != null)) {
        return prevPlay(true);
      }
      if (playRepeat == PlayRepeat.listCycle) {
        prevIndex = episodes.length - 1;
      } else {
        return false;
      }
    }

    int? cid = episodes[prevIndex].cid;
    while (cid == null) {
      prevIndex--;
      if (prevIndex < 0) {
        return false;
      }
      cid = episodes[prevIndex].cid;
    }

    if (cid != this.cid.value) {
      onChangeEpisode(episodes[prevIndex]);
      return true;
    } else {
      return false;
    }
  }

  /// 鍒楄〃寰幆鎴栬€呴『搴忔挱鏀炬椂锛岃嚜鍔ㄦ挱鏀句笅涓€涓?  @override
  bool nextPlay([bool skipPart = false]) {
    try {
      final List<BaseEpisodeItem> episodes = <BaseEpisodeItem>[];
      bool isPart = false;
      final videoDetail = this.videoDetail.value;

      // part -> playall -> season
      if (!skipPart && (videoDetail.pages?.length ?? 0) > 1) {
        isPart = true;
        final List<Part> pages = videoDetail.pages!;
        episodes.addAll(pages);
      } else if (videoDetailCtr.isPlayAll) {
        episodes.addAll(videoDetailCtr.mediaList);
      } else if (videoDetail.ugcSeason != null) {
        final UgcSeason ugcSeason = videoDetail.ugcSeason!;
        final List<SectionItem> sections = ugcSeason.sections!;
        for (int i = 0; i < sections.length; i++) {
          final List<EpisodeItem> episodesList = sections[i].episodes!;
          episodes.addAll(episodesList);
        }
      }

      final PlayRepeat playRepeat =
          videoDetailCtr.plPlayerController.playRepeat;

      if (episodes.isEmpty) {
        if (playRepeat == PlayRepeat.listCycle) {
          videoDetailCtr.plPlayerController.play(repeat: true);
          return true;
        }
        if (playRepeat == PlayRepeat.autoPlayRelated &&
            videoDetailCtr.plPlayerController.showRelatedVideo) {
          return playRelated();
        }
        return false;
      }

      final int currentIndex = episodes.indexWhere(
        (e) =>
            e.cid ==
            (skipPart
                ? videoDetail.isPageReversed
                      ? videoDetail.pages!.last.cid
                      : videoDetail.pages!.first.cid
                : this.cid.value),
      );

      int nextIndex = currentIndex + 1;

      if (!isPart &&
          videoDetailCtr.isPlayAll &&
          currentIndex == episodes.length - 2) {
        videoDetailCtr.getMediaList();
      }

      // 鍒楄〃寰幆
      if (nextIndex >= episodes.length) {
        if (isPart &&
            (videoDetailCtr.isPlayAll || videoDetail.ugcSeason != null)) {
          return nextPlay(true);
        }

        if (playRepeat == PlayRepeat.listCycle) {
          nextIndex = 0;
        } else if (playRepeat == PlayRepeat.autoPlayRelated &&
            videoDetailCtr.plPlayerController.showRelatedVideo) {
          return playRelated();
        } else {
          return false;
        }
      }

      int? cid = episodes[nextIndex].cid;
      while (cid == null) {
        nextIndex++;
        if (nextIndex >= episodes.length) {
          return false;
        }
        cid = episodes[nextIndex].cid;
      }

      if (cid != this.cid.value) {
        onChangeEpisode(episodes[nextIndex]);
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  bool playRelated() {
    RelatedController relatedCtr;
    if (Get.isRegistered<RelatedController>(tag: heroTag)) {
      relatedCtr = Get.find<RelatedController>(tag: heroTag);
    } else {
      relatedCtr = Get.put(RelatedController(autoQuery: false), tag: heroTag)
        ..queryData().whenComplete(playRelated);
      return false;
    }

    if (relatedCtr.loadingState.value case Success(:final response)) {
      final firstItem = response?.firstOrNull;
      if (firstItem == null) {
        SmartDialog.showToast('鏆傛棤鐩稿叧瑙嗛锛屽仠姝㈣繛鎾?);
        return false;
      }
      onChangeEpisode(
        BaseEpisodeItem(
          aid: firstItem.aid,
          bvid: firstItem.bvid,
          cid: firstItem.cid,
          cover: firstItem.cover,
        ),
      );
      return true;
    }

    return false;
  }

  // ai鎬荤粨
  static Future<AiConclusionResult?> getAiConclusion(
    String bvid,
    int cid,
    int? mid,
  ) async {
    if (!Accounts.heartbeat.isLogin) {
      SmartDialog.showToast("璐﹀彿鏈櫥褰?);
      return null;
    }
    SmartDialog.showLoading(msg: '姝ｅ湪鑾峰彇AI鎬荤粨');
    final res = await VideoHttp.aiConclusion(
      bvid: bvid,
      cid: cid,
      upMid: mid,
    );
    SmartDialog.dismiss();
    if (res case Success(:final response)) {
      return response.modelResult;
    } else if (res is Error && res.code == 1) {
      SmartDialog.showToast("AI澶勭悊涓紝璇风◢鍚庡啀璇?);
    } else {
      SmartDialog.showToast("褰撳墠瑙嗛鏆備笉鏀寔AI瑙嗛鎬荤粨");
    }
    return null;
  }

  Future<void> aiConclusion() async {
    aiConclusionResult = await getAiConclusion(
      bvid,
      cid.value,
      videoDetail.value.owner?.mid,
    );
  }
}

