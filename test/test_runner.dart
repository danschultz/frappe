library frappe.test_runner;

import 'event_stream_test.dart' as EventStreamTest;
import 'property_test.dart' as PropertyTest;
import 'stream_property_test.dart' as StreamPropertyTest;
import 'computed_property_test.dart' as ComputedPropertyTest;

void main() {
  EventStreamTest.main();
  PropertyTest.main();
  StreamPropertyTest.main();
  ComputedPropertyTest.main();
}