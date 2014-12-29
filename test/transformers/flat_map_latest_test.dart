library flat_map_latest_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:frappe/src/transformers.dart';
import 'util.dart';

void main() => describe("FlatMapLatest", () {
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

  it("includes events from latest spawned stream", () {
    return testStream(controller.stream.transform(new FlatMapLatest((value) => spawnedControllers[value].stream)),
    behavior: () {
      controller.add(1);
      controller.add(2);
      spawnedControllers[2].add(4);
      return new Future(() => spawnedControllers[1].add(3));
    },
    expectation: (values) => expect(values).toEqual([4]));
  });

  it("closes transformed stream when source stream is done", () {
    var stream = controller.stream.transform(new FlatMap((value) => spawnedControllers[value].stream));
    controller..add(1)..close();
    return stream.toList().then((values) => expect(values).toEqual([]));
  });
});