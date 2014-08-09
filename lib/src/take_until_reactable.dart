part of frappe;

class _TakeUntilReactable<T> extends _ForwardingStream<T> {
  _TakeUntilReactable(Reactable<T> reactable, Future stop) : super(reactable) {
    stop.then((_) => close());
  }
}