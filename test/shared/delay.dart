library delay_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testDelay(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("delay()", () {
    it("throttles the delivery of each event by a duration", () {
      return testStream(reactable.delay(new Duration(milliseconds: 50)),
          behavior: () {
            source..add(1)..add(2)..add(3);
            return new Future.delayed(new Duration(milliseconds: 110));
          },
          expectation: (values) => expect(values).toEqual([1, 2]));
    });
  });
}