part of frappe.transformers;

class SkipUntil<T> implements StreamTransformer<T, T> {
  final Future _signal;

  SkipUntil(Future signal) : _signal = signal;

  Stream<T> bind(Stream<T> stream) {
    StreamController<bool> toggler;

    // Begin listening to the signal once the toggle stream has been listened to, otherwise
    // the returned stream might include events before the returned stream has a listener.
    toggler = new StreamController<bool>(onListen: () {
      _signal.then((_) => toggler.add(true));
    });

    return stream.transform(new When(toggler.stream));
  }
}