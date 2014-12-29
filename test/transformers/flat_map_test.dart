library buffer_when_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:frappe/src/transformers.dart';
import 'util.dart';

void main() => describe("FlatMap", () {
  StreamController controller;
  Map<int, StreamController> spawnedControllers;

  beforeEach(() {
    controller = new StreamController();
    spawnedControllers = {
      1: new StreamController(),
      2: new StreamController()
    };
  });

  afterEach(() {
    controller.close();
    spawnedControllers.values.forEach((controller) => controller.close());
  });

  it("includes events from spawned streams", () {
    return testStream(controller.stream.transform(new FlatMap((value) => spawnedControllers[value].stream)),
        behavior: () {
          controller.add(1);
          controller.add(2);
          spawnedControllers[1].add(3);
          spawnedControllers[2].add(4);
        },
        expectation: (values) => expect(values).toEqual([3, 4]));
  });

  it("closes transformed stream when source stream is done", () {
    var stream = controller.stream.transform(new FlatMap((value) => spawnedControllers[value].stream));
    controller..add(1)..close();
    return stream.toList().then((values) => expect(values).toEqual([]));
  });
});