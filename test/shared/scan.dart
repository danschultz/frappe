library scan_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testScan(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("scan()", () {
    it("delivers the initial value", () {
      return testStream(reactable.scan(1, (a, b) => a + b),
          expectation: (values) => expect(values).toEqual([1]));
    });

    it("delivers the accumlated value for each event", () {
      return testStream(reactable.scan(1, (a, b) => a + b),
          behavior: () => source..add(2)..add(3),
          expectation: (values) => expect(values).toEqual([1, 3, 6]));
    });
  });
}