part of reactive;

class _ConstantProperty<T> extends Property<T> {
  T _currentValue;

  EventStream _changes;
  @override
  EventStream<T> get changes => _changes;

  _ConstantProperty(T value) :
    _currentValue = value,
    _changes = new EventStream(new Stream.fromIterable([])),
    super._();

  @override
  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError}) {
    return new Stream.fromFuture(new Future(() => _currentValue))
        .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}