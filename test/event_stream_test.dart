library event_stream_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:frappe/frappe.dart';
import 'reactable_shared_tests.dart';
import 'util.dart';

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
