library combine_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:frappe/src/transformers.dart';
import '../util.dart';

void main() => describe("Combine", () {
  StreamController controllerA;
  StreamController controllerB;

  beforeEach(() {
    controllerA = new StreamController();
    controllerB = new StreamController();
  });

  afterEach(() {
    controllerA.close();
    controllerB.close();
  });

  it("combine when both streams have an event", () {
    return testStream(controllerA.stream.transform(new Combine(controllerB.stream, (a, b) => a + b)),
        behavior: () {
          controllerA.add(1);
          controllerB.add(1);
        },
        expectation: (values) => expect(values).toEqual([2]));
  });

  it("combines always after both streams have an event", () {
    return testStream(controllerA.stream.transform(new Combine(controllerB.stream, (a, b) => a + b)),
        behavior: () {
          controllerA.add(1);
          controllerB.add(1);

          controllerB.add(2);
        },
        expectation: (values) => expect(values).toEqual([2, 3]));
  });

  it("returned stream closes when both streams are done", () {
    return testStream(controllerA.stream.transform(new Combine(controllerB.stream, (a, b) => a + b)),
        behavior: () {
          controllerA.close();
          controllerB.close();
        },
        expectation: (values) => expect(values).toEqual([]));
  });
});