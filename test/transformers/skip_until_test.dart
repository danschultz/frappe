library skip_until_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:frappe/src/transformers.dart';
import '../util.dart';

void main() => describe("SkipUntil", () {
  StreamController controller;
  Completer signal;

  beforeEach(() {
    controller = new StreamController();
    signal = new Completer();
  });

  afterEach(() {
    controller.close();
  });

  it("doesn't include events until signal", () {
    return testStream(controller.stream.transform(new SkipUntil(signal.future)),
        behavior: () => new Future(() {
          controller.add(1);
          controller.add(2);
          signal.complete(true);
          controller.add(3);
        }),
        expectation: (values) => expect(values).toEqual([3]));
  });

  it("closes transformed stream when source stream is done", () {
    return testStream(controller.stream.transform(new SkipUntil(signal.future)),
        behavior: () => controller.close(),
        expectation: (values) => expect(values).toEqual([]));
  });
});