part of frappe.transformers;

class BufferWhen<T> implements StreamTransformer {
  final Stream _signal;

  BufferWhen(Stream signal) : _signal = signal;

  Stream<T> bind(Stream<T> stream) {
    StreamSubscription signalSubscription;
    StreamSubscription streamSubscription;
    StreamController<T> controller;

    void done() {
      signalSubscription.cancel();
      streamSubscription.cancel();
      controller.close();
    }

    void onListen() {
      streamSubscription = stream.listen(controller.add, onError: controller.addError, onDone: done);
      signalSubscription = _signal.listen((isBuffering) {
        if (isBuffering) {
          streamSubscription.pause();
        } else {
          streamSubscription.resume();
        }
      });
    }

    void onPause() {
      signalSubscription.pause();
      streamSubscription.pause();
    }

    void onResume() {
      signalSubscription.resume();
      streamSubscription.resume();
    }

    controller = _createControllerForStream(stream,
        onListen: onListen,
        onResume: onResume,
        onPause: onPause,
        onCancel: done);

    return controller.stream;
  }
}