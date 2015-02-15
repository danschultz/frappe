library frappe.tests.util;

import 'dart:async';

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
