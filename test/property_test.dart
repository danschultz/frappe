library signal_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:reactive/reactive.dart';
import 'callback_helpers.dart';

void main() => describe("Property", () {
  EventStream stream;
  StreamController controller;
  Property signal;

  beforeEach(() {
    controller = new StreamController();
    stream = new EventStream(controller.stream);
  });

  describe("listen()", () {
    describe("with initial value", () {
      beforeEach(() => signal = stream.asPropertyWithInitialValue(1));

      describe("without any subscriptions", () {
        beforeEach(() => controller.add(2));

        it("first value is the initial value", () {
          listenToFirstEvent(signal, expectAsync((value) => expect(value).toBe(1)));
        });
      });

      describe("with subscriptions", () {
        StreamSubscription previousSubscription;

        beforeEach(() {
          controller.add(2);
          previousSubscription = signal.listen(doNothing);
        });

        afterEach(() => previousSubscription.cancel());

        it("first value is the latest value of 2", () {
          listenToFirstEvent(signal, expectAsync((value) => expect(value).toBe(2)));
        });
      });
    });

    describe("without initial value", () {
      beforeEach(() => signal = stream.asProperty());

      it("first value is the next value in the stream", () {
        listenToFirstEvent(signal, expectAsync((value) => expect(value).toBe(2)));
        controller.add(2);
      });
    });
  });
});
