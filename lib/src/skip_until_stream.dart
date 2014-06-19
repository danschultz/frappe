part of relay;

class _SkipUntilStream<T> extends _ForwardingStream<T> {
  Future _start;
  bool _shouldForward = false;

  _SkipUntilStream(Stream<T> stream, this._start) : super(stream) {
    _start.then((_) => _shouldForward = true);
  }

  void onData(EventSink<T> sink, T event) {
    if (_shouldForward) {
      sink.add(event);
    }
  }

  void onError(EventSink<T> sink, Object errorEvent, StackTrace stackTrace) {
    if (_shouldForward) {
      sink.addError(errorEvent, stackTrace);
    }
  }
}