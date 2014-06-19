part of reactive;

class EventStream<T> extends StreamView<T> implements Observable<T> {
  EventStream(Stream<T> stream) : super(stream);

  /// Returns a new stream that contains events from this stream and the [other] stream.
  EventStream merge(Stream other) => new EventStream(new _MergedStream([this, other]));

  Signal<T> scan(T initialValue, T combine(T value, T element)) {
    return new EventStream<T>(new _ScanStream(this, initialValue, combine))
        .asSignalWithInitialValue(initialValue);
  }

  /// Returns a new stream that will begin forwarding events from this stream when the
  /// [future] completes.
  EventStream<T> skipUntil(Future future) {
    return new EventStream<T>(new _SkipUntilStream(this, future));
  }

  /// Returns a new stream that contains events from this stream until the [future]
  /// completes.
  EventStream<T> takeUntil(Future future) {
    return new EventStream<T>(new _TakeUntilStream(this, future));
  }

  /// Returns a new stream that upon forwarding an event from this stream, will ignore
  /// any subsequent events until [duration], after which the last event will be
  /// forwarded.
  ///
  /// The returned stream will not throttle errors.
  EventStream<T> throttle(Duration duration) {
    return new EventStream<T>(new _ThrottleStream(this, duration));
  }

  Signal<T> asSignal() {
    return new _StreamSignal(this);
  }

  Signal<T> asSignalWithInitialValue(T initialValue) {
    return new _StreamSignal.initialValue(this, initialValue);
  }
}