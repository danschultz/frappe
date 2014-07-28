part of frappe;

class _TakeUntilStream<T> extends _ForwardingStream<T> {
  _TakeUntilStream(Stream<T> stream, Future stop) : super(new EventStream(stream)) {
    stop.then((_) => close());
  }
}