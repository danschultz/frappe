library computed_property_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:relay/relay.dart';
import 'callback_helpers.dart';

void main() => describe("Computed properties", () {
  EventStream stream1;
  StreamController controller1;
  Property signal1;

  EventStream stream2;
  StreamController controller2;
  Property signal2;

  beforeEach(() {
    controller1 = new StreamController();
    stream1 = new EventStream(controller1.stream);
    signal1 = stream1.asProperty();

    controller2 = new StreamController();
    stream2 = new EventStream(controller2.stream);
    signal2 = stream2.asProperty();
  });

  it("recomputes when dependencies change", () {
    var result = signal1 + signal2;
    listenToFirstEvent(result, expectAsync((value) => expect(value).toBe(3)));

    controller1.add(1);
    controller2.add(2);
  });
});
