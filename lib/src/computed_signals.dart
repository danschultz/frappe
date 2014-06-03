part of reactive;

class _ComputedSignal<T, R> extends StreamSignal<R> {
  _ComputedSignal(Stream<T> stream, R computation()) :
    super(computation(), stream.map((_) => computation()));
}

class _CombinatorSignal<T> extends _ComputedSignal<T, T> {
  _CombinatorSignal(Signal a, Signal b, T computation(a, b)) :
    super(
        a.onChange.merge(b.onChange).map((_) => computation(a(), b())),
        () => computation(a(), b()));
}