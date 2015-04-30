library frappe.test.shared.async_map_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testAsyncMap(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("asyncMap()", () {
    it("delivers returned value", () {
      return testStream(reactable.asyncMap((value) => new Future(() => "a")),
          behavior: () {
            source.add(1);
            return new Future.delayed(new Duration(milliseconds: 20), () => true);
          },
          expectation: (values) => expect(values).toEqual(["a"]));
    });
  });
}