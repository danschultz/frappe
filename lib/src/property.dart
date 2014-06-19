part of relay;

// Extend dynamic to suppress warnings with operator overrides
abstract class Property<T extends dynamic> implements Observable<T> {
  EventStream<T> get changes;

  T get _currentValue;

  Property._();

  factory Property.constant(T value) => new _ConstantProperty(value);

  Property<bool> and(Property<bool> other) {
    return new _ComputedProperty<bool>(this, other, (a, b) => a && b);
  }

  Property<bool> or(Property<bool> other) {
    return new _ComputedProperty<bool>(this, other, (a, b) => a || b);
  }

  Property<bool> equals(Property other) {
    return new _ComputedProperty<bool>(this, other, (a, b) => a == b);
  }

  Property operator +(Property other) {
    return new _ComputedProperty(this, other, (a, b) => a + b);
  }

  Property operator -(Property other) {
    return new _ComputedProperty(this, other, (a, b) => a - b);
  }

  Property operator *(Property other) {
    return new _ComputedProperty(this, other, (a, b) => a * b);
  }

  Property operator /(Property other) {
    return new _ComputedProperty(this, other, (a, b) => a / b);
  }
}
