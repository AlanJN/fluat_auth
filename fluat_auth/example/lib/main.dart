import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluat_auth/fluat.dart' as fluat;

import 'login_page.dart';
import 'home_page.dart';

const String ios_key = '';
const String android_key = '';
void main() {
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
    _event = fluat.authEventHandler.listen((event) {
      if (event is fluat.ATAuthLoginEvent) {
        print('一键登录');
        fluat.ATAuthLoginEvent authEvent = event;
        print(authEvent.token);
        _userLogin();
      }
      if (event is fluat.WeChatLoginEvent) {
        print('微信登录');
      }
      if (event is fluat.AppleLoginEvent) {
        print('苹果登录');
      }
      if (event is fluat.AccountLoginEvent) {
        print('账号登录');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _event.cancel();
  }

  _initAliAuthSdk() async {
    await fluat.initAliAuthSDK(iOSSecretKey: ios_key, androidSecretKey: android_key).then((value) {
      if (value == 1) {
        setState(() {
          _fastLogin = !_fastLogin;
        });
      }
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
                  fluat.aliAuthLogin();
                },
              ));
  }
}
