library stream_property_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:frappe/frappe.dart';
import 'reactable_shared_tests.dart';
import 'util.dart';

void main() => describe("StreamProperty", () {
  injectReactableTests((controller) => new Property.fromStream(controller.stream));

  StreamController controller;
  Property property;

  beforeEach(() => controller = new StreamController());

  describe("asStream()", () {
    beforeEach(() => property = new Property.fromStreamWithInitialValue(1, controller.stream));

    it("contains the current value", () {
      return property.asStream().first.then((value) => expect(value).toBe(1));
    });

    it("contains property changes", () {
      controller..add(2)..close();
      return property.asStream().last.then((value) => expect(value).toBe(2));
    });
  });

  describe("listen()", () {
    beforeEach(() => property = new Property.fromStream(controller.stream));

    it("is done when stream is closed", () {
      new Future(() => controller.close());
      return property.listen(null).asFuture();
    });

    it("onError is called when stream receives errors", () {
      property.listen(doNothing,
          onError: expectAsync((error, stackTrace) => expect(error).toBeNotNull()),
          cancelOnError: true);

      controller.addError("Error");
    });

    describe("with initial value", () {
      beforeEach(() => property = new Property.fromStreamWithInitialValue(1, controller.stream));

      describe("without any subscriptions", () {
        beforeEach(() => controller.add(2));

        it("first value is the initial value", () {
          listenToFirstEvent(property, expectAsync((value) => expect(value).toBe(1)));
        });
      });

      describe("with subscriptions", () {
        StreamSubscription previousSubscription;

        beforeEach(() {
          controller.add(2);
          previousSubscription = property.listen(doNothing);
        });

        afterEach(() => previousSubscription.cancel());

        it("first value is 2", () {
          listenToFirstEvent(property, expectAsync((value) => expect(value).toBe(2)));
        });
      });
    });

    describe("without initial value", () {
      beforeEach(() => property = new Property.fromStream(controller.stream));

      it("first value is the next value in the stream", () {
        listenToFirstEvent(property, expectAsync((value) => expect(value).toBe(2)));
        controller.add(2);
      });
    });

    describe("multiple listeners", () {
      // Tests fix for https://github.com/danschultz/frappe/issues/25
      it("redelivers the current value", () {
        controller.add(1);

        return property.first.then((value) {
          expect(value).toBe(1);

          return property.first.then((value) {
            expect(value).toBe(1);
          });
        });
      });

      it("redelivers the current value to delayed listeners", () {
        controller.add(1);

        return property.first.then((value) {
          expect(value).toBe(1);

          return new Future.delayed(new Duration(milliseconds: 100), () => property.first).then((value) {
            expect(value).toBe(1);
          });
        });
      });
    });
  });
});
