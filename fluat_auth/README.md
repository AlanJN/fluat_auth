## Fluat_auth

`Fluat_auth` 是 [阿里号码认证服务SDK](https://help.aliyun.com/product/75010.html)插件.

## 文档

[官方文档](https://help.aliyun.com/product/75010.html)

原生SDK版本 iOS: V2.10.1 Android: V2.10.1

请按照文档中指示 注册应用获取到iOSKey 和 AndroidKey 用于初始化SDK

默认使用者掌握或了解iOS或Android原生开发

## 功能
* 一键登录
* 本机号码校验
* 授权页部分UI定制 （如需高度定制化授权页UI,请自行修改原生代码即可）


## 安装

在`pubspec.yaml` 文件中添加`fluat_auth`依赖:

```
dependencies:
  fluat_auth: ^1.0.0
```

注意:请看好所使用的版本号

## 使用

**初始化SDK**

```
fluat.initAliAuthSDK(
    iOSSecretKey: ios_key, androidSecretKey: android_key, loggerEnable: true)
```



**检验环境**

```
await fluat.checkEnvAvailable(authType: fluat.FluATAuthType.LOGIN).then((value) {
  setState(() {
    _fastLogin = value;
  });
});
```



**监听事件回调**

```
_event = fluat.authEventHandler.listen((event) {
});
```



**唤起授权页面**

```
fluat.showAuthLoginPage(uiConfig: fluat.AuthLoginUIConfig());
```



**释放监听**   

```
_event.cancel();
```



**更多功能和参数，请查看源码**