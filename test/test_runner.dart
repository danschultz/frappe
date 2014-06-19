library reactive.test_runner;

import 'event_stream_test.dart' as ReactiveStreamTest;
import 'property_test.dart' as PropertyTest;
import 'computed_property_test.dart' as ComputedPropertyTest;

void main() {
  ReactiveStreamTest.main();
  PropertyTest.main();
  ComputedPropertyTest.main();
}