part of frappe.transformers;

class Debounce<T> implements StreamTransformer<T, T> {
  final Duration _duration;

  Debounce(Duration duration) : _duration = duration;

  Stream<T> bind(Stream<T> stream) {
    var isDebouncing = false;
    Timer timer;

    StreamSubscription<T> onListen(EventSink<T> sink) {
      void schedule(T value) {
        if (timer != null) {
          timer.cancel();
        }
        timer = new Timer(_duration, () => sink.add(value));
      }

      return stream.listen((event) {
        if (!isDebouncing) {
          sink.add(event);
        } else {
          schedule(event);
        }
        isDebouncing = true;
      }, onError: sink.addError);
    }

    return bindStream(like: stream, onListen: onListen);
  }
}