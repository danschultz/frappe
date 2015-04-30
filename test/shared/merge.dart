library frappe.test.shared.merge_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testMerge(Reactable provider(Stream stream)) {
  StreamController source;
  StreamController other;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    other = new StreamController();
    reactable = provider(source.stream);
  });

  describe("merge()", () {
    it("joins the values of each stream", () {
      return testStream(reactable.merge(other.stream),
          behavior: () {
            source.add(1);
            other.add(2);
          },
          expectation: (values) => expect(values).toEqual([1, 2]));
    });
  });
}