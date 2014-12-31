part of frappe;

abstract class _ControllerProperty<T> extends Property<T> {
  T __currentValue;
  bool _hasCurrentValue = false;
  set _currentValue(T value) {
    _hasCurrentValue = true;
    __currentValue = value;
  }

  StreamController<T> _controller;
  Stream<T> get changes => _controller.stream;

  StreamSubscription<T> _currentValueSubscription;

  _ControllerProperty({T initialValue, bool hasInitialValue: false}) : super._() {
    _controller = new StreamController.broadcast(
        onListen: () => _startListening(),
        onCancel: () => _stopListening());

    if (hasInitialValue) {
      _currentValue = initialValue;
    }
  }

  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError}) {
    Stream stream;

    if (_hasCurrentValue) {
      stream = new EventStream(new Stream.fromIterable([__currentValue])).merge(changes);
    } else {
      stream = changes;
    }

    return stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void _startListening() {
    _currentValueSubscription = changes.listen((value) => _currentValue = value, onError: (_) {});
  }

  void _stopListening() {
    _currentValueSubscription.cancel();
  }
}
