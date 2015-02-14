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
    var input = stream.asBroadcastStream(onCancel: (subscription) => subscription.cancel());
    _hasCurrentValue = hasInitialValue;
    _currentValue = initialValue;

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

    _controller = new StreamController.broadcast(onListen: onListen, onCancel: onCancel);
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

  StreamSubscription<T> listen(void onData(T value), {Function onError, void onDone(), bool cancelOnError}) {
    var controller = new StreamController();

    if (_hasCurrentValue) {
      controller.add(_currentValue);
    }

    controller.addStream(_controller.stream).then((_) => controller.close());

    return controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Property _wrap(Stream stream) => new Property.fromStream(stream);

  @override
  Property<T> asProperty() => this;

  @override
  Property<T> asPropertyWithInitialValue(T initialValue) {
    return new Property.fromStreamWithInitialValue(initialValue, changes);
  }

  @override
  /// Returns a stream that contains events for the current value of this `Property`,
  /// as well as any of its changes.
  EventStream<T> asStream() => new EventStream(this);

  /// Combines this property and [other] with the `&&` operator.
  Property<bool> and(Property<bool> other) => combine(other, (a, b) => a && b);

  /// Combines this property and [other] with the `||` operator.
  Property<bool> or(Property<bool> other) => combine(other, (a, b) => a || b);

  /// Combines this property and [other] with the `==` operator.
  Property<bool> equals(Property other) => combine(other, (a, b) => a == b);

  Property<bool> not() => map((value) => !value).asProperty();

  /// Combines this property and [other] with the `>` operator.
  Property<bool> operator >(Property other) => combine(other, (a, b) => a > b);

  /// Combines this property and [other] with the `>=` operator.
  Property<bool> operator >=(Property other) => combine(other, (a, b) => a >= b);

  /// Combines this property and [other] with the `<` operator.
  Property<bool> operator <(Property other) => combine(other, (a, b) => a < b);

  /// Combines this property and [other] with the `<=` operator.
  Property<bool> operator <=(Property other) => combine(other, (a, b) => a <= b);

  /// Combines this property and [other] with the `+` operator.
  Property operator +(Property other) => combine(other, (a, b) => a + b);

  /// Combines this property and [other] with the `-` operator.
  Property operator -(Property other) => combine(other, (a, b) => a - b);

  /// Combines this property and [other] with the `*` operator.
  Property operator *(Property other) => combine(other, (a, b) => a * b);

  /// Combines this property and [other] with the `/` operator.
  Property operator /(Property other) => combine(other, (a, b) => a / b);
}
