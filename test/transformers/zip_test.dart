library zip_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:frappe/src/transformers.dart';
import '../util.dart';

void main() => describe("Zip", () {
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

  it("combine each pair of events", () {
    return testStream(controllerA.stream.transform(new Zip(controllerB.stream, (a, b) => a + b)),
        behavior: () {
          controllerA.add(1);
          controllerB.add(1);

          controllerA.add(2);
          controllerB.add(2);

          controllerA.add(3);
          controllerA.add(4);
          controllerA.add(5);

          controllerB.add(3);
        },
        expectation: (values) => expect(values).toEqual([2, 4, 6]));
  });

  it("returned stream closes when a source stream is done", () {
    return testStream(controllerA.stream.transform(new Zip(controllerB.stream, (a, b) => a + b)),
        behavior: () {
          controllerB.close();
        },
        expectation: (values) => expect(values).toEqual([]));
  });
});