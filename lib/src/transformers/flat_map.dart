part of frappe.transformers;

class FlatMap<S, T> implements StreamTransformer {
  final StreamConverter<S, T> _convert;

  FlatMap(StreamConverter<S, T> convert) : _convert = convert;

  Stream<T> bind(Stream<S> stream) {
    var subscriptions = new Queue<StreamSubscription>();

    var onListen = (EventSink<T> sink) {
      return stream.listen((data) {
        Stream<T> mappedStream = _convert(data);
        subscriptions.add(mappedStream.listen((event) {
          sink.add(event);
        }, onError: sink.addError));
      });
    };

    var cleanup = () => cancelSubscriptions(subscriptions).then((_) => subscriptions.clear());

    return bindStream(like: stream, onListen: onListen, onDone: () => cleanup(), onCancel: () => cleanup());
  }
}