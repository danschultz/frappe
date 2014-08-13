part of frappe;

class _ForwardingReactable<T> extends Reactable<T> {
  Reactable _reactable;

  StreamController<T> _controller;
  StreamSubscription _subscription;

  _ForwardingReactable(this._reactable) {
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

  void onData(EventSink sink, T event) {
    sink.add(event);
  }

  void onError(EventSink sink, Object errorEvent, StackTrace stackTrace) {
    sink.addError(errorEvent, stackTrace);
  }

  void close() {
    _controller.close();

    if (_subscription != null) {
      _subscription.cancel();
    }
  }

  void _onListen() {
    _subscription = _reactable.listen(
        (event) {
          try {
            onData(_controller, event);
          } catch (error, stackTrace) {
            _controller.addError(error, stackTrace);
          }
        },
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