library buffer_when_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:frappe/src/transformers.dart';
import '../util.dart';

void main() => describe("BufferWhen", () {
  StreamController controller;
  StreamController signal;

  beforeEach(() {
    controller = new StreamController();
    signal = new StreamController();
  });

  afterEach(() {
    controller.close();
    signal.close();
  });

  it("buffers events when signal is true", () {
    return testStream(controller.stream.transform(new BufferWhen(signal.stream)),
        behavior: () {
          controller.add(1);
          signal.add(true);
          controller.add(2);
        },
        expectation: (values) => expect(values).toEqual([1]));
  });

  it("flushes buffered events when signal is false", () {
    return testStream(controller.stream.transform(new BufferWhen(signal.stream)),
        behavior: () {
          controller.add(1);
          signal.add(true);
          controller.add(2);
          signal.add(false);
          controller.add(3);
        },
        expectation: (values) => expect(values).toEqual([1, 2, 3]));
  });
});