part of frappe;

/// A [Reactable] is a type that unifies the API between [EventStream]s and [Property]s.
abstract class Reactable<T> {
  /// Returns a [Property] where the current value is an iterable that contains the
  /// latest values from a collection of [reactables].
  ///
  /// The supplied [reactables] can be a mixture of [Property]s and [EventStream]s,
  /// where any [Property]s will first be converted to a stream.
  ///
  /// The returned [Property] will only have a value once all the [reactables] contain
  /// a value.
  static Property<Iterable> collect(Iterable<Reactable> reactables) {
    var values = () => Future.wait(reactables.map((reactable) => reactable.first));
    var changes = reactables.skip(1).fold(reactables.first.asStream(), (value, element) {
      return value.asStream().merge(element.asStream());
    });
    return changes.flatMapLatest((value) => new Stream.fromFuture(values())).asProperty();
  }

  /// Returns the first element of the reactable.
  ///
  /// Stops listening to the reactable after the first element has been
  /// received.
  ///
  /// If an error event occurs before the first data event, the resulting future
  /// is completed with that error.
  ///
  /// If this stream is empty (a done event occurs before the first data event),
  /// the resulting future completes with a [StateError].
  ///
  /// Except for the type of the error, this method is equivalent to
  /// `this.elementAt(0)`.
  Future<T> get first => new _ReactableAsStream(this).first;

  /// Returns the last element of the reactable.
  ///
  /// If an error event occurs before the first data event, the resulting future
  /// is completed with that error.
  ///
  /// If the reactable is empty (a done event occurs before the first data event),
  /// the resulting future completes with a [StateError].
  Future<T> get last => new _ReactableAsStream(this).last;

  /// Reports whether this reactable contains any elements.
  ///
  /// Stops listening to the reactable after the first element has been received.
  ///
  /// Internally the method cancels its subscription after the first element. This
  /// means that non-broadcast streams are closed and cannot be reused after a call
  /// to this getter.
  Future<bool> get isEmpty => new _ReactableAsStream(this).isEmpty;

  /// Checks whether [test] accepts any element provided by this reactable.
  ///
  /// Completes the [Future] when the answer is known.
  ///
  /// If this stream reports an error, the [Future] reports that error.
  ///
  /// Stops listening to the reactable after the first matching element has been
  /// found.
  ///
  /// Internally the method cancels its subscription after this element. This means
  /// that non-broadcast streams are closed and cannot be reused after a call to this
  /// method.
  Future<bool> any(bool test(T element)) => new _ReactableAsStream(this).any(test);

  /// Returns this reactable as a [Property].
  ///
  /// If this reactable is already a property, this this returns itself.
  Property<T> asProperty() => new Property.fromStream(asStream());

  /// Returns this reactable as a [Property] with an initial value.
  ///
  /// If this reactable is already a [Property], then this method returns a new [Property]
  /// where its current value is set to [initialValue].
  Property<T> asPropertyWithInitialValue(T initialValue) =>
      new Property.fromStreamWithInitialValue(initialValue, asStream());

  /// Returns this reactable as an [EventStream].
  EventStream<T> asStream() => new EventStream(new _ReactableAsStream(this));

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
  EventStream asyncExpand(Stream convert(T event)) => new EventStream(
      new _ReactableAsStream(this).asyncExpand(convert));

  EventStream asyncMap(dynamic convert(T event)) => new EventStream(new _ReactableAsStream(this).asyncMap(convert));

  Future<bool> contains(Object needle) => new _ReactableAsStream(this).contains(needle);

  /// Returns a new stream that upon forwarding an event from this stream, will ignore
  /// any subsequent events until [duration], after which the last event will be
  /// forwarded.
  ///
  /// The returned stream will not throttle errors.
  Reactable<T> debounce(Duration duration) => asStream().transform(new Debounce<T>(duration));

  /// Delays the delivery of each non-error event from this stream by the given [duration].
  Reactable<T> delay(Duration duration) => asStream().transform(new Delay<T>(duration));

  Reactable<T> distinct([bool equals(T previous, T next)]) => new EventStream(
      new _ReactableAsStream(this).distinct(equals));

  Future drain([futureValue]) => new _ReactableAsStream(this).drain(futureValue);

  Future<bool> every(bool test(T element)) => new _ReactableAsStream(this).every(test);

  Reactable expand(Iterable convert(T value)) => new EventStream(new _ReactableAsStream(this).expand(convert));

  Future<dynamic> firstWhere(bool test(T element), {Object defaultValue()}) =>
      new _ReactableAsStream(this).firstWhere(test, defaultValue: defaultValue);

  Future fold(initialValue, combine(previous, T element)) => new _ReactableAsStream(this).fold(initialValue, combine);

  Future forEach(void action(T element)) => new _ReactableAsStream(this).forEach(action);

  /// Returns a property that indicates if this reactable is waiting for an event [other].
  ///
  /// The initial value for the returned property is `true`, and returns `false` once
  /// [other] delivers an event.
  ///
  /// This method is useful for displaying spinners while waiting for AJAX responses.
  Property<bool> isWaitingOn(Reactable other) {
    return new Property
        .constant(true).asStream()
        .merge(new Property.fromFuture(other.first.then((_) => false)).asStream())
        .asProperty();
  }

  Reactable<T> handleError(onError, {bool test(error)}) => new EventStream(
      new _ReactableAsStream(this).handleError(onError, test: test));

  Future<dynamic> lastWhere(bool test(T element), {Object defaultValue()}) =>
      new _ReactableAsStream(this).lastWhere(test, defaultValue: defaultValue);

  /// Adds a subscription to this observable with the same behavior as Dart's
  /// [Stream.listen] method.
  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError});

  Reactable map(convert(T event)) => new EventStream(new _ReactableAsStream(this).map(convert));

  Future<T> reduce(T combine(T previous, T element)) => new _ReactableAsStream(this).reduce(combine);

  /// Returns a [Property] where the first value is the [initialValue] and values after
  /// that are the result of [combine].
  ///
  /// [combine] is an accumulator function where its first argument is either the initial
  /// value or the result of the last combine, and the second argument is the next value
  /// in this stream.
  Property<T> scan(T initialValue, T combine(T value, T element)) {
    return new _ScanReactable(this, initialValue, combine).asPropertyWithInitialValue(initialValue);
  }

  /// Returns an [EventStream] that contains events from each stream that is spawned from
  /// [convert].
  EventStream flatMap(Stream convert(T event)) {
    return asStream().transform(new FlatMap(convert));
  }

  /// Returns an [EventStream] that only includes events from the last spawned stream.
  EventStream flatMapLatest(Stream convert(T event)) => asStream().transform(new FlatMapLatest(convert));

  /// Returns a new stream that contains events from this stream until the [future]
  /// completes.
  Reactable<T> takeUntil(Future future) => new _TakeUntilReactable(this, future);

  Reactable<T> takeWhile(bool test(T element)) => new EventStream(new _ReactableAsStream(this).takeWhile(test));

  /// Returns a new reactable that forwards events when the last value for [toggle] is
  /// `true`.
  ///
  /// Errors will always be forwarded regardless of the value of [toggle].
  Reactable<T> when(Reactable<bool> toggle) => new _WhenReactable(this, toggle);

  Reactable<T> where(bool test(T event)) => new EventStream(new _ReactableAsStream(this).where(test));
}