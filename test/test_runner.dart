library relay.test_runner;

import 'event_stream_test.dart' as EventStreamTest;
import 'property_test.dart' as PropertyTest;
import 'computed_property_test.dart' as ComputedPropertyTest;

void main() {
  EventStreamTest.main();
  PropertyTest.main();
  ComputedPropertyTest.main();
}