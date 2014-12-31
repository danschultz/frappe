library event_stream_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:frappe/frappe.dart';
import 'callback_helpers.dart';
import 'reactable_shared_tests.dart';

void main() => describe("EventStream", () {
  injectReactableTests((controller) => new EventStream(controller.stream));

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

  describe("bufferWhen()", () {
    StreamController toggleSwitchController;
    Property toggleSwitch;

    beforeEach(() {
      toggleSwitchController = new StreamController();
      toggleSwitch = new Property.fromStream(toggleSwitchController.stream);
    });

    it("pauses events when toggle switch is true", () {
      toggleSwitchController.add(true);

      new Future(() => main..add(1)..close());

      return stream.bufferWhen(toggleSwitch).toList().then((values) {
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

      return stream.bufferWhen(toggleSwitch).toList().then((values) {
        expect(values).toEqual([1]);
      });
    });
  });

  describe("skipUntil()", () {
    it("provides events after future completes", () {
      var skipStream = stream.skipUntil(other.stream.last);

      main.add(1);
      other..add(true)..close();
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
});
