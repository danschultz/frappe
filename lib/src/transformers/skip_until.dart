part of frappe.transformers;

class SkipUntil<T> implements StreamTransformer<T, T> {
  final Future _signal;

  SkipUntil(Future signal) : _signal = signal;

  Stream<T> bind(Stream<T> stream) {
    return stream.transform(new When(new Stream.fromFuture(_signal).map((_) => true)));
  }
}