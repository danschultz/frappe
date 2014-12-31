library frappe.test_runner;

import 'event_stream_test.dart' as event_stream_test;
import 'property_test.dart' as property_test;
import 'constant_property_test.dart' as constant_property_test;
import 'stream_property_test.dart' as stream_property_test;
import 'computed_property_test.dart' as computed_property_test;
import 'collect_reactable_test.dart' as collect_reactable_test;

void main() {
  event_stream_test.main();
  property_test.main();
  constant_property_test.main();
  stream_property_test.main();
  computed_property_test.main();
  collect_reactable_test.main();
}