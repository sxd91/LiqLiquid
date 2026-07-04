import 'package:liqliquid/pages/article/view.dart';
import 'package:liqliquid/pages/article_list/view.dart';
import 'package:liqliquid/pages/audio/view.dart';
import 'package:liqliquid/pages/blacklist/view.dart';
import 'package:liqliquid/pages/bubble/view.dart';
import 'package:liqliquid/pages/danmaku_block/view.dart';
import 'package:liqliquid/pages/dlna/view.dart';
import 'package:liqliquid/pages/download/view.dart';
import 'package:liqliquid/pages/dynamics/view.dart';
import 'package:liqliquid/pages/dynamics_create_vote/view.dart';
import 'package:liqliquid/pages/dynamics_detail/view.dart';
import 'package:liqliquid/pages/dynamics_topic/view.dart';
import 'package:liqliquid/pages/dynamics_topic_rcmd/view.dart';
import 'package:liqliquid/pages/fan/view.dart';
import 'package:liqliquid/pages/fav/view.dart';
import 'package:liqliquid/pages/fav_create/view.dart';
import 'package:liqliquid/pages/fav_detail/view.dart';
import 'package:liqliquid/pages/fav_search/view.dart';
import 'package:liqliquid/pages/follow/view.dart';
import 'package:liqliquid/pages/follow_search/view.dart';
import 'package:liqliquid/pages/follow_type/follow_same/view.dart';
import 'package:liqliquid/pages/follow_type/followed/view.dart';
import 'package:liqliquid/pages/history/view.dart';
import 'package:liqliquid/pages/history_search/view.dart';
import 'package:liqliquid/pages/home/view.dart';
import 'package:liqliquid/pages/hot/view.dart';
import 'package:liqliquid/pages/later/view.dart';
import 'package:liqliquid/pages/later_search/view.dart';
import 'package:liqliquid/pages/live_dm_block/view.dart';
import 'package:liqliquid/pages/live_room/view.dart';
import 'package:liqliquid/pages/login/view.dart';
import 'package:liqliquid/pages/main/view.dart';
import 'package:liqliquid/pages/main_reply/view.dart';
import 'package:liqliquid/pages/match_info/view.dart';
import 'package:liqliquid/pages/member/view.dart';
import 'package:liqliquid/pages/member_dynamics/view.dart';
import 'package:liqliquid/pages/member_guard/view.dart';
import 'package:liqliquid/pages/member_profile/view.dart';
import 'package:liqliquid/pages/member_search/view.dart';
import 'package:liqliquid/pages/member_upower_rank/view.dart';
import 'package:liqliquid/pages/member_video_web/archive/view.dart';
import 'package:liqliquid/pages/member_video_web/season_series/view.dart';
import 'package:liqliquid/pages/msg_feed_top/at_me/view.dart';
import 'package:liqliquid/pages/msg_feed_top/like_detail/view.dart';
import 'package:liqliquid/pages/msg_feed_top/like_me/view.dart';
import 'package:liqliquid/pages/msg_feed_top/reply_me/view.dart';
import 'package:liqliquid/pages/msg_feed_top/sys_msg/view.dart';
import 'package:liqliquid/pages/music/view.dart';
import 'package:liqliquid/pages/my_reply/view.dart';
import 'package:liqliquid/pages/popular_precious/view.dart';
import 'package:liqliquid/pages/popular_series/view.dart';
import 'package:liqliquid/pages/search/view.dart';
import 'package:liqliquid/pages/search_result/view.dart';
import 'package:liqliquid/pages/search_trending/view.dart';
import 'package:liqliquid/pages/setting/pages/bar_set.dart';
import 'package:liqliquid/pages/setting/pages/color_select.dart';
import 'package:liqliquid/pages/setting/pages/display_mode.dart';
import 'package:liqliquid/pages/setting/pages/font_size_select.dart';
import 'package:liqliquid/pages/setting/pages/logs.dart';
import 'package:liqliquid/pages/setting/pages/play_speed_set.dart';
import 'package:liqliquid/pages/setting/view.dart';
import 'package:liqliquid/pages/settings_search/view.dart';
import 'package:liqliquid/pages/space_setting/view.dart';
import 'package:liqliquid/pages/sponsor_block/view.dart';
import 'package:liqliquid/pages/subscription/view.dart';
import 'package:liqliquid/pages/subscription_detail/view.dart';
import 'package:liqliquid/pages/video/view.dart';
import 'package:liqliquid/pages/webview/view.dart';
import 'package:liqliquid/pages/whisper/view.dart';
import 'package:liqliquid/pages/whisper_detail/view.dart';
import 'package:get/get.dart';

class Routes {
  static final List<GetPage<dynamic>> getPages = [
    GetPage(name: '/', page: () => const MainApp()),
    // 棣栭〉(鎺ㄨ崘)
    GetPage(name: '/home', page: () => const HomePage()),
    // 鐑棬
    GetPage(name: '/hot', page: () => const HotPage()),
    // 瑙嗛璇︽儏
    GetPage(name: '/videoV', page: () => const VideoDetailPageV(), transition: Transition.cupertino),
    //
    GetPage(name: '/webview', page: () => const WebviewPage()),
    // 璁剧疆
    GetPage(name: '/setting', page: () => const SettingPage()),
    //
    GetPage(name: '/fav', page: () => const FavPage()),
    //
    GetPage(name: '/favDetail', page: () => const FavDetailPage(), transition: Transition.cupertino),
    // 绋嶅悗鍐嶇湅
    GetPage(name: '/later', page: () => const LaterPage()),
    // 鍘嗗彶璁板綍
    GetPage(name: '/history', page: () => const HistoryPage()),
    // 鎼滅储椤甸潰
    GetPage(name: '/search', page: () => const SearchPage(), transition: Transition.cupertino),
    // 鎼滅储缁撴灉
    GetPage(name: '/searchResult', page: () => const SearchResultPage()),
    // 鍔ㄦ€?    GetPage(name: '/dynamics', page: () => const DynamicsPage()),
    GetPage(name: '/dynamicDetail', page: () => const DynamicDetailPage(), transition: Transition.cupertino),
    // 鍏虫敞
    GetPage(name: '/follow', page: () => const FollowPage()),
    // 绮変笣
    GetPage(name: '/fan', page: () => const FansPage()),
    // 鐩存挱璇︽儏
    GetPage(name: '/liveRoom', page: () => const LiveRoomPage(), transition: Transition.cupertino),
    // 鐢ㄦ埛涓績
    GetPage(name: '/member', page: () => const MemberPage(), transition: Transition.cupertino),
    GetPage(name: '/memberSearch', page: () => const MemberSearchPage()),
    //
    GetPage(name: '/blackListPage', page: () => const BlackListPage()),
    GetPage(name: '/colorSetting', page: () => const ColorSelectPage()),
    GetPage(name: '/fontSizeSetting', page: () => const FontSizeSelectPage()),
    // 灞忓箷甯х巼
    GetPage(name: '/displayModeSetting', page: () => const SetDisplayMode()),
    //
    GetPage(name: '/articlePage', page: () => const ArticlePage(), transition: Transition.cupertino),

    // 鍘嗗彶璁板綍鎼滅储
    GetPage(name: '/playSpeedSet', page: () => const PlaySpeedPage()),
    // 鏀惰棌鎼滅储
    GetPage(name: '/favSearch', page: () => const FavSearchPage()),
    GetPage(name: '/historySearch', page: () => const HistorySearchPage()),
    GetPage(name: '/laterSearch', page: () => const LaterSearchPage()),
    GetPage(name: '/followSearch', page: () => const FollowSearchPage()),
    // 娑堟伅椤甸潰
    GetPage(name: '/whisper', page: () => const WhisperPage()),
    // 绉佷俊璇︽儏
    GetPage(name: '/whisperDetail', page: () => const WhisperDetailPage(), transition: Transition.cupertino),
    // 鍥炲鎴戠殑
    GetPage(name: '/replyMe', page: () => const ReplyMePage()),
    // @鎴戠殑
    GetPage(name: '/atMe', page: () => const AtMePage()),
    // 鏀跺埌鐨勮禐
    GetPage(name: '/likeMe', page: () => const LikeMePage()),
    // 绯荤粺娑堟伅
    GetPage(name: '/sysMsg', page: () => const SysMsgPage()),
    // 鐧诲綍椤甸潰
    GetPage(name: '/loginPage', page: () => const LoginPage()),
    // 鐢ㄦ埛鍔ㄦ€?    GetPage(name: '/memberDynamics', page: () => const MemberDynamicsPage()),
    // 鏃ュ織
    GetPage(name: '/logs', page: () => const LogsPage()),
    // 璁㈤槄
    GetPage(name: '/subscription', page: () => const SubPage()),
    // 璁㈤槄璇︽儏
    GetPage(name: '/subDetail', page: () => const SubDetailPage()),
    // 寮瑰箷灞忚斀绠＄悊
    GetPage(name: '/danmakuBlock', page: () => const DanmakuBlockPage()),
    GetPage(name: '/sponsorBlock', page: () => const SponsorBlockPage()),
    GetPage(name: '/createFav', page: () => const CreateFavPage()),
    GetPage(name: '/editProfile', page: () => const EditProfilePage()),
    GetPage(name: '/settingsSearch', page: () => const SettingsSearchPage()),
    GetPage(name: '/searchTrending', page: () => const SearchTrendingPage()),
    GetPage(name: '/dynTopic', page: () => const DynTopicPage()),
    GetPage(name: '/articleList', page: () => const ArticleListPage()),
    GetPage(name: '/barSetting', page: () => const BarSetPage()),
    GetPage(name: '/upowerRank', page: () => const UpowerRankPage()),
    GetPage(name: '/spaceSetting', page: () => const SpaceSettingPage()),
    GetPage(name: '/dynTopicRcmd', page: () => const DynTopicRcmdPage()),
    GetPage(name: '/matchInfo', page: () => const MatchInfoPage()),
    GetPage(name: '/msgLikeDetail', page: () => const LikeDetailPage()),
    GetPage(name: '/liveDmBlockPage', page: () => const LiveDmBlockPage()),
    GetPage(name: '/createVote', page: () => const CreateVotePage()),
    GetPage(name: '/musicDetail', page: () => const MusicDetailPage()),
    GetPage(name: '/popularSeries', page: () => const PopularSeriesPage()),
    GetPage(name: '/popularPrecious', page: () => const PopularPreciousPage()),
    GetPage(name: '/audio', page: () => const AudioPage()),
    GetPage(name: '/mainReply', page: () => const MainReplyPage()),
    GetPage(name: '/followed', page: () => const FollowedPage()),
    GetPage(name: '/sameFollowing', page: () => const FollowSamePage()),
    GetPage(name: '/download', page: () => const DownloadPage()),
    GetPage(name: '/dlna', page: () => const DLNAPage()),
    GetPage(name: '/myReply', page: () => const MyReply()),
    GetPage(name: '/videoWeb', page: () => const MemberVideoWeb()),
    GetPage(name: '/ssWeb', page: () => const MemberSSWeb()),
    GetPage(name: '/memberGuard', page: () => const MemberGuard()),
    GetPage(name: '/bubble', page: () => const BubblePage()),
  ];
}
