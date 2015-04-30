library frappe.test.shared.handle_error_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testHandleError(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("handleError()", () {
    it("does not throw an error", () {
      return testStream(reactable.handleError((e) => e),
          behavior: () => source..addError("Oh noez!")..add(1),
          expectation: (values) => expect(values).toEqual([1]));
    });
  });
}