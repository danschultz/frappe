part of frappe;

class _ForwardingStream<T> extends _ForwardingReactable<T> implements Stream<T> {
  _ForwardingStream(Stream<T> stream) : super(new EventStream(stream));
}