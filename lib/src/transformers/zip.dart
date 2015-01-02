part of frappe.transformers;

class Zip<A, B, R> implements StreamTransformer<A, R> {
  final Stream<B> _other;
  final Combiner<A, B, R> _combiner;

  Zip(Stream<B> other, Combiner<A, B, R> combiner) :
    _other = other,
    _combiner = combiner;

  Stream<R> bind(Stream<A> stream) {
    var other = _other.asBroadcastStream();
    stream = stream.asBroadcastStream();

    StreamController<R> controller;
    StreamSubscription<A> subscriptionA;
    StreamSubscription<B> subscriptionB;

    void done() {
      subscriptionA.cancel();
      subscriptionB.cancel();
      controller.close();
    }

    controller = _createControllerForStream(stream, onListen: () {
      var bufferA = new Queue();
      var bufferB = new Queue();

      void fireIfPairedValuesExist() {
        if (bufferA.isNotEmpty && bufferB.isNotEmpty) {
          controller.add(_combiner(bufferA.removeFirst(), bufferB.removeFirst()));
        }
      }

      subscriptionA = stream.listen((value) {
        bufferA.addLast(value);
        fireIfPairedValuesExist();
      }, onDone: () => done());
      subscriptionB = other.listen((value) {
        bufferB.addLast(value);
        fireIfPairedValuesExist();
      }, onDone: () => done());
    }, onCancel: () => done());

    return controller.stream;
  }
}