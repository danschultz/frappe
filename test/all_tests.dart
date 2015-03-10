library all_tests;

import 'event_stream_test.dart' as event_stream;
import 'property_test.dart' as property;

void main() {
  event_stream.main();
  property.main();
}