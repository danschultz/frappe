library frappe.test.shared.take_until_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testTakeUntil(Reactable provider(Stream stream)) {
  StreamController source;
  StreamController signal;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController(sync: true);
    signal = new StreamController(sync: true);
    reactable = provider(source.stream);
  });

  describe("takeUntil()", () {
    it("takes values until the signal stream has a value", () {
      return testStream(reactable.takeUntil(signal.stream),
          behavior: () {
            source.add(1);
            source.add(2);
            signal.add(true);
            source.add(3);
          },
          expectation: (values) => expect(values).toEqual([1, 2]));
    });
  });
}