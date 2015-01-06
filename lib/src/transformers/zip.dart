part of frappe.transformers;

class Zip<A, B, R> implements StreamTransformer<A, R> {
  final Stream<B> _other;
  final Combiner<A, B, R> _combiner;

  Zip(Stream<B> other, Combiner<A, B, R> combiner) :
    _other = other,
    _combiner = combiner;

  Stream<R> bind(Stream<A> stream) {
    Queue appendToQueue(Queue queue, element) => queue..add(element);

    stream = stream.asBroadcastStream();
    var other = _other.asBroadcastStream();

    var bufferA = stream.transform(new Scan(new Queue<A>(), appendToQueue));
    var bufferB = other.transform(new Scan(new Queue<B>(), appendToQueue));

    var combined = Combine.all([bufferA, bufferB]) as Stream<List<Queue>>;

    return combined
        .where((queues) => queues.first.isNotEmpty && queues.last.isNotEmpty)
        .map((queues) => _combiner(queues.first.removeFirst(), queues.last.removeFirst()))
        .transform(new TakeUntil(stream.length))
        .transform(new TakeUntil(other.length));
  }
}