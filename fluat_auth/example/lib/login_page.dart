import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback loginCallBack;
  final bool canFastLogin;
  final VoidCallback fastLoginCallBack;
  const LoginPage({Key key, this.loginCallBack, this.canFastLogin, this.fastLoginCallBack})
      : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: widget.canFastLogin
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                        color: Colors.blue,
                        child: Text(
                          '登录',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          widget.loginCallBack();
                        }),
                    RaisedButton(
                        color: Colors.blue,
                        child: Text(
                          '一键登录',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          widget.fastLoginCallBack();
                        }),
                  ],
                )
              : Text('检验环境未通过，一键登录不可用')),
    );
  }
}
