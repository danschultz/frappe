part of frappe;

/// A property is an observable with the concept of a current value.
///
/// Calling [listen] on a property will deliver its current value, if one exists.
/// This means that if the property has previously emitted the value of *x* to
/// its subscribers, it will deliver this value to any new subscribers. Depending
/// on how the property was created, some properties might not have an initial
/// value to start with.
// Extend dynamic to suppress warnings with operator overrides
abstract class Property<T extends dynamic> implements Reactable<T> {
  /// An [EventStream] that contains the current values of the property.
  EventStream<T> get changes;

  Property._();

  /// Returns a new property where its current value is always [value].
  factory Property.constant(T value) => new _ConstantProperty(value);

  /// Returns a new property where its current value is the latest value emitted
  /// from [stream].
  factory Property.fromStream(Stream<T> stream) => new _StreamProperty(stream);

  /// Returns a new property where its starting value is [initialValue], and its
  /// value after that is the latest value emitted from [stream].
  factory Property.fromStreamWithInitialValue(T initialValue, Stream<T> stream) =>
      new _StreamProperty.initialValue(stream, initialValue);

  /// Returns a new property where its current value is the completed value of
  /// the [future].
  factory Property.fromFuture(Future<T> future) =>
      new Property.fromStream(new Stream.fromFuture(future));

  /// Combines this property and [other] with the `&&` operator.
  Property<bool> and(Property<bool> other) {
    return new _CombinedProperty(this, other, (a, b) => a && b);
  }

  /// Combines this property and [other] with the `||` operator.
  Property<bool> or(Property<bool> other) {
    return new _CombinedProperty(this, other, (a, b) => a || b);
  }

  /// Combines this property and [other] with the `==` operator.
  Property<bool> equals(Property other) {
    return new _CombinedProperty(this, other, (a, b) => a == b);
  }

  /// Combines this property and [other] with the `>` operator.
  Property<bool> operator >(Property other) {
    return new _CombinedProperty(this, other, (a, b) => a > b);
  }

  /// Combines this property and [other] with the `>=` operator.
  Property<bool> operator >=(Property other) {
    return new _CombinedProperty(this, other, (a, b) => a >= b);
  }

  /// Combines this property and [other] with the `<` operator.
  Property<bool> operator <(Property other) {
    return new _CombinedProperty(this, other, (a, b) => a < b);
  }

  /// Combines this property and [other] with the `<=` operator.
  Property<bool> operator <=(Property other) {
    return new _CombinedProperty(this, other, (a, b) => a <= b);
  }

  /// Combines this property and [other] with the `+` operator.
  Property operator +(Property other) {
    return new _CombinedProperty(this, other, (a, b) => a + b);
  }

  /// Combines this property and [other] with the `-` operator.
  Property operator -(Property other) {
    return new _CombinedProperty(this, other, (a, b) => a - b);
  }

  /// Combines this property and [other] with the `*` operator.
  Property operator *(Property other) {
    return new _CombinedProperty(this, other, (a, b) => a * b);
  }

  /// Combines this property and [other] with the `/` operator.
  Property operator /(Property other) {
    return new _CombinedProperty(this, other, (a, b) => a / b);
  }

  /// Creates a new property that converts the each value of this property
  /// using the [convert] function.
  Property map(convert(T value)) {
    return new _ComputedProperty(this, convert);
  }
}
