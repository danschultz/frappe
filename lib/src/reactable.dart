part of frappe;

/// A [Reactable] is a type that unifies the API between [EventStream]s and [Property]s.
abstract class Reactable<T> extends Stream<T> {
  /// Returns a [Property] where the current value is an iterable that contains the
  /// latest values from a collection of [reactables].
  ///
  /// The supplied [reactables] can be a mixture of [Property]s and [EventStream]s,
  /// where any [Property]s will first be converted to a stream.
  ///
  /// The returned [Property] will only have a value once all the [reactables] contain
  /// a value.
  static Property<Iterable> collect(Iterable<Reactable> reactables) {
    return new Property.fromStream(Combine.all(reactables.toList()));
  }

  Reactable<T> asBroadcastStream({void onListen(StreamSubscription<T> subscription),
                                 void onCancel(StreamSubscription<T> subscription)}) {
    return _wrap(super.asBroadcastStream(onListen: onListen, onCancel: onCancel));
  }

  /// Returns this reactable as a [Property].
  ///
  /// If this reactable is already a property, this this returns itself.
  Property<T> asProperty() => new Property.fromStream(this);

  /// Returns this reactable as a [Property] with an initial value.
  ///
  /// If this reactable is already a [Property], then this method returns a new [Property]
  /// where its current value is set to [initialValue].
  Property<T> asPropertyWithInitialValue(T initialValue) =>
      new Property.fromStreamWithInitialValue(initialValue, this);

  /// Returns this reactable as an [EventStream].
  @deprecated("Expected to be removed in v0.5. Use asEventStream() instead.")
  EventStream<T> asStream() => asEventStream();

  /// Returns this reactable as an [EventStream].
  EventStream<T> asEventStream() => new EventStream(this);

  /// Returns a stream with the events of a stream per original event.
  ///
  /// This acts like [expand], except that [convert] returns a [Stream] instead of an
  /// [Iterable]. The events of the returned stream becomes the events of the
  /// returned stream, in the order they are produced.
  ///
  /// If [convert] returns `null`, no value is put on the output stream, just as if
  /// it returned an empty stream.
  ///
  /// The returned stream is a broadcast stream if this stream is.
  Reactable asyncExpand(Stream convert(T event)) => _wrap(super.asyncExpand(convert));

  Reactable asyncMap(dynamic convert(T event)) => _wrap((super.asyncMap(convert)));

  /// Returns a new stream that buffers events when the last event in [toggle] is `true`.
  ///
  /// Buffered events are delivered when [toggle] becomes `false`.
  Reactable<T> bufferWhen(Stream<bool> toggle) => transform(new BufferWhen(toggle));

  Reactable combine(Stream other, Object combiner(T a, b)) => transform(new Combine(other, combiner));

  Reactable concat(Stream other) => transform(new Concat(other));

  Reactable concatAll() => transform(new ConcatAll());

  /// Returns a new stream that upon forwarding an event from this stream, will ignore
  /// any subsequent events until [duration], after which the last event will be
  /// forwarded.
  ///
  /// The returned stream will not throttle errors.
  Reactable<T> debounce(Duration duration) => transform(new Debounce<T>(duration));

  /// Delays the delivery of each non-error event from this stream by the given [duration].
  Reactable<T> delay(Duration duration) => transform(new Delay<T>(duration));

  Reactable<T> distinct([bool equals(T previous, T next)]) => _wrap(super.distinct(equals));

  Reactable<T> doAction(void onData(T value), {Function onError, void onDone()}) =>
      transform(new DoAction(onData, onError: onError, onDone: onDone));

  Reactable expand(Iterable convert(T value)) => _wrap(super.expand(convert));

  /// Returns an [EventStream] that contains events from each stream that is spawned from
  /// [convert].
  Reactable flatMap(Stream convert(T event)) => transform(new FlatMap(convert));

  /// Returns an [EventStream] that only includes events from the last spawned stream.
  Reactable flatMapLatest(Stream convert(T event)) => transform(new FlatMapLatest(convert));

  /// Returns a property that indicates if this reactable is waiting for an event [other].
  ///
  /// The initial value for the returned property is `true`, and returns `false` once
  /// [other] delivers an event.
  ///
  /// This method is useful for displaying spinners while waiting for AJAX responses.
  Property<bool> isWaitingOn(Reactable other) {
    return new Property.constant(true).merge(new Property.fromFuture(other.first.then((_) => false)));
  }

  Reactable<T> handleError(onError, {bool test(error)}) => _wrap(super.handleError(onError, test: test));

  Reactable map(convert(T event)) => _wrap(super.map(convert));

  /// Returns a new stream that contains events from this stream and the [other] stream.
  Reactable merge(Stream other) => transform(new Merge(other));

  Reactable mergeAll() => transform(new MergeAll());

  /// Returns a [Property] where the first value is the [initialValue] and values after
  /// that are the result of [combine].
  ///
  /// [combine] is an accumulator function where its first argument is either the initial
  /// value or the result of the last combine, and the second argument is the next value
  /// in this stream.
  Reactable<T> scan(T initialValue, T combine(T value, T element)) => transform(new Scan(initialValue, combine));

  Reactable<T> skip(int count) => _wrap(super.skip(count));

  Reactable<T> skipWhile(bool test(T element)) => _wrap(super.skipWhile(test));

  /// Returns a new stream that will begin forwarding events from this stream when the
  /// [signal] completes.
  Reactable<T> skipUntil(Stream signal) => transform(new SkipUntil(signal));

  Reactable<T> take(int count) => _wrap(super.take(count));

  /// Returns a new stream that contains events from this stream until the [signal]
  /// completes.
  Reactable<T> takeUntil(Stream signal) => transform(new TakeUntil(signal));

  Reactable<T> takeWhile(bool test(T element)) => _wrap(super.takeWhile(test));

  Reactable timeout(Duration timeLimit, {void onTimeout(EventSink sink)}) =>
      _wrap(super.timeout(timeLimit, onTimeout: onTimeout));

  Reactable transform(StreamTransformer<T, dynamic> streamTransformer) => _wrap(super.transform(streamTransformer));

  /// Returns a new reactable that forwards events when the last value for [toggle] is
  /// `true`.
  ///
  /// Errors will always be forwarded regardless of the value of [toggle].
  Reactable<T> when(Stream<bool> toggle) => transform(new When(toggle));

  Reactable<T> where(bool test(T event)) => _wrap(super.where(test));

  /// Returns a new reactable that merges this stream with [other] by combining their
  /// values in a pair-wire fashion.
  ///
  /// A zipped stream will only start producing values when there's a value from each
  /// stream. The returned stream will stop producing values when either stream ends.
  Reactable zip(Stream other, Combiner combiner) => transform(new Zip(other, combiner));

  Reactable _wrap(Stream stream);
}