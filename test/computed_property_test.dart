library computed_signal_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:reactive/reactive.dart';
import 'callback_helpers.dart';

void main() => describe("Computed properties", () {
  EventStream stream;
  StreamController controller;
  Property signal;

  beforeEach(() {
    controller = new StreamController();
    stream = new EventStream(controller.stream);
    signal = stream.asProperty();
  });

  it("recomputes when dependencies change", () {
    var result = signal.and(new Property.constant(true));
    listenToFirstEvent(result, (value) => expect(value).toBeTruthy());
    controller.add(true);
  });
});
