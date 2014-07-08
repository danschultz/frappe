part of frappe;

abstract class _ControllerProperty<T> extends Property<T> {
  StreamController<T> _controller;
  Stream<T> get changes => _controller.stream;

  _ControllerProperty() : super._() {
    _controller = new StreamController.broadcast(
        onListen: () => _startListening(),
        onCancel: () => _stopListening());
  }

  @override
  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError}) {
    return changes.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void _startListening();

  void _stopListening();
}
