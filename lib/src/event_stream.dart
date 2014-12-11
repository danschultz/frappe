part of frappe;

/// An [EventStream] is wrapper around a standard Dart [Stream], but provides utility
/// methods for creating other streams or properties.
class EventStream<T> extends StreamView<T> with Reactable<T> {
  /// Returns a new [EventStream] that wraps a standard Dart [Stream].
  EventStream(Stream<T> stream) : super(stream);

  /// Returns a new stream that contains events from this stream and the [other] stream.
  EventStream merge(Stream other) {
    return _asEventStream(new _MergedStream([this, other]));
  }

  /// Returns a new stream that buffers events when the last event in [toggle] is `true`.
  ///
  /// Buffered events are delivered when [toggle] becomes `false`.
  EventStream<T> bufferWhen(Reactable<bool> toggle) {
    return _asEventStream(new _BufferWhenReactable(this, toggle).asStream());
  }

  /// Returns a new stream that will begin forwarding events from this stream when the
  /// [future] completes.
  EventStream<T> skipUntil(Future future) => _asEventStream(new _SkipUntilReactable(this, future).asStream());

  EventStream<T> asStream() {
    return this;
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
  /// method when returning their stream. It guarantees that the returned stream will be
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
    return new EventStream(new _ReactableAsStream(super.distinct(equals)));
  }

  EventStream expand(Iterable convert(T value)) {
    return new EventStream(new _ReactableAsStream(super.expand(convert)));
  }

  EventStream<T> handleError(Function onError, {bool test(error)}) {
    return new EventStream(new _ReactableAsStream(super.handleError(onError, test: test)));
  }

  EventStream map(convert(T event)) {
    return new EventStream(new _ReactableAsStream(super.map(convert)));
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
    return new EventStream(new _ReactableAsStream(super.takeWhile(test)));
  }

  EventStream timeout(Duration timeLimit, {void onTimeout(EventSink sink)}) {
    return new EventStream(super.timeout(timeLimit, onTimeout: onTimeout));
  }

  EventStream transform(StreamTransformer<T, dynamic> streamTransformer) {
    return new EventStream(super.transform(streamTransformer));
  }

  EventStream<T> where(bool test(T event)) {
    return new EventStream(new _ReactableAsStream(super.where(test)));
  }
}
