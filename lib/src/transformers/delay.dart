part of frappe.transformers;

class Delay<T> implements StreamTransformer<T, T> {
  final Duration _duration;

  Delay(Duration duration) : _duration = duration;

  Stream<T> bind(Stream<T> stream) {
    return stream.asyncMap((event) => new Future.delayed(_duration, () => event));
  }
}