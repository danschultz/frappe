part of reactive;

class _ScanStream<T> extends _ForwardingStream<T> {
  T _value;
  Function _combine;

  _ScanStream(Stream<T> stream, T initialValue, T combine(T value, T element)) :
    _value = initialValue,
    _combine = combine,
    super(stream);

  void onData(EventSink<T> sink, T event) {
    _value = _combine(_value, event);
    sink.add(_value);
  }
}
