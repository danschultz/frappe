part of frappe;

class _DelayReactable<T> extends _ForwardingReactable<T> {
  Duration _delay;

  _DelayReactable(Reactable<T> reactable, this._delay) : super(reactable);

  void onData(EventSink<T> sink, T event) {
    new Timer(_delay, () => sink.add(event));
  }
}