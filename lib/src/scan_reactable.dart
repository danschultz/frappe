part of frappe;

class _ScanReactable<T> extends _ForwardingReactable<T> {
  T _value;
  Function _combine;

  _ScanReactable(Reactable<T> reactable, T initialValue, T combine(T value, T element)) :
    _value = initialValue,
    _combine = combine,
    super(reactable);

  void onData(EventSink<T> sink, T event) {
    _value = _combine(_value, event);
    sink.add(_value);
  }
}
