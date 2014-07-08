part of frappe;

/// An [EventStream] is wrapper around a standard Dart [Stream], but provides utility
/// methods for creating other streams or properties.
class EventStream<T> extends StreamView<T> implements Watchable<T> {
  EventStream(Stream<T> stream) : super(stream);

  /// Delays the delivery of each non-error event from this stream by the given [duration].
  EventStream<T> delay(Duration duration) {
    return _asEventStream(new _DelayStream(this, duration));
  }

  /// Returns a new stream that includes events and errors from only the latest stream
  /// returned by [convert].
  ///
  /// This method can be thought of stream switching.
  EventStream asyncExpandLatest(Stream convert(T event)) {
    return _asEventStream(new _AsyncExpandLatestStream(this, convert));
  }

  /// Returns a new stream that contains events from this stream and the [other] stream.
  EventStream merge(Stream other) {
    return _asEventStream(new _MergedStream([this, other]));
  }

  /// Returns a new stream that is paused and events buffered when the last event in the
  /// [toggleSwitch] is `true`.
  ///
  /// Buffered events are flushed when the [toggleSwitch] becomes `false`.
  EventStream<T> pauseWhen(Watchable<bool> toggleSwitch) {
    return _asEventStream(new _PauseWhenStream(this, toggleSwitch));
  }

  /// Returns a [Property] where the first value is the [initalValue] and values after
  /// that are the result of [combine].
  ///
  /// [combine] is an accumulator function where its first argument is either the initial
  /// value or the result of the last combine, and the second argument is the next value
  /// in this stream.
  Property<T> scan(T initialValue, T combine(T value, T element)) {
    return new EventStream<T>(new _ScanStream(this, initialValue, combine))
        .asPropertyWithInitialValue(initialValue);
  }

  /// Returns a new stream that will begin forwarding events from this stream when the
  /// [future] completes.
  EventStream<T> skipUntil(Future future) {
    return _asEventStream(new _SkipUntilStream(this, future));
  }

  /// Returns a new stream that contains events from this stream until the [future]
  /// completes.
  EventStream<T> takeUntil(Future future) {
    return _asEventStream(new _TakeUntilStream(this, future));
  }

  /// Returns a new stream that upon forwarding an event from this stream, will ignore
  /// any subsequent events until [duration], after which the last event will be
  /// forwarded.
  ///
  /// The returned stream will not throttle errors.
  EventStream<T> throttle(Duration duration) {
    return _asEventStream(new _ThrottleStream(this, duration));
  }

  /// Returns a new stream that forwards events when the last value for [toggle] is
  /// `true`.
  ///
  /// Errors will always be forwarded regardless of the value of [toggle].
  EventStream<T> when(Watchable<bool> toggle) {
    return _asEventStream(new _WhenStream(this, toggle));
  }

  /// Returns a [Property] where the first value will be the next value from this stream.
  Property<T> asProperty() {
    return new _StreamProperty(this);
  }

  /// Returns a [Property] where the first value will be the [initialValue], and values
  /// after that will be the values from this stream.
  Property<T> asPropertyWithInitialValue(T initialValue) {
    return new _StreamProperty.initialValue(this, initialValue);
  }

  /// Returns a wrapped broadcast or single-subscription version of [stream] based on
  /// [isBroadcast].
  ///
  /// All methods defined on this class that return an [EventStream] should use this
  /// method when returning their stream. It guarentees that the returned stream will be
  /// the same type of stream as this stream (either broadcast or single-subscription).
  EventStream _asEventStream(Stream stream) {
    return new EventStream(isBroadcast ? stream.asBroadcastStream() : stream);
  }

  //
  // Wrappers for Dart Stream methods
  //
  EventStream<T> asBroadcastStream({void onListen(StreamSubscription subscription),
                                    void onCancel(StreamSubscription subscription)}) {
    return new EventStream(super.asBroadcastStream(onListen: onListen, onCancel: onCancel));
  }

  EventStream asyncExpand(Stream convert(T event)) {
    return new EventStream(super.asyncExpand(convert));
  }

  EventStream asyncMap(convert(T event)) {
    return new EventStream(super.asyncMap(convert));
  }

  EventStream<T> distinct([bool equals(T previous, T next)]) {
    return new EventStream(super.distinct(equals));
  }

  EventStream expand(Iterable convert(T value)) {
    return new EventStream(super.expand(convert));
  }

  EventStream<T> handleError(Function onError, {bool test(error)}) {
    return new EventStream(super.handleError(onError, test: test));
  }

  EventStream map(convert(T event)) {
    return new EventStream(super.map(convert));
  }

  EventStream<T> skip(int count) {
    return new EventStream(super.skip(count));
  }

  EventStream<T> skipWhile(bool test(T element)) {
    return new EventStream(super.skipWhile(test));
  }

  EventStream<T> take(int count) {
    return new EventStream(super.take(count));
  }

  EventStream<T> takeWhile(bool test(T element)) {
    return new EventStream(super.takeWhile(test));
  }

  EventStream timeout(Duration timeLimit, {void onTimeout(EventSink sink)}) {
    return new EventStream(super.timeout(timeLimit, onTimeout: onTimeout));
  }

  EventStream transform(StreamTransformer<T, dynamic> streamTransformer) {
    return new EventStream(super.transform(streamTransformer));
  }

  EventStream<T> where(bool test(T event)) {
    return new EventStream(super.where(test));
  }
}
