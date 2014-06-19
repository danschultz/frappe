library event_stream_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:relay/relay.dart';
import 'callback_helpers.dart';

void main() => describe("EventStream", () {
  StreamController main;
  StreamController other;
  EventStream stream;

  beforeEach(() {
    main = new StreamController();
    stream = new EventStream(main.stream);
    other = new StreamController();
  });

  describe("merge()", () {
    it("contains events from both streams", () {
      main..add(1)..close();
      other..add(2)..close();

      return stream.merge(other.stream).toList()
          .then((values) => expect(values).toEqual([1, 2]));
    });

    it("contains errors from both streams", () {
      main..addError(1)..close();
      other..addError(2)..close();

      var errors = [];
      return stream
          .merge(other.stream)
          .handleError((error) => errors.add(error)).isEmpty
          .then((_) => expect(errors).toEqual([1, 2]));
    });

    describe("when cancelOnError is true", () {
      it("closes stream on error", () {
        main..add(1)..close();
        other..addError("error");

        return stream.merge(other.stream).listen(doNothing, cancelOnError: true).cancel();
      });
    });
  });

  describe("takeUntil()", () {
    it("provides events until future completes", () {
      var takeStream = stream.takeUntil(other.stream.last);

      main.add(1);
      other..add(2)..close();
      main.add(3);

      return takeStream.toList().then((values) => expect(values).toEqual([1]));
    });

    it("provides errors until future completes", () {
      var errors = [];
      var takeStream = stream.takeUntil(other.stream.last).handleError((error) => errors.add(error));

      main.addError(1);
      other..add(2)..close();
      main.addError(3);

      return takeStream.isEmpty.then((_) => expect(errors).toEqual([1]));
    });

    it("closes when source stream is closed", () {
      var takeStream = stream.takeUntil(other.stream.last);
      main.close();
      return takeStream.isEmpty.then((isEmpty) => expect(isEmpty).toBe(true));
    });
  });

  describe("skipUntil()", () {
    it("provides events after future completes", () {
      var skipStream = stream.skipUntil(other.stream.last);

      main.add(1);
      other..add(2)..close();
      main..add(3)..close();

      return skipStream.toList().then((values) => expect(values).toEqual([3]));
    });

    it("provides errors until future completes", () {
      var errors = [];
      var skipStream = stream.skipUntil(other.stream.last).handleError((error) => errors.add(error));

      main.addError(1);
      other..add(2)..close();
      main..addError(3)..close();

      return skipStream.isEmpty.then((_) => expect(errors).toEqual([3]));
    });

    it("closes when source stream is closed", () {
      var skipStream = stream.skipUntil(other.stream.last);
      main.close();
      return skipStream.isEmpty.then((isEmpty) => expect(isEmpty).toBe(true));
    });
  });

  describe("throttle()", () {
    it("provides the last event after duration passes", () {
      main..add(1)
          ..add(2)
          ..add(3);

      new Timer(new Duration(milliseconds: 50), () => main.close());

      return stream.throttle(new Duration(milliseconds: 25)).toList().then((values) => expect(values).toEqual([1, 3]));
    });

    it("does not throttle errors", () {
      var errors = [];
      var throttledStream = stream.throttle(new Duration(milliseconds: 25)).handleError((error) => errors.add(error));

      main..add(1)
          ..add(2)
          ..add(3)
          ..addError("error 1")
          ..addError("error 2")
          ..addError("error 3");

      new Timer(new Duration(milliseconds: 50), () => main.close());

      return throttledStream.toList().then((values) {
        expect(values).toEqual([1, 3]);
        expect(errors).toEqual(["error 1", "error 2", "error 3"]);
      });
    });
  });
});
