library zip_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testZip(Reactable provider(Stream stream)) {
  StreamController source;
  StreamController other;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    other = new StreamController();
    reactable = provider(source.stream);
  });

  describe("zip()", () {
    it("combines events at each index", () {
      return testStream(reactable.zip(other.stream, (a, b) => [a, b]),
          behavior: () {
            source.add(1);
            other.add(2);
          },
          expectation: (values) => expect(values).toEqual([[1, 2]]));
    });
  });
}