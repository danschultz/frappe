part of frappe.transformers;

class TakeUntil<T> implements StreamTransformer<T, T> {
  final Future _signal;

  TakeUntil(Future signal) : _signal = signal;

  Stream<T> bind(Stream<T> stream) {
    StreamController<T> controller;

    StreamSubscription<T> streamSubscription;
    StreamSubscription<bool> closeSubscription;

    void onListen() {
      streamSubscription = stream.listen(controller.add, onError: controller.addError, onDone: () {
        controller.close();
        closeSubscription.cancel();
      });

      // Forward the completion handler from the signal into a stream controller. This allows
      // events from Futures and Streams to be scheduled together, and prevents scenarios where
      // the stream receives events and doesn't forward them when they're received in close
      // proximity to when the future completes.
      var closeController = new StreamController();
      _signal.then((_) {
        closeController.add(true);
      });
      closeSubscription = closeController.stream.take(1).listen((_) {
        streamSubscription.cancel();
        controller.close();
      });
    }

    controller = _createControllerForStream(stream,
        onListen: () => onListen(),
        onCancel: () {
          streamSubscription.cancel();
          closeSubscription.cancel();
        },
        onPause: () => streamSubscription.pause(),
        onResume: () => streamSubscription.resume());
    return controller.stream;
  }
}