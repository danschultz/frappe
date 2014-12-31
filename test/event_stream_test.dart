library event_stream_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:frappe/frappe.dart';
import 'callback_helpers.dart';
import 'reactable_shared_tests.dart';

void main() => describe("EventStream", () {
  injectReactableTests((controller) => new EventStream(controller.stream));

  StreamController main;
  StreamController other;
  EventStream stream;

  beforeEach(() {
    main = new StreamController();
    stream = new EventStream(main.stream);
    other = new StreamController();
  });
});
