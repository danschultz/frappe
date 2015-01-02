part of frappe.transformers;

class Combine<A, B, R> implements StreamTransformer<A, R> {
  final Stream<B> _other;
  final Combiner<A, B, R> _combiner;

  Combine(Stream<B> other, Combiner<A, B, R> combiner) :
    _other = other,
    _combiner = combiner;

  Stream<R> bind(Stream<A> stream) {
    StreamController<R> controller;
    StreamSubscription<A> subscriptionA;
    StreamSubscription<B> subscriptionB;

    var completerA = new Completer();
    var completerB = new Completer();

    A valueA;
    var hasA = false;

    B valueB;
    var hasB = false;

    void combineIfValuesExist() {
      if (hasA && hasB) {
        controller.add(_combiner(valueA, valueB));
      }
    }

    void done() {
      subscriptionA.cancel();
      subscriptionB.cancel();
      controller.close();
    }

    controller = _createControllerForStream(stream, onListen: () {
      subscriptionA = stream.listen((value) {
        valueA = value;
        hasA = true;
        combineIfValuesExist();
      }, onError: controller.addError, onDone: completerA.complete);

      subscriptionB = _other.listen((value) {
        valueB = value;
        hasB = true;
        combineIfValuesExist();
      }, onError: controller.addError, onDone: completerB.complete);
    });

    Future.wait([completerA.future, completerB.future]).then((_) => done());

    return controller.stream;
  }
}
