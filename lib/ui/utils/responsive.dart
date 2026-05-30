import 'dart:math' as math;

import 'package:flutter/material.dart';

class Responsive {
  static const double compactWidth = 360;
  static const double tabletWidth = 700;
  static const double desktopContentWidth = 900;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compactWidth;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletWidth;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compactWidth) return 16;
    if (width < tabletWidth) return 20;
    return 32;
  }

  static double headerTopPadding(BuildContext context) {
    return MediaQuery.paddingOf(context).top + (isCompact(context) ? 18 : 28);
  }

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return math.min(width, desktopContentWidth);
  }

  static Widget centered({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? contentWidth(context),
        ),
        child: child,
      ),
    );
  }
}
