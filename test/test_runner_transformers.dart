library transformers_test_runner;

import 'transformers/buffer_when_test.dart' as bufferWhenTest;
import 'transformers/combine_test.dart' as combineTest;
import 'transformers/debounce_test.dart' as debounceTest;
import 'transformers/flat_map_latest_test.dart' as flatMapLatestTest;
import 'transformers/flat_map_test.dart' as flatMapTest;
import 'transformers/scan_test.dart' as scanTest;
import 'transformers/skip_until_test.dart' as skipUntilTest;
import 'transformers/take_until_test.dart' as takeUntilTest;
import 'transformers/when_test.dart' as whenTest;
import 'transformers/zip_test.dart' as zipTest;

void main() {
  bufferWhenTest.main();
  combineTest.main();
  debounceTest.main();
  flatMapLatestTest.main();
  flatMapTest.main();
  scanTest.main();
  skipUntilTest.main();
  takeUntilTest.main();
  whenTest.main();
  zipTest.main();
}
