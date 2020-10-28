import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluat_auth/fluat.dart' as fluat;

import 'login_page.dart';
import 'home_page.dart';

const String ios_key = 'i+7GI/Z0wyy3pa/ezlSsKwMCqhcDlio1zECAl1daiRE0vHPZhPeqRIc1O9Y27VmKuXm4Lsxw4Md'
    '+AgoWao/Et64KZAwPxwQfBmn5ScYPf1C/caEU5hNv5VclUzO07hxDS53iWGrpD1mm47O3cmcJU8M7V/Vy0OempC/liAKDydlXx78b7YLYMh5IoNOOESUmvYzwyW/T9tBlcieaUum2E1lWemltXRJvBuHuw9OThwjlmKigqHp7Aw==';
const String android_key =
    'kStgh7Y/3GyTDsI/zeuPX1VJoFDCbeORMFM56o1QzvA2uoTIZFYInB59NroUU/G/XKMV4Uc67/tIN9mqx6Pji48Rqmwvb4L6CQizlquqGExFbIhS50UQBIF71HddjVn0Lh9+HHLvEOKbxhvSbRw6upqPyIgGmFdcZGaySlE9wpljlTPpzI1iZqnMF2a3hX/1dHKEVY130iqH/cpcT93JYS5i+y5G2Wa7M1Jr5kC7RcaeHhJAiN0VJXZ9hS4e2QUCvWnug1LyNck1VUOoSj4fsHvU9kT9XImi';
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
