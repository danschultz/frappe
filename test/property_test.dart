library property_Test;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'reactable_shared_tests.dart';
import 'util.dart';

void main() => describe("Property", () {
  Property<int> property;

  beforeEach(() => property = new Property<int>.constant(1));

  describe("constant", () {
    beforeEach(() => property = new Property<int>.constant(1));

    it("delivers the value to the first subscriber", () {
      testStream(property, expectation: (values) => expect(values).toEqual([1]));
    });

    it("delivers the value to multiple subscribers", () {
      var value1 = property.first;
      var value2 = property.first;
      return Future.wait([value1, value2]).then((values) => expect(values).toEqual([1, 1]));
    });

    it("is done after delivering its value", () {
      var completer = new Completer();
      property.listen(null, onDone: completer.complete);
      return completer.future;
    });
  });

  describe("with initial value", () {
    StreamController<int> controller;

    beforeEach(() {
      controller = new StreamController();
      property = new Property.fromStreamWithInitialValue(1, controller.stream);
    });

    it("delivers its initial value", () {
      testStream(property, expectation: (values) => expect(values).toEqual([1]));
    });

    it("delivers values after its initial value", () {
      testStream(property,
          behavior: () => controller.add(2),
          expectation: (values) => expect(values).toEqual([1, 2]));
    });

    it("delivers values to multiple subscribers", () {
      var values1 = property.toList();
      var values2 = property.toList();
      controller..add(2)..close();
      return Future.wait([values1, values2]).then((values) => expect(values).toEqual([[1, 2], [1, 2]]));
    });

    it("is done when the source stream is done", () {
      var completer = new Completer();
      property.listen(null, onDone: completer.complete);
      controller.close();
      return completer.future;
    });

    it("cancels subscriptions to the source stream", () {
      var completer = new Completer();
      var controller = new StreamController(onCancel: completer.complete);
      var property = new Property.fromStreamWithInitialValue(1, controller.stream);
      property.listen(null).cancel();
      return completer.future;
    });

    describe("changes", () {
      it("doesn't include the initial value", () {
        testStream(property.changes,
            behavior: () => controller.add(2),
            expectation: (values) => expect(values).toEqual([2]));
      });
    });

    describe("asEventStream()", () {
      it("includes the initial value and changes", () {
        testStream(property.changes,
            behavior: () => controller.add(2),
            expectation: (values) => expect(values).toEqual([1, 2]));
      });
    });
  });

  describe("without initial value", () {
    StreamController<int> controller;

    beforeEach(() {
      controller = new StreamController();
      property = new Property.fromStream(controller.stream);
    });

    it("delivers values from the source stream", () {
      testStream(property,
          behavior: () => controller.add(1),
          expectation: (values) => expect(values).toEqual([1]));
    });

    it("delivers values to multiple subscribers", () {
      var values1 = property.toList();
      var values2 = property.toList();
      controller..add(1)..close();
      return Future.wait([values1, values2]).then((values) => expect(values).toEqual([[1], [1]]));
    });

    it("is done when the source stream is done", () {
      var completer = new Completer();
      property.listen(null, onDone: completer.complete);
      controller.close();
      return completer.future;
    });

    it("cancels subscriptions to the source stream", () {
      var completer = new Completer();
      var controller = new StreamController(onCancel: completer.complete);
      var property = new Property.fromStream(controller.stream);
      property.listen(null).cancel();
      return completer.future;
    });
  });

  testReturnTypes(Property, () => new Property.constant(1));
});
