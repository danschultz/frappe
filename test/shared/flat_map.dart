library frappe.test.shared.flat_map_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testFlatMap(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("flatMap()", () {
    it("returns the events from each spawned stream", () {
      return testStream(reactable.flatMap((value) => new Stream.fromIterable([value, value + 1])),
          behavior: () => source..add(1)..add(3)..add(5),
          expectation: (values) => expect(values).toEqual([1, 2, 3, 4, 5, 6]));
    });
  });
}