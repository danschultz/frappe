library event_stream_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:courier/courier.dart';
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

  describe("delay()", () {
    it("delivers events from this stream after the specified duration", () {
      var milliseconds = 100;

      var result;
      new Timer(new Duration(milliseconds: milliseconds ~/ 2), expectAsync(() => expect(result).toBeNull()));
      listenToFirstEvent(stream.delay(new Duration(milliseconds: milliseconds)), (data) => result = data);

      main.add(1);
    });

    it("does not delay error events", () {
      var milliseconds = 100;

      var error;
      new Timer(new Duration(milliseconds: milliseconds ~/ 2), expectAsync(() => expect(error).toBeNotNull()));

      var delayed = stream.delay(new Duration(milliseconds: milliseconds)).handleError((data) => error = data);
      listenToFirstEvent(delayed, doNothing);

      main..addError("error 1")..close();
    });
  });

  describe("asyncMapLatest()", () {
    Map<int, StreamController> controllers;

    beforeEach(() {
      controllers = {
        1: new StreamController(),
        2: new StreamController()
      };

      main..add(1);
      main..add(2);
    });

    it("includes events from latest returned stream", () {
      // Use a future to make sure that the controllers don't have values when the main
      // events (1, 2) are added.
      new Future(() {
        controllers[1]..add("a")..close();
        controllers[2]..add("b")..close();
        main.close();
      });

      return stream.asyncExpandLatest((event) => controllers[event].stream)
          .toList().then((values) => expect(values).toEqual(["b"]));
    });

    it("forwards events from the latest stream", () {
      // Use a future to make sure that the controllers don't have values when the main
      // events (1, 2) are added.
      new Future(() {
        controllers[1]..add("a")..close();
        controllers[2]..addError("error B")..close();
        main.close();
      });

      stream.asyncExpandLatest((event) => controllers[event].stream)
          .listen(doNothing, onError: expectAsync((error) => expect(error).toBe("error B")), cancelOnError: true);
    });

    it("doesn't forward events from old stream", () {
      // Use a future to make sure that the controllers don't have values when the main
      // events (1, 2) are added.
      new Future(() {
        controllers[1]..addError("error A")..close();
        controllers[2]..add("b")..close();
        main.close();
      });

      return stream.asyncExpandLatest((event) => controllers[event].stream)
          .toList().then((values) => expect(values).toEqual(["b"]));
    });
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

  describe("pauseWhen()", () {
    StreamController toggleSwitchController;
    Property toggleSwitch;

    beforeEach(() {
      toggleSwitchController = new StreamController();
      toggleSwitch = new Property.fromStream(toggleSwitchController.stream);
    });

    it("pauses events when toggle switch is true", () {
      toggleSwitchController.add(true);

      new Future(() => main..add(1)..close());

      return stream.pauseWhen(toggleSwitch).toList().then((values) {
        expect(values.isEmpty).toBe(true);
      });
    });

    it("flushes buffered events when toggle switch is false", () {
      toggleSwitchController.add(true);

      new Future(() {
        main.add(1);
        toggleSwitchController.add(false);

        new Future(() => main.close());
      });

      return stream.pauseWhen(toggleSwitch).toList().then((values) {
        expect(values).toEqual([1]);
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
