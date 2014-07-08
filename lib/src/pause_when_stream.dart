part of frappe;

class _PauseWhenStream<T> extends _ForwardingStream<T> {
  Watchable<bool> _toggleSwitch;
  StreamSubscription<bool> _toggleSwitchSubscription;

  bool _isBuffering = false;
  Queue<T> _buffer = new Queue();

  _PauseWhenStream(Stream<T> stream, Watchable<bool> toggleSwitch) :
    _toggleSwitch = toggleSwitch,
    super(stream);

  @override
  void onData(EventSink sink, T event) {
    if (!_isBuffering) {
      super.onData(sink, event);
    } else {
      _buffer.addLast(event);
    }
  }

  @override
  void _onListen() {
    _toggleSwitchSubscription = _toggleSwitch.listen((isBuffering) {
      _isBuffering = isBuffering;

      if (!_isBuffering) {
        _flushBuffer();
      }
    });

    super._onListen();
  }

  @override
  void _onCancel() {
    super._onCancel();
    _toggleSwitchSubscription.cancel();
    _buffer.clear();
  }

  @override
  void _onDone() {
    super._onDone();
    _toggleSwitchSubscription.cancel();
  }

  void _flushBuffer() {
    while (_buffer.isNotEmpty) {
      _controller.add(_buffer.removeFirst());
    }
  }
}