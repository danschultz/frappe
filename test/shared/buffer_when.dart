library buffer_when_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testBufferWhen(Reactable provider(Stream stream)) {
  StreamController source;
  StreamController toggle;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    toggle = new StreamController();
    reactable = provider(source.stream);
  });

  describe("bufferWhen()", () {
    it("buffers when toggle is true", () {
      return testStream(reactable.bufferWhen(toggle.stream),
          behavior: () {
            source.add(1);

            return new Future(() {
              toggle.add(true);
              source.add(2);
            });
          },
          expectation: (values) => expect(values).toEqual([1]));
    });

    it("delivers when toggle is false", () {
      return testStream(reactable.bufferWhen(toggle.stream),
          behavior: () {
            source.add(1);

            return new Future(() {
              toggle.add(true);
              source.add(2);

              return new Future(() {
                toggle.add(false);
                source.add(3);
              });
            });
          },
          expectation: (values) => expect(values).toEqual([1, 2, 3]));
    });
  });
}