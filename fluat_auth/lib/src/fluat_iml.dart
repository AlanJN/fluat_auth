import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'fluat_method.dart';
import 'package:fluat_auth/fluat_auth.dart';
import 'dart:io';

MethodChannel _channel = MethodChannel('fluat_auth')..setMethodCallHandler(_methodHandler);

StreamController<BaseAuthEvent> _authEventHandlerController = StreamController.broadcast();

Stream get authEventHandler => _authEventHandlerController.stream;

/// 初始化阿里号码认证SDK
/// [iOSSecretKey] iOS秘钥
/// [androidSecretKey] 安卓秘钥
/// [inIOS] 默认为true 设置iOSSDK信息
/// [inAndroid]默认为true 设置AndroidSDK信息
/// [loggerEnable] 是否处于开启调试状态 默认false 仅Android有效
/// [config] 授权页部分UI配置，如果需要定制 请二次开发原生代码或集成原生SDK自己开发
Future<bool> initAliAuthSDK(
    {String iOSSecretKey,
    String androidSecretKey,
    bool inIOS: true,
    bool inAndroid: true,
    bool loggerEnable: false}) async {
  if (inIOS && iOSSecretKey.trim().isEmpty) {
    throw ArgumentError.value(iOSSecretKey, 'iOS secret key is illegal');
  }
  if (inAndroid && androidSecretKey.trim().isEmpty) {
    throw ArgumentError.value(androidSecretKey, 'Android secret key is illegal');
  }
  return await _channel.invokeMethod(FluATAuthMethod.Init, {
    'iOSSecretKey': iOSSecretKey,
    'inIOS': inIOS,
    'androidSecretKey': androidSecretKey,
    'inAndroid': inAndroid,
    'loggerEnable': loggerEnable,
  });
}

/// 检查当前环境是否支持一键登录或号码认证
/// [authType] [FluATAuthType]  必填
/// [accelerate] 加速获取本机号码校验token/加速一键登录授权页弹起,默认true,根据authType类型调用加速类型
/// [timeOut] 加速获取本机号码校验token/加速一键登录授权页弹起的超时时间,默认3s
Future<bool> checkEnvAvailable(
    {@required FluATAuthType authType, bool accelerate = true, int timeOut = 3}) async {
  if (authType == null) {
    throw ArgumentError.value(authType, 'authType is illegal');
  }
  return await _channel.invokeMethod(FluATAuthMethod.CheckEnv,
      {'authType': authType.toNativeInt(), 'accelerate': accelerate, 'timeOut': timeOut});
}

/// 唤起一键登录授权页,点击授权页登录按钮会获取一键登录token
/// [timeOut] : 接口超时时间 单位s 默认3s
Future<bool> showAuthLoginPage({int timeOut = 3, AuthLoginUIConfig uiConfig}) async {
  return await _channel.invokeMethod(
      FluATAuthMethod.ShowAuth, {'timeout': timeOut, 'config': uiConfig?.toNativeUIConfig()});
}

/// 注销授权页，建议用此方法，对于移动卡授权页的消失会清空一些数据
Future<bool> closeAuthPage() async {
  return await _channel.invokeMethod(FluATAuthMethod.CloseAuthPage);
}

/// [BaseAuthEvent]
/// 成功时,errCode = 600000,其他情况,请参考阿里文档:PNSReturnCode
/// [FluatAuthEvent] 在成功时会带有token返回
Future _methodHandler(MethodCall methodCall) {
  var event = BaseAuthEvent.create(methodCall.method, methodCall.arguments);
  _authEventHandlerController.add(event);
  return Future.value();
}
