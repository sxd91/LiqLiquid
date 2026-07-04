import 'package:liqliquid/models/dynamics/result.dart';
import 'package:liqliquid/pages/dynamics_repost/view.dart';
import 'package:liqliquid/utils/num_utils.dart';
import 'package:liqliquid/utils/page_utils.dart';
import 'package:liqliquid/utils/request_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActionPanel extends StatelessWidget {
  const ActionPanel({
    super.key,
    required this.item,
  });
  final DynamicItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final outline = theme.colorScheme.outline;
    final moduleStat = item.modules.moduleStat!;
    final forward = moduleStat.forward!;
    final comment = moduleStat.comment!;
    final like = moduleStat.like!;
    final btnStyle = TextButton.styleFrom(
      tapTargetSize: .padded,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      foregroundColor: outline,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Builder(
            builder: (context) {
              return TextButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => RepostPanel(
                    item: item,
                    onSuccess: () {
                      int count = forward.count ?? 0;
                      forward.count = count + 1;
                      if (context.mounted) {
                        (context as Element?)?.markNeedsBuild();
                      }
                    },
                  ),
                ),
                icon: Icon(
                  FontAwesomeIcons.shareFromSquare,
                  size: 16,
                  color: outline,
                  semanticLabel: "杞彂",
                ),
                style: btnStyle,
                label: Text(
                  forward.count != null
                      ? NumUtils.numFormat(forward.count)
                      : '杞彂',
                ),
              );
            },
          ),
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: () => PageUtils.pushDynDetail(
              item,
              isPush: true,
              viewComment: true,
            ),
            icon: Icon(
              FontAwesomeIcons.comment,
              size: 16,
              color: outline,
              semanticLabel: "璇勮",
            ),
            style: btnStyle,
            label: Text(
              comment.count != null ? NumUtils.numFormat(comment.count) : '璇勮',
            ),
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              final likeIcon = Icon(
                like.status!
                    ? FontAwesomeIcons.solidThumbsUp
                    : FontAwesomeIcons.thumbsUp,
                size: 16,
                color: like.status! ? primary : outline,
                semanticLabel: like.status! ? "宸茶禐" : "鐐硅禐",
              );
              return TextButton.icon(
                onPressed: () => RequestUtils.onLikeDynamic(
                  item,
                  likeIcon.color == primary,
                  () {
                    if (context.mounted) {
                      (context as Element?)?.markNeedsBuild();
                    }
                  },
                ),
                icon: likeIcon,
                style: btnStyle,
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    like.count != null ? NumUtils.numFormat(like.count) : '鐐硅禐',
                    key: ValueKey<int?>(like.count),
                    style: TextStyle(color: like.status! ? primary : outline),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

