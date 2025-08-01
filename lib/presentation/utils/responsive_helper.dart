import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isMobile(BuildContext context) {
    return screenWidth(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 600 && screenWidth(context) < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= 1200;
  }

  static bool isLandscape(BuildContext context) {
    return screenWidth(context) > screenHeight(context);
  }

  static bool isPortrait(BuildContext context) {
    return screenHeight(context) > screenWidth(context);
  }

  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context) ? 12.0 : 16.0;
    } else if (isTablet(context)) {
      return isLandscape(context) ? 20.0 : 24.0;
    } else {
      return isLandscape(context) ? 28.0 : 32.0;
    }
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return isLandscape(context) ? baseSize * 0.9 : baseSize;
    } else if (isTablet(context)) {
      return isLandscape(context) ? baseSize * 1.0 : baseSize * 1.1;
    } else {
      return isLandscape(context) ? baseSize * 1.1 : baseSize * 1.2;
    }
  }

  static EdgeInsets getResponsiveEdgeInsets(BuildContext context) {
    final padding = getResponsivePadding(context);
    return EdgeInsets.all(padding);
  }

  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final padding = getResponsivePadding(context);
    return EdgeInsets.symmetric(horizontal: padding);
  }

  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    final padding = getResponsivePadding(context);
    return EdgeInsets.symmetric(vertical: padding);
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return isLandscape(context) ? baseSize * 0.9 : baseSize;
    } else if (isTablet(context)) {
      return isLandscape(context) ? baseSize * 1.1 : baseSize * 1.2;
    } else {
      return isLandscape(context) ? baseSize * 1.3 : baseSize * 1.4;
    }
  }

  static int getResponsiveGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context) ? 3 : 2;
    } else if (isTablet(context)) {
      return isLandscape(context) ? 4 : 3;
    } else {
      return isLandscape(context) ? 5 : 4;
    }
  }

  static double getResponsiveCardHeight(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context) ? 100.0 : 120.0;
    } else if (isTablet(context)) {
      return isLandscape(context) ? 120.0 : 140.0;
    } else {
      return isLandscape(context) ? 140.0 : 160.0;
    }
  }

  static double getResponsiveButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context) ? 40.0 : 48.0;
    } else if (isTablet(context)) {
      return isLandscape(context) ? 48.0 : 56.0;
    } else {
      return isLandscape(context) ? 56.0 : 64.0;
    }
  }

  static double getResponsiveTextFieldHeight(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context) ? 40.0 : 48.0;
    } else if (isTablet(context)) {
      return isLandscape(context) ? 48.0 : 56.0;
    } else {
      return isLandscape(context) ? 56.0 : 64.0;
    }
  }

  static double getResponsiveSpacing(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context) ? 8.0 : 12.0;
    } else if (isTablet(context)) {
      return isLandscape(context) ? 12.0 : 16.0;
    } else {
      return isLandscape(context) ? 16.0 : 20.0;
    }
  }

  static double getResponsiveBorderRadius(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context) ? 8.0 : 12.0;
    } else if (isTablet(context)) {
      return isLandscape(context) ? 12.0 : 16.0;
    } else {
      return isLandscape(context) ? 16.0 : 20.0;
    }
  }

  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static Widget responsiveListView({
    required BuildContext context,
    required List<Widget> children,
    EdgeInsets? padding,
    ScrollPhysics? physics,
  }) {
    return ListView(
      padding: padding ?? getResponsiveEdgeInsets(context),
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      children: children,
    );
  }

  static Widget responsiveSingleChildScrollView({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    ScrollPhysics? physics,
  }) {
    return SingleChildScrollView(
      padding: padding ?? getResponsiveEdgeInsets(context),
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      child: child,
    );
  }

  static Widget responsiveGridView({
    required BuildContext context,
    required List<Widget> children,
    EdgeInsets? padding,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    double? childAspectRatio,
  }) {
    return GridView.count(
      padding: padding ?? getResponsiveEdgeInsets(context),
      crossAxisCount: getResponsiveGridCrossAxisCount(context),
      crossAxisSpacing: crossAxisSpacing ?? getResponsiveSpacing(context),
      mainAxisSpacing: mainAxisSpacing ?? getResponsiveSpacing(context),
      childAspectRatio: childAspectRatio ?? (isLandscape(context) ? 1.2 : 0.85),
      children: children,
    );
  }

  static Widget responsiveColumn({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    EdgeInsets? padding,
  }) {
    return Padding(
      padding: padding ?? getResponsiveEdgeInsets(context),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }

  static Widget responsiveRow({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    EdgeInsets? padding,
  }) {
    return Padding(
      padding: padding ?? getResponsiveEdgeInsets(context),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }

  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? getResponsiveEdgeInsets(context),
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }

  static Widget responsiveCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
    double? elevation,
  }) {
    return Card(
      margin: margin ?? EdgeInsets.all(getResponsiveSpacing(context)),
      elevation: elevation ?? 2.0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getResponsiveBorderRadius(context)),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(getResponsivePadding(context)),
        child: child,
      ),
    );
  }

  static Widget responsiveButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsets? padding,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? getResponsiveButtonHeight(context),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: getResponsivePadding(context),
                vertical: getResponsiveSpacing(context),
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              getResponsiveBorderRadius(context),
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget responsiveTextField({
    required BuildContext context,
    required String label,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getResponsiveBorderRadius(context),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: getResponsivePadding(context),
          vertical: getResponsiveSpacing(context),
        ),
      ),
    );
  }
}
