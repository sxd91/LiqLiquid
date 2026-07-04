import 'dart:math';

import 'package:liqliquid/common/assets.dart';
import 'package:liqliquid/common/constants.dart';
import 'package:liqliquid/common/style.dart';
import 'package:liqliquid/common/widgets/badge.dart';
import 'package:liqliquid/common/widgets/custom_icon.dart';
import 'package:liqliquid/common/widgets/dialog/dialog.dart';
import 'package:liqliquid/common/widgets/dialog/report.dart';
import 'package:liqliquid/common/widgets/extra_hit_test_widget.dart';
import 'package:liqliquid/common/widgets/flutter/text/text.dart' as custom_text;
import 'package:liqliquid/common/widgets/gesture/tap_gesture_recognizer.dart';
import 'package:liqliquid/common/widgets/image/network_img_layer.dart';
import 'package:liqliquid/common/widgets/image_grid/image_grid_view.dart';
import 'package:liqliquid/common/widgets/pendant_avatar.dart';
import 'package:liqliquid/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo, ReplyControl, Content, Url;
import 'package:liqliquid/grpc/reply.dart';
import 'package:liqliquid/http/loading_state.dart';
import 'package:liqliquid/http/reply.dart';
import 'package:liqliquid/http/video.dart';
import 'package:liqliquid/models/common/badge_type.dart';
import 'package:liqliquid/models/common/image_type.dart';
import 'package:liqliquid/pages/dynamics/widgets/vote.dart';
import 'package:liqliquid/pages/member/widget/medal_widget.dart';
import 'package:liqliquid/pages/save_panel/view.dart';
import 'package:liqliquid/pages/video/controller.dart';
import 'package:liqliquid/pages/video/reply/widgets/zan_grpc.dart';
import 'package:liqliquid/utils/accounts.dart';
import 'package:liqliquid/utils/app_scheme.dart';
import 'package:liqliquid/utils/bili_utils.dart';
import 'package:liqliquid/utils/color_utils.dart';
import 'package:liqliquid/utils/danmaku_utils.dart';
import 'package:liqliquid/utils/date_utils.dart';
import 'package:liqliquid/utils/duration_utils.dart';
import 'package:liqliquid/utils/extension/context_ext.dart';
import 'package:liqliquid/utils/extension/num_ext.dart';
import 'package:liqliquid/utils/extension/theme_ext.dart';
import 'package:liqliquid/utils/feed_back.dart';
import 'package:liqliquid/utils/global_data.dart';
import 'package:liqliquid/utils/image_utils.dart';
import 'package:liqliquid/utils/page_utils.dart';
import 'package:liqliquid/utils/platform_utils.dart';
import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:liqliquid/utils/storage_pref.dart';
import 'package:liqliquid/utils/url_utils.dart';
import 'package:liqliquid/utils/utils.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:protobuf/protobuf.dart';

class ReplyItemGrpc extends StatelessWidget {
  const ReplyItemGrpc({
    super.key,
    required this.replyItem,
    required this.replyLevel,
    this.replyReply,
    this.needDivider = true,
    this.onReply,
    this.onDelete,
    this.upMid,
    this.showDialogue,
    this.getTag,
    this.onViewImage,
    this.onCheckReply,
    this.onToggleTop,
    this.jumpToDialogue,
  });
  final ReplyInfo replyItem;
  final int replyLevel;
  final Function(ReplyInfo replyItem, int? rpid)? replyReply;
  final bool needDivider;
  final ValueChanged<ReplyInfo>? onReply;
  final Function(ReplyInfo replyItem, int? subIndex)? onDelete;
  final Int64? upMid;
  final VoidCallback? showDialogue;
  final Function? getTag;
  final VoidCallback? onViewImage;
  final ValueChanged<ReplyInfo>? onCheckReply;
  final ValueChanged<ReplyInfo>? onToggleTop;
  final VoidCallback? jumpToDialogue;

  static final _voteRegExp = RegExp(r"^\{vote:\d+?\}$");
  static final _timeRegExp = RegExp(r'^(?:\d+[:锛歖)?\d+[:锛歖\d+$');
  static bool enableWordRe = Pref.enableWordRe;
  static int? replyLengthLimit = Pref.replyLengthLimit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    void showMore() => showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: min(640, context.mediaQueryShortestSide),
      ),
      builder: (context) {
        return morePanel(
          context: context,
          item: replyItem,
          onDelete: () => onDelete?.call(replyItem, null),
          isSubReply: false,
        );
      },
    );

    Widget child = Padding(
      padding: const .fromLTRB(12, 14, 8, 5),
      child: _buildContent(context, theme),
    );
    if (needDivider) {
      child = Column(
        mainAxisSize: .min,
        children: [
          child,
          Divider(
            indent: 55,
            endIndent: 15,
            height: 0.3,
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
          ),
        ],
      );
    }
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => replyReply?.call(replyItem, null),
        onLongPress: showMore,
        onSecondaryTap: PlatformUtils.isMobile ? null : showMore,
        child: child,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final member = replyItem.member;
    Widget header = GestureDetector(
      onTap: () {
        feedBack();
        Get.toNamed('/member?mid=${replyItem.mid}');
      },
      child: ExtraHitTestWidget(
        width: 46,
        child: Row(
          crossAxisAlignment: .center,
          spacing: 12,
          children: [
            PendantAvatar(
              member.face,
              size: 34,
              badgeSize: 14,
              vipStatus: member.vipStatus.toInt(),
              officialType: member.officialVerifyType.toInt(),
              pendantImage: member.hasGarbPendantImage()
                  ? member.garbPendantImage
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    spacing: 6,
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: TextStyle(
                            color: (member.vipStatus > 0 && member.vipType == 2)
                                ? theme.colorScheme.vipColor
                                : theme.colorScheme.outline,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      BiliUtils.levelPicture(
                        member.level.toInt(),
                        isSeniorMember: member.isSeniorMember == 1,
                        height: 11,
                      ),
                      if (replyItem.mid == upMid)
                        const PBadge(
                          text: 'UP',
                          size: PBadgeSize.small,
                          isStack: false,
                          fontSize: 9,
                        )
                      else if (GlobalData().showMedal &&
                          member.hasFansMedalLevel())
                        MedalWidget(
                          medalName: member.fansMedalName,
                          level: member.fansMedalLevel.toInt(),
                          backgroundColor: DmUtils.decimalToColor(
                            member.fansMedalColor.toInt(),
                          ),
                          nameColor: DmUtils.decimalToColor(
                            member.fansMedalColorName.toInt(),
                          ),
                          padding: const .symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        replyLevel == 0
                            ? DateFormatUtils.format(
                                replyItem.ctime.toInt(),
                                format: DateFormatUtils.longFormatDs,
                              )
                            : DateFormatUtils.dateFormat(
                                replyItem.ctime.toInt(),
                              ),
                        style: TextStyle(
                          fontSize: theme.textTheme.labelSmall!.fontSize,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      if (replyItem.replyControl.hasLocation())
                        Text(
                          ' 鈥?${replyItem.replyControl.location}',
                          style: TextStyle(
                            fontSize: theme.textTheme.labelSmall!.fontSize,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (PendantAvatar.showDecorate) {
      final garb = replyItem.memberV2.garb;
      if (garb.hasCardImage()) {
        const double height = 38.0;
        return Stack(
          clipBehavior: .none,
          children: [
            Positioned(
              top: 0,
              right: 0,
              height: height,
              child: CachedNetworkImage(
                height: height,
                memCacheHeight: height.cacheSize(context),
                imageUrl: ImageUtils.safeThumbnailUrl(garb.cardImage),
                placeholder: (_, _) => const SizedBox.shrink(),
              ),
            ),
            if (garb.hasCardNumber())
              Positioned(
                top: 0,
                right: 0,
                height: height,
                child: Center(
                  child: Text(
                    '${garb.fanNumPrefix}\n${garb.cardNumber}',
                    style: TextStyle(
                      fontSize: 8,
                      fontFamily: Assets.digitalNum,
                      color: ColourUtils.parseColor(garb.cardFanColor),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const .only(right: 80),
              child: header,
            ),
          ],
        );
      }
    }
    return header;
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    final replyControl = replyItem.replyControl;
    final padding = EdgeInsets.only(left: replyLevel == 0 ? 6 : 45, right: 6);
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        _buildHeader(context, theme),
        const SizedBox(height: 10),
        Padding(
          padding: padding,
          child: custom_text.Text.rich(
            primary: theme.colorScheme.primary,
            style: TextStyle(
              height: 1.75,
              fontSize: theme.textTheme.bodyMedium!.fontSize,
            ),
            maxLines: replyLevel == 1 ? replyLengthLimit : null,
            TextSpan(
              children: [
                if (replyControl.isUpTop) ...[
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: PBadge(
                      text: 'TOP',
                      size: PBadgeSize.small,
                      isStack: false,
                      type: PBadgeType.line_primary,
                      fontSize: 9,
                      textScaleFactor: 1,
                    ),
                  ),
                  const TextSpan(text: ' '),
                ],
                _buildMessage(
                  context,
                  theme,
                  replyControl.showTranslation
                      ? replyItem.translatedContent
                      : replyItem.content,
                  replyControl,
                ),
              ],
            ),
          ),
        ),
        if (replyItem.content.pictures.isNotEmpty) ...[
          Padding(
            padding: padding,
            child: ImageGridView(
              picArr: replyItem.content.pictures
                  .map(
                    (item) => ImageModel(
                      width: item.imgWidth,
                      height: item.imgHeight,
                      url: item.imgSrc,
                    ),
                  )
                  .toList(),
              onViewImage: onViewImage,
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (replyLevel != 0) ...[
          const SizedBox(height: 4),
          buttonAction(context, theme, replyControl),
        ],
        if (replyLevel == 1 && replyItem.count > Int64.ZERO) ...[
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 12),
            child: replyItemRow(context, theme, replyItem.replies),
          ),
        ],
      ],
    );
  }

  Widget _buildTranslateBtn(
    BuildContext context,
    ThemeData theme,
    ReplyControl replyControl,
    TextStyle textStyle,
    ButtonStyle buttonStyle,
  ) {
    late bool isProcessing = false;
    final color = replyControl.showTranslation
        ? theme.colorScheme.primary
        : theme.colorScheme.outline.withValues(alpha: 0.8);
    return SizedBox(
      height: 32,
      child: TextButton(
        style: buttonStyle,
        onPressed: () async {
          if (replyControl.showTranslation) {
            replyControl.showTranslation = false;
            (context as Element).markNeedsBuild();
          } else {
            if (isProcessing) {
              return;
            }
            if (replyItem.hasTranslatedContent()) {
              replyControl.showTranslation = true;
              (context as Element).markNeedsBuild();
              return;
            }
            isProcessing = true;
            final res = await ReplyGrpc.translateReply(
              type: replyItem.type,
              oid: replyItem.oid,
              rpid: replyItem.id,
            );
            if (res case Success(:final response)) {
              final item = response.translatedReplies[replyItem.id];
              if (item != null && item.hasTranslatedContent()) {
                replyControl.showTranslation = true;
                replyItem.translatedContent = item.translatedContent;
                if (context.mounted) {
                  (context as Element).markNeedsBuild();
                }
              } else {
                SmartDialog.showToast('缈昏瘧缁撴灉涓虹┖');
              }
            } else if (res case Error(:final errMsg)) {
              SmartDialog.showToast('缈昏瘧澶辫触: $errMsg');
            }
            isProcessing = false;
          }
        },
        child: Row(
          spacing: 3,
          mainAxisSize: .min,
          children: [
            Icon(Icons.translate, size: 16, color: color),
            Text(
              replyControl.showTranslation ? '鍘熸枃' : '缈昏瘧',
              style: textStyle.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonAction(
    BuildContext context,
    ThemeData theme,
    ReplyControl replyControl,
  ) {
    final textStyle = TextStyle(
      height: 1,
      fontWeight: .normal,
      color: theme.colorScheme.outline,
      fontSize: theme.textTheme.labelMedium!.fontSize,
    );
    const buttonStyle = ButtonStyle(
      visualDensity: .compact,
      tapTargetSize: .shrinkWrap,
      padding: WidgetStatePropertyAll(.zero),
    );

    Widget? dialogBtn;
    if (replyLevel == 2 && needDivider && replyItem.id != replyItem.dialog) {
      dialogBtn = SizedBox(
        height: 32,
        child: TextButton(
          onPressed: showDialogue,
          style: buttonStyle,
          child: Text('鏌ョ湅瀵硅瘽', style: textStyle),
        ),
      );
    } else if (replyLevel == 3 && replyItem.parent != replyItem.root) {
      dialogBtn = SizedBox(
        height: 32,
        child: TextButton(
          onPressed: jumpToDialogue,
          style: buttonStyle,
          child: Text('璺宠浆鍥炲', style: textStyle),
        ),
      );
    }
    return Row(
      children: [
        const SizedBox(width: 36),
        SizedBox(
          height: 32,
          child: TextButton(
            style: buttonStyle,
            onPressed: () {
              feedBack();
              onReply?.call(replyItem);
            },
            child: Row(
              spacing: 3,
              mainAxisSize: .min,
              children: [
                Icon(
                  Icons.reply,
                  size: 18,
                  color: theme.colorScheme.outline.withValues(alpha: 0.8),
                ),
                Text('鍥炲', style: textStyle),
              ],
            ),
          ),
        ),
        const SizedBox(width: 2),
        if (replyControl.translationSwitch ==
            .TRANSLATION_SWITCH_SHOW_TRANSLATION) ...[
          _buildTranslateBtn(
            context,
            theme,
            replyControl,
            textStyle,
            buttonStyle,
          ),
          const SizedBox(width: 2),
        ] else if (replyControl.cardLabels.isNotEmpty) ...[
          Text(
            dialogBtn != null
                ? replyControl.cardLabels.first.textContent
                : replyControl.cardLabels.map((e) => e.textContent).join('  '),
            style: textStyle.copyWith(color: theme.colorScheme.secondary),
          ),
          const SizedBox(width: 2),
        ],
        ?dialogBtn,
        const Spacer(),
        ZanButtonGrpc(replyItem: replyItem),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget replyItemRow(
    BuildContext context,
    ThemeData theme,
    List<ReplyInfo> replies,
  ) {
    final extraRow = replies.length < replyItem.count.toInt();
    late final length = replies.length + (extraRow ? 1 : 0);
    return Padding(
      padding: const EdgeInsets.only(left: 42, right: 4),
      child: Material(
        color: theme.colorScheme.onInverseSurface,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        clipBehavior: Clip.hardEdge,
        animationDuration: Duration.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (replies.isNotEmpty)
              ...List.generate(replies.length, (index) {
                final childReply = replies[index];
                EdgeInsets padding;
                if (length == 1) {
                  padding = const EdgeInsets.fromLTRB(8, 5, 8, 5);
                } else {
                  if (index == 0) {
                    padding = const EdgeInsets.fromLTRB(8, 8, 8, 4);
                  } else if (index == length - 1) {
                    padding = const EdgeInsets.fromLTRB(8, 4, 8, 8);
                  } else {
                    padding = const EdgeInsets.fromLTRB(8, 4, 8, 4);
                  }
                }
                void showMore() => showModalBottomSheet(
                  context: context,
                  useSafeArea: true,
                  isScrollControlled: true,
                  constraints: BoxConstraints(
                    maxWidth: min(640, context.mediaQueryShortestSide),
                  ),
                  builder: (context) {
                    return morePanel(
                      context: context,
                      item: childReply,
                      onDelete: () => onDelete?.call(replyItem, index),
                      isSubReply: true,
                    );
                  },
                );
                return InkWell(
                  onTap: () =>
                      replyReply?.call(replyItem, childReply.id.toInt()),
                  onLongPress: showMore,
                  onSecondaryTap: PlatformUtils.isMobile ? null : showMore,
                  child: Padding(
                    padding: padding,
                    child: Text.rich(
                      style: TextStyle(
                        fontSize: theme.textTheme.bodyMedium!.fontSize,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        ),
                        height: 1.6,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      TextSpan(
                        children: [
                          TextSpan(
                            text: childReply.member.name,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                            ),
                            recognizer: NoDeadlineTapGestureRecognizer()
                              ..onTap = () {
                                feedBack();
                                Get.toNamed(
                                  '/member?mid=${childReply.member.mid}',
                                );
                              },
                          ),
                          if (childReply.mid == upMid) ...[
                            const TextSpan(text: ' '),
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: PBadge(
                                text: 'UP',
                                size: PBadgeSize.small,
                                isStack: false,
                                fontSize: 9,
                                textScaleFactor: 1,
                              ),
                            ),
                            const TextSpan(text: ' '),
                          ],
                          TextSpan(
                            text: childReply.root == childReply.parent
                                ? ': '
                                : childReply.mid == upMid
                                ? ''
                                : ' ',
                          ),
                          _buildMessage(
                            context,
                            theme,
                            childReply.content,
                            childReply.replyControl,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            if (extraRow)
              InkWell(
                onTap: () => replyReply?.call(replyItem, null),
                child: Padding(
                  padding: length == 1
                      ? const EdgeInsets.fromLTRB(8, 6, 8, 6)
                      : const EdgeInsets.fromLTRB(8, 5, 8, 8),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: theme.textTheme.labelMedium!.fontSize,
                      ),
                      children: [
                        if (replyItem.replyControl.upReply)
                          TextSpan(
                            text: 'UP涓荤瓑浜?',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        TextSpan(
                          text: '鍏?{replyItem.count}鏉″洖澶?,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  InlineSpan _buildMessage(
    BuildContext context,
    ThemeData theme,
    Content content,
    ReplyControl replyControl,
  ) {
    final List<InlineSpan> spanChildren = <InlineSpan>[];
    bool hasNote = false;

    final urlKeys = content.urls.keys;
    // 鏋勫缓姝ｅ垯琛ㄨ揪寮?    final List<String> specialTokens = [
      ...content.emotes.keys,
      ...content.topics.keys.map((e) => '#$e#'),
      ...content.atNameToMid.keys.map((e) => '@$e'),
      ...urlKeys,
    ];
    String patternStr = [
      ...specialTokens.map(RegExp.escape),
      r'(?:\d+[:锛歖)?\d+[:锛歖\d+',
      r'\{vote:\d+?\}',
      Constants.urlRegex.pattern,
    ].join('|');
    final RegExp pattern = RegExp(patternStr);

    late List<String> matchedUrls = [];

    void addPlainTextSpan(str) {
      spanChildren.add(TextSpan(text: str));
    }

    void addUrl(String matchStr, Url url, {bool addPlainText = false}) {
      if (url.extra.isWordSearch && !enableWordRe) {
        if (addPlainText) {
          addPlainTextSpan(matchStr);
        }
        return;
      }
      final isCv = url.clickReport.startsWith('{"cvid');
      if (isCv) {
        hasNote = true;
      }
      final children = [
        if (!isCv && url.hasPrefixIcon())
          WidgetSpan(
            child: CachedNetworkImage(
              height: 19,
              memCacheHeight: 19.cacheSize(context),
              color: theme.colorScheme.primary,
              imageUrl: ImageUtils.thumbnailUrl(url.prefixIcon),
              placeholder: (_, _) => const SizedBox.shrink(),
            ),
          ),
        TextSpan(
          text: isCv ? '[绗旇] ' : url.title,
          style: TextStyle(
            color: theme.colorScheme.primary,
          ),
          recognizer: NoDeadlineTapGestureRecognizer()
            ..onTap = () {
              if (url.appUrlSchema.isEmpty) {
                if (RegExp(
                  r'^(av|bv)',
                  caseSensitive: false,
                ).hasMatch(matchStr)) {
                  UrlUtils.matchUrlPush(matchStr, '');
                } else {
                  RegExpMatch? match = RegExp(
                    r'^cv(\d+)$|/read/cv(\d+)|note-app/view\?cvid=(\d+)',
                    caseSensitive: false,
                  ).firstMatch(matchStr);
                  String? cvid =
                      match?.group(1) ?? match?.group(2) ?? match?.group(3);
                  if (cvid != null) {
                    Get.toNamed(
                      '/articlePage',
                      parameters: {
                        'id': cvid,
                        'type': 'read',
                      },
                    );
                    return;
                  }
                  PageUtils.handleWebview(matchStr);
                }
              } else {
                if (url.extra.isWordSearch) {
                  Get.toNamed(
                    '/searchResult',
                    parameters: {'keyword': url.title},
                  );
                } else {
                  PageUtils.handleWebview(matchStr);
                }
              }
            },
        ),
      ];
      if (isCv) {
        spanChildren.insertAll(0, children);
      } else {
        spanChildren.addAll(children);
      }
    }

    // 鍒嗗壊鏂囨湰骞跺鐞嗘瘡涓儴鍒?    content.message.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        String matchStr = match[0]!;
        late final name = matchStr.substring(1);
        late final topic = matchStr.substring(1, matchStr.length - 1);
        if (content.emotes.containsKey(matchStr)) {
          // 澶勭悊琛ㄦ儏
          final emote = content.emotes[matchStr]!;
          final size = emote.size.toInt() * 20.0;
          spanChildren.add(
            WidgetSpan(
              child: NetworkImgLayer(
                src: emote.hasWebpUrl()
                    ? emote.webpUrl
                    : emote.hasGifUrl()
                    ? emote.gifUrl
                    : emote.url,
                type: ImageType.emote,
                width: size,
                height: size,
              ),
            ),
          );
        } else if (matchStr.startsWith("@") &&
            content.atNameToMid.containsKey(name)) {
          // 澶勭悊@鐢ㄦ埛
          spanChildren.add(
            TextSpan(
              text: matchStr,
              style: TextStyle(color: theme.colorScheme.primary),
              recognizer: NoDeadlineTapGestureRecognizer()
                ..onTap = () =>
                    Get.toNamed('/member?mid=${content.atNameToMid[name]}'),
            ),
          );
        } else if (_voteRegExp.hasMatch(matchStr)) {
          spanChildren.add(
            TextSpan(
              text: '鎶曠エ: ${content.vote.title}',
              style: TextStyle(color: theme.colorScheme.primary),
              recognizer: NoDeadlineTapGestureRecognizer()
                ..onTap = () =>
                    showVoteDialog(context, content.vote.id.toInt()),
            ),
          );
        } else if (_timeRegExp.hasMatch(matchStr)) {
          matchStr = matchStr.replaceAll('锛?, ':');
          bool isValid = false;
          try {
            final ctr = Get.find<VideoDetailController>(
              tag: getTag?.call() ?? Get.arguments['heroTag'],
            );
            isValid =
                DurationUtils.parseDuration(matchStr) * 1000 <=
                ctr.data.timeLength!;
          } catch (e) {
            if (kDebugMode) debugPrint('failed to validate: $e');
          }
          spanChildren.add(
            TextSpan(
              text: isValid ? ' $matchStr ' : matchStr,
              style: isValid
                  ? TextStyle(color: theme.colorScheme.primary)
                  : null,
              recognizer: isValid
                  ? (NoDeadlineTapGestureRecognizer()
                      ..onTap = () {
                        // 璺宠浆鍒版寚瀹氫綅缃?                        try {
                          SmartDialog.showToast('璺宠浆鑷筹細$matchStr');
                          Get.find<VideoDetailController>(
                            tag: Get.arguments['heroTag'],
                          ).plPlayerController.seekTo(
                            Duration(
                              seconds: DurationUtils.parseDuration(matchStr),
                            ),
                            isSeek: false,
                          );
                        } catch (e) {
                          SmartDialog.showToast('璺宠浆澶辫触: $e');
                        }
                      })
                  : null,
            ),
          );
        } else {
          final url = content.urls[matchStr];
          if (url != null && !matchedUrls.contains(matchStr)) {
            addUrl(matchStr, url, addPlainText: true);
            // 鍙樉绀轰竴娆?            matchedUrls.add(matchStr);
          } else if (matchStr.length > 1 && content.topics[topic] != null) {
            spanChildren.add(
              TextSpan(
                text: matchStr,
                style: TextStyle(color: theme.colorScheme.primary),
                recognizer: NoDeadlineTapGestureRecognizer()
                  ..onTap = () {
                    Get.toNamed(
                      '/searchResult',
                      parameters: {'keyword': topic},
                    );
                  },
              ),
            );
          } else if (Constants.urlRegex.hasMatch(matchStr)) {
            spanChildren.add(
              TextSpan(
                text: matchStr,
                style: TextStyle(color: theme.colorScheme.primary),
                recognizer: NoDeadlineTapGestureRecognizer()
                  ..onTap = () => PageUtils.handleWebview(matchStr),
              ),
            );
          } else {
            addPlainTextSpan(matchStr);
          }
        }
        return '';
      },
      onNonMatch: (String nonMatchStr) {
        addPlainTextSpan(nonMatchStr);
        return nonMatchStr;
      },
    );

    // if (urlKeys.isNotEmpty) {
    //   List<String> unmatchedItems = urlKeys
    //       .where((url) => !matchedUrls.contains(url))
    //       .toList();
    //   if (unmatchedItems.isNotEmpty) {
    //     for (final patternStr in unmatchedItems) {
    //       addUrl(patternStr, content.urls[patternStr]!);
    //     }
    //   }
    // }

    if (!hasNote && replyControl.isNote && replyControl.isNoteV2) {
      final Color color;
      NoDeadlineTapGestureRecognizer? recognizer;

      final hasClickUrl = content.richText.note.hasClickUrl();
      if (hasClickUrl || content.richText.opus.hasOpusId()) {
        color = theme.colorScheme.primary;
        recognizer = NoDeadlineTapGestureRecognizer()
          ..onTap = () => hasClickUrl
              ? PiliScheme.routePushFromUrl(content.richText.note.clickUrl)
              : Get.toNamed(
                  '/articlePage',
                  parameters: {
                    'id': content.richText.opus.opusId.toString(),
                    'type': 'opus',
                  },
                );
      } else {
        color = theme.colorScheme.secondary;
      }
      spanChildren.insert(
        0,
        TextSpan(
          text: '[绗旇] ',
          style: TextStyle(color: color),
          recognizer: recognizer,
        ),
      );
    }

    return TextSpan(children: spanChildren);
  }

  Widget morePanel({
    required BuildContext context,
    required ReplyInfo item,
    required VoidCallback onDelete,
    required bool isSubReply,
  }) {
    late String message = item.content.message;
    final ownerMid = Int64(Accounts.main.mid);
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    final style = theme.textTheme.titleSmall!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: Get.back,
            borderRadius: Style.bottomSheetRadius,
            child: SizedBox(
              height: 35,
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                  ),
                ),
              ),
            ),
          ),
          if (kDebugMode && GStorage.reply != null) ...[
            ListTile(
              onTap: () {
                Get.back();
                GStorage.reply!.put(
                  item.id.toString(),
                  (item.deepCopy()
                        ..unknownFields.clear()
                        ..replies.clear()
                        ..clearTrackInfo())
                      .writeToBuffer(),
                );
              },
              title: Text(
                'save to local',
                style: style.copyWith(color: theme.colorScheme.primary),
              ),
            ),
            ListTile(
              onTap: () {
                Get.back();
                onDelete();
                GStorage.reply!.delete(item.id.toString());
              },
              title: Text(
                'remove from local',
                style: style.copyWith(color: theme.colorScheme.primary),
              ),
            ),
            ListTile(
              onTap: () {
                Get.back();
                final oid = item.oid.toInt();
                final data =
                    (item.deepCopy()
                          ..unknownFields.clear()
                          ..replies.clear()
                          ..clearTrackInfo())
                        .writeToBuffer();
                GStorage.reply!.putAll({
                  for (var i = oid; i < oid + 1000; i++) i.toString(): data,
                });
              },
              title: Text(
                'save to local (x1000)',
                style: style.copyWith(color: theme.colorScheme.primary),
              ),
            ),
          ],
          if (ownerMid == upMid || ownerMid == item.member.mid)
            ListTile(
              onTap: () async {
                Get.back();
                bool? isDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    final theme = Theme.of(context);
                    return AlertDialog(
                      title: const Text('鍒犻櫎璇勮'),
                      content: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: '纭畾鍒犻櫎杩欐潯璇勮鍚楋紵\n\n'),
                            if (ownerMid != item.member.mid.toInt()) ...[
                              TextSpan(
                                text: '@${item.member.name}',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const TextSpan(text: ':\n'),
                            ],
                            TextSpan(text: message),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: Text(
                            '鍙栨秷',
                            style: TextStyle(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text('纭畾'),
                        ),
                      ],
                    );
                  },
                );
                if (isDelete == null || !isDelete) {
                  return;
                }
                SmartDialog.showLoading(msg: '鍒犻櫎涓?..');
                final res = await VideoHttp.replyDel(
                  type: item.type.toInt(),
                  oid: item.oid.toInt(),
                  rpid: item.id.toInt(),
                );
                SmartDialog.dismiss();
                if (res.isSuccess) {
                  SmartDialog.showToast('鍒犻櫎鎴愬姛');
                  onDelete();
                } else {
                  SmartDialog.showToast('鍒犻櫎澶辫触, $res');
                }
              },
              minLeadingWidth: 0,
              leading: Icon(Icons.delete_outlined, color: errorColor, size: 19),
              title: Text('鍒犻櫎', style: style.copyWith(color: errorColor)),
            ),
          if (ownerMid != Int64.ZERO)
            ListTile(
              onTap: () {
                Get.back();
                autoWrapReportDialog(
                  context,
                  ReportOptions.commentReport,
                  (reasonType, reasonDesc, banUid) async {
                    final res = await ReplyHttp.report(
                      rpid: item.id,
                      oid: item.oid,
                      reasonType: reasonType,
                      reasonDesc: reasonDesc,
                      banUid: banUid,
                    );
                    if (res.isSuccess) {
                      onDelete();
                    }
                    return res;
                  },
                );
              },
              minLeadingWidth: 0,
              leading: Icon(Icons.error_outline, color: errorColor, size: 19),
              title: Text('涓炬姤', style: style.copyWith(color: errorColor)),
            ),
          if (replyLevel == 1 && !isSubReply && ownerMid == upMid)
            ListTile(
              onTap: () {
                Get.back();
                onToggleTop?.call(item);
              },
              minLeadingWidth: 0,
              leading: const Icon(Icons.vertical_align_top, size: 19),
              title: Text(
                '${replyItem.replyControl.isUpTop ? '鍙栨秷' : ''}缃《',
                style: style,
              ),
            ),
          ListTile(
            onTap: () {
              Get.back();
              Utils.copyText(message);
            },
            minLeadingWidth: 0,
            leading: const Icon(Icons.copy_all_outlined, size: 19),
            title: Text('澶嶅埗鍏ㄩ儴', style: style),
          ),
          ListTile(
            onTap: () {
              Get.back();
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Padding(
                    padding: const .symmetric(horizontal: 20, vertical: 16),
                    child: SelectableText(
                      message,
                      style: const TextStyle(fontSize: 15, height: 1.7),
                      contextMenuBuilder: (_, editableTextState) =>
                          _filterMenuBuilder(context, editableTextState),
                    ),
                  ),
                ),
              );
            },
            minLeadingWidth: 0,
            leading: const Icon(Icons.copy_outlined, size: 19),
            title: Text('鑷敱澶嶅埗', style: style),
          ),
          ListTile(
            onTap: () {
              Get.back();
              SavePanel.toSavePanel(upMid: upMid, item: item);
            },
            minLeadingWidth: 0,
            leading: const Icon(Icons.save_alt, size: 19),
            title: Text('淇濆瓨璇勮', style: style),
          ),
          if (kDebugMode || item.mid == ownerMid)
            ListTile(
              onTap: () {
                Get.back();
                onCheckReply?.call(item);
              },
              minLeadingWidth: 0,
              leading: const Icon(CustomIcons.shield_reply, size: 19),
              title: Text('妫€鏌ヨ瘎璁?, style: style),
            ),
        ],
      ),
    );
  }

  static Widget _filterMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    final items = editableTextState.contextMenuButtonItems;
    if (!editableTextState.textEditingValue.selection.isCollapsed) {
      items.add(
        ContextMenuButtonItem(
          onPressed: () {
            Navigator.of(context).pop();
            final select = editableTextState.textEditingValue;
            String text = RegExp.escape(
              select.selection.textInside(select.text),
            );
            if (ReplyGrpc.enableFilter) text = '|$text';

            showConfirmDialog(
              context: context,
              title: const Text('鏄惁纭璇勮杩囨护鐨勫彉鏇达細'),
              content: Text.rich(
                TextSpan(
                  text: ReplyGrpc.replyRegExp.pattern,
                  children: [
                    TextSpan(
                      text: text,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: .bold,
                      ),
                    ),
                  ],
                ),
              ),
              onConfirm: () {
                final filter = ReplyGrpc.replyRegExp.pattern + text;
                ReplyGrpc.replyRegExp = RegExp(filter, caseSensitive: true);
                ReplyGrpc.enableFilter = true;
                GStorage.setting.put(SettingBoxKey.banWordForReply, filter);
                SmartDialog.showToast('宸蹭繚瀛?);
              },
            );
          },
          label: '鍔犲叆杩囨护',
        ),
      );
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      buttonItems: items,
      anchors: editableTextState.contextMenuAnchors,
    );
  }
}

