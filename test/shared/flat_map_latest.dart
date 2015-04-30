library frappe.test.shared.flat_map_latest_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testFlatMapLatest(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("flatMapLatest()", () {
    it("returns the events from the latest spawned stream", () {
      Stream spawn(value) {
        var controller = new StreamController();
        new Future.delayed(new Duration(milliseconds: 25), () => controller..add(value)..add(value + 1));
        return controller.stream;
      }
      
      return testStream(reactable.flatMapLatest((value) => spawn(value)),
          behavior: () {
            source..add(1)..add(3)..add(5);
            return new Future.delayed(new Duration(milliseconds: 50));
          },
          expectation: (values) => expect(values).toEqual([5, 6]));
    });
  });
}