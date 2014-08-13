part of frappe;

class _ReactableAsStream<T> extends Stream<T> {
  Reactable<T> _reactable;

  _ReactableAsStream(this._reactable);

  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError}) {
    return _reactable.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}