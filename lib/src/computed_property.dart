part of reactive;

class _ComputedProperty<T> extends _ControllerProperty<T> {
  Property<T> _a;
  Property<T> _b;
  Function _compute;

  StreamSubscription<T> _subscriptionA;
  StreamSubscription<T> _subscriptionB;

  T _currentValue;

  _ComputedProperty(this._a, this._b, T compute(T a, T b)) :
    _compute = compute,
    super();

  void _recompute(T a, T b) {
    _currentValue = _compute(a, b);
    _controller.add(_currentValue);
  }

  @override
  void _startListening() {
    _subscriptionA = _a.listen(
        (event) => _recompute(event, _b._currentValue),
        onError: (error, stackTrace) => _controller.addError(error, stackTrace));

    _subscriptionB = _b.listen(
        (event) => _recompute(_a._currentValue, event),
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
