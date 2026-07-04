import 'package:liqliquid/http/constants.dart';

abstract final class Api {
  // 鎺ㄨ崘瑙嗛
  static const String recommendListApp =
      '${HttpString.appBaseUrl}/x/v2/feed/index';
  static const String recommendListWeb =
      '/x/web-interface/wbi/index/top/feed/rcmd';

  // APP绔笉鎰熷叴瓒ｃ€佸彇娑堜笉鎰熷叴瓒?  static const String feedDislike = '${HttpString.appBaseUrl}/x/feed/dislike';
  static const String feedDislikeCancel =
      '${HttpString.appBaseUrl}/x/feed/dislike/cancel';

  // 鐑棬瑙嗛
  static const String hotList = '/x/web-interface/popular';

  // 瑙嗛娴?  // https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/video/videostream_url.md
  static const String ugcUrl = '/x/player/wbi/playurl';

  // 鐣墽瑙嗛娴?  // https://api.bilibili.com/pgc/player/web/v2/playurl?cid=104236640&bvid=BV13t411n7ex
  static const String pgcUrl = '/pgc/player/web/v2/playurl';

  static const String pugvUrl = '/pugv/player/web/playurl';

  static const String tvPlayUrl = '/x/tv/playurl';

  // 瀛楀箷
  // aid, cid
  static const String playInfo = '/x/player/wbi/v2';

  // 瑙嗛璇︽儏
  // 绔栧睆 https://api.bilibili.com/x/web-interface/view?aid=527403921
  // https://api.bilibili.com/x/web-interface/view/detail  鑾峰彇瑙嗛瓒呰缁嗕俊鎭?web绔?
  static const String videoIntro = '/x/web-interface/view';
  // 瑙嗛璇︽儏 瓒呰缁?  // https://api.bilibili.com/x/web-interface/view/detail?aid=527403921

  /// https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/video/action.md
  // 鐐硅禐 Post
  /// aid	num	绋夸欢avid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  /// bvid	str	绋夸欢bvid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  /// like	num	鎿嶄綔鏂瑰紡	蹇呰	1锛氱偣璧?2锛氬彇娑堣禐
  // csrf	str	CSRF Token锛堜綅浜巆ookie锛?蹇呰
  // https://api.bilibili.com/x/web-interface/archive/like
  // static const String likeVideo = '/x/web-interface/archive/like';

  // 鏀圭敤app绔偣璧炴帴鍙?  static const String likeVideo = '${HttpString.appBaseUrl}/x/v2/view/like';
  //鍒ゆ柇瑙嗛鏄惁琚偣璧烇紙鍙岀锛塆et
  // access_key	str	APP鐧诲綍Token	APP鏂瑰紡蹇呰
  /// aid	num	绋夸欢avid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  /// bvid	str	绋夸欢bvid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  // https://api.bilibili.com/x/web-interface/archive/has/like
  // static const String hasLikeVideo = '/x/web-interface/archive/has/like';

  static const String pgcLikeCoinFav = '/pgc/season/episode/community';

  // 瑙嗛鐐硅俯 web绔笉鏀寔

  // 鐐硅俯 Post(app绔?
  /// access_key str	APP鐧诲綍Token 蹇呰
  /// aid num	绋夸欢avid	蹇呰
  ///
  static const String dislikeVideo =
      '${HttpString.appBaseUrl}/x/v2/view/dislike';

  // 鎶曞竵瑙嗛锛坵eb绔級POST
  /// aid	num	绋夸欢avid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  /// bvid	str	绋夸欢bvid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  /// multiply	num	鎶曞竵鏁伴噺	蹇呰	涓婇檺涓?
  /// select_like	num	鏄惁闄勫姞鐐硅禐	闈炲繀瑕?0锛氫笉鐐硅禐 1锛氬悓鏃剁偣璧?榛樿涓?
  // csrf	str	CSRF Token锛堜綅浜巆ookie锛?蹇呰
  // https://api.bilibili.com/x/web-interface/coin/add
  // static const String coinVideo = '/x/web-interface/coin/add';

  // 鏀圭敤app绔姇甯佹帴鍙?  static const String coinVideo = '${HttpString.appBaseUrl}/x/v2/view/coin/add';

  // 鍒ゆ柇瑙嗛鏄惁琚姇甯侊紙鍙岀锛塆ET
  // access_key	str	APP鐧诲綍Token	APP鏂瑰紡蹇呰
  /// aid	num	绋夸欢avid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  /// bvid	str	绋夸欢bvid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  /// https://api.bilibili.com/x/web-interface/archive/coins
  // static const String hasCoinVideo = '/x/web-interface/archive/coins';

  /// 鏀惰棌澶?璇︽儏
  /// media_id  褰撳墠鏀惰棌澶筰d 鎼滅储鍏ㄩ儴鏃朵负榛樿鏀惰棌澶筰d
  /// pn int 褰撳墠椤?  /// ps int pageSize
  /// keyword String 鎼滅储璇?  /// order String 鎺掑簭鏂瑰紡 view 鏈€澶氭挱鏀?mtime 鏈€杩戞敹钘?pubtime 鏈€杩戞姇绋?  /// tid int 鍒嗗尯id
  /// platform web
  /// type 0 褰撳墠鏀惰棌澶?1 鍏ㄩ儴鏀惰棌澶?  // https://api.bilibili.com/x/v3/fav/resource/list?media_id=76614671&pn=1&ps=20&keyword=&order=mtime&type=0&tid=0
  static const String favResourceList = '/x/v3/fav/resource/list';

  // 鏀惰棌瑙嗛锛堝弻绔級POST
  // access_key	str	APP鐧诲綍Token	APP鏂瑰紡蹇呰
  /// rid	num	绋夸欢avid	蹇呰
  /// type	num	蹇呴』涓?	蹇呰
  /// add_media_ids	nums	闇€瑕佸姞鍏ョ殑鏀惰棌澶筸lid	闈炲繀瑕?鍚屾椂娣诲姞澶氫釜锛岀敤,锛?2C锛夊垎闅?  /// del_media_ids	nums	闇€瑕佸彇娑堢殑鏀惰棌澶筸lid	闈炲繀瑕?鍚屾椂鍙栨秷澶氫釜锛岀敤,锛?2C锛夊垎闅?  // csrf	str	CSRF Token锛堜綅浜巆ookie锛?Cookie鏂瑰紡蹇呰
  // https://api.bilibili.com/medialist/gateway/coll/resource/deal
  // https://api.bilibili.com/x/v3/fav/resource/deal
  static const String favVideo = '/x/v3/fav/resource/batch-deal';

  static const String unfavAll = '/x/v3/fav/resource/unfav-all';

  static const String copyFav = '/x/v3/fav/resource/copy';

  static const String moveFav = '/x/v3/fav/resource/move';

  static const String cleanFav = '/x/v3/fav/resource/clean';

  static const String sortFav = '/x/v3/fav/resource/sort';

  static const String sortFavFolder = '/x/v3/fav/folder/sort';

  // 鍒ゆ柇瑙嗛鏄惁琚敹钘忥紙鍙岀锛塆ET
  /// aid
  // https://api.bilibili.com/x/v2/fav/video/favoured
  // static const String hasFavVideo = '/x/v2/fav/video/favoured';

  // 鍒嗕韩瑙嗛 锛圵eb绔級 POST
  // https://api.bilibili.com/x/web-interface/share/add
  // aid	num	绋夸欢avid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  // bvid	str	绋夸欢bvid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  // csrf	str	CSRF Token锛堜綅浜巆ookie锛?蹇呰

  // 涓€閿笁杩?  // https://api.bilibili.com/x/web-interface/archive/like/triple
  // aid	num	绋夸欢avid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  // bvid	str	绋夸欢bvid	蹇呰锛堝彲閫夛級	avid涓巄vid浠婚€変竴涓?  // csrf	str	CSRF Token锛堜綅浜巆ookie锛?蹇呰
  static const String ugcTriple = '/x/web-interface/archive/like/triple';

  static const String pgcTriple = '/pgc/season/episode/like/triple';

  // 鑾峰彇鎸囧畾鐢ㄦ埛鍒涘缓鐨勬墍鏈夋敹钘忓す淇℃伅
  // 璇ユ帴鍙ｄ篃鑳芥煡璇㈢洰鏍囧唴瀹筰d瀛樺湪浜庨偅浜涙敹钘忓す涓?  // up_mid	num	鐩爣鐢ㄦ埛mid	蹇呰
  // type	num	鐩爣鍐呭灞炴€?闈炲繀瑕?榛樿涓哄叏閮?0锛氬叏閮?2锛氳棰戠浠?  // rid	num	鐩爣 瑙嗛绋夸欢avid
  static const String favFolder = '/x/v3/fav/folder/created/list-all';

  static const String copyToview = '/x/v2/history/toview/copy';

  static const String moveToview = '/x/v2/history/toview/move';

  // 瑙嗛璇︽儏椤?鐩稿叧瑙嗛
  static const String relatedList = '/x/web-interface/archive/related';

  // 鏌ヨ鐢ㄦ埛涓庤嚜宸卞叧绯籣浠呮煡鍏虫敞
  static const String relation = '/x/relation';

  static const String relations = '/x/relation/relations';

  // 鎿嶄綔鐢ㄦ埛鍏崇郴
  static const String relationMod = '/x/relation/modify';

  // 鐩镐簰鍏崇郴鏌ヨ // 澶辨晥
  // static const String relationSearch = '/x/space/wbi/acc/relation';

  // 璇勮鍒楄〃
  // https://api.bilibili.com/x/v2/reply/main?csrf=6e22efc1a47225ea25f901f922b5cfdd&mode=3&oid=254175381&pagination_str=%7B%22offset%22:%22%22%7D&plat=1&seek_rpid=0&type=11
  static const String replyList = '/x/v2/reply';

  // 妤间腑妤?  static const String replyReplyList = '/x/v2/reply/reply';

  // 璇勮鐐硅禐
  static const String likeReply = '/x/v2/reply/action';

  static const String hateReply = '/x/v2/reply/hate';

  // 鍙戣〃璇勮
  // https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/comment/action.md
  static const String replyAdd = '/x/v2/reply/add';

  // 鍒犻櫎璇勮
  // https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/comment/action.md
  static const String replyDel = '/x/v2/reply/del';

  // 鐢ㄦ埛(琚?鍏虫敞鏁般€佹姇绋挎暟
  // https://api.bilibili.com/x/relation/stat?vmid=697166795
  static const String userStat = '/x/relation/stat';

  // 鑾峰彇鎴戠殑琛ㄦ儏鍒楄〃
  // business:reply锛堝洖澶嶏級dynamic锛堝姩鎬侊級
  //https://api.bilibili.com/x/emote/user/panel/web?business=reply
  static const String myEmote = '/x/emote/user/panel/web';

  // 鑾峰彇鐢ㄦ埛淇℃伅
  static const String userInfo = '/x/web-interface/nav';

  // 鑾峰彇褰撳墠鐢ㄦ埛鐘舵€?  static const String userStatOwner = '/x/web-interface/nav/stat';

  // 鏀惰棌澶?  // https://api.bilibili.com/x/v3/fav/folder/created/list?pn=1&ps=10&up_mid=17340771
  static const String userFavFolder = '/x/v3/fav/folder/created/list';

  static const String favFolderInfo = '/x/v3/fav/folder/info';

  static const String addFolder = '/x/v3/fav/folder/add';

  static const String editFolder = '/x/v3/fav/folder/edit';

  static const String deleteFolder = '/x/v3/fav/folder/del';

  // 姝ｅ湪鐩存挱鐨剈p & 鍏虫敞鐨剈p
  // https://api.bilibili.com/x/polymer/web-dynamic/v1/portal
  static const String followUp = '/x/polymer/web-dynamic/v1/portal';

  static const String dynUplist = '/x/polymer/web-dynamic/v1/uplist';

  // 鍏虫敞鐨剈p鍔ㄦ€?  // https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all
  // https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all?timezone_offset=-480&type=video&page=1&features=itemOpusStyle
  // https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all?host_mid=548196587&offset=&page=1&features=itemOpusStyle
  static const String followDynamic = '/x/polymer/web-dynamic/v1/feed/all';

  // 鍔ㄦ€佺偣璧?  // static const String likeDynamic =
  //     '${HttpString.tUrl}/dynamic_like/v1/dynamic_like/thumb';

  // 鍔ㄦ€佺偣璧?new
  static const String thumbDynamic = '/x/dynamic/feed/dyn/thumb';

  // 鑾峰彇绋嶅悗鍐嶇湅
  static const String seeYouLater = '/x/v2/history/toview/web';

  // 鑾峰彇鍘嗗彶璁板綍
  static const String historyList = '/x/web-interface/history/cursor';

  // 鏆傚仠鍘嗗彶璁板綍
  static const String pauseHistory = '/x/v2/history/shadow/set';

  // 鏌ヨ鍘嗗彶璁板綍鏆傚仠鐘舵€?  static const String historyStatus = '/x/v2/history/shadow?jsonp=jsonp';

  // 娓呯┖鍘嗗彶璁板綍
  static const String clearHistory = '/x/v2/history/clear';

  // 鍒犻櫎鏌愭潯鍘嗗彶璁板綍
  static const String delHistory = '/x/v2/history/delete';

  // 鎼滅储鍘嗗彶璁板綍
  static const String searchHistory = '/x/web-interface/history/search';

  // 鐑悳
  static const String hotSearchList =
      'https://s.search.bilibili.com/main/hotword';

  // 榛樿鎼滅储璇?  static const String searchDefault = '/x/web-interface/wbi/search/default';

  // 鎼滅储鍏抽敭璇?  static const String searchSuggest =
      'https://s.search.bilibili.com/main/suggest';

  // 鍒嗙被鎼滅储
  static const String searchByType = '/x/web-interface/wbi/search/type';

  static const String searchAll = '/x/web-interface/wbi/search/all/v2';

  // 璁板綍瑙嗛鎾斁杩涘害
  // https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/video/report.md
  static const String heartBeat = '/x/click-interface/web/heartbeat';

  static const String historyReport = '/x/v2/history/report';

  static const String roomEntryAction =
      '${HttpString.liveBaseUrl}/xlive/web-room/v1/index/roomEntryAction';

  static const String mediaListHistory = '/x/v1/medialist/history';

  // 鏌ヨ瑙嗛鍒哖鍒楄〃 (avid/bvid杞琧id)
  static const String ab2c = '/x/player/pagelist';

  // 鐣墽/鍓ч泦鏄庣粏
  static const String pgcInfo = '/pgc/view/web/season';

  static const String pugvInfo = '/pugv/view/web/season';

  // https://api.bilibili.com/pgc/season/episode/web/info?ep_id=12345678
  static const String episodeInfo = '/pgc/season/episode/web/info';

  // 鍏ㄩ儴鍏虫敞鐨剈p
  // vmid 鐢ㄦ埛id pn 椤电爜 ps 姣忛〉涓暟锛屾渶澶?0 order: desc
  // order_type 鎺掑簭瑙勫垯 鏈€杩戣闂紶绌猴紝鏈€甯歌闂紶 attention
  static const String followings = '/x/relation/followings';

  // 鎼滅储follow
  static const followSearch = '/x/relation/followings/search';

  // 绮変笣
  // vmid 鐢ㄦ埛id pn 椤电爜 ps 姣忛〉涓暟锛屾渶澶?0 order: desc
  // order_type 鎺掑簭瑙勫垯 鏈€杩戣闂紶绌猴紝鏈€甯歌闂紶 attention
  static const String fans = '/x/relation/fans';

  // 鐩存挱
  // ?page=1&page_size=30&platform=web
  static const String liveList =
      '${HttpString.liveBaseUrl}/xlive/web-interface/v1/second/getUserRecommend';

  // 鐩存挱闂磋鎯?  // cid roomId
  // qn 80:娴佺晠锛?50:楂樻竻锛?00:钃濆厜锛?0000:鍘熺敾锛?0000:4K, 30000:鏉滄瘮
  static const String liveRoomInfo =
      '${HttpString.liveBaseUrl}/xlive/web-room/v2/index/getRoomPlayInfo';

  static const String sendLiveMsg = '${HttpString.liveBaseUrl}/msg/send';

  // 鐩存挱闂磋鎯?H5
  static const String liveRoomInfoH5 =
      '${HttpString.liveBaseUrl}/xlive/web-room/v1/index/getH5InfoByRoom';

  // 鐩存挱闂村脊骞曢鑾峰彇
  // roomid roomId
  static const String liveRoomDmPrefetch =
      '${HttpString.liveBaseUrl}/xlive/web-room/v1/dM/gethistory';

  //鐩存挱闂村脊骞曞瘑閽ヨ幏鍙栨帴鍙?  static const String liveRoomDmToken =
      '${HttpString.liveBaseUrl}/xlive/web-room/v1/index/getDanmuInfo';

  // 鐢ㄦ埛淇℃伅 闇€瑕乄bi绛惧悕
  // https://api.bilibili.com/x/space/wbi/acc/info?mid=503427686&token=&platform=web&web_location=1550101&w_rid=d709892496ce93e3d94d6d37c95bde91&wts=1689301482
  static const String memberInfo = '/x/space/wbi/acc/info';

  static const String space = '${HttpString.appBaseUrl}/x/v2/space';

  static const String spaceArchive =
      '${HttpString.appBaseUrl}/x/v2/space/archive/cursor';

  static const String spaceStory =
      '${HttpString.appBaseUrl}/x/v2/feed/index/space/story/cursor';

  static const String spaceChargingArchive =
      '${HttpString.appBaseUrl}/x/v2/space/archive/charging';

  static const String spaceSeason =
      '${HttpString.appBaseUrl}/x/v2/space/season/videos';

  static const String spaceSeries =
      '${HttpString.appBaseUrl}/x/v2/space/series';

  static const String spaceBangumi =
      '${HttpString.appBaseUrl}/x/v2/space/bangumi';

  static const String spaceArticle =
      '${HttpString.appBaseUrl}/x/v2/space/article';

  static const String spaceFav = '/x/v3/fav/folder/space';

  static const String seasonSeries = '/x/polymer/web-space/seasons_series_list';

  // 鐢ㄦ埛鍚嶇墖淇℃伅
  static const String memberCardInfo = '/x/web-interface/card';

  // 鐢ㄦ埛鎶曠
  // https://api.bilibili.com/x/space/wbi/arc/search?
  // mid=85754245&
  // ps=30&
  // tid=0&
  // pn=1&
  // keyword=&
  // order=pubdate&
  // platform=web&
  // web_location=1550101&
  // order_avoided=true&
  // w_rid=d893cf98a4e010cf326373194a648360&
  // wts=1689767832
  static const String searchArchive = '/x/space/wbi/arc/search';

  // 鐢ㄦ埛鍔ㄦ€佹悳绱?  // static const String memberDynamicSearch = '/x/space/dynamic/search';
  static const String dynSearch = '/x/polymer/web-dynamic/v1/feed/space/search';

  // 鐢ㄦ埛鍔ㄦ€?  static const String memberDynamic = '/x/polymer/web-dynamic/v1/feed/space';

  // 绋嶅悗鍐嶇湅
  static const String toViewLater = '/x/v2/history/toview/add';

  // 绉婚櫎宸茶鐪?  static const String toViewDel = '/x/v2/history/toview/v2/dels';

  // 娓呯┖绋嶅悗鍐嶇湅
  static const String toViewClear = '/x/v2/history/toview/clear';

  // 杩界暘
  static const String pgcAdd = '/pgc/web/follow/add';

  // 鍙栨秷杩界暘
  static const String pgcDel = '/pgc/web/follow/del';

  static const String pgcUpdate = '/pgc/web/follow/status/update';

  // 鎴戠殑杩界暘/杩藉墽 ?type=1&pn=1&ps=15
  static const String favPgc = '/x/space/bangumi/follow/list';

  // 榛戝悕鍗?  static const String blackLst = '/x/relation/blacks';

  // github 鑾峰彇鏈€鏂扮増
  static const String latestApp =
      'https://api.github.com/repos/sxd91/qiliquid/releases';

  // 澶氬皯浜哄湪鐪?  // https://api.bilibili.com/x/player/online/total?aid=913663681&cid=1203559746&bvid=BV1MM4y1s7NZ&ts=56427838
  static const String onlineTotal = '/x/player/online/total';

  // static const String webDanmaku = '/x/v2/dm/web/seg.so';

  // 鍙戦€佽棰戝脊骞?  //https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/danmaku/action.md
  static const String shootDanmaku = '/x/v2/dm/post';

  // 寮瑰箷灞忚斀鏌ヨ锛圙et锛?  static const String danmakuFilter = '/x/dm/filter/user';

  // 寮瑰箷灞忚斀璇嶆坊鍔狅紙Post锛?  // 琛ㄥ崟鍐呭锛?  // type: 0锛堝叧閿瘝锛?锛堟鍒欙級2锛堢敤鎴凤級
  // filter: 灞忚斀鍐呭
  // csrf
  static const String danmakuFilterAdd = '/x/dm/filter/user/add';

  // 寮瑰箷灞忚斀璇嶅垹闄わ紙Post锛?  // 琛ㄥ崟鍐呭锛?  // ids: 琚垹闄ゆ潯鐩紪鍙?  // csrf
  static const String danmakuFilterDel = '/x/dm/filter/user/del';

  // up涓诲垎缁?  static const String followUpTag = '/x/relation/tags';

  // 璁剧疆Up涓诲垎缁?  // 0 娣诲姞鑷抽粯璁ゅ垎缁? 鍚﹀垯浣跨敤,鍒嗗壊tagid
  static const String addUsers = '/x/relation/tags/addUsers';

  static const String addSpecial = '/x/relation/tag/special/add';

  static const String delSpecial = '/x/relation/tag/special/del';

  // 鑾峰彇鎸囧畾鍒嗙粍涓嬬殑up
  static const String followUpGroup = '/x/relation/tag';

  static const String createFollowTag = '/x/relation/tag/create';

  static const String updateFollowTag = '/x/relation/tag/update';

  static const String delFollowTag = '/x/relation/tag/del';

  // 鑾峰彇鏈绉佷俊鏁?  // https://api.vc.bilibili.com/session_svr/v1/session_svr/single_unread
  static const String msgUnread =
      '${HttpString.tUrl}/session_svr/v1/session_svr/single_unread';

  // 鑾峰彇娑堟伅涓績鏈淇℃伅
  static const String msgFeedUnread = '/x/msgfeed/unread';
  //https://api.bilibili.com/x/msgfeed/reply?platform=web&build=0&mobi_app=web
  static const String msgFeedReply = '/x/msgfeed/reply';
  //https://api.bilibili.com/x/msgfeed/at?platform=web&build=0&mobi_app=web
  static const String msgFeedAt = '/x/msgfeed/at';
  //https://api.bilibili.com/x/msgfeed/like?platform=web&build=0&mobi_app=web
  static const String msgFeedLike = '/x/msgfeed/like';
  //https://message.bilibili.com/x/sys-msg/query_notify_list?page_size=20&cursor=xxx
  static const String msgSysNotify =
      '${HttpString.messageBaseUrl}/x/sys-msg/query_notify_list';

  // 绯荤粺淇℃伅鍏夋爣鏇存柊锛堝凡璇绘爣璁帮級
  //https://message.bilibili.com/x/sys-msg/update_cursor?csrf=xxxx&csrf=xxxx&cursor=1705288500000000000&has_up=0&build=0&mobi_app=web
  static const String msgSysUpdateCursor =
      '${HttpString.messageBaseUrl}/x/sys-msg/update_cursor';

  /// 绉佽亰
  ///  'https://api.vc.bilibili.com/session_svr/v1/session_svr/get_sessions?
  /// session_type=1&
  /// group_fold=1&
  /// unfollow_fold=0&
  /// sort_rule=2&
  /// build=0&
  /// mobi_app=web&
  /// w_rid=8641d157fb9a9255eb2159f316ee39e2&
  /// wts=1697305010

  static const String sessionList =
      '${HttpString.tUrl}/session_svr/v1/session_svr/get_sessions';

  /// 绉佽亰鐢ㄦ埛淇℃伅
  /// uids
  /// build=0&mobi_app=web
  static const String sessionAccountList =
      '${HttpString.tUrl}/account/v1/user/cards';

  /// https://api.vc.bilibili.com/svr_sync/v1/svr_sync/fetch_session_msgs?
  /// talker_id=400787461&
  /// session_type=1&
  /// size=20&
  /// sender_device_id=1&
  /// build=0&
  /// mobi_app=web&
  /// web_location=333.1296&
  /// w_rid=cfe3bf58c9fe181bbf4dd6c75175e6b0&
  /// wts=1697350697

  static const String sessionMsg =
      '${HttpString.tUrl}/svr_sync/v1/svr_sync/fetch_session_msgs';

  /// 鏍囪宸茶 POST
  /// talker_id:
  /// session_type: 1
  /// ack_seqno: 920224140918926
  /// build: 0
  /// mobi_app: web
  /// csrf_token:
  /// csrf:
  static const String ackSessionMsg =
      '${HttpString.tUrl}/session_svr/v1/session_svr/update_ack';

  // 鑾峰彇鏌愪釜鍔ㄦ€佽鎯?  // timezone_offset=-480
  // id=849312409672744983
  // features=itemOpusStyle
  static const String dynamicDetail = '/x/polymer/web-dynamic/v1/detail';

  // AI鎬荤粨
  /// https://api.bilibili.com/x/web-interface/view/conclusion/get?
  /// bvid=BV1ju4y1s7kn&
  /// cid=1296086601&
  /// up_mid=4641697&
  /// w_rid=1607c6c5a4a35a1297e31992220900ae&
  /// wts=1697033079
  static const String aiConclusion = '/x/web-interface/view/conclusion/get';

  // captcha楠岃瘉鐮?  static const String getCaptcha =
      '${HttpString.passBaseUrl}/x/passport-login/captcha?source=main_web';

  // web绔煭淇￠獙璇佺爜
  static const String smsCode =
      '${HttpString.passBaseUrl}/x/passport-login/web/sms/send';

  // web绔獙璇佺爜鐧诲綍

  // web绔瘑鐮佺櫥褰?  static const String logInByWebPwd =
      '${HttpString.passBaseUrl}/x/passport-login/web/login';

  // 鑾峰彇guestID
  // static const String getGuestId = '/x/passport-user/guest/reg';

  // app绔煭淇￠獙璇佺爜
  static const String appSmsCode =
      '${HttpString.passBaseUrl}/x/passport-login/sms/send';

  // app绔獙璇佺爜鐧诲綍
  static const String logInByAppSms =
      '${HttpString.passBaseUrl}/x/passport-login/login/sms';

  // 鑾峰彇鐭俊楠岃瘉鐮?  // static const String appSafeSmsCode =
  //     'https://passport.bilibili.com/x/safecenter/common/sms/send';

  /// app绔瘑鐮佺櫥褰?  /// username
  /// password
  /// key
  /// salt
  static const String loginByPwdApi =
      '${HttpString.passBaseUrl}/x/passport-login/oauth2/login';

  /// 瀵嗙爜鐧诲綍鏃讹紝鎻愮ず鈥滄湰娆＄櫥褰曠幆澧冨瓨鍦ㄩ闄? 闇€浣跨敤鎵嬫満鍙疯繘琛岄獙璇佹垨缁戝畾鈥?  /// 鏍规嵁https://ivan.hanloth.cn/archives/530/娴佺▼杩涜鎵嬫満鍙烽獙璇?  /// tmp_code
  static const String safeCenterGetInfo =
      '${HttpString.passBaseUrl}/x/safecenter/user/info';

  /// 楠岃瘉缁戝畾鎵嬫満鍙峰墠鐨勪汉鏈洪獙璇?  static const String preCapture =
      '${HttpString.passBaseUrl}/x/safecenter/captcha/pre';

  /// 瀵嗙爜鐧诲綍鏃堕鎺у彂閫佹墜鏈洪獙璇佺爜
  ///sms_type	str	loginTelCheck
  /// tmp_code	str	楠岃瘉鏍囪浠ｇ爜	鏉ヨ嚜鏁版嵁澶勭悊涓殑瑙ｆ瀽鍑虹殑鍙傛暟tmp_token
  /// gee_challenge	str	鏋侀獙id	鐢宠浜烘満楠岃瘉鏃跺緱鍒?data->gee_challenge)
  /// gee_seccode	str	鏋侀獙key	浜烘満楠岃瘉鍚庡緱鍒?result->geetest_seccode)
  /// gee_validate	str	鏋侀獙result	浜烘満楠岃瘉鍚庡緱鍒?result->geetest_validate)
  /// recaptcha_token	str	楠岃瘉token	鐢宠浜烘満楠岃瘉鏃跺緱鍒?data->recaptcha_token)
  static const String safeCenterSmsCode =
      '${HttpString.passBaseUrl}/x/safecenter/common/sms/send';

  /// type	str	loginTelCheck
  /// code	int	楠岃瘉鐮佸唴瀹?  /// tmp_code	str	楠岃瘉鏍囪浠ｇ爜	鏉ヨ嚜鏁版嵁澶勭悊涓殑瑙ｆ瀽鍑虹殑鍙傛暟tmp_token
  /// request_id	str	楠岃瘉璇锋眰鏍囪	鏉ヨ嚜鏁版嵁澶勭悊涓殑瑙ｆ瀽鍑虹殑鍙傛暟requestId
  /// captcha_key	str	楠岃瘉绉橀挜	鏉ヨ嚜鐢宠楠岃瘉鐮佺殑captcha_key锛坉ata->captcha_key锛?  static const String safeCenterSmsVerify =
      '${HttpString.passBaseUrl}/x/safecenter/login/tel/verify';

  static const String oauth2AccessToken =
      '${HttpString.passBaseUrl}/x/passport-login/oauth2/access_token';

  /// 瀵嗙爜鍔犲瘑瀵嗛挜
  /// disable_rcmd
  /// local_id
  static const getWebKey = '${HttpString.passBaseUrl}/x/passport-login/web/key';

  /// cookie杞琣ccess_key
  static const qrcodeConfirm =
      '${HttpString.passBaseUrl}/x/passport-tv-login/h5/qrcode/confirm';

  /// 鐢宠浜岀淮鐮?TV绔?
  static const getTVCode =
      '${HttpString.passBaseUrl}/x/passport-tv-login/qrcode/auth_code';

  ///鎵爜鐧诲綍锛圱V绔級
  static const qrcodePoll =
      '${HttpString.passBaseUrl}/x/passport-tv-login/qrcode/poll';

  static const logout = '${HttpString.passBaseUrl}/login/exit/v2';

  /// 缃《瑙嗛
  static const getTopVideoApi = '/x/space/top/arc';

  /// 涓婚〉 - 鏈€杩戞姇甯佺殑瑙嗛
  /// vmid
  /// gaia_source = main_web
  /// web_location
  /// w_rid
  /// wts
  static const getRecentCoinVideoApi = '/x/space/coin/video';

  /// 鏈€杩戠偣璧炵殑瑙嗛
  static const getRecentLikeVideoApi = '/x/space/like/video';

  /// 鐢ㄦ埛涓撴爮
  static const getMemberSeasonsApi = '/x/polymer/web-space/home/seasons_series';

  /// 鑾疯禐鏁?鎾斁鏁?  /// mid
  static const getMemberViewApi = '/x/space/upstat';

  static const seasonArchives = '/x/polymer/web-space/seasons_archives_list';

  static const seriesArchives = '/x/series/archives';

  /// 鑾峰彇鏈鍔ㄦ€佹暟
  static const getUnreadDynamic = '/x/web-interface/dynamic/entrance';

  /// 鐢ㄦ埛鍔ㄦ€佷富椤?  static const dynamicSpmPrefix = '${HttpString.spaceBaseUrl}/1/dynamic';

  /// 婵€娲籦uvid3
  static const activateBuvidApi = '/x/internal/gaia-gateway/ExClimbWuzhi';

  /// 鎴戠殑璁㈤槄
  static const userSubFolder = '/x/v3/fav/folder/collected/list';

  /// 鎴戠殑璁㈤槄-鍚堥泦璇︽儏
  static const favSeasonList = '/x/space/fav/season/list';

  /// 鍙戦€佺淇?  static const String sendMsg = '${HttpString.tUrl}/web_im/v1/web_im/send_msg';

  /// 鎺掕姒?  static const String getRankApi = "/x/web-interface/ranking/v2";

  static const String pgcRank = "/pgc/web/rank/list";

  static const String pgcSeasonRank = "/pgc/season/rank/web/list";

  /// 鍙栨秷璁㈤槄-鎾崟
  static const String unfavFolder = '/x/v3/fav/folder/unfav';

  // static const String videoTags = '/x/tag/archive/tags';
  static const String videoTags = '/x/web-interface/view/detail/tag';

  static const String reportMember =
      '${HttpString.spaceBaseUrl}/ajax/report/add';

  static const String removeMsg = '/session_svr/v1/session_svr/remove_session';

  static const String delSysMsg = '/x/sys-msg/del_notify_list';

  static const String delMsgfeed = '/x/msgfeed/del';

  static const String setTop = '/session_svr/v1/session_svr/set_top';

  static const String createDynamic = '/x/dynamic/feed/create/dyn';

  static const String createTextDynamic = '/dynamic_svr/v1/dynamic_svr/create';

  // static const String removeDynamic = '${HttpString.tUrl}/dynamic_svr/v1/dynamic_svr/rm_dynamic';

  static const String removeDynamic = '/x/dynamic/feed/operate/remove';

  static const String uploadBfs = '/x/dynamic/feed/draw/upload_bfs';

  static const String uploadImage = '/x/upload/web/image';

  // 鐐硅禐鎶曞竵鏀惰棌鍏虫敞
  static const String videoRelation = '/x/web-interface/archive/relation';

  static const String favSeason = '/x/v3/fav/season/fav';

  static const String unfavSeason = '/x/v3/fav/season/unfav';

  /// 绋嶅悗鍐嶇湅&鏀惰棌澶硅棰戝垪琛?  static const String mediaList = '/x/v2/medialist/resource/list';

  static const String pgcIndexCondition = '/pgc/season/index/condition';

  static const String pgcIndexResult = '/pgc/season/index/result';

  static const String archiveNoteList = '/x/note/publish/list/archive';

  static const String noteList = '/x/note/list';

  static const String userNoteList = '/x/note/publish/list/user';

  static const String addNote = '/x/note/add';

  static const String delNote = '/x/note/del';

  static const String delPublishNote = '/x/note/publish/del';

  static const String archiveNote = '/x/note/list/archive';

  static const String favArticle = '/x/polymer/web-dynamic/v1/opus/feed/fav';

  static const String communityAction =
      '/x/community/cosmo/interface/simple_action';

  static const String delFavArticle = '/x/article/favorites/del';

  static const String addFavArticle = '/x/article/favorites/add';

  static const String replyTop = '/x/v2/reply/top';

  static const String getCoin = '${HttpString.accountBaseUrl}/site/getCoin';

  static const String getLiveEmoticons =
      '${HttpString.liveBaseUrl}/xlive/web-ucenter/v2/emoticon/GetEmoticons';

  static const String pgcTimeline = '/pgc/web/timeline';

  static const String searchTrending = '/x/v2/search/trending/ranking';

  static const String setTopDyn = '/x/dynamic/feed/space/set_top';

  static const String rmTopDyn = '/x/dynamic/feed/space/rm_top';

  static const String searchRecommend =
      '${HttpString.appBaseUrl}/x/v2/search/recommend';

  static const String articleInfo = '/x/article/viewinfo';

  static const String dynamicReport = '/x/dynamic/feed/dynamic_report/add';

  // https://github.com/SocialSisterYi/bilibili-API-collect/pull/1242
  static const String articleView = '/x/article/view';

  static const String opusDetail = '/x/polymer/web-dynamic/v1/opus/detail';

  static const String gaiaVgateRegister = '/x/gaia-vgate/v1/register';

  static const String gaiaVgateValidate = '/x/gaia-vgate/v1/validate';

  static const String voteInfo = '/x/vote/vote_info';

  static const String doVote = '/x/vote/do_vote';

  static const String liveFeedIndex =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/index/feed';

  static const String liveFollow =
      '${HttpString.liveBaseUrl}/xlive/web-ucenter/user/following';

  static const String liveSecondList =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/second/getList';

  static const String msgSetNotice = '/x/msgfeed/notice';

  static const String liveAreaList =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/index/getAreaList';

  static const String liveRoomAreaList =
      '${HttpString.liveBaseUrl}/room/v1/Area/getList';

  static const String getLiveFavTag =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/second/get_fav_tag';

  static const String setLiveFavTag =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/second/set_fav_tag';

  static const String liveSearch =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/search_live';

  static const String topicTop =
      '${HttpString.appBaseUrl}/x/topic/web/details/top';

  static const String topicFeed = '/x/polymer/web-dynamic/v1/feed/topic';

  static const String spaceOpus = '/x/polymer/web-dynamic/v1/opus/feed/space';

  static const String articleList = '/x/article/list/web/articles';

  static const String setMsgDnd =
      '${HttpString.tUrl}/link_setting/v1/link_setting/set_msg_dnd';

  static const String imUserInfos = '${HttpString.tUrl}/x/im/user_infos';

  static const String getSessionSs =
      '${HttpString.tUrl}/link_setting/v1/link_setting/get_session_ss';

  static const String getMsgDnd =
      '${HttpString.tUrl}/link_setting/v1/link_setting/get_msg_dnd';

  static const String setPushSs =
      '${HttpString.tUrl}/link_setting/v1/link_setting/set_push_ss';

  static const String dynReserve = '/x/dynamic/feed/reserve/click';

  static const String spaceReserve = '/x/space/reserve';

  static const String spaceReserveCancel = '/x/space/reserve/cancel';

  static const String favPugv = '/pugv/app/web/favorite/page';

  static const String addFavPugv = '/pugv/app/web/favorite/add';

  static const String delFavPugv = '/pugv/app/web/favorite/del';

  static const String favTopicList = '/x/topic/web/fav/list';

  static const String addFavTopic = '/x/topic/fav/sub/add';

  static const String delFavTopic = '/x/topic/fav/sub/cancel';

  static const String likeTopic = '/x/topic/like';

  static const String pgcReviewL = '/pgc/review/long/list';

  static const String pgcReviewS = '/pgc/review/short/list';

  static const String pgcReviewLike = '/pgc/review/action/like';

  static const String pgcReviewDislike = '/pgc/review/action/dislike';

  static const String pgcReviewPost = '/pgc/review/short/post';

  static const String pgcReviewMod = '/pgc/review/short/modify';

  static const String pgcReviewDel = '/pgc/review/short/del';

  static const String topicPubSearch =
      '${HttpString.appBaseUrl}/x/topic/pub/search';

  static const String upowerRank = '/x/upower/up/member/rank/v2';

  static const String favFavFolder = '/x/v3/fav/folder/fav';

  static const String unfavFavFolder = '/x/v3/fav/folder/unfav';

  static const String coinArc = '${HttpString.appBaseUrl}/x/v2/space/coinarc';

  static const String likeArc = '${HttpString.appBaseUrl}/x/v2/space/likearc';

  static const String spaceSetting = '/x/space/setting/app';

  static const String spaceSettingMod = '/x/space/privacy/batch/modify';

  static const String vipExpAdd = '/x/vip/experience/add';

  static const String coinLog = '/x/member/web/coin/log';

  static const String dynTopicRcmd = '/x/topic/web/dynamic/rcmd';

  static const String matchInfo = '/x/esports/match/info';

  static const String dynPic = '/x/polymer/web-dynamic/v1/detail/pic';

  static const String msgLikeDetail = '/x/msgfeed/like_detail';

  static const String getLiveInfoByUser =
      '${HttpString.liveBaseUrl}/xlive/web-room/v1/index/getInfoByUser';

  static const String liveSetSilent =
      '${HttpString.liveBaseUrl}/liveact/user_silent';

  static const String addShieldKeyword =
      '${HttpString.liveBaseUrl}/xlive/web-ucenter/v1/banned/AddShieldKeyword';

  static const String delShieldKeyword =
      '${HttpString.liveBaseUrl}/xlive/web-ucenter/v1/banned/DelShieldKeyword';

  static const String liveShieldUser =
      '${HttpString.liveBaseUrl}/liveact/shield_user';

  static const String spaceComic = '${HttpString.appBaseUrl}/x/v2/space/comic';

  static const String spaceAudio = '/audio/music-service/web/song/upper';

  static const String spaceCheese = '/pugv/app/web/season/page';

  static const String dynMention = '/x/polymer/web-dynamic/v1/mention/search';

  static const String createVote = '/x/vote/create';

  static const String updateVote = '/x/vote/update';

  static const String createReserve = '/x/new-reserve/up/reserve/create';

  static const String updateReserve = '/x/new-reserve/up/reserve/update';

  static const String reserveInfo = '/x/new-reserve/up/reserve/info';

  static const String loginLog = '/x/member/web/login/log';

  static const String expLog = '/x/member/web/exp/log';

  static const String moralLog = '/x/member/web/moral/log';

  static const String liveLikeReport =
      '${HttpString.liveBaseUrl}/xlive/app-ucenter/v1/like_info_v3/like/likeReportV3';

  static const String loginDevices =
      '${HttpString.passBaseUrl}/x/safecenter/user_login_devices';

  static const String bgmDetail = '/x/copyright-music-publicity/bgm/detail';

  static const String wishUpdate =
      '/x/copyright-music-publicity/bgm/wish/update';

  static const String bgmRecommend =
      '/x/copyright-music-publicity/bgm/recommend_list';

  static const String spaceShop =
      '${HttpString.mallBaseUrl}/community-hub/small_shop/feed/tab/item';

  static const String superChatMsg =
      '${HttpString.liveBaseUrl}/av/v1/SuperChat/getMessageList';

  static const String popularSeriesOne = '/x/web-interface/popular/series/one';

  static const String popularSeriesList =
      '/x/web-interface/popular/series/list';

  static const String popularPrecious = '/x/web-interface/popular/precious';

  static const String userRealName = '/x/member/app/up/realname';

  static const String liveDmReport =
      '${HttpString.liveBaseUrl}/xlive/web-ucenter/v1/dMReport/Report';

  static const String danmakuLike = '/x/v2/dm/thumbup/add';

  static const String danmakuReport = '/x/dm/report/add';

  static const String danmakuRecall = '/x/dm/recall';

  static const String danmakuEditState = '/x/v2/dm/edit/state';

  static const String followedUp = '/x/relation/followings/followed_upper';

  static const String sameFollowing = '/x/relation/same/followings';

  static const String seasonStatus = '/pgc/view/web/season/user/status';

  static const String followeeVotes =
      '${HttpString.tUrl}/vote_svr/v1/vote_svr/followee_votes';

  static const String liveContributionRank =
      '${HttpString.liveBaseUrl}/xlive/general-interface/v1/rank/queryContributionRank';

  static const String superChatReport =
      '${HttpString.liveBaseUrl}/av/v1/SuperChat/report';

  static const String imMsgReport = '${HttpString.tUrl}/x/bplus/im/report/add';

  static const String dynPrivatePubSetting =
      '/x/dynamic/feed/dyn/private_pub_setting';

  static const String editDyn = '/x/dynamic/feed/edit/dyn';

  static const String replyInteraction =
      '/x/v2/reply/subject/interaction-status';

  static const String replySubjectModify = '/x/v2/reply/subject/modify';

  static const String videoshot = '/x/player/videoshot';

  static const String liveMedalWall =
      '${HttpString.liveBaseUrl}/xlive/web-ucenter/user/MedalWall';

  static const String memberGuard =
      '${HttpString.liveBaseUrl}/xlive/app-ucenter/v1/guard/MainGuardCardAll';

  static const String bubble = '/x/tribee/v1/dyn/all';

  static const String sortFollowTag = '/x/relation/tags/update_sort';

  static const String replyReport = '/x/v2/reply/report';

  static const String dynReaction = '/x/polymer/web-dynamic/v1/detail/reaction';
}


