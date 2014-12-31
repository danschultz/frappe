library frappe.test_runner;

import 'event_stream_test.dart' as eventStreamTest;
import 'property_test.dart' as propertyTest;
import 'constant_property_test.dart' as constantPropertyTest;
import 'stream_property_test.dart' as streamPropertyTest;
import 'computed_property_test.dart' as computedPropertyTest;
import 'collect_reactable_test.dart' as collectReactableTest;

void main() {
  eventStreamTest.main();
  propertyTest.main();
  constantPropertyTest.main();
  streamPropertyTest.main();
  computedPropertyTest.main();
  collectReactableTest.main();
}