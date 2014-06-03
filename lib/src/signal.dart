part of reactive;

// Extend dynamic to suppress warnings with operator overrides
abstract class Signal<T extends dynamic> extends Object {
  T _value;
  T get value => _value;

  StreamController<T> _onChange = new StreamController.broadcast();
  ReactiveStream<T> get onChange => new ReactiveStream(_onChange.stream.distinct());

  Signal._();

  factory Signal(T value) {
    return new _ConstantSignal(value);
  }

  T call() => value;

  void _setValue(T newValue) {
    var oldValue = value;
    _value = newValue;
    _onChange.add(newValue);
  }

  Signal<T> operator +(Signal<T> other) {
    return new _CombinatorSignal(this, other, (a, b) => a + b);
  }

  BoolSignal equals(Signal other) {
    return new BoolSignal(new _CombinatorSignal(this, other, (a, b) => a == b));
  }

  Signal derive(Object computation(T value)) {
    return new _ComputedSignal(onChange, () => computation(value));
  }
}

class StreamSignal<T> extends Signal<T> {
  Stream<T> _stream;
  StreamSubscription<T> _subscription;

  bool get _isSubscribed => _subscription != null;

  StreamSignal(T initialValue, this._stream) : super._() {
    _setValue(initialValue);
    subscribe();
  }

  void subscribe() {
    if (!_isSubscribed) {
      _subscription = _stream.listen((event) => _setValue(event));
    }
  }

  Future unsubscribe() {
    if (_isSubscribed) {
      return _subscription.cancel().then((_) => _subscription = null);
    } else {
      return new Future.value();
    }
  }
}

class _ConstantSignal<T> extends Signal<T> {
  _ConstantSignal(T value) : super._() {
    _setValue(value);
  }
}
