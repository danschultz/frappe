part of frappe.transformers;

class Combine<A, B, R> implements StreamTransformer<A, R> {
  static Stream<List> all(List<Stream> streams) {
    return bindStream(onListen: (EventSink<List> sink) {
      Stream<List> merged = Merge.all(streams.map((stream) => stream.map((event) => [stream, event])));
      Stream<Map<Stream, Object>> values = merged.transform(new Scan<Map<Stream, Object>>({}, (previous, current) {
        var values = new Map.from(previous);
        values[current.first] = current.last;
        return values;
      }));

      return values
          .where((values) => values.length == streams.length)
          .map((values) => streams.map((stream) => values[stream]).toList(growable: false))
          .listen((combined) => sink.add(combined));
    });
  }

  final Stream<B> _other;
  final Combiner<A, B, R> _combiner;

  Combine(Stream<B> other, Combiner<A, B, R> combiner) :
    _other = other,
    _combiner = combiner;

  Stream<R> bind(Stream<A> stream) {
    return bindStream(like: stream, onListen: (EventSink<R> sink) {
      return Combine.all([stream, _other]).listen((values) => sink.add(_combiner(values.first, values.last)));
    });
  }
}
