part of reactive;

class _TakeUntilStream<T> extends _ForwardingStream<T> {
  _TakeUntilStream(Stream<T> stream, Future stop) : super(stream) {
    stop.then((_) => close());
  }
}