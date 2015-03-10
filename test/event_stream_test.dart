library event_stream_test;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'shared/as_event_stream.dart';
import 'shared/async_expand.dart';
import 'shared/async_map.dart';
import 'shared/buffer_when.dart';
import 'shared/combine.dart';
import 'shared/debounce.dart';
import 'shared/delay.dart';
import 'shared/distinct.dart';
import 'shared/expand.dart';
import 'shared/flat_map.dart';
import 'shared/flat_map_latest.dart';
import 'shared/handle_error.dart';
import 'shared/map.dart';
import 'shared/merge.dart';
import 'shared/scan.dart';
import 'shared/skip.dart';
import 'shared/skip_while.dart';
import 'shared/skip_until.dart';
import 'shared/take.dart';
import 'shared/take_while.dart';
import 'shared/take_until.dart';
import 'shared/when.dart';
import 'shared/where.dart';
import 'shared/zip.dart';
import 'shared/return_types.dart';
import 'shared/util.dart';

void main() => describe("EventStream", () {
  EventStream<int> stream;
  StreamController controller;

  beforeEach(() {
    controller = new StreamController();
    stream = new EventStream(controller.stream);
  });

  it("delivers values from the source stream", () {
    return testStream(stream,
        behavior: () => controller.add(1),
        expectation: (values) => expect(values).toEqual([1]));
  });

  it("is done when the source stream is done", () {
    var completer = new Completer();
    stream.listen(null, onDone: completer.complete);
    controller.close();
    return completer.future;
  });

  it("cancels subscriptions to the source stream", () {
    var completer = new Completer();
    var controller = new StreamController(onCancel: completer.complete);
    var property = new EventStream(controller.stream);
    property.listen(null).cancel();
    return completer.future;
  });

  testReturnTypes(EventStream, () => new EventStream(new Stream.fromIterable([1])));
  testAsEventStream((stream) => new Property.fromStream(stream));
  testAsyncExpand((stream) => new EventStream(stream));
  testAsyncMap((stream) => new EventStream(stream));
  testBufferWhen((stream) => new EventStream(stream));
  testCombine((stream) => new EventStream(stream));
  testDebounce((stream) => new EventStream(stream));
  testDelay((stream) => new EventStream(stream));
  testDistinct((stream) => new EventStream(stream));
  testExpand((stream) => new EventStream(stream));
  testFlatMap((stream) => new EventStream(stream));
  testFlatMapLatest((stream) => new EventStream(stream));
  testHandleError((stream) => new EventStream(stream));
  testMap((stream) => new EventStream(stream));
  testMerge((stream) => new EventStream(stream));
  testScan((stream) => new EventStream(stream));
  testSkip((stream) => new EventStream(stream));
  testSkipUntil((stream) => new EventStream(stream));
  testSkipWhile((stream) => new EventStream(stream));
  testTake((stream) => new EventStream(stream));
  testTakeWhile((stream) => new EventStream(stream));
  testTakeUntil((stream) => new EventStream(stream));
  testWhen((stream) => new EventStream(stream));
  testWhere((stream) => new EventStream(stream));
  testZip((stream) => new EventStream(stream));
});
