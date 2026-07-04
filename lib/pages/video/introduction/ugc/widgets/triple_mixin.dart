import 'dart:async';

import 'package:liqliquid/pages/video/pay_coins/view.dart';
import 'package:liqliquid/utils/global_data.dart';
import 'package:liqliquid/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

mixin TripleMixin on GetxController, TickerProvider {
  // 鏄惁鐐硅禐
  final RxBool hasLike = false.obs;
  // 鎶曞竵鏁伴噺
  final RxNum coinNum = RxNum(0);
  // 鏄惁鎶曞竵
  bool get hasCoin => coinNum.value != 0;
  // 鏄惁鏀惰棌
  final RxBool hasFav = false.obs;

  bool get hasTriple => hasLike.value && hasCoin && hasFav.value;

  bool get isLogin;

  bool isHasCopyright(int copyright) {
    return copyright != 2;
  }

  bool reachCoinLimit(bool hasCopyRight, num coinNum) {
    return (!hasCopyRight && coinNum >= 1) || coinNum >= 2;
  }

  int get copyright;

  void onPayCoin(int coin, bool coinWithLike);

  void actionCoinVideo() {
    if (!isLogin) {
      SmartDialog.showToast('璐﹀彿鏈櫥褰?);
      return;
    }

    final coinNum = this.coinNum.value;
    final copyright = this.copyright;
    final hasCopyright = isHasCopyright(copyright);
    if (reachCoinLimit(hasCopyright, coinNum)) {
      SmartDialog.showToast('杈惧埌鎶曞竵涓婇檺鍟');
      return;
    }

    if (GlobalData().coins != null && GlobalData().coins! < 1) {
      SmartDialog.showToast('纭竵涓嶈冻');
      // return;
    }

    PayCoinsPage.toPayCoinsPage(
      onPayCoin: onPayCoin,
      hasCoin: coinNum == 1,
      hasCopyright: hasCopyright,
    );
  }

  void actionTriple();
  void actionLikeVideo();

  // no need for pugv
  AnimationController? _tripleAnimCtr;
  Animation<double>? _tripleAnimation;

  AnimationController get tripleAnimCtr =>
      _tripleAnimCtr ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
        reverseDuration: const Duration(milliseconds: 400),
      );

  Animation<double> get tripleAnimation => _tripleAnimation ??= tripleAnimCtr
      .drive(CurveTween(curve: Curves.easeInOut));

  Timer? _timer;

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  static final _duration = PlatformUtils.isMobile
      ? const Duration(milliseconds: 200)
      : const Duration(milliseconds: 255);

  void onStartTriple() {
    _timer ??= Timer(_duration, () {
      HapticFeedback.lightImpact();
      if (hasTriple) {
        SmartDialog.showToast('宸插畬鎴愪笁杩?);
      } else {
        tripleAnimCtr.forward().whenComplete(() {
          tripleAnimCtr.reset();
          actionTriple();
        });
      }
      _cancelTimer();
    });
  }

  void onCancelTriple([bool isTapUp = false]) {
    if (tripleAnimCtr.status == AnimationStatus.forward) {
      tripleAnimCtr.reverse();
    } else if (_timer != null && _timer!.tick == 0) {
      _cancelTimer();
      if (isTapUp) {
        actionLikeVideo();
      }
    }
  }

  @override
  void onClose() {
    _cancelTimer();
    _tripleAnimCtr?.dispose();
    super.onClose();
  }
}

