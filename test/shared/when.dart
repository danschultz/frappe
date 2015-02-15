library when_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testWhen(Reactable provider(Stream stream)) {
  StreamController source;
  StreamController signal;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController(sync: true);
    signal = new StreamController(sync: true);
    reactable = provider(source.stream);
  });

  describe("when()", () {
    it("delivers events while signal stream is true", () {
      return testStream(reactable.when(signal.stream),
          behavior: () {
            source.add(1);
            signal.add(true);
            source.add(2);
          },
          expectation: (values) => expect(values).toEqual([2]));
    });
  });
}