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
                                 void onCancel(StreamSubscription<T> subscription)});

  /// Returns this reactable as a [Property].
  ///
  /// If this reactable is already a property, this this returns itself.
  Property<T> asProperty();

  /// Returns this reactable as a [Property] with an initial value.
  ///
  /// If this reactable is already a [Property], then this method returns a new [Property]
  /// where its current value is set to [initialValue].
  Property<T> asPropertyWithInitialValue(T initialValue);

  /// Returns this reactable as an [EventStream].
  @deprecated("Expected to be removed in v0.5. Use asEventStream() instead.")
  EventStream<T> asStream() => asEventStream();

  /// Returns this reactable as an [EventStream].
  EventStream<T> asEventStream();

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
  Reactable asyncExpand(Stream convert(T event));

  Reactable asyncMap(dynamic convert(T event));

  /// Returns a new stream that buffers events when the last event in [toggle] is `true`.
  ///
  /// Buffered events are delivered when [toggle] becomes `false`.
  Reactable<T> bufferWhen(Stream<bool> toggle);

  Reactable combine(Stream other, Object combiner(T a, b));

  Reactable concat(Stream other);

  Reactable concatAll();

  /// Returns a new stream that upon forwarding an event from this stream, will ignore
  /// any subsequent events until [duration], after which the last event will be
  /// forwarded.
  ///
  /// The returned stream will not throttle errors.
  Reactable<T> debounce(Duration duration);

  /// Delays the delivery of each non-error event from this stream by the given [duration].
  Reactable<T> delay(Duration duration);

  Reactable<T> distinct([bool equals(T previous, T next)]);

  Reactable<T> doAction(void onData(T value), {Function onError, void onDone()});

  Reactable expand(Iterable convert(T value));

  /// Returns an [EventStream] that contains events from each stream that is spawned from
  /// [convert].
  Reactable flatMap(Stream convert(T event));

  /// Returns an [EventStream] that only includes events from the last spawned stream.
  Reactable flatMapLatest(Stream convert(T event));

  /// Returns a property that indicates if this reactable is waiting for an event from
  /// [other].
  ///
  /// This method is useful for displaying spinners while waiting for AJAX responses.
  Property<bool> isWaitingOn(Stream other) {
    return new Property.fromStreamWithInitialValue(
        false,
        flatMapLatest((_) => new EventStream.single(true).merge(other.take(1).map((_) => false))))
      .distinct();
  }

  Reactable<T> handleError(onError, {bool test(error)});

  Reactable map(convert(T event));

  /// Returns a new stream that contains events from this stream and the [other] stream.
  Reactable merge(Stream other);

  Reactable mergeAll();

  Reactable<bool> not() => map((value) => !value);

  Reactable<T> sampleOn(Stream trigger);

  Reactable<T> samplePeriodically(Duration duration);

  /// Returns a [Property] where the first value is the [initialValue] and values after
  /// that are the result of [combine].
  ///
  /// [combine] is an accumulator function where its first argument is either the initial
  /// value or the result of the last combine, and the second argument is the next value
  /// in this stream.
  Reactable scan(initialValue, combine(value, T element));

  Reactable selectFirst(Stream other);

  Reactable<T> skip(int count);

  Reactable<T> skipWhile(bool test(T element));

  /// Returns a new stream that will begin forwarding events from this stream when the
  /// [signal] completes.
  Reactable<T> skipUntil(Stream signal);

  Reactable startWith(value);

  Reactable startWithValues(Iterable values);

  Reactable<T> take(int count);

  /// Returns a new stream that contains events from this stream until the [signal]
  /// completes.
  Reactable<T> takeUntil(Stream signal);

  Reactable<T> takeWhile(bool test(T element));

  Reactable timeout(Duration timeLimit, {void onTimeout(EventSink sink)});

  Reactable transform(StreamTransformer<T, dynamic> streamTransformer);

  /// Returns a new reactable that forwards events when the last value for [toggle] is
  /// `true`.
  ///
  /// Errors will always be forwarded regardless of the value of [toggle].
  Reactable<T> when(Stream<bool> toggle);

  Reactable<T> where(bool test(T event));

  /// Returns a new reactable that merges this stream with [other] by combining their
  /// values in a pair-wire fashion.
  ///
  /// A zipped stream will only start producing values when there's a value from each
  /// stream. The returned stream will stop producing values when either stream ends.
  Reactable zip(Stream other, Combiner combiner);
}