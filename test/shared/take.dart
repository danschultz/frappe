library frappe.test.shared.take_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testTake(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("take()", () {
    it("takes the first N events", () {
      return testStream(reactable.take(2),
          behavior: () => source..add(1)..add(2)..add(3),
          expectation: (values) => expect(values).toEqual([1, 2]));
    });
  });
}