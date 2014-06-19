part of reactive;

class _StreamProperty<T> extends _ControllerProperty<T> {
  EventStream<T> _stream;
  T _currentValue;
  bool _hasInitialValue;

  StreamController<T> _controller;
  EventStream<T> get changes => _controller.stream;

  StreamSubscription<T> _subscription;

  _StreamProperty._(EventStream<T> stream, {T initialValue, bool hasInitialValue: false}) :
    _currentValue = initialValue,
    _hasInitialValue = hasInitialValue,
    _stream = stream.asBroadcastStream(),
    super();

  factory _StreamProperty(EventStream<T> stream) => new _StreamProperty._(stream);

  factory _StreamProperty.initialValue(EventStream<T> stream, T initialValue) =>
    new _StreamProperty._(stream, initialValue: initialValue, hasInitialValue: true);

  @override
  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError}) {
    Stream stream;

    if (_hasInitialValue) {
      stream = new EventStream(new Stream.fromIterable([_currentValue])).merge(changes);
    } else {
      stream = changes;
    }

    return stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void _handleValue(T value) {
    _currentValue = value;
    _controller.add(value);
  }

  @override
  void _startListening() {
    _subscription = _stream.listen(
        (event) => _handleValue(event),
        onError: (error, stackTrace) => _controller.addError(error, stackTrace));
  }

  @override
  void _stopListening() {
    _subscription.cancel();
    _subscription = null;
  }
}