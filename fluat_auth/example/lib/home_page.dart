import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final VoidCallback logoutCallBack;

  const HomePage({Key key, this.logoutCallBack}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
            color: Colors.blue,
            child: Text(
              '登出',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              widget.logoutCallBack();
            }),
      ),
    );
  }
}
