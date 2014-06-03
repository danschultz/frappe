part of reactive;

class BoolSignal extends _ComputedSignal<bool, bool> {
  BoolSignal(Signal<bool> signal) : super(signal.onChange, () => signal.value);

  BoolSignal and(Signal<bool> other) {
    return new BoolSignal(new _CombinatorSignal(this, other, (a, b) => a && b));
  }

  BoolSignal or(Signal<bool> other) {
    return new BoolSignal(new _CombinatorSignal(this, other, (a, b) => a || b));
  }
}
