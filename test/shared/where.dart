library frappe.test.shared.where_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testWhere(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("where()", () {
    it("delivers event if block return true", () {
      return testStream(reactable.where((value) => value < 3),
          behavior: () => source..add(1)..add(3)..add(2),
          expectation: (values) => expect(values).toEqual([1, 2]));
    });
  });
}