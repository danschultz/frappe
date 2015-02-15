library skip_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testSkip(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("skip()", () {
    it("skips the first N events", () {
      return testStream(reactable.skip(1),
          behavior: () => source..add(1)..add(2),
          expectation: (values) => expect(values).toEqual([2]));
    });
  });
}