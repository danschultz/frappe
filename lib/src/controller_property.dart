part of frappe;

abstract class _ControllerProperty<T> extends Property<T> {
  StreamController<T> _controller;
  Stream<T> get changes => _controller.stream;

  _ControllerProperty() : super._() {
    _controller = new StreamController.broadcast(
        onListen: () => _startListening(),
        onCancel: () => _stopListening());
  }

  void _startListening();

  void _stopListening();
}
