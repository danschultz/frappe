library async_expand_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testAsyncExpand(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("asyncExpand()", () {
    it("delivers returned values", () {
      return testStream(reactable.asyncExpand((value) => new Stream.fromIterable(["a"])),
          behavior: () => source.add(1),
          expectation: (values) => expect(values).toEqual(["a"]));
    });
  });
}