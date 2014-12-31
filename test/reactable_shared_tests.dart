library reactable_shared_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

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

    describe("map()", () {
      it("maps each event", () {
        return testReactable(reactable.map((value) => value + 1),
            behavior: () {
              controller..add(1)..add(2);
            },
            expectation: (values) => expect(values).toEqual([2, 3]));
      });
    });
  });
}