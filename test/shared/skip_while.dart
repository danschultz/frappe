library skip_while_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testSkipWhile(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("skipWhile()", () {
    it("skips events until block return true", () {
      return testStream(reactable.skipWhile((value) => value < 3),
          behavior: () => source..add(1)..add(2)..add(3)..add(4),
          expectation: (values) => expect(values).toEqual([3, 4]));
    });
  });
}