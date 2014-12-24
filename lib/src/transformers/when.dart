part of frappe.transformers;

class When<T> implements StreamTransformer<T, T> {
  final Stream<bool> _toggle;

  When(Stream<bool> toggle) : _toggle = toggle.asBroadcastStream();

  Stream<T> bind(Stream<T> stream) {
    var broadcastStream = stream.asBroadcastStream();
    return _toggle
        .transform(new FlatMapLatest((isToggled) => isToggled ? broadcastStream : new Stream.fromIterable([])))
        .transform(new TakeUntil(broadcastStream.last));
  }
}