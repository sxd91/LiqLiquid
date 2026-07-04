// Shared Hero + CupertinoPageRoute navigation utilities.
// Provides stable Hero tags and iOS-style page transitions.

import 'package:liqliquid/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class HeroNavigator {

  /// Build a stable hero tag from a base identifier.
  /// Unlike the old random-based approach, this produces stable tags
  /// so Hero transitions work correctly.
  static String heroTag(Object base, [String suffix = '']) {
    return '\$hero__\${base.hashCode}_\$suffix';
  }

  /// Navigate with iOS-style CupertinoPageRoute and optional Hero elements.
  static Future<T?> push<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool fullscreenDialog = false,
  }) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute<T>(
        builder: builder,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Push a named route with CupertinoPageRoute style.
  static Future<T?> pushNamed<T>({
    required BuildContext context,
    required String routeName,
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }
}

