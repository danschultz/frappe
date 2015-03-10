library as_event_stream_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'util.dart';

void testAsEventStream(Reactable provider(Stream stream)) {
  StreamController source;
  Reactable reactable;

  beforeEach(() {
    source = new StreamController();
    reactable = provider(source.stream);
  });

  describe("asEventStream()", () {
    it("includes new values", () {
      return testStream(reactable.asEventStream(),
          behavior: () => source..add(2)..add(3),
          expectation: (values) {
            expect(values).toEqual([2, 3]);
          });
    });

    it("behaves like an event stream", () {
      var stream = reactable.asEventStream();
      source..add(1)..close();

      return stream.toList().then((values) {
        expect(values).toEqual([1]);

        // Since this is an event stream, a second call to listen should not deliver any events.
        return stream.toList().then((values) {
          expect(values).toEqual([]);
        });
      });
    });
  });
}