part of frappe;

class _DelayStream<T> extends _ForwardingStream<T> {
  Duration _delay;

  _DelayStream(Stream<T> stream, this._delay) : super(new EventStream(stream));

  void onData(EventSink<T> sink, T event) {
    new Timer(_delay, () => sink.add(event));
  }
}