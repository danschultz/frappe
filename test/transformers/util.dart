library frappe.tests.util;

import 'dart:async';

Future<List> testStream(Stream stream, {behavior(), expectation(List values)}) {
  var results = [];

  var subscription = stream.listen((value) {
    results.add(value);
  });

  return new Future(() => behavior())
      .then((v) => new Future(() {
        subscription.cancel();
      }))
      .then((_) => expectation(results));
}