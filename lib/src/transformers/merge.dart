part of frappe.transformers;

class Merge<S, T> implements StreamTransformer<S, T> {
  final Stream<T> _other;

  Merge(Stream<T> other) : _other = other;

  Stream bind(Stream<S> stream) {
    StreamSubscription<S> subscriptionA;
    StreamSubscription<T> subscriptionB;
    var completerA = new Completer();
    var completerB = new Completer();
    StreamController controller;

    void onListen() {
      subscriptionA = stream.listen(controller.add, onError: controller.addError, onDone: completerA.complete);
      subscriptionB = _other.listen(controller.add, onError: controller.addError, onDone: completerB.complete);
    }

    void onPause() {
      subscriptionA.pause();
      subscriptionB.pause();
    }

    void onResume() {
      subscriptionA.resume();
      subscriptionB.resume();
    }

    controller = _createControllerForStream(stream, onListen: onListen, onPause: onPause, onResume: onResume);

    Future.wait([completerA.future, completerB.future]).then((_) => controller.close());

    return controller.stream;
  }
}