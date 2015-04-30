library frappe.test.shared.distinct_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testDistinct(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("distinct()", () {
    it("omits events that have the same value as the previous", () {
      return testStream(reactable.distinct(),
          behavior: () => source..add(1)..add(2)..add(2)..add(1),
          expectation: (values) => expect(values).toEqual([1, 2, 1]));
    });
  });
}