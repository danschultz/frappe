library reactable_shared_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'callback_helpers.dart';

void injectReactableTests(Reactable provider(StreamController controller)) {
  describe("injected reactable tests", () {
    StreamController controller;
    Reactable reactable;

    beforeEach(() {
      controller = new StreamController();
      reactable = provider(controller);
    });

    afterEach(() {
      controller.close();
    });

    describe("first", () {
      it("completes with the first event", () {
        controller..add(1)..add(2)..close();
        return reactable.first.then((value) => expect(value).toBe(1));
      });

      it("completes with an error", () {
        controller.addError("example error");
        return reactable.first.catchError(doNothing);
      });
    });

    describe("last", () {
      it("completes with the last event", () {
        controller..add(1)..add(2)..close();
        return reactable.last.then((value) => expect(value).toBe(2));
      });

      it("completes with an error", () {
        controller.addError("example error");
        return reactable.last.catchError(doNothing);
      });
    });

    describe("flatMap", () {
      Map<int, StreamController> controllers;

      beforeEach(() {
        controllers = {
            1: new StreamController(),
            2: new StreamController()
        };

        controller..add(1);
        controller..add(2);
      });

      it("includes values from spawned streams", () {
        var flatMapped = reactable.flatMap((value) => controllers[value].stream);

        new Future(() => controllers[2]..add("b")..close())
            .then((_) => new Future(() => controllers[1]..add("a")..close()))
            .then((_) => new Future(() => controller.close()));

        return flatMapped.toList().then((values) => expect(values).toEqual(["b", "a"]));
      });
    });

    describe("flatMapLatest()", () {
      Map<int, StreamController> controllers;

      beforeEach(() {
        controllers = {
            1: new StreamController(),
            2: new StreamController()
        };

        controller..add(1);
        controller..add(2);
      });

      it("includes values from last returned stream", () {
        // Use a future to make sure that the controllers don't have values when the main
        // events (1, 2) are added.
        new Future(() {
          controllers[1]..add("a")..close();
          controllers[2]..add("b")..close();
          controller.close();
        });

        return reactable.flatMapLatest((event) => controllers[event].stream)
            .last.then((value) => expect(value).toEqual("b"));
      });

      it("doesn't include values from previous streams", () {
        // Use a future to make sure that the controllers don't have values when the main
        // events (1, 2) are added.
        new Future(() => controllers[2]..add("b")..close())
            .then((_) => new Future(() => controllers[1]..add("a")..close()))
            .then((_) => controller.close());

        return reactable.flatMapLatest((event) => controllers[event].stream)
            .toList().then((values) => expect(values).toEqual(["b"]));
      });
    });

    describe("isWaitingOn()", () {
      Reactable other;
      StreamController otherController;

      beforeEach(() {
        otherController = new StreamController();
        other = new EventStream(otherController.stream);
      });

      afterEach(() {
        return otherController.close();
      });

      it("is true before other delivers an event", () {
        var result = reactable.isWaitingOn(other);
        return result.first.then((value) => expect(value).toBe(true));
      });

      it("is false once other delivers an event", () {
        var result = reactable.isWaitingOn(other);
        new Future(() => otherController.add(1));
        return result.last.then((value) => expect(value).toBe(false));
      });
    });

    describe("takeUntil()", () {
      Completer stopper;

      beforeEach(() => stopper = new Completer());

      it("provides events until future completes", () {
        var takeUntil = reactable.takeUntil(stopper.future);

        new Future(() => controller.add(1))
            .then((_) => new Future(() => stopper.complete()))
            .then((_) => controller.add(3));

        return takeUntil.asStream().toList().then((values) => expect(values).toEqual([1]));
      });

      it("provides errors until future completes", () {
        var errors = [];
        var takeUntil = reactable.takeUntil(stopper.future).handleError((error) => errors.add(error));

        new Future(() => controller.addError(1))
            .then((_) => new Future(() => stopper.complete()))
            .then((_) => controller.addError(3));

        return takeUntil.isEmpty.then((_) => expect(errors).toEqual([1]));
      });

      it("closes when source stream is closed", () {
        var takeUntil = reactable.takeUntil(stopper.future);
        controller.close();
        return takeUntil.isEmpty.then((isEmpty) => expect(isEmpty).toBe(true));
      });
    });

    describe("debounce()", () {
      it("provides the last event after duration passes", () {
        controller
            ..add(1)
            ..add(2)
            ..add(3);

        new Timer(new Duration(milliseconds: 50), () => controller.close());

        return reactable.debounce(new Duration(milliseconds: 25))
            .asStream().toList()
            .then((values) => expect(values).toEqual([1, 3]));
      });

      it("does not throttle errors", () {
        var errors = [];
        var throttledStream = reactable
            .debounce(new Duration(milliseconds: 25))
            .handleError((error) => errors.add(error));

        controller
            ..add(1)
            ..add(2)
            ..add(3)
            ..addError("error 1")
            ..addError("error 2")
            ..addError("error 3");

        new Timer(new Duration(milliseconds: 50), () => controller.close());

        return throttledStream.toList().then((values) {
          expect(values).toEqual([1, 3]);
          expect(errors).toEqual(["error 1", "error 2", "error 3"]);
        });
      });
    });

    describe("when()", () {
      StreamController toggleController;
      Property toggle;

      beforeEach(() {
        toggleController = new StreamController();
        toggle = new Property.fromStream(toggleController.stream);
      });

      it("includes events when toggle is true", () {
        toggleController.add(true);

        new Future(() => controller..add(1)..close());

        return reactable.when(toggle).asStream().toList().then((values) {
          expect(values).toEqual([1]);
        });
      });

      it("excludes events when toggle is false", () {
        toggleController..add(true)..add(false);

        new Future(() => controller..add(1)..close());

        return reactable.when(toggle).asStream().toList().then((values) {
          expect(values.isEmpty).toBe(true);
        });
      });
    });
  });
}