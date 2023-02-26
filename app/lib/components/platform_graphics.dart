// import 'package:cupertino_lists/cupertino_lists.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// Error-free platform accessor
class NewPlatform {
  static bool get isIOS => kIsWeb ? false : Platform.isIOS;

  static bool get isAndroid => kIsWeb ? false : Platform.isAndroid;

  static bool get isWeb => kIsWeb;
}

Future<T?> showPlatformModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool bounce = false,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Duration? duration,
  RouteSettings? settings,
  double? closeProgressThreshold,
}) =>
    NewPlatform.isIOS
        ? showCupertinoModalBottomSheet<T>(
            context: context,
            builder: builder,
            expand: expand,
            bounce: bounce,
            backgroundColor: backgroundColor,
            barrierColor: barrierColor,
            clipBehavior: clipBehavior,
            duration: duration,
            enableDrag: enableDrag,
            isDismissible: isDismissible,
            secondAnimation: secondAnimation,
            shape: shape,
            useRootNavigator: useRootNavigator,
          )
        : showMaterialModalBottomSheet<T>(
            context: context,
            builder: builder,
            backgroundColor: backgroundColor,
            barrierColor: barrierColor,
            clipBehavior: clipBehavior,
            closeProgressThreshold: closeProgressThreshold,
            duration: duration,
            enableDrag: enableDrag,
            isDismissible: isDismissible,
            shape: shape,
            useRootNavigator: useRootNavigator,
          );

abstract class PlatformWidget<C extends Widget, M extends Widget,
    W extends Widget?> extends StatelessWidget {
  const PlatformWidget({super.key});

  C buildCupertinoWidget(BuildContext context);
  M buildMaterialWidget(BuildContext context);
  W? buildWebWidget(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    if (NewPlatform.isIOS) {
      return buildCupertinoWidget(context);
    } else if (NewPlatform.isAndroid) {
      return buildMaterialWidget(context);
    } else {
      return buildWebWidget(context) ?? buildMaterialWidget(context);
    }
  }
}

const kThumbColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFFFFFF),
  darkColor: Color(0xFF636366),
);

class PlatformPicker<T> extends PlatformWidget<
    CupertinoSlidingSegmentedControl<T>, ButtonBar, Null> {
  const PlatformPicker({
    super.key,
    required this.children,
    required this.onValueChanged,
    this.groupValue,
    this.thumbColor,
  });

  final Map<T, Widget> children;
  final ValueChanged<T?> onValueChanged;
  final T? groupValue;
  final Color? thumbColor;

  @override
  CupertinoSlidingSegmentedControl<T> buildCupertinoWidget(
      BuildContext context) {
    return CupertinoSlidingSegmentedControl<T>(
      children: children,
      onValueChanged: onValueChanged,
      groupValue: groupValue,
      thumbColor: thumbColor ?? kThumbColor,
    );
  }

  @override
  ButtonBar buildMaterialWidget(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: children.entries
          .map(
            (entry) => TextButton(
              onPressed: () => onValueChanged(entry.key),
              style: ButtonStyle(
                // overlayColor: MaterialStateProperty.all(thumbColor),
                foregroundColor: entry.key == groupValue
                    ? MaterialStateProperty.all(thumbColor)
                    : null,
                backgroundColor: entry.key == groupValue
                    ? MaterialStateProperty.all(Colors.black)
                    : null,
              ),
              child: entry.value,
            ),
          )
          .toList(),
    );
  }
}

class PlatformListTile
    extends PlatformWidget<CupertinoListTile, ListTile, Null> {
  const PlatformListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.backgroundColorActivated,
    this.padding,
    this.additionalInfo,
  });
  final Widget title;
  final Widget? subtitle;
  final VoidCallback? onTap;
  final Widget? additionalInfo;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? backgroundColorActivated;
  final EdgeInsetsGeometry? padding;
  @override
  CupertinoListTile buildCupertinoWidget(BuildContext context) =>
      CupertinoListTile.notched(
        title: title,
        onTap: onTap,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        backgroundColor: backgroundColor,
        backgroundColorActivated: backgroundColorActivated,
        padding: padding,
      );

  @override
  ListTile buildMaterialWidget(BuildContext context) => ListTile(
        title: title,
        onTap: onTap,
        subtitle: subtitle,
        tileColor: backgroundColor,
        leading: leading,
        trailing: trailing,
        contentPadding: padding,
      );
}

class PlatformListTileGroup
    extends PlatformWidget<CupertinoListSection, ExpansionTile, Null> {
  const PlatformListTileGroup({
    super.key,
    required this.children,
    this.backgroundColor,
    this.padding,
    required this.header,
    this.footer,
  });
  final List<Widget> children;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final Widget header;
  final Widget? footer;
  @override
  CupertinoListSection buildCupertinoWidget(BuildContext context) =>
      CupertinoListSection.insetGrouped(
        backgroundColor:
            backgroundColor ?? CupertinoColors.systemGroupedBackground,
        header: header,
        footer: footer,
        children: children,
      );

  @override
  ExpansionTile buildMaterialWidget(BuildContext context) => ExpansionTile(
        backgroundColor: backgroundColor,
        childrenPadding: padding,
        title: header,
        subtitle: footer,
        initiallyExpanded: true,
        children: children,
      );
}

class PlatformListView
    extends PlatformWidget<CustomScrollView, ListView, Null> {
  const PlatformListView({
    super.key,
    required this.children,
  });
  final List<Widget> children;
  @override
  CustomScrollView buildCupertinoWidget(BuildContext context) =>
      CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              children,
            ),
          ),
        ],
      );

  @override
  ListView buildMaterialWidget(BuildContext context) => ListView(
        children: children,
      );
}
