part of frappe.transformers;

class FlatMapLatest<S, T> implements StreamTransformer<S, T> {
  final StreamConverter<S, T> _convert;

  FlatMapLatest(StreamConverter<S, T> convert) : _convert = convert;

  Stream<T> bind(Stream<S> stream) {
    StreamSubscription latest;

    Future cancelLatest() {
      if (latest != null) {
        return latest.cancel();
      } else {
        return null;
      }
    }

    StreamSubscription<S> onListen(EventSink<T> sink) {
      return stream.listen((event) {
        cancelLatest();

        Stream<T> mappedStream = _convert(event);
        latest = mappedStream.listen(sink.add, onError: sink.addError);
      });
    }

    return bindStream(like: stream, onListen: onListen, onCancel: () => cancelLatest(), onDone: () => cancelLatest());
  }
}