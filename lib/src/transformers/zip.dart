part of frappe.transformers;

class Zip<A, B, R> implements StreamTransformer<A, R> {
  final Stream<B> _other;
  final Combiner<A, B, R> _combiner;

  Zip(Stream<B> other, Combiner<A, B, R> combiner) :
    _other = other,
    _combiner = combiner;

  Stream<R> bind(Stream<A> stream) {
    StreamController<R> controller;
    StreamSubscription<A> subscriptionA;
    StreamSubscription<B> subscriptionB;

    void done() {
      subscriptionA.cancel();
      subscriptionB.cancel();
      controller.close();
    }

    controller = _createControllerLikeStream(stream: stream, onListen: () {
      var bufferA = new Queue();
      var bufferB = new Queue();

      void zipIfValuesExist() {
        if (bufferA.isNotEmpty && bufferB.isNotEmpty) {
          controller.add(_combiner(bufferA.removeFirst(), bufferB.removeFirst()));
        }
      }

      subscriptionA = stream.listen((value) {
        bufferA.addLast(value);
        zipIfValuesExist();
      }, onError: controller.addError, onDone: () => done());
      subscriptionB = _other.listen((value) {
        bufferB.addLast(value);
        zipIfValuesExist();
      }, onError: controller.addError, onDone: () => done());
    }, onCancel: () => done());

    return controller.stream;
  }
}