library computed_signal_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:reactive/reactive.dart';
import 'callback_helpers.dart';

void main() => describe("Computed signals", () {
  EventStream stream;
  StreamController controller;
  Signal signal;

  beforeEach(() {
    controller = new StreamController();
    stream = new EventStream(controller.stream);
    signal = stream.asSignal();
  });

  it("recomputes when dependencies change", () {
    var result = signal.and(new Signal.constant(true));
    listenToFirstEvent(result, (value) => expect(value).toBeTruthy());
    controller.add(true);
  });
});
