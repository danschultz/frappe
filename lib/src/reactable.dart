part of frappe;

/// A [Reactable] is unifies the API between [EventStream]s and [Property]s.
abstract class Reactable<T> extends Stream<T> {
  /// Returns a [Property] where the current value is an iterable that contains the
  /// latest values from a collection of [reactables].
  ///
  /// The supplied [reactables] can be a mixture of [Property]s and [EventStream]s,
  /// where any [Property]s will first be converted to a stream.
  ///
  /// The returned [Property] will only have a value once all the [reactables] contain
  /// a value.
  static Property<Iterable> collect(Iterable<Reactable> reactables) {
    return new Property.fromStream(Combine.all(reactables.toList()));
  }

  @override
  Reactable<T> asBroadcastStream({void onListen(StreamSubscription<T> subscription),
                                 void onCancel(StreamSubscription<T> subscription)});

  /// Returns this reactable as a [Property].
  ///
  /// If this reactable is already a property, this this returns itself.
  Property<T> asProperty();

  /// Returns this reactable as a [Property] with an initial value.
  ///
  /// If this reactable is already a [Property], then this method returns a new [Property]
  /// where its current value is set to [initialValue].
  Property<T> asPropertyWithInitialValue(T initialValue);

  /// Returns this reactable as an [EventStream].
  @deprecated("Expected to be removed in v0.5. Use asEventStream() instead.")
  EventStream<T> asStream() => asEventStream();

  /// Returns this reactable as an [EventStream].
  EventStream<T> asEventStream();

  @override
  Reactable asyncExpand(Stream convert(T event));

  @override
  Reactable asyncMap(dynamic convert(T event));

  /// Pauses the delivery of events from the source stream when the signal stream
  /// delivers a value of `true`. The buffered events are delivered when the signal
  /// delivers a value of `false`. Errors originating from the source and signal
  /// streams will be forwarded to the transformed stream and will not be buffered.
  /// If the source stream is a broadcast stream, then the transformed stream will
  /// also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var controller = new StreamController();
  ///     var signal = new StreamController();
  ///
  ///     var stream = new EventStream(controller.stream);
  ///     var buffered = stream.bufferWhen(signal.stream));
  ///
  ///     controller.add(1);
  ///     signal.add(true);
  ///     controller.add(2);
  ///
  ///     buffered.listen(print);
  ///
  ///     // 1
  Reactable<T> bufferWhen(Stream<bool> toggle);

  /// Combines the latest values of two streams using a two argument function.
  /// The combining function will not be called until each stream delivers its
  /// first value. After the first value of each stream is delivered, the
  /// combining function will be invoked for each event from the source streams.
  /// Errors occurring on the streams will be forwarded to the transformed
  /// stream. If the source stream is a broadcast stream, then the transformed
  /// stream will also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var controller1 = new StreamController();
  ///     var controller2 = new StreamController();
  ///
  ///     var combined = new EventStream(controller1.stream).combine(controller2.stream, (a, b) => a + b));
  ///
  ///     combined.listen(print);
  ///
  ///     controller1.add(1);
  ///     controller2.add(1);
  ///     controller1.add(2);
  ///     controller2.add(2);
  ///
  ///     // 2
  ///     // 3
  ///     // 4
  Reactable combine(Stream other, Object combiner(T a, b));

  /// Concatenates two streams into one stream by delivering the values of the source stream,
  /// and then delivering the values of the other stream once the source stream completes.
  /// This means that it's possible that events from the second stream might not be included
  /// if the source stream hasn't completed. Use `Concat.all()` to concatenate many streams.
  ///
  /// Errors will be forwarded from either stream, whether or not the source stream has
  /// completed. If the source stream is a broadcast stream, then the transformed stream will
  /// also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var source = new StreamController();
  ///     var other = new StreamController();
  ///
  ///     var stream = new EventStream(source.stream).concat(other.stream));
  ///     stream.listen(print);
  ///
  ///     other..add(1)..add(2);
  ///     source..add(3)..add(4)..close();
  ///
  ///     // 3
  ///     // 4
  ///     // 1
  ///     // 2
  Reactable concat(Stream other);

  /// Concatenates a stream of streams into a single stream, by delivering the first stream's
  /// values, and then delivering the next stream's values after the previous stream has
  /// completed.
  ///
  /// This means that it's possible that events from the second stream might not be included
  /// if the source stream hasn't completed. Use `Concat.all()` to concatenate many streams.
  ///
  /// Errors will be forwarded from either stream, whether or not the source stream has
  /// completed. If the source stream is a broadcast stream, then the transformed stream will
  /// also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var source = new StreamController();
  ///     var other1 = new StreamController();
  ///     var other2 = new StreamController();
  ///
  ///     source..add(other1.stream)..add(other2.stream);
  ///
  ///     other2..add(1)..add(2);
  ///     other1..add(3)..add(4)..close();
  ///
  ///     var stream = new EventStream(source.stream).concatAll());
  ///     stream.listen(print);
  ///
  ///     // 3
  ///     // 4
  ///     // 1
  ///     // 2
  Reactable concatAll();

  /// Delivers the last event from the source after the duration has passed
  /// without receiving an event.
  ///
  /// Errors occurring on the source stream will not be ignored. If the source
  /// stream is a broadcast stream, then the transformed stream will also be
  /// a broadcast stream.
  ///
  ///     source:             asdf----asdf----
  ///     source.debounce(2): -----f-------f--
  ///
  /// **Example:**
  ///
  ///     var controller = new StreamController();
  ///
  ///     var debounced = new EventStream(controller.stream).debounce(new Duration(seconds:1)));
  ///     debounced.listen(print);
  ///
  ///     controller.add(1);
  ///     controller.add(2);
  ///     controller.add(3);
  ///
  ///     // 3
  Reactable<T> debounce(Duration duration);

  /// Throttles the delivery of each event by a given duration. Errors occurring
  /// on the source stream will not be delayed. If the source stream is a broadcast
  /// stream, then the transformed stream will also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var controller = new StreamController();
  ///     var delayed = new EventStream(controller.stream).delay(new Duration(seconds: 2)));
  ///
  ///     // source:              asdf----
  ///     // source.delayed(2):   --a--s--d--f---
  Reactable<T> delay(Duration duration);

  @override
  Reactable<T> distinct([bool equals(T previous, T next)]);

  /// Invokes a side-effect function for each value, error and done event in the stream.
  ///
  /// This is useful for debugging, but also invoking `preventDefault` for browser events.
  /// Side effects will only be invoked once if the transformed stream has multiple
  /// subscribers.
  ///
  /// Errors occurring on the source stream will be forwarded to the returned stream, even
  /// when passing an error handler to `DoAction`. If the source stream is a broadcast
  /// stream, then the transformed stream will also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var controller = new StreamController();
  ///     var stream = new EventStream(controller.stream).doAction(
  ///         (value) => print("Do Next: $value"),
  ///         onError: (error) => print("Do Error: $error"),
  ///         onDone: () => print("Do Done")););
  ///
  ///     stream.listen((value) => print("Next: $value"),
  ///         onError: (e) => print("Error: $e"),
  ///         onDone: () => print("Done"));
  ///
  ///     controller..add(1)..add(2)..close();
  ///
  ///     // Do Next: 1
  ///     // Next: 1
  ///     // Do Next: 2
  ///     // Next: 2
  ///     // Do Done
  ///     // Done
  Reactable<T> doAction(void onData(T value), {Function onError, void onDone()});

  @override
  Reactable expand(Iterable convert(T value));

  /// Spawns a new stream from a function for each event in the source stream.
  /// The returned stream will contain the events and errors from each of the
  /// spawned streams until they're closed. If the source stream is a broadcast
  /// stream, then the transformed stream will also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var controller = new StreamController();
  ///     var flapMapped = new EventStream(controller.stream).flatMap((value) {
  ///       return new Stream.fromIterable([value + 1]);
  ///     });
  ///
  ///     flatMapped.listen(print);
  ///
  ///     controller.add(1);
  ///     controller.add(2);
  ///
  ///     // 2
  ///     // 3
  Reactable flatMap(Stream convert(T event));

  /// Similar to `FlatMap`, but instead of including events from all spawned
  /// streams, only includes the ones from the latest stream. Think of this
  /// as stream switching.
  ///
  /// **Example:**
  ///
  ///     var controller = new StreamController();
  ///     var latest = new EventStream(controller.stream).flatMapLatest((value) {
  ///       return new Stream.fromIterable([value + 1]);
  ///     });
  ///
  ///     latest.listen(print);
  ///
  ///     controller.add(1);
  ///     controller.add(2);
  ///
  ///     // 3
  Reactable flatMapLatest(Stream convert(T event));

  /// Returns a property that indicates if this reactable is waiting for an event from
  /// another stream.
  ///
  /// This method is useful for displaying spinners while waiting for AJAX responses.
  ///
  /// **Example:**
  ///
  ///     var source = new EventStream.single(1);
  ///     var other = new EventStream.fromFuture(new Future.delayed(new Duration(seconds: 1)));
  ///
  ///     var isWaiting = source.isWaitingOn(other);
  ///     isWaiting.listen(print);
  ///
  ///     // true
  ///     // false
  Property<bool> isWaitingOn(Stream other) {
    return new Property.fromStreamWithInitialValue(
        false,
        flatMapLatest((_) => new EventStream.fromValue(true).merge(other.take(1).map((_) => false))))
      .distinct();
  }

  @override
  Reactable<T> handleError(onError, {bool test(error)});

  @override
  Reactable map(convert(T event));

  /// Combines the events from two streams into a single stream. Errors occurring
  /// on any merged stream will be forwarded to the transformed stream. If the
  /// source stream is a broadcast stream, then the transformed stream will also
  /// be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var controller1 = new StreamController();
  ///     var controller2 = new StreamController();
  ///
  ///     var merged = new EventStream(controller1.stream).merge(controller2.stream));
  ///
  ///     merged.listen(print);
  ///
  ///     controller1.add(1);
  ///     controller2.add(2);
  ///     controller1.add(3);
  ///     controller2.add(4);
  ///
  ///     // 1
  ///     // 2
  ///     // 3
  ///     // 4
  Reactable merge(Stream other);

  /// Combines the events from a stream of streams into a single stream.
  ///
  /// The returned stream will contain the errors occurring on any stream. If the source
  /// stream is a broadcast stream, then the transformed stream will also be a broadcast
  /// stream.
  ///
  /// **Example:**
  ///
  ///     var source = new StreamController();
  ///     var stream1 = new Stream.fromIterable([1, 2]);
  ///     var stream2 = new Stream.fromIterable([3, 4]);
  ///
  ///     var merged = new EventStream(source.stream).mergeAll());
  ///     source..add(stream1)..add(stream2);
  ///
  ///     merged.listen(print);
  ///
  ///     // 1
  ///     // 2
  ///     // 3
  ///     // 4
  Reactable mergeAll();

  /// Applies the logical `!` operation to each value.
  Reactable<bool> not() => map((value) => !value);

  /// Takes the latest value of the source stream whenever the trigger stream
  /// produces an event.
  ///
  /// Errors that happen on the source stream will be forwarded to the transformed
  /// stream. If the source stream is a broadcast stream, then the transformed
  /// stream will also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     // values start at 0
  ///     var source = new Stream.periodic(new Duration(seconds: 1), (i) => i);
  ///     var trigger = new Stream.periodic(new Duration(seconds: 2), (i) => i);
  ///
  ///     var stream = new EventStream(source.stream).sampleOn(trigger.stream)).take(3);
  ///
  ///     stream.listen(print);
  ///
  ///     // 0
  ///     // 2
  ///     // 4
  Reactable<T> sampleOn(Stream trigger);

  /// Takes the latest value of the source stream at a specified interval.
  ///
  /// Errors that happen on the source stream will be forwarded to the transformed
  /// stream. If the source stream is a broadcast stream, then the transformed
  /// stream will also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     // values start at 0
  ///     var source = new Stream.periodic(new Duration(seconds: 1), (i) => i);
  ///     var stream = new EventStream(source.stream).samplePeriodically(new Duration(seconds: 2))).take(3);
  ///
  ///     stream.listen(print);
  ///
  ///     // 0
  ///     // 2
  ///     // 4
  Reactable<T> samplePeriodically(Duration duration);

  /// Reduces the values of a stream into a single value by using an initial
  /// value and an accumulator function. The function is passed the previous
  /// accumulated value and the current value of the stream. This is useful
  /// for maintaining state using a stream. Errors occurring on the source
  /// stream will be forwarded to the transformed stream. If the source stream
  /// is a broadcast stream, then the transformed stream will also be a
  /// broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var button = new ButtonElement();
  ///
  ///     var clickCount = new EventStream(button.onClick).scan(0, (previous, current) => previous + 1));
  ///
  ///     clickCount.listen(print);
  ///
  ///     // [button click] .. prints: 1
  ///     // [button click] .. prints: 2
  Reactable scan(initialValue, combine(value, T element));

  /// Forwards events from the first stream to deliver an event.
  ///
  /// Errors are forwarded from both streams until a stream is selected. Once a stream is selected,
  /// only errors from the selected stream are forwarded. If the source stream is a broadcast stream,
  /// then the transformed stream will also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var stream1 = new Stream.periodic(new Duration(seconds: 1)).map((_) => "Stream 1");
  ///     var stream2 = new Stream.periodic(new Duration(seconds: 2)).map((_) => "Stream 2");
  ///
  ///     var selected = new EventStream(stream1).selectFirst(stream2)).take(1);
  ///     selected.listen(print);
  ///
  ///     // Stream 1
  Reactable selectFirst(Stream other);

  @override
  Reactable<T> skip(int count);

  @override
  Reactable<T> skipWhile(bool test(T element));

  /// Waits to deliver events from a stream until the signal `Stream` delivers a
  /// value. Errors that happen on the source stream will be forwarded once the
  /// `Stream` delivers its value. Errors happening on the signal stream will be
  /// forwarded immediately. If the source stream is a broadcast stream, then the
  /// transformed stream will also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var signal = new StreamController();
  ///     var controller = new StreamController();
  ///
  ///     var skipStream = new EventStream(controller.stream).skipUntil(signal.stream));
  ///
  ///     skipStream.listen(print);
  ///
  ///     controller.add(1);
  ///     controller.add(2);
  ///     signal.add(true);
  ///     controller.add(3);
  ///     controller.add(4);
  ///
  ///     // 3
  ///     // 4
  Reactable<T> skipUntil(Stream signal);

  /// Prepends a value to the beginning of a stream. Use [startWithValues] to prepend
  /// multiple values.
  ///
  /// Errors on the source stream will be forwarded to the transformed stream. If the
  /// source stream is a broadcast stream, then the transformed stream will also be a
  /// broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var source = new Stream.fromIterable([2, 3]);
  ///     var stream = new EventStream(source).startWith(1);
  ///     stream.listen(print);
  ///
  ///     // 1
  ///     // 2
  ///     // 3
  Reactable startWith(value);

  /// Prepends values to the beginning of a stream.
  ///
  /// Errors on the source stream will be forwarded to the transformed stream. If the
  /// source stream is a broadcast stream, then the transformed stream will also be a
  /// broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var source = new Stream.fromIterable([3]);
  ///     var stream = new EventStream(source).startWithValues([1, 2]);
  ///     stream.listen(print);
  ///
  ///     // 1
  ///     // 2
  ///     // 3
  Reactable startWithValues(Iterable values);

  @override
  Reactable<T> take(int count);

  /// Delivers events from the source stream until the signal `Stream` produces a value.
  /// At which point, the transformed stream closes. The returned stream will continue
  /// to deliver values if the signal stream closes without a value.
  ///
  /// This is useful for automatically cancelling a stream subscription to prevent memory
  /// leaks. Errors that happen on the source and signal stream will be forwarded to the
  /// transformed stream. If the source stream is a broadcast stream, then the transformed
  /// stream will also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var signal = new StreamController();
  ///     var controller = new StreamController();
  ///
  ///     var takeUntil = new EventStream(controller.stream).takeUntil(signal.stream));
  ///
  ///     takeUntil.listen(print, onDone: () => print("done"));
  ///
  ///     controller.add(1);
  ///     controller.add(2);
  ///     signal.add(true);
  ///     controller.add(3);
  ///     controller.add(4);
  ///
  ///     // 1
  ///     // 2
  ///     // done
  Reactable<T> takeUntil(Stream signal);

  @override
  Reactable<T> takeWhile(bool test(T element));

  @override
  Reactable timeout(Duration timeLimit, {void onTimeout(EventSink sink)});

  @override
  Reactable transform(StreamTransformer<T, dynamic> streamTransformer);

  /// Starts delivering events from the source stream when the signal stream
  /// delivers a value of `true`. Events are skipped when the signal stream
  /// delivers a value of `false`. Errors from the source or toggle stream will be
  /// forwarded to the transformed stream. If the source stream is a broadcast
  /// stream, then the transformed stream will also be a broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var controller = new StreamController();
  ///     var signal = new StreamController();
  ///
  ///     var whenStream = new EventStream(controller.stream).when(signal.stream));
  ///
  ///     whenStream.listen(print);
  ///
  ///     controller.add(1);
  ///     signal.add(true);
  ///     controller.add(2);
  ///     signal.add(false);
  ///     controller.add(3);
  ///
  ///     // 2
  Reactable<T> when(Stream<bool> toggle);

  @override
  Reactable<T> where(bool test(T event));

  /// Combines the events of two streams into one by invoking a combiner function
  /// that is invoked when each stream delivers an event at each index. The
  /// transformed stream finishes when either source stream finishes. Errors from
  /// either stream will be forwarded to the transformed stream. If the source
  /// stream is a broadcast stream, then the transformed stream will also be a
  /// broadcast stream.
  ///
  /// **Example:**
  ///
  ///     var controller1 = new StreamController();
  ///     var controller2 = new StreamController();
  ///
  ///     var zipped = new EventStream(controller1.stream).zip(controller2.stream, (a, b) => a + b));
  ///
  ///     zipped.listen(print);
  ///
  ///     controller1.add(1);
  ///     controller1.add(2);
  ///     controller2.add(1);
  ///     controller1.add(3);
  ///     controller2.add(2);
  ///     controller2.add(3);
  ///
  ///     // 2
  ///     // 4
  ///     // 6
  Reactable zip(Stream other, Combiner combiner);
}