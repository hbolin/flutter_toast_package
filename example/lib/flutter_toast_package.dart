library flutter_toast_package;

import 'dart:async';

import 'package:flutter/material.dart';

enum FlutterToastPosition {
  TOP,
  CENTER,
  BOTTOM,
}

class FlutterToast {
  /// 参考于android的LENGTH_SHORT显示时长
  static const int LENGTH_SHORT = 2000;

  /// 参考于android的LENGTH_LONG显示时长
  static const int LENGTH_LONG = 3500;

  // toast消失的最短时间
  static const int _dismissAnimalTime = 300;

  // toast是否正在showing
  bool _showing = false;
  OverlayState _overlayState;
  OverlayEntry _overlayEntry;

  void toast(BuildContext context, String message, {duration = LENGTH_SHORT, Color bgColor, Color textColor, FlutterToastPosition position = FlutterToastPosition.BOTTOM}) {
    var toastWidget = _buildToastTextWidget(context, message, bgColor, textColor);
    customToast(context, toastWidget, duration: duration, position: position);
  }

  void customToast(BuildContext context, Widget child, {duration = LENGTH_SHORT, FlutterToastPosition position = FlutterToastPosition.BOTTOM}) {
    _overlayState = Overlay.of(context);

    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return _buildPositioned(context, child, position);
    });

    _showing = false;
    _overlayState.insert(_overlayEntry);

    _dismissToast(duration);
  }

  void _dismissToast(int duration) async {
    await Future.delayed(Duration(milliseconds: 100));
    _showing = true;
    _overlayEntry.markNeedsBuild();
    await Future.delayed(Duration(milliseconds: duration));
    _showing = false;
    _overlayEntry.markNeedsBuild();
    await Future.delayed(Duration(milliseconds: _dismissAnimalTime));
    _overlayEntry.remove();
  }

  // toast位置和动画的设置
  Widget _buildPositioned(BuildContext context, Widget toastWidget, FlutterToastPosition position) {
    var child = AnimatedOpacity(
      opacity: _showing ? 1.0 : 0.0,
      duration: Duration(milliseconds: _dismissAnimalTime),
      child: toastWidget,
    );

    switch (position) {
      case FlutterToastPosition.TOP:
        return IgnorePointer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 1 / 10),
                child: child,
              )
            ],
          ),
        );
      case FlutterToastPosition.CENTER:
        return IgnorePointer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              child,
            ],
          ),
        );
      case FlutterToastPosition.BOTTOM:
      default:
        return IgnorePointer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 1 / 10),
                child: child,
              )
            ],
          ),
        );
    }
  }

  // toast text绘制
  static Widget _buildToastTextWidget(BuildContext context, String message, Color bgColor, Color textColor) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: bgColor ?? Colors.black.withOpacity(0.8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          message,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.caption.fontSize,
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
