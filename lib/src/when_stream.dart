part of frappe;

class _WhenStream<T> extends _ForwardingStream<T> {
  Property<bool> _toggle;
  StreamSubscription<bool> _toggleSubscription;

  bool _isForwarding = false;

  _WhenStream(Stream<T> stream, Property<bool> toggle) :
    _toggle = toggle,
    super(stream);

  @override
  void onData(EventSink sink, T event) {
    if (_isForwarding) {
      super.onData(sink, event);
    }
  }

  @override
  void _onListen() {
    _toggleSubscription = _toggle.listen((value) => _isForwarding = value);
    super._onListen();
  }

  @override
  void _onDone() {
    super._onDone();
    _toggleSubscription.cancel();
  }

  @override
  void _onCancel() {
    super._onCancel();
    _toggleSubscription.cancel();
  }
}