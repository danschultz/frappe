part of reactive;

abstract class _ForwardingStream<T> extends Stream<T> {
  Stream<T> _stream;

  StreamController<T> _controller;
  StreamSubscription _subscription;

  _ForwardingStream(this._stream) {
    _controller = new StreamController(
        onListen: _onListen,
        onPause: _onPause,
        onResume: _onResume,
        onCancel: _onCancel);
  }

  @override
  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError}) {
    return _controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void onData(EventSink<T> sink, T event) {
    sink.add(event);
  }

  void onError(EventSink<T> sink, Object errorEvent, StackTrace stackTrace) {
    sink.addError(errorEvent, stackTrace);
  }

  void close() {
    _controller.close();
    _subscription.cancel();
  }

  void _onListen() {
    _subscription = _stream.listen(
        (event) => onData(_controller, event),
        onError: (error, stackTrace) => onError(_controller, error, stackTrace),
        onDone: _onDone);
  }

  void _onPause() {
    _subscription.pause();
  }

  void _onResume() {
    _subscription.resume();
  }

  void _onCancel() {
    _subscription.cancel();
  }

  void _onDone() {
    _controller.close();
  }
}