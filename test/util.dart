library frappe.tests.util;

import 'dart:async';
import 'package:frappe/frappe.dart';

Function doNothing = (_) {};

Future testStream(Stream stream, {behavior(), expectation(List values)}) {
  var results = [];

  var subscription = stream.listen((value) {
    results.add(value);
  });

  return new Future(() {
    if (behavior != null) {
      return behavior();
    }
  })
  .then((_) => new Future(() {
    subscription.cancel();
  }))
  .then((_) => expectation(results));
}

Future testReactable(Reactable reactable, {behavior(), expectation(List values)}) {
  return testStream(reactable.asStream(), behavior: behavior, expectation: expectation);
}

void listenToFirstEvent(Reactable observable, void onData(data)) {
  StreamSubscription subscription;

  subscription = observable.listen((data) {
    onData(data);
    subscription.cancel();
  });
}