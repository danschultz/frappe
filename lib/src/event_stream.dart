part of frappe;

/// An [EventStream] is wrapper around a standard Dart [Stream], but provides utility
/// methods for creating other streams or properties.
class EventStream<T> extends Reactable<T> {
  final Stream<T> _stream;

  bool get isBroadcast => _stream.isBroadcast;

  /// Returns a new [EventStream] that wraps a standard Dart [Stream].
  EventStream(Stream<T> stream) : _stream = stream;

  /// Returns a new [EventStream] that contains events from an [iterable].
  factory EventStream.fromIterable(Iterable<T> iterable) {
    return new EventStream<T>(new Stream<T>.fromIterable(iterable));
  }

  /// Returns a new [EventStream] that contains a single event of the completed [future].
  factory EventStream.fromFuture(Future<T> future) {
    return new EventStream<T>(new Stream<T>.fromFuture(future));
  }

  StreamSubscription<T> listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError}) {
    return _stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  EventStream<T> asEventStream() => this;

  /// Returns a [Property] where the first value will be the next value from this stream.
  Property<T> asProperty() => new Property.fromStream(this);

  /// Returns a [Property] where the first value will be the [initialValue], and values
  /// after that will be the values from this stream.
  Property<T> asPropertyWithInitialValue(T initialValue) =>
      new Property.fromStreamWithInitialValue(initialValue, this);

  Reactable _wrap(Stream stream) => new EventStream(stream);
}
