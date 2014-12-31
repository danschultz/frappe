part of frappe;

class _CombinedProperty<S, T> extends _ControllerProperty<T> {
  Property<S> _a;
  Property _b;
  Function _compute;

  StreamSubscription<S> _subscriptionA;
  StreamSubscription _subscriptionB;

  bool _hasReceivedA = false;
  bool _hasReceivedB = false;
  bool get _canCompute => _hasReceivedA && _hasReceivedB;

  S _valueA;
  Object _valueB;

  _CombinedProperty(this._a, this._b, T compute(S a, b)) :
    _compute = compute,
    super();

  void _recompute(S a, b) {
    if (_canCompute) {
      try {
        _currentValue = _compute(a, b);
      } catch (error, stackTrace) {
        _controller.addError(error, stackTrace);
      }
    }
  }

  @override
  void _startListening() {
    _subscriptionA = _a.listen(
        (event) {
          _hasReceivedA = true;
          _valueA = event;
          _recompute(event, _valueB);
        },
        onError: (error, stackTrace) => _controller.addError(error, stackTrace));

    _subscriptionB = _b.listen(
        (event) {
          _hasReceivedB = true;
          _valueB = event;
          _recompute(_valueA, event);
        },
        onError: (error, stackTrace) => _controller.addError(error, stackTrace));
  }

  @override
  void _stopListening() {
    if (_subscriptionA != null) {
      _subscriptionA.cancel();
      _subscriptionA = null;
    }

    if (_subscriptionB != null) {
      _subscriptionB.cancel();
      _subscriptionB = null;
    }
  }
}
