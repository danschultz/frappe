part of reactive;

class ReactiveStream<T> extends StreamView<T> {
  ReactiveStream(Stream<T> stream) : super(stream);

  Signal<T> _latest;
  Signal<T> get latest {
    if (_latest == null) {
      _latest = new StreamSignal(null, this);
    }
    return _latest;
  }

  /// Returns a new stream that contains events from this stream and the [other] stream.
  ReactiveStream merge(Stream other) => new ReactiveStream(new _MergedStream([this, other]));

  /// Returns a new stream that will begin forwarding events from this stream when the
  /// [future] completes.
  ReactiveStream<T> skipUntil(Future future) {
    return new ReactiveStream<T>(new _SkipUntilStream(this, future));
  }

  /// Returns a new stream that contains events from this stream until the [future]
  /// completes.
  ReactiveStream<T> takeUntil(Future future) {
    return new ReactiveStream<T>(new _TakeUntilStream(this, future));
  }

  /// Returns a new stream that upon forwarding an event from this stream, will ignore
  /// any subsequent events until [duration], after which the last event will be
  /// forwarded.
  ///
  /// The returned stream will not throttle errors.
  ReactiveStream<T> throttle(Duration duration) {
    return new ReactiveStream<T>(new _ThrottleStream(this, duration));
  }
}