part of frappe;

class _CombinedProperty<T> extends _ControllerProperty<T> {
  Property<T> _a;
  Property<T> _b;
  Function _compute;

  StreamSubscription<T> _subscriptionA;
  StreamSubscription<T> _subscriptionB;

  bool _hasReceivedA = false;
  bool _hasReceivedB = false;

  Object _valueA;
  Object _valueB;

  _CombinedProperty(this._a, this._b, T compute(T a, T b)) :
    _compute = compute,
    super();

  void _recompute(T a, T b) {
    if (_hasReceivedA && _hasReceivedB) {
      try {
        _controller.add(_compute(a, b));
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

class _ComputedProperty<T, R> extends _ControllerProperty<R> {
  Property<T> _property;
  Function _compute;

  StreamSubscription _subscription;

  _ComputedProperty(this._property, this._compute);

  void _recompute(T value) {
    try {
      _controller.add(_compute(value));
    } catch (error, stackTrace) {
      _controller.addError(error, stackTrace);
    }
  }

  @override
  void _startListening() {
    _subscription = _property.listen((event) => _recompute(event),
        onError: (error, stackTrace) => _controller.addError(error, stackTrace));
  }

  @override
  void _stopListening() {
    _subscription.cancel();
    _subscription = null;
  }
}
