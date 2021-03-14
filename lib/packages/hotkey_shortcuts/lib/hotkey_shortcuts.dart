import 'dart:async';

import 'package:flutter/services.dart';

class HotkeyShortcuts {
  static const MethodChannel _channel = const MethodChannel('hotkey_shortcuts');

  static final Map<String, List<void Function()>> hotkeyMap = {};

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void updateWindowSize({int width, int height}) {
    _channel
        .invokeMethod("updateWindowSize", {'width': width, 'height': height});
  }

  static void moveWindowPosition({double dx, double dy}) {
    _channel.invokeMethod(
        "updateWindowPosition", {"dx": dx.round(), "dy": dy.round()});
  }

  static void recordWindowPosition() {
    _channel.invokeMethod("recordWindowPosition");
  }

  static void pasteToFrontestApp() {
    _channel.invokeMethod("pasteToFrontestApp");
  }

  static Future<List<dynamic>> getInstalledApps() {
    return _channel.invokeListMethod("getInstalledApps");
  }

  static void launchApp(String path) {
    _channel.invokeMethod("launchApp", path);
  }

  static void execCommand(String command) {
    _channel.invokeMethod("execCommand", command);
  }

  static Future register(String hotkey, void Function() callback) {
    _channel.setMethodCallHandler(_onHotkey);
    var list = hotkeyMap[hotkey];
    if (list == null) {
      list = [callback];
      _channel.invokeMethod("registerHotkey", [hotkey]);
    } else {
      list.add(callback);
    }
    hotkeyMap[hotkey] = list;
    return null;
  }

  static Future _onHotkey(MethodCall call) {
    if (call.method != 'onHotkey') {
      return null;
    }
    var hotkey = call.arguments[0];
    var list = hotkeyMap[hotkey];
    if (list == null) {
      return null;
    }
    list.forEach((element) {
      element();
    });
    return null;
  }
}
