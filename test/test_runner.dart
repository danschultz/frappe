library frappe.test_runner;

import 'event_stream_test.dart' as EventStreamTest;
import 'stream_property_test.dart' as StreamPropertyTest;
import 'computed_property_test.dart' as ComputedPropertyTest;

void main() {
  EventStreamTest.main();
  StreamPropertyTest.main();
  ComputedPropertyTest.main();
}