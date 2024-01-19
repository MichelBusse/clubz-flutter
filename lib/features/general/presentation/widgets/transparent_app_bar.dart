import 'package:clubz/core/res/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/res/routes.dart';

/// A bottom sheet wrapper for the sharing options.
class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  TransparentAppBar({this.transparent = true, this.toolbarHeight, this.title, this.leading, this.actions, this.bottom, Key? key})
      : preferredSize = _PreferredTransparentAppBarSize(toolbarHeight, bottom?.preferredSize.height), super(key: key);

  @override
  final Size preferredSize;

  final double? toolbarHeight;

  final Widget? title;

  final Widget? leading;

  final List<Widget>? actions;

  final PreferredSizeWidget? bottom;

  final bool transparent;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: transparent ? Colors.transparent : AppConstants.colorScaffoldBackground,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.black, Colors.transparent]),
        ),
      ),
      leading: leading ?? IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(AppRoutes.feed);
          }
        },
      ),
      title: title,
      actions: actions,
      bottom: bottom,
    );
  }
}

// Copied from code of AppBar widget.
class _PreferredTransparentAppBarSize extends Size {
  _PreferredTransparentAppBarSize(this.toolbarHeight, this.bottomHeight)
      : super.fromHeight((toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}