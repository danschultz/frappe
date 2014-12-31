library scan_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:frappe/src/transformers.dart';
import '../util.dart';

void main() => describe("Scan", () {
  StreamController controller;

  beforeEach(() {
    controller = new StreamController();
  });

  afterEach(() {
    controller.close();
  });

  it("calls combine for each event", () {
    return testStream(controller.stream.transform(new Scan(0, (a, b) => a + b)),
        behavior: () {
          controller.add(1);
          controller.add(2);
        },
        expectation: (values) => expect(values).toEqual([1, 3]));
  });
});