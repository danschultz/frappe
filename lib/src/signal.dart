part of reactive;

// Extend dynamic to suppress warnings with operator overrides
abstract class Signal<T extends dynamic> implements Observable<T> {
  EventStream<T> get changes;

  T get _currentValue;

  Signal._();

  factory Signal.constant(T value) => new _ConstantSignal(value);

  Signal<bool> and(Signal<bool> other) {
    return new _ComputedSignal<bool>(this, other, (a, b) => a && b);
  }

  Signal<bool> or(Signal<bool> other) {
    return new _ComputedSignal<bool>(this, other, (a, b) => a || b);
  }

  Signal<bool> equals(Signal other) {
    return new _ComputedSignal<bool>(this, other, (a, b) => a == b);
  }

  Signal operator +(Signal other) {
    return new _ComputedSignal(this, other, (a, b) => a + b);
  }

  Signal operator -(Signal other) {
    return new _ComputedSignal(this, other, (a, b) => a - b);
  }

  Signal operator *(Signal other) {
    return new _ComputedSignal(this, other, (a, b) => a * b);
  }

  Signal operator /(Signal other) {
    return new _ComputedSignal(this, other, (a, b) => a / b);
  }
}
