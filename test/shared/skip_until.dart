library skip_until_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testSkipUntil(Reactable provider(Stream stream)) {
  StreamController source;
  StreamController signal;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    signal = new StreamController();
    reactable = provider(source.stream);
  });

  describe("skipUntil()", () {
    it("skips events until toggle has an event", () {
      return testStream(reactable.skipUntil(signal.stream),
          behavior: () {
            source.add(1);
            source.add(2);

            return new Future(() {
              signal.add(true);
              source.add(3);
            });
          },
          expectation: (values) => expect(values).toEqual([3]));
    });
  });
}