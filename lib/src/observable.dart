part of reactive;

abstract class Observable<T> {
  StreamSubscription<T> listen(void onData(T event), {void onError(), void onDone(), bool cancelOnError});
}