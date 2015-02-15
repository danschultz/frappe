library expand_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testExpand(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("expand()", () {
    it("expands the elements of the event", () {
      return testStream(reactable.expand((iterable) => iterable),
          behavior: () => source.add([1, 2, 3]),
          expectation: (values) => expect(values).toEqual([1, 2, 3]));
    });
  });
}