library flutter_toast_package;

import 'dart:async';

import 'package:flutter/material.dart';

class FlutterToast {
  /// 参考于android的LENGTH_SHORT显示时长
  static const int LENGTH_SHORT = 2000;

  /// 参考于android的LENGTH_LONG显示时长
  static const int LENGTH_LONG = 3500;

  // toast消失的最短时间
  static const int _dimissAnimalTime = 400;

  static String _message;
  static int _duration;
  static bool _showing = false; // toast是否正在showing
  static OverlayState _overlayState;
  static OverlayEntry _overlayEntry;
  static Timer _timer;
  static Timer _timer2;

  static toast(BuildContext context, String message, {duration = LENGTH_SHORT}) async {
    assert(duration > _dimissAnimalTime, "toast 消失的动画时间为$_dimissAnimalTime，设置的显示时间必须大于该时间");

    _message = message;
    _duration = duration;
    _overlayState = Overlay.of(context);

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(builder: (BuildContext context) => _build(context));
    }

    if (_showing) {
      // 重新绘制UI，类似setState
      _overlayEntry.markNeedsBuild();
    } else {
      _showing = true;
      _overlayState.insert(_overlayEntry);
    }

    _timer?.cancel();
    _timer2?.cancel();

    _timer = Timer(Duration(milliseconds: _duration - _dimissAnimalTime), () {
      _showing = false;
      _overlayEntry.markNeedsBuild();

      _timer2 = Timer(Duration(milliseconds: _dimissAnimalTime), () {
        _overlayEntry.remove();
      });
    });
  }

  // toast位置和动画的设置
  static Widget _build(BuildContext context) {
    return Positioned(
      // top值，可以改变这个值来改变toast在屏幕中的位置
      top: MediaQuery.of(context).size.height * 4 / 5,
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 80.0),
          child: AnimatedOpacity(
            opacity: _showing ? 1.0 : 0.0, // 目标透明度
            duration: _showing ? Duration(milliseconds: 300) : Duration(milliseconds: _dimissAnimalTime),
            child: _buildToastWidget(),
          ),
        ),
      ),
    );
  }

  // toast绘制
  static Widget _buildToastWidget() {
    return Center(
      child: Card(
        color: Colors.black.withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Text(
            _message,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
