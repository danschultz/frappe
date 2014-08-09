part of frappe;

/// An [Reactable] is a type that unifies the API between [EventStream]s
/// and [Property]s.
abstract class Reactable<T> {
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
  Future<T> get first => new _ReactableStream(this).first;

  /// Returns the last element of the reactable.
  ///
  /// If an error event occurs before the first data event, the resulting future
  /// is completed with that error.
  ///
  /// If the reactable is empty (a done event occurs before the first data event),
  /// the resulting future completes with a [StateError].
  Future<T> get last => new _ReactableStream(this).last;

  /// Counts the elements in the reactable.
  Future<int> get length => new _ReactableStream(this).length;

  /// Returns the single element.
  ///
  /// If an error event occurs before or after the first data event, the resulting
  /// future is completed with that error.
  ///
  /// If this is empty or has more than one element throws a [StateError].
  Future<T> get single => new _ReactableStream(this).single;

  /// Reports whether this reactable contains any elements.
  ///
  /// Stops listening to the reactable after the first element has been received.
  ///
  /// Internally the method cancels its subscription after the first element. This
  /// means that non-broadcast streams are closed and cannot be reused after a call
  /// to this getter.
  Future<bool> get isEmpty => new _ReactableStream(this).isEmpty;

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
  Future<bool> any(bool test(T element)) => new _ReactableStream(this).any(test);

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
  EventStream asyncExpand(Stream convert(T event)) => new _ReactableStream(this).asyncExpand(convert);

  /// Returns a new stream that includes events and errors from the last stream returned
  /// by [convert].
  ///
  /// This method can be thought of stream switching.
  EventStream asyncExpandLatest(Stream convert(T event)) => new _AsyncExpandLatestReactable(this, convert);

  EventStream asyncMap(dynamic convert(T event)) => new _ReactableStream(this).asyncMap(convert);

  Future<bool> contains(Object needle) => new _ReactableStream(this).contains(needle);

  /// Delays the delivery of each non-error event from this stream by the given [duration].
  Reactable<T> delay(Duration duration) => new _DelayReactable(this, duration);

  EventStream<T> distinct([bool equals(T previous, T next)]) => new _ReactableStream(this).distinct(equals);

  Future drain([futureValue]) => new _ReactableStream(this).drain(futureValue);

  Future<T> elementAt(int index) => new _ReactableStream(this).elementAt(index);

  Future<bool> every(bool test(T element)) => new _ReactableStream(this).every(test);

  Reactable expand(Iterable convert(T value)) => new _ReactableStream(this).expand(convert);

  Future<dynamic> firstWhere(bool test(T element), {Object defaultValue()}) =>
      new _ReactableStream(this).firstWhere(test, defaultValue: defaultValue);

  Future fold(initialValue, combine(previous, T element)) => new _ReactableStream(this).fold(initialValue, combine);

  Future forEach(void action(T element)) => new _ReactableStream(this).forEach(action);

  Reactable<T> handleError(onError, {bool test(error)}) => new _ReactableStream(this).handleError(onError, test: test);

  Future<String> join([String separator = ""]) => new _ReactableStream(this).join(separator);

  Future<dynamic> lastWhere(bool test(T element), {Object defaultValue()}) =>
      new _ReactableStream(this).lastWhere(test, defaultValue: defaultValue);

  /// Adds a subscription to this observable with the same behavior as Dart's
  /// [Stream.listen] method.
  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError});

  Reactable map(convert(T event)) => new _ReactableStream(this).map(convert);

  Future<T> reduce(T combine(T previous, T element)) => new _ReactableStream(this).reduce(combine);

  /// Returns a [Property] where the first value is the [initalValue] and values after
  /// that are the result of [combine].
  ///
  /// [combine] is an accumulator function where its first argument is either the initial
  /// value or the result of the last combine, and the second argument is the next value
  /// in this stream.
  Property<T> scan(T initialValue, T combine(T value, T element)) {
    return new EventStream<T>(new _ScanReactable(this, initialValue, combine))
        .asPropertyWithInitialValue(initialValue);
  }

  Future<T> singleWhere(bool test(T element)) => new _ReactableStream(this).singleWhere(test);

  Reactable<T> skip(int count) => new _ReactableStream(this).skip(count);

  Reactable<T> take(int count) => new _ReactableStream(this).take(count);

  /// Returns a new stream that contains events from this stream until the [future]
  /// completes.
  Reactable<T> takeUntil(Future future) => new _TakeUntilReactable(this, future);

  Reactable<T> takeWhile(bool test(T element)) => new _ReactableStream(this).takeWhile(test);

  Future<List<T>> toList() => new _ReactableStream(this).toList();

  Future<Set<T>> toSet() => new _ReactableStream(this).toSet();

  /// Returns a new stream that upon forwarding an event from this stream, will ignore
  /// any subsequent events until [duration], after which the last event will be
  /// forwarded.
  ///
  /// The returned stream will not throttle errors.
  Reactable<T> throttle(Duration duration) => new _ThrottleReactable(this, duration);

  Reactable<T> where(bool test(T event)) => new _ReactableStream(this).where(test);
}