library debounce_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testDebounce(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("debounce()", () {
    it("delivers the last event after duration", () {
      return testStream(reactable.debounce(new Duration(milliseconds: 50)),
          behavior: () {
            source..add(1)..add(2)..add(3);
            return new Future.delayed(new Duration(seconds: 1));
          },
          expectation: (values) => expect(values).toEqual([3]));
    });
  });
}