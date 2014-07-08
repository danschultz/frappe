part of frappe;

class _AsyncExpandLatestStream<T> extends _ForwardingStream {
  Function _convert;

  StreamSubscription _latestSubscription;

  _AsyncExpandLatestStream(EventStream<T> stream, Stream convert(T event)) :
    _convert = convert,
    super(stream);

  @override
  void onData(EventSink sink, T event) {
    _cancelLatestSubscription();

    Stream stream = _convert(event);
    _latestSubscription = stream.listen(
        (event) => sink.add(event),
        onError: (error, stackTrace) => sink.addError(error, stackTrace));
  }

  @override
  void _onCancel() {
    super._onCancel();
    _cancelLatestSubscription();
  }

  void _cancelLatestSubscription() {
    if (_latestSubscription != null) {
      _latestSubscription.cancel();
    }
  }
}