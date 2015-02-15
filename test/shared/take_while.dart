library take_while_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testTakeWhile(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("takeWhile()", () {
    it("takes values while the block returns true", () {
      return testStream(reactable.takeWhile((value) => value < 3),
          behavior: () => source..add(1)..add(2)..add(3),
          expectation: (values) => expect(values).toEqual([1, 2]));
    });
  });
}