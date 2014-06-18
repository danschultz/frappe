part of reactive;

class EventStream<T> extends StreamView<T> implements Observable<T> {
  EventStream(Stream<T> stream) : super(stream);

  Signal<T> _latest;
  Signal<T> get latest {
    if (_latest == null) {
      _latest = new StreamSignal(null, this);
    }
    return _latest;
  }

  /// Returns a new stream that contains events from this stream and the [other] stream.
  EventStream merge(Stream other) => new EventStream(new _MergedStream([this, other]));

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
}