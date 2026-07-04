import 'package:liqliquid/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo;
import 'package:liqliquid/http/reply.dart';
import 'package:liqliquid/utils/feed_back.dart';
import 'package:liqliquid/utils/num_utils.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ZanButtonGrpc extends StatelessWidget {
  const ZanButtonGrpc({
    super.key,
    required this.replyItem,
  });

  final ReplyInfo replyItem;

  Future<void> onHateReply(
    BuildContext context,
    bool isProcessing,
    VoidCallback onDone, {
    required bool isLike,
    required bool isDislike,
  }) async {
    if (isProcessing) {
      return;
    }
    isProcessing = true;
    feedBack();
    final int oid = replyItem.oid.toInt();
    final int rpid = replyItem.id.toInt();
    // 1 宸茬偣璧?2 涓嶅枩娆?0 鏈搷浣?    final int action = isDislike ? 0 : 2;
    final res = await ReplyHttp.hateReply(
      type: replyItem.type.toInt(),
      action: action == 2 ? 1 : 0,
      oid: oid,
      rpid: rpid,
    );
    // SmartDialog.dismiss();
    if (res.isSuccess) {
      SmartDialog.showToast(isDislike ? '鍙栨秷韪? : '鐐硅俯鎴愬姛');
      if (action == 2) {
        if (isLike) replyItem.like -= $fixnum.Int64.ONE;
        replyItem.replyControl.action = $fixnum.Int64.TWO;
      } else {
        replyItem.replyControl.action = $fixnum.Int64.ZERO;
      }
      if (context.mounted) {
        (context as Element?)?.markNeedsBuild();
      }
    } else {
      res.toast();
    }
    onDone();
  }

  // 璇勮鐐硅禐
  Future<void> onLikeReply(
    BuildContext context,
    bool isProcessing,
    VoidCallback onDone, {
    required bool isLike,
    required bool isDislike,
  }) async {
    if (isProcessing) {
      return;
    }
    isProcessing = true;
    feedBack();
    final int oid = replyItem.oid.toInt();
    final int rpid = replyItem.id.toInt();
    // 1 宸茬偣璧?2 涓嶅枩娆?0 鏈搷浣?    final int action = isLike ? 0 : 1;
    final res = await ReplyHttp.likeReply(
      type: replyItem.type.toInt(),
      oid: oid,
      rpid: rpid,
      action: action,
    );
    if (res.isSuccess) {
      SmartDialog.showToast(isLike ? '鍙栨秷璧? : '鐐硅禐鎴愬姛');
      if (action == 1) {
        replyItem
          ..like += $fixnum.Int64.ONE
          ..replyControl.action = $fixnum.Int64.ONE;
      } else {
        replyItem
          ..like -= $fixnum.Int64.ONE
          ..replyControl.action = $fixnum.Int64.ZERO;
      }
      if (context.mounted) {
        (context as Element?)?.markNeedsBuild();
      }
    } else {
      res.toast();
    }
    onDone();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    late bool isProcessing = false;
    final action = replyItem.replyControl.action;
    final isLike = action == $fixnum.Int64.ONE;
    final isDislike = action == $fixnum.Int64.TWO;
    final outline = theme.colorScheme.outline;
    final primary = theme.colorScheme.primary;
    final ButtonStyle style = TextButton.styleFrom(
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 32,
          child: TextButton(
            style: const ButtonStyle(
              visualDensity: .compact,
              tapTargetSize: .shrinkWrap,
              padding: WidgetStatePropertyAll(.zero),
              minimumSize: WidgetStatePropertyAll(.square(40)),
            ),
            onPressed: () => onHateReply(
              context,
              isProcessing,
              () => isProcessing = false,
              isLike: isLike,
              isDislike: isDislike,
            ),
            child: Icon(
              isDislike
                  ? FontAwesomeIcons.solidThumbsDown
                  : FontAwesomeIcons.thumbsDown,
              size: 16,
              color: isDislike ? primary : outline,
              semanticLabel: isDislike ? '宸茶俯' : '鐐硅俯',
            ),
          ),
        ),
        SizedBox(
          height: 32,
          child: TextButton(
            style: style,
            onPressed: () => onLikeReply(
              context,
              isProcessing,
              () => isProcessing = false,
              isLike: isLike,
              isDislike: isDislike,
            ),
            child: Row(
              spacing: 4,
              children: [
                Icon(
                  isLike
                      ? FontAwesomeIcons.solidThumbsUp
                      : FontAwesomeIcons.thumbsUp,
                  size: 16,
                  color: isLike ? primary : outline,
                  semanticLabel: isLike ? '宸茶禐' : '鐐硅禐',
                ),
                Text(
                  NumUtils.numFormat(replyItem.like.toInt()),
                  style: TextStyle(
                    color: isLike ? primary : outline,
                    fontSize: theme.textTheme.labelSmall!.fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

