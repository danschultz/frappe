part of frappe.transformers;

class TakeUntil<T> implements StreamTransformer<T, T> {
  final Future _signal;

  TakeUntil(Future signal) : _signal = signal;

  Stream<T> bind(Stream<T> stream) {
    var controller = _createControllerForStream(stream);
    var subscription = stream.listen(controller.add, onError: controller.addError, onDone: () => controller.close());
    _signal.then((_) {
      subscription.cancel();
      controller.close();
    });
    return controller.stream;
  }
}