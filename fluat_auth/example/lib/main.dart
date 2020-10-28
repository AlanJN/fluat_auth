import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluat_auth/fluat_auth.dart' as fluat;

import 'login_page.dart';
import 'home_page.dart';

const String ios_key = '';
const String android_key = '';
void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<fluat.BaseAuthEvent> _event;

  bool _login = false;
  bool _fastLogin = false;

  void _userLogin() {
    setState(() {
      _login = true;
    });
  }

  void _userLogout() {
    setState(() {
      _login = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initAliAuthSdk();
    //监听事件回调
    _event = fluat.authEventHandler.listen((event) {
      if (event is fluat.FluatCheckEnvEvent) {
        print('检查环境:' + event.errCode);
      }
      if (event is fluat.FluatAccelerateEvent) {
        print('加速获取本机号码校验token/加速一键登录授权页弹起:' + event.errCode);
      }
      if (event is fluat.FluatAuthEvent) {
        print('获取一键登录token/获取本机号码校验token:' + event.errCode);
        if (event.errCode == '600000' && event.authToken.isNotEmpty) {
          print('获取一键登录token/获取本机号码校验token:' + event.authToken);
          // 如果是一键登录 获取到token后 择需要关闭授权页 继续之后的业务
          fluat.closeAuthPage();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _event.cancel();
  }

  _initAliAuthSdk() async {
    //设置SDK
    var result = await fluat.initAliAuthSDK(
        iOSSecretKey: ios_key, androidSecretKey: android_key, loggerEnable: true);
    print("initAliAuthSDK $result");

    //检验环境
    await fluat.checkEnvAvailable(authType: fluat.FluATAuthType.LOGIN).then((value) {
      setState(() {
        _fastLogin = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(brightness: Brightness.light),
            scaffoldBackgroundColor: Colors.white),
        home: _login
            ? HomePage(
                logoutCallBack: _userLogout,
              )
            : LoginPage(
                canFastLogin: _fastLogin,
                loginCallBack: _userLogin,
                fastLoginCallBack: () {
                  fluat.showAuthLoginPage(uiConfig: fluat.AuthLoginUIConfig());
                },
              ));
  }
}
