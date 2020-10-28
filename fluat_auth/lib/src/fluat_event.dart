typedef BaseAuthEvent _AuthEventInvoker(Map argument);

Map<String, _AuthEventInvoker> _nameAndEventMapper = {
  "fluatCheckEnvEvent": (Map argument) => FluatCheckEnvEvent.fromMap(argument),
  "fluatAccelerateEvent": (Map argument) => FluatAccelerateEvent.fromMap(argument),
  "fluatAuthEvent": (Map argument) => FluatAuthEvent.fromMap(argument),
};

class BaseAuthEvent {
  final String errCode;
  BaseAuthEvent._(this.errCode);

  factory BaseAuthEvent.create(String name, Map argument) => _nameAndEventMapper[name](argument);
}

class FluatCheckEnvEvent extends BaseAuthEvent {
  FluatCheckEnvEvent.fromMap(Map map) : super._(map["errCode"]);
}

class FluatAccelerateEvent extends BaseAuthEvent {
  FluatAccelerateEvent.fromMap(Map map) : super._(map["errCode"]);
}

class FluatAuthEvent extends BaseAuthEvent {
  String authToken;
  FluatAuthEvent.fromMap(Map map)
      : authToken = map["token"],
        super._(map["errCode"]);
}
