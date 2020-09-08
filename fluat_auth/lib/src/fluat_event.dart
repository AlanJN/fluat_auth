typedef BaseAuthEvent _AuthEventInvoker(Map argument);

Map<String, _AuthEventInvoker> _nameAndEventMapper = {
  "authLoginEvent": (Map argument) => ATAuthLoginEvent.fromMap(argument),
  "weChatLoginEvent": (Map argument) => WeChatLoginEvent.fromMap(argument),
  "appleLoginEvent": (Map argument) => AppleLoginEvent.fromMap(argument),
  "accountLoginEvent": (Map argument) => AccountLoginEvent.fromMap(argument),
  "authErrorEvent": (Map argument) => ErrorEvent.fromMap(argument),
};

class BaseAuthEvent {
  final int errCode;

  bool get isSuccessful => errCode == 0;

  BaseAuthEvent._(this.errCode);

  factory BaseAuthEvent.create(String name, Map argument) => _nameAndEventMapper[name](argument);
}

class ATAuthLoginEvent extends BaseAuthEvent {
  String token;
  ATAuthLoginEvent.fromMap(Map map)
      : token = map["authToken"],
        super._(map["errCode"]);
}

class WeChatLoginEvent extends BaseAuthEvent {
  WeChatLoginEvent.fromMap(Map map) : super._(map["errCode"]);
}

class AppleLoginEvent extends BaseAuthEvent {
  AppleLoginEvent.fromMap(Map map) : super._(map["errCode"]);
}

class AccountLoginEvent extends BaseAuthEvent {
  AccountLoginEvent.fromMap(Map map) : super._(map["errCode"]);
}

class ErrorEvent extends BaseAuthEvent {
  ErrorEvent.fromMap(Map map) : super._(map["errCode"]);
}
