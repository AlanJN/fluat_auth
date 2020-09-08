import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fluat_auth/fluat.dart';

MethodChannel _channel = MethodChannel('fluat_auth')..setMethodCallHandler(_methodHandler);

StreamController<BaseAuthEvent> _authEventHandlerController = StreamController.broadcast();

Stream get authEventHandler => _authEventHandlerController.stream;

/*
*  初始化阿里号码认证SDK
*  iOSSecretKey : iOS秘钥 必填
*  androidSecretKey : 安卓秘钥 必填
* */
Future<dynamic> initAliAuthSDK({String iOSSecretKey, String androidSecretKey}) async {
  if (Platform.isIOS && iOSSecretKey.trim().isEmpty) {
    throw ArgumentError.value(iOSSecretKey, 'your ios secret key is illegal');
  }
  if (Platform.isAndroid && androidSecretKey.trim().isEmpty) {
    throw ArgumentError.value(androidSecretKey, 'your android secret key is illegal');
  }
  return await _channel
      .invokeMethod('initAliAuthSDK', {'iOS': iOSSecretKey, 'android': androidSecretKey});
}

/*
* 唤起一键登录授权页
* timeOut : 超时时间 默认3s 非必填
* */
Future<bool> aliAuthLogin({int timeOut = 3}) async {
  return await _channel.invokeMethod('aliAuthLogin', {'timeout': timeOut});
}

Future _methodHandler(MethodCall methodCall) {
  var event = BaseAuthEvent.create(methodCall.method, methodCall.arguments);
  _authEventHandlerController.add(event);
  return Future.value();
}
