part of frappe;

class _StreamProperty<T> extends _ControllerProperty<T> {
  Stream<T> _stream;

  StreamSubscription<T> _subscription;

  _StreamProperty._(Stream<T> stream, {T initialValue, bool hasInitialValue: false}) :
    _stream = stream,
    super(initialValue: initialValue, hasInitialValue: hasInitialValue);

  factory _StreamProperty(Stream<T> stream) => new _StreamProperty._(stream);

  factory _StreamProperty.initialValue(Stream<T> stream, T initialValue) =>
    new _StreamProperty._(stream, initialValue: initialValue, hasInitialValue: true);

  void _handleValue(T value) {
    _currentValue = value;
    _controller.add(value);
  }

  @override
  void _startListening() {
    super._startListening();

    _subscription = _stream.listen(
        (event) => _handleValue(event),
        onDone: () => _controller.close(),
        onError: (error, stackTrace) => _controller.addError(error, stackTrace));
  }

  @override
  void _stopListening() {
    super._stopListening();

    _subscription.cancel();
    _subscription = null;
  }
}