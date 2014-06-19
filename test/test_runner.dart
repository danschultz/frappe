library reactive.test_runner;

import 'event_stream_test.dart' as ReactiveStreamTest;
import 'signal_test.dart' as SignalTest;
import 'computed_signal_test.dart' as ComputedSignalTest;

void main() {
  ReactiveStreamTest.main();
  SignalTest.main();
  ComputedSignalTest.main();
}