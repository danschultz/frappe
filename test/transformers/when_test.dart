library when_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:frappe/src/transformers.dart';
import 'util.dart';

void main() => describe("When", () {
  StreamController controller;
  StreamController toggle;

  beforeEach(() {
    controller = new StreamController();
    toggle = new StreamController();
  });

  afterEach(() {
    controller.close();
  });

  it("includes events when signal is true", () {
    return testStream(controller.stream.transform(new When(toggle.stream)),
        behavior: () => new Future(() {
          controller.add(1);
          toggle.add(true);
          controller.add(2);
        }),
        expectation: (values) => expect(values).toEqual([2]));
  });

  it("excludes events when signal is false", () {
    return testStream(controller.stream.transform(new When(toggle.stream)),
        behavior: () => new Future(() {
          controller.add(1);
          toggle.add(true);
          controller.add(2);
          toggle.add(false);
          controller.add(3);
        }),
        expectation: (values) => expect(values).toEqual([2]));
  });
});