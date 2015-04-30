library frappe.test.property_test;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'shared/as_event_stream.dart';
import 'shared/async_expand.dart';
import 'shared/async_map.dart';
import 'shared/buffer_when.dart';
import 'shared/combine.dart';
import 'shared/debounce.dart';
import 'shared/delay.dart';
import 'shared/distinct.dart';
import 'shared/expand.dart';
import 'shared/flat_map.dart';
import 'shared/flat_map_latest.dart';
import 'shared/handle_error.dart';
import 'shared/map.dart';
import 'shared/merge.dart';
import 'shared/scan.dart';
import 'shared/skip.dart';
import 'shared/skip_while.dart';
import 'shared/take.dart';
import 'shared/take_while.dart';
import 'shared/take_until.dart';
import 'shared/where.dart';
import 'shared/zip.dart';
import 'shared/return_types.dart';
import 'shared/util.dart';

void main() => describe("Property", () {
  Property<int> property;

  beforeEach(() => property = new Property<int>.constant(1));

  describe("constant", () {
    beforeEach(() => property = new Property<int>.constant(1));

    it("delivers the value to the first subscriber", () {
      return testStream(property, expectation: (values) => expect(values).toEqual([1]));
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

  describe("from stream", () {
    StreamController<int> controller;
    Property property;

    beforeEach(() {
      controller = new StreamController();
      property = new Property.fromStream(controller.stream);
    });

    it("delivers values from the source stream", () {
      return testStream(property,
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

    describe("changes", () {
      it("included new values", () {
        return testStream(property.changes,
            behavior: () => controller..add(2)..add(3),
            expectation: (values) => expect(values).toEqual([2, 3]));
      });

      it("doesn't exclude duplicates", () {
        return testStream(property.changes,
            behavior: () => controller..add(2)..add(2),
            expectation: (values) => expect(values).toEqual([2, 2]));
      });
    });

    describe("with initial value", () {
      StreamController<int> controller;

      beforeEach(() {
        controller = new StreamController();
        property = new Property.fromStreamWithInitialValue(1, controller.stream);
      });

      it("delivers its initial value", () {
        return testStream(property, expectation: (values) => expect(values).toEqual([1]));
      });

      it("delivers values after its initial value", () {
        return testStream(property,
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
          return testStream(property.changes,
              behavior: () => controller.add(2),
              expectation: (values) => expect(values).toEqual([2]));
        });
      });

      describe("asEventStream()", () {
        it("includes the initial value and changes", () {
          return testStream(property.asEventStream(),
              behavior: () => controller.add(2),
              expectation: (values) => expect(values).toEqual([1, 2]));
        });
      });
    });
  });

  testReturnTypes(Property, () => new Property.constant(1));
  testAsEventStream((stream) => new Property.fromStream(stream));
  testAsyncExpand((stream) => new Property.fromStream(stream));
  testAsyncMap((stream) => new Property.fromStream(stream));
  testBufferWhen((stream) => new Property.fromStream(stream));
  testCombine((stream) => new Property.fromStream(stream));
  testDebounce((stream) => new Property.fromStream(stream));
  testDelay((stream) => new Property.fromStream(stream));
  testDistinct((stream) => new Property.fromStream(stream));
  testExpand((stream) => new Property.fromStream(stream));
  testFlatMap((stream) => new Property.fromStream(stream));
  testFlatMapLatest((stream) => new Property.fromStream(stream));
  testHandleError((stream) => new Property.fromStream(stream));
  testMap((stream) => new Property.fromStream(stream));
  testMerge((stream) => new Property.fromStream(stream));
  testScan((stream) => new Property.fromStream(stream));
  testSkip((stream) => new Property.fromStream(stream));
  testSkipWhile((stream) => new Property.fromStream(stream));
  testTake((stream) => new Property.fromStream(stream));
  testTakeWhile((stream) => new Property.fromStream(stream));
  testTakeUntil((stream) => new Property.fromStream(stream));
  testWhere((stream) => new Property.fromStream(stream));
  testZip((stream) => new Property.fromStream(stream));

  // Because Property's always deliver their last value, these test needs to be tweaked in order to pass.
  //testSkipUntil((stream) => new Property.fromStream(stream));
  //testWhen((stream) => new Property.fromStream(stream));
});
