library map_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testMap(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("map()", () {
    it("converts the value of each event", () {
      return testStream(reactable.map((value) => value + 1),
          behavior: () => source..add(1)..add(2),
          expectation: (values) => expect(values).toEqual([2, 3]));
    });
  });
}