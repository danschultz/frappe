library frappe.tests.util;

import 'dart:async';
import 'package:frappe/frappe.dart';

Function doNothing = (_) {};

Future testStream(Stream stream, {behavior(), expectation(List values)}) {
  var results = [];

  var subscription = stream.listen((value) {
    results.add(value);
  });

  return new Future(() => behavior())
      .then((_) => new Future(() {
        subscription.cancel();
      }))
      .then((_) => expectation(results));
}

Future testReactable(Reactable reactable, {behavior(), expectation(List values)}) {
  var results = [];

  var subscription = reactable.listen((value) {
    results.add(value);
  });

  return new Future(() => behavior())
      .then((_) => new Future(() {
        subscription.cancel();
      }))
      .then((_) => expectation(results));
}

void listenToFirstEvent(Reactable observable, void onData(data)) {
  StreamSubscription subscription;

  subscription = observable.listen((data) {
    onData(data);
    subscription.cancel();
  });
}