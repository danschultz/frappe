part of frappe.transformers;

class Scan<T> implements StreamTransformer {
  final T _initialValue;
  final Function _combine;

  Scan(T initialValue, T combine(T previous, T current)) :
    _initialValue = initialValue,
    _combine = combine;

  Stream<T> bind(Stream<T> stream) {
    return bindStream(like: stream, onListen: (EventSink<T> sink) {
      var value = _initialValue;
      return stream.listen((data) {
        value = _combine(value, data);
        sink.add(value);
      });
    });
  }
}
