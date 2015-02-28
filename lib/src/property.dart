part of frappe;

/// A property is an observable with the concept of a current value.
///
/// Calling [listen] on a property will deliver its current value, if one exists.
/// This means that if the property has previously emitted the value of *x* to
/// its subscribers, it will deliver this value to any new subscribers. Depending
/// on how the property was created, some properties might not have an initial
/// value to start with.
class Property<T> extends Reactable<T> {
  StreamController _controller;
  bool _hasCurrentValue = false;
  T _currentValue;

  /// An [EventStream] that contains the changes of the property.
  ///
  /// The stream will *not* contain an event for the current value of the `Property`.
  EventStream<T> get changes => new EventStream(_controller.stream);

  bool get isBroadcast => _controller.stream.isBroadcast;

  Property._(Stream<T> stream, bool hasInitialValue, [T initialValue]) {
    _hasCurrentValue = hasInitialValue;
    _currentValue = initialValue;
    _controller = _createControllerForStream(stream);
  }

  /// Returns a new property where its current value is always [value].
  factory Property.constant(T value) => new Property.fromStream(new Stream.fromIterable([value]));

  /// Returns a new property where its current value is the latest value emitted
  /// from [stream].
  factory Property.fromStream(Stream<T> stream) => new Property._(stream, false);

  /// Returns a new property where its starting value is [initialValue], and its
  /// value after that is the latest value emitted from [stream].
  factory Property.fromStreamWithInitialValue(T initialValue, Stream<T> stream) =>
      new Property._(stream, true, initialValue);

  /// Returns a new property where its current value is the completed value of
  /// the [future].
  factory Property.fromFuture(Future<T> future) => new Property.fromStream(new Stream.fromFuture(future));

  /// Returns a new property where the starting value is [initialValue], and its
  /// value after that is the value from [future].
  factory Property.fromFutureWithInitialValue(T initialValue, Future<T> future) =>
      new Property.fromStreamWithInitialValue(initialValue, new Stream.fromFuture(future));

  StreamController _createControllerForStream(Stream stream) {
    var input = stream.asBroadcastStream(onCancel: (subscription) => subscription.cancel());

    StreamSubscription subscription;

    void onListen() {
      if (subscription == null) {
        subscription = input.listen(
            (value) {
              _currentValue = value;
              _hasCurrentValue = true;
              _controller.add(value);
            },
            onError: _controller.addError,
            onDone: () {
              _controller.close();
            });
      }
    }

    void onCancel() {
      subscription.cancel();
      subscription = null;
    }

    return new StreamController.broadcast(onListen: onListen, onCancel: onCancel, sync: true);
  }

  /// Combines this property and [other] with the `&&` operator.
  Property<bool> and(Stream<bool> other) => combine(other, (a, b) => a && b);

  /// Combines this property and [other] with the `||` operator.
  Property<bool> or(Stream<bool> other) => combine(other, (a, b) => a || b);

  // Overrides

  Property<T> asBroadcastStream({void onListen(StreamSubscription<T> subscription),
                                 void onCancel(StreamSubscription<T> subscription)}) {
    return new Property.fromStream(super.asBroadcastStream(onListen: onListen, onCancel: onCancel));
  }

  EventStream<T> asEventStream() => new EventStream(this);

  Property<T> asProperty() => this;

  Property<T> asPropertyWithInitialValue(T initialValue) =>
      new Property.fromStreamWithInitialValue(initialValue, changes);

  Property asyncExpand(Stream convert(T event)) => new Property.fromStream(super.asyncExpand(convert));

  Property asyncMap(dynamic convert(T event)) => new Property.fromStream((super.asyncMap(convert)));

  Property<T> bufferWhen(Stream<bool> toggle) => transform(new BufferWhen(toggle));

  Property combine(Stream other, Object combiner(T a, b)) => transform(new Combine(other, combiner));

  Property concat(Stream other) => transform(new Concat(other));

  Property concatAll() => transform(new ConcatAll());

  Property<T> debounce(Duration duration) => transform(new Debounce<T>(duration));

  Property<T> delay(Duration duration) => transform(new Delay<T>(duration));

  Property<T> distinct([bool equals(T previous, T next)]) => new Property.fromStream(super.distinct(equals));

  Property<T> doAction(void onData(T value), {Function onError, void onDone()}) =>
      transform(new DoAction(onData, onError: onError, onDone: onDone));

  Property expand(Iterable convert(T value)) => new Property.fromStream(super.expand(convert));

  Property flatMap(Stream convert(T event)) => transform(new FlatMap(convert));

  Property flatMapLatest(Stream convert(T event)) => transform(new FlatMapLatest(convert));

  Property<T> handleError(onError, {bool test(error)}) =>
      new Property.fromStream(super.handleError(onError, test: test));

  StreamSubscription<T> listen(void onData(T value), {Function onError, void onDone(), bool cancelOnError}) {
    var controller = new StreamController(sync: true);

    if (_hasCurrentValue) {
      controller.add(_currentValue);
    }

    controller.addStream(_controller.stream, cancelOnError: false).then((_) => controller.close());

    return controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Property map(convert(T event)) => new Property.fromStream(super.map(convert));

  Property merge(Stream other) => transform(new Merge(other));

  Property mergeAll() => transform(new MergeAll());

  Property<T> sampleOn(Stream trigger) => transform(new SampleOn(trigger));

  Property<T> samplePeriodically(Duration duration) => transform(new SamplePeriodically(duration));

  Property scan(initialValue, combine(value, T element)) => transform(new Scan(initialValue, combine));

  Property selectFirst(Stream other) => transform(new SelectFirst(other));

  Property<T> skip(int count) => new Property.fromStream(super.skip(count));

  Property<T> skipWhile(bool test(T element)) => new Property.fromStream(super.skipWhile(test));

  Property<T> skipUntil(Stream signal) => transform(new SkipUntil(signal));

  Property startWith(value) => transform(new StartWith(value));

  Property startWithValues(Iterable values) => transform(new StartWith.many(values));

  Property<T> take(int count) => new Property.fromStream(super.take(count));

  Property<T> takeUntil(Stream signal) => transform(new TakeUntil(signal));

  Property<T> takeWhile(bool test(T element)) => new Property.fromStream(super.takeWhile(test));

  Property timeout(Duration timeLimit, {void onTimeout(EventSink sink)}) =>
      new Property.fromStream(super.timeout(timeLimit, onTimeout: onTimeout));

  Property transform(StreamTransformer<T, dynamic> streamTransformer) =>
      new Property.fromStream(super.transform(streamTransformer));

  Property<T> when(Stream<bool> toggle) => transform(new When(toggle));

  Property<T> where(bool test(T event)) => new Property.fromStream(super.where(test));

  Property zip(Stream other, Combiner combiner) => transform(new Zip(other, combiner));

  // Deprecated

  /// Combines this property and [other] with the `==` operator.
  @deprecated("Expected to be removed in v0.5. Use combine() instead.")
  Property<bool> equals(Property other) => combine(other, (a, b) => a == b);

  /// Combines this property and [other] with the `>` operator.
  @deprecated("Expected to be removed in v0.5. Use combine() instead.")
  Property<bool> operator >(Property other) => combine(other, (a, b) => a > b);

  /// Combines this property and [other] with the `>=` operator.
  @deprecated("Expected to be removed in v0.5. Use combine() instead.")
  Property<bool> operator >=(Property other) => combine(other, (a, b) => a >= b);

  /// Combines this property and [other] with the `<` operator.
  @deprecated("Expected to be removed in v0.5. Use combine() instead.")
  Property<bool> operator <(Property other) => combine(other, (a, b) => a < b);

  /// Combines this property and [other] with the `<=` operator.
  @deprecated("Expected to be removed in v0.5. Use combine() instead.")
  Property<bool> operator <=(Property other) => combine(other, (a, b) => a <= b);

  /// Combines this property and [other] with the `+` operator.
  @deprecated("Expected to be removed in v0.5. Use combine() instead.")
  Property operator +(Property other) => combine(other, (a, b) => a + b);

  /// Combines this property and [other] with the `-` operator.
  @deprecated("Expected to be removed in v0.5. Use combine() instead.")
  Property operator -(Property other) => combine(other, (a, b) => a - b);

  /// Combines this property and [other] with the `*` operator.
  @deprecated("Expected to be removed in v0.5. Use combine() instead.")
  Property operator *(Property other) => combine(other, (a, b) => a * b);

  /// Combines this property and [other] with the `/` operator.
  @deprecated("Expected to be removed in v0.5. Use combine() instead.")
  Property operator /(Property other) => combine(other, (a, b) => a / b);
}
