part of frappe.transformers;

class BufferWhen<T> implements StreamTransformer {
  final Stream _signal;

  BufferWhen(Stream signal) : _signal = signal.asBroadcastStream();

  Stream<T> bind(Stream<T> stream) {
    var buffer = new StreamController.broadcast()..addStream(stream);
    var bufferedStream = buffer.stream;

    var beforeSignal = bufferedStream.transform(new TakeUntil(_signal.first));
    var afterSignal = _signal.transform(new FlatMapLatest((buffer) {
      return buffer ? new Stream.fromIterable([]) : bufferedStream;
    }));
    var done = bufferedStream.isEmpty;

    return beforeSignal.transform(new Merge(afterSignal.transform(new TakeUntil(done))));
  }
}