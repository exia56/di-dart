/// inspire by https://stackoverflow.com/questions/13731631/creating-function-with-variable-number-of-arguments-or-parameters-in-dart#answer-13732459
typedef OnCall = dynamic Function(List arguments);

class VarargsFunction {
  VarargsFunction(this._func);

  final Function _func;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!invocation.isMethod || invocation.namedArguments.isNotEmpty) {
      super.noSuchMethod(invocation);
    }
    final arguments = invocation.positionalArguments;
    final namedArguments = invocation.namedArguments;
    print(arguments[0]);
    return Function.apply(_func, arguments[0], namedArguments);
  }
}

class DependencyNotFoundException implements Exception {
  final String key;

  DependencyNotFoundException(this.key);

  @override
  String toString() {
    final errorString = 'DependencyNotFoundException: ${key} key is not found';
    return '$errorString\n${super.toString()}';
  }
}

class DependencyTypeNotMatchException implements Exception {
  final String key;
  final Type expectType;
  final Type genericType;

  DependencyTypeNotMatchException(this.key, this.genericType, this.expectType);

  @override
  String toString() {
    final errorString =
        'DependencyTypeNotMatchException: ${key} is expected as $expectType type, but really is $genericType';
    return '$errorString\n${super.toString()}';
  }
}

class _DIMapValue {
  final List<String> dependencyList;
  final Map<String, String> dependencyNamed;
  final dynamic builder;
  final Type type;
  _DIMapValue(
      this.builder, this.dependencyList, this.dependencyNamed, this.type);
}

class DI {
  static DI _instance;

  static DI get insatnce {
    _instance ??= DI._();
    return _instance;
  }

  DI._();

  final _dependencyMap = <String, _DIMapValue>{};
  final _createdMap = <String, Object>{};

  void register<T>(String key, Function builder,
      {List<String> dependencyKeys, Map<String, String> namedParameter}) {
    _dependencyMap[key] =
        _DIMapValue(builder, dependencyKeys, namedParameter, T);
  }

  _DIMapValue _getDependencyValue(String key) {
    final value = _dependencyMap[key];
    if (value == null) {
      throw DependencyNotFoundException(key);
    }
    return value;
  }

  Object _createObjInstance(String key) {
    final value = _getDependencyValue(key);

    final dependencys =
        value.dependencyList?.map((dependencyKey) => get(dependencyKey)) ?? [];
    final depandencyNamed = value.dependencyNamed?.map(
        (key, value) => MapEntry<Symbol, dynamic>(Symbol(key), get(value)));
    final objInstance =
        Function.apply(value.builder, dependencys.toList(), depandencyNamed);

    _createdMap[key] = objInstance;

    return objInstance;
  }

  T get<T>(String key) {
    var obj = _createdMap[key] ?? _createObjInstance(key);
    if (obj is! T) {
      throw DependencyTypeNotMatchException(key, obj.runtimeType, T);
    }
    return obj as T;
  }
}
