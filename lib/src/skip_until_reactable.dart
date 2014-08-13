part of frappe;

class _SkipUntilReactable<T> extends _ForwardingReactable<T> {
  Future _start;
  bool _shouldForward = false;

  _SkipUntilReactable(Reactable<T> reactable, this._start) : super(reactable) {
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